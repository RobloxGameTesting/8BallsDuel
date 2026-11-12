game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolGeometry = require(Pool.PoolGeometry)
local PoolPhysics = require(Pool.PoolPhysics)
local PoolTableRenderer2D = require(Pool.PoolTableRenderer2D)

local PoolTutorialScene = {}

local Tutorial = PoolConstants.Tutorial
local CueBallNumber = PoolConstants.CueBallNumber

local ObjectBallNumber = Tutorial.ObjectBallNumber

function PoolTutorialScene.GetPocket()
	for _, v in PoolGeometry.GetPockets() do
		if v.Id == Tutorial.PocketId then
			return v
		end
	end

	return nil
end

function PoolTutorialScene.GetPositions()
	local pocket = PoolTutorialScene.GetPocket()

	if not pocket then
		return nil, nil
	end

	local v = -pocket.Normal
	local v2 = pocket.MouthCentre + v * Tutorial.ObjectBackFromMouth

	return PoolGeometry.BreakSpot, v2
end

function PoolTutorialScene:Apply(): boolean
	local positions, v = PoolTutorialScene.GetPositions()

	if not (positions and v) then
		return false
	end

	PoolPhysics.Reset(self, {
		{ Number = ObjectBallNumber, Position = v, DisplayPosition = v }
	})

	local ball = self.Balls[CueBallNumber]

	if ball then
		ball.Position = positions
	end

	self.IsBreakShot = false

	return true
end

function PoolTutorialScene.GhostBall(p)
	local pocket = PoolTutorialScene.GetPocket()
	local ball = p.Balls[ObjectBallNumber]

	if not (pocket and ball) then
		return nil
	end

	local v = pocket.MouthCentre - ball.Position

	if v.Magnitude < 0.001 then
		return nil
	end

	return ball.Position - v.Unit * PoolConstants.BallDiameter
end

function PoolTutorialScene.PottingAim(p)
	local ball = p.Balls[CueBallNumber]
	local ghostBall = PoolTutorialScene.GhostBall(p)

	if not (ball and ghostBall) then
		return nil
	end

	local v = ghostBall - ball.Position

	return if not (v.Magnitude < 0.001) then v.Unit else nil
end

function PoolTutorialScene.AimError(vector2: Vector2, p)
	local pottingAim = PoolTutorialScene.PottingAim(p)

	if pottingAim and not (vector2.Magnitude < 0.001) then
		return (math.acos((math.clamp(vector2.Unit:Dot(pottingAim), -1, 1))))
	end

	return 1e999
end

function PoolTutorialScene.IsAimOnLine(vector2: Vector2, p): boolean
	return PoolTutorialScene.AimError(vector2, p) <= math.rad(Tutorial.AimToleranceDegrees)
end

function PoolTutorialScene.IsAimOnBall(vector2: Vector2, p): boolean
	local ball = p.Balls[CueBallNumber]
	local ball2 = p.Balls[ObjectBallNumber]

	if not ball or not ball2 or vector2.Magnitude < 0.001 then
		return false
	end

	local unit = vector2.Unit
	local vector = ball2.Position - ball.Position

	if vector:Dot(unit) <= 0 then
		return false
	end

	return math.abs(unit.X * vector.Y - unit.Y * vector.X) <= PoolConstants.BallDiameter * Tutorial.AimCaptureBallFraction
end

function PoolTutorialScene:ShowHand(p, parent, callback)
	local v = Maid.new()

	self.AimLocked = true
	local hand = ReplicatedStorage.Libraries.GameSpecific.Tutorial.Assets.Arrows:FindFirstChild("Hand")
	local tutorialHand

	if hand and hand:IsA("ImageLabel") then
		tutorialHand = hand:Clone()
		tutorialHand.Name = "TutorialHand"
		tutorialHand.AnchorPoint = Vector2.new(0.5, 0.5)
		tutorialHand.Size = UDim2.fromScale(0.09, 0.09)
		tutorialHand.BackgroundTransparency = 1
		tutorialHand.ZIndex = 400
		tutorialHand.Parent = parent

		v.hand = tutorialHand
	else
		tutorialHand = nil
	end

	local pottingAim = PoolTutorialScene.PottingAim(p)
	local flag = false

	local function surrender() -- 1 equivalent call inferred from this helper
		if flag then
			return
		end

		flag = true

		if tutorialHand then
			tutorialHand.Visible = false
		end

		self.AimLocked = false

		if callback then
			callback()
		end
	end

	v.began = UserInputService.InputBegan:Connect(function(input, _)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			surrender() -- inferred equivalent call
		end
	end)

	if not pottingAim then
		return v
	end

	local v2 = math.atan2(pottingAim.Y, pottingAim.X)
	local v3 = math.rad(Tutorial.HandSweepDegrees) / 2
	local total = 0

	v.tick = RunService.RenderStepped:Connect(function(dt: number)
		if flag then
			return
		end

		total += dt

		self.AimLocked = true

		local v4 = math.sin(total * 6.283185307179586 / Tutorial.HandSweepSeconds)

		local v5 = v2 - v3 * v4

		self.Direction = Vector2.new(math.cos(v5), (math.sin(v5)))

		if tutorialHand then
			tutorialHand.Position = UDim2.fromScale(0.86, v4 * 0.16 + 0.5)
		end
	end)

	function v.release()
		self.AimLocked = false
	end

	return v
end

function PoolTutorialScene:HoldAimInWindow(p)
	local v = Maid.new()
	local aimToleranceDegrees = math.rad(Tutorial.AimToleranceDegrees)

	v.tick = RunService.RenderStepped:Connect(function()
		self.AimLocked = false

		local pottingAim = PoolTutorialScene.PottingAim(p)

		if not pottingAim then
			return
		end

		local direction = self.Direction

		if direction.Magnitude < 0.001 then
			self.Direction = pottingAim

			return
		end

		local unit = direction.Unit

		if math.acos((math.clamp(unit:Dot(pottingAim), -1, 1))) <= aimToleranceDegrees then
			return
		end

		local v2 = pottingAim.X * unit.Y - pottingAim.Y * unit.X >= 0 and 1 or -1

		local v3 = math.atan2(pottingAim.Y, pottingAim.X) + v2 * aimToleranceDegrees

		self.Direction = Vector2.new(math.cos(v3), (math.sin(v3)))
	end)

	return v
end

local function powerMeterParts(p)
	local v = {}

	if p and p.PowerTrack then
		table.insert(v, p.PowerTrack)

		local powerLabel = p.PowerTrack.Parent and p.PowerTrack.Parent:FindFirstChild("PowerLabel")

		if powerLabel and powerLabel:IsA("GuiObject") then
			table.insert(v, powerLabel)
		end
	end

	return v
end

function PoolTutorialScene.SetPowerMeterParked(p, flag: boolean, flag2: boolean?)
	for _, v in powerMeterParts(p) do
		local position = v:GetAttribute("TutorialHomePosition")

		if flag then
			if position == nil then
				position = v.Position
				v:SetAttribute("TutorialHomePosition", position)
			end

			local v2 = v.AbsolutePosition.X + v.AbsoluteSize.X + 48

			v.Position = position - UDim2.fromOffset(v2, 0)
		elseif position ~= nil then
			if flag2 then
				TweenService:Create(
					v,
					TweenInfo.new(Tutorial.PowerMeterTweenSeconds, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Position = position }
				):Play()
			else
				v.Position = position
			end

			v:SetAttribute("TutorialHomePosition", nil)
		end
	end
end

function PoolTutorialScene.ShowChargeHand(p, p2, p3, parent)
	local v = Maid.new()
	local root = p2 and p2.Renderer2D and p2.Renderer2D.Root

	if not root then
		return v
	end

	local hand = ReplicatedStorage.Libraries.GameSpecific.Tutorial.Assets.Arrows:FindFirstChild("Hand")

	if not (hand and hand:IsA("ImageLabel")) then
		return v
	end

	local tutorialChargeHand = hand:Clone()
	tutorialChargeHand.Name = "TutorialChargeHand"
	tutorialChargeHand.AnchorPoint = Vector2.new(0.5, 0.5)
	tutorialChargeHand.Size = UDim2.fromScale(0.075, 0.075)
	tutorialChargeHand.BackgroundTransparency = 1
	tutorialChargeHand.ZIndex = 400
	tutorialChargeHand.Parent = parent
	v.hand = tutorialChargeHand

	local chargeHandSeconds = Tutorial.ChargeHandSeconds
	local v2 = chargeHandSeconds + Tutorial.PowerHandHoldSeconds
	local v3 = 0

	v.tick = RunService.RenderStepped:Connect(function(dt: number)
		local ball = p3.Balls[CueBallNumber]
		local direction = p.Direction

		if not ball or direction.Magnitude < 0.001 then
			return
		end

		v3 = (v3 + dt) % v2

		local v4 = math.min(v3 / chargeHandSeconds, 1)

		local unit = direction.Unit

		local v5 = Tutorial.ChargeHandFromInches
		local ghostBall = PoolTutorialScene.GhostBall(p3)

		if ghostBall then
			v5 = (ghostBall - ball.Position).Magnitude - Tutorial.ChargeHandGhostGapInches
		end

		local lerped = (ball.Position + unit * math.max(v5, 0)):Lerp(
			ball.Position + unit * Tutorial.ChargeHandToInches,
			v4
		)

		local tableToScale = PoolTableRenderer2D.TableToScale(lerped)

		tutorialChargeHand.Position = UDim2.fromOffset(
			root.AbsolutePosition.X + tableToScale.X.Scale * root.AbsoluteSize.X,
			root.AbsolutePosition.Y + tableToScale.Y.Scale * root.AbsoluteSize.Y
		)
	end)

	return v
end

function PoolTutorialScene.ShowPowerHand(p, parent)
	local v = Maid.new()
	local powerTrack = p and p.PowerTrack

	if not powerTrack then
		return v
	end

	local hand = ReplicatedStorage.Libraries.GameSpecific.Tutorial.Assets.Arrows:FindFirstChild("Hand")

	if not (hand and hand:IsA("ImageLabel")) then
		return v
	end

	local tutorialPowerHand = hand:Clone()
	tutorialPowerHand.Name = "TutorialPowerHand"
	tutorialPowerHand.AnchorPoint = Vector2.new(0, 0.5)
	tutorialPowerHand.Size = UDim2.fromScale(0.075, 0.075)
	tutorialPowerHand.BackgroundTransparency = 1
	tutorialPowerHand.ZIndex = 400
	tutorialPowerHand.Parent = parent
	v.hand = tutorialPowerHand

	local powerHandSeconds = Tutorial.PowerHandSeconds
	local v2 = powerHandSeconds + Tutorial.PowerHandHoldSeconds
	local v3 = 0

	v.tick = RunService.RenderStepped:Connect(function(dt: number)
		v3 = (v3 + dt) % v2

		local v4 = math.min(v3 / powerHandSeconds, 1)

		tutorialPowerHand.Position = UDim2.fromOffset(
			powerTrack.AbsolutePosition.X + powerTrack.AbsoluteSize.X + Tutorial.PowerHandGap,
			powerTrack.AbsolutePosition.Y + powerTrack.AbsoluteSize.Y * v4
		)
	end)

	return v
end

function PoolTutorialScene.WaitForAim(p, p2)
	while not PoolTutorialScene.IsAimOnLine(p.Direction, p2) do
		RunService.RenderStepped:Wait()
	end
end

function PoolTutorialScene.WaitForShot(p)
	p.Shot:Wait()
end

function PoolTutorialScene.WaitForPot(p)
	local v = false
	local total = 0

	while true do
		local ball = p.Balls[ObjectBallNumber]

		if not ball or ball.Pocketed then
			return true
		end

		local ball2 = p.Balls[CueBallNumber]
		local v2

		if ball.Velocity.Magnitude < 0.001 then
			v2 = not ball2 or ball2.Velocity.Magnitude < 0.001
		else
			v2 = false
		end

		v = not v2 or v

		if v and p.Settled and v2 then
			return false
		end

		local v3 = RunService.RenderStepped:Wait()

		if v then
			continue
		end

		total += v3

		if total >= 1 then
			return false
		end
	end
end

return PoolTutorialScene