local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Mouses = require(ReplicatedStorage.Libraries.Classes.Mouses)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAimOverlay = require(Pool.PoolAimOverlay)
local PoolConstants = require(Pool.PoolConstants)
local PoolGeometry = require(Pool.PoolGeometry)
local PoolHudRenderer = require(Pool.PoolHudRenderer)
local PoolPhysics = require(Pool.PoolPhysics)
local PoolSkins = require(Pool.PoolSkins)
local PoolTableRenderer2D = require(Pool.PoolTableRenderer2D)
local PoolViewController = require(Pool.PoolViewController)

local PoolInputController = {}

local Input = PoolConstants.Input

local function pointerPosition(p) -- 8 equivalent calls inferred from this helper
	Mouses.SetPosition(p.Mouse)

	return p.Mouse.mouseViewport
end

local function pointerInTableSpace(p) -- 7 equivalent calls inferred from this helper
	return PoolTableRenderer2D.PixelToTable(p.View.Renderer2D, pointerPosition(p)) -- inferred equivalent call
end

local function clampFor(p, vector2: Vector2) -- 3 equivalent calls inferred from this helper
	if p.ClampPlacement then
		return p.ClampPlacement(vector2)
	end

	return PoolGeometry.ClampToPlayArea(vector2)
end

local function resolvePlacement(state, position: Vector2)
	local simulation = state.Simulation
	local placement = clampFor(state, position) -- inferred equivalent call

	for _ = 1, 6 do
		local v = false

		for _, v2 in PoolPhysics.GetActiveBalls(simulation) do
			if v2.Number == PoolPhysics.CueNumber(simulation) then
				continue
			end

			local v3 = placement - v2.Position
			local magnitude = v3.Magnitude

			if not (magnitude < PoolConstants.BallDiameter) then
				continue
			end

			local v4

			if magnitude > 0.001 then
				v4 = v3.Unit
			else
				v4 = Vector2.new(1, 0)
			end

			placement += v4 * (PoolConstants.BallDiameter - magnitude + 0.01)
			v = true
		end

		placement = clampFor(state, placement) -- inferred equivalent call

		if not v then
			break
		end
	end

	return placement
end

function PoolInputController:SetAimDirection(vector2: Vector2)
	if vector2.Magnitude <= 0.0001 then
		return
	end

	self.AimLocked = true
	self.Direction = vector2.Unit
end

function PoolInputController:SetBallHeld(ballHeld: boolean)
	self.BallHeld = ballHeld
end

function PoolInputController:SetPower(value: number)
	self.Power = math.clamp(value, 0, 1)

	PoolHudRenderer.SetPower(self.Hud, self.Power)
end

function PoolInputController:TakeAim()
	self.AimLocked = true
	self.ChargeLocked = true

	self.Muted = true

	if self.State == "Charging" then
		PoolInputController.SetState(self, "Aiming")
	end

	PoolInputController.SetPower(self, 0)

	self.Dragging = false
	self.DragFrom = nil
	self.DragAngle = nil

	self.AimAnchor = pointerPosition(self) -- inferred equivalent call
end

function PoolInputController:EnterCamera()
	if self.State == "Camera" then
		return
	end

	self.CameraReturn = self.State
	PoolInputController.ReleaseAim(self)
	PoolInputController.SetState(self, "Camera")
end

function PoolInputController:ExitCamera()
	if self.State ~= "Camera" then
		return
	end

	local cameraReturn = self.CameraReturn or "Aiming"

	self.CameraReturn = nil
	self.LeavingCamera = true
	PoolInputController.SetState(self, cameraReturn)
	self.LeavingCamera = false
end

function PoolInputController.IsCameraActive(p): boolean
	return p.State == "Camera"
end

function PoolInputController:ReleaseAim()
	self.AimLocked = false

	self.ChargeLocked = false

	self.Muted = false

	self.BallHeld = false

	PoolInputController.SetPower(self, 0)

	self.AimAnchor = nil
end

function PoolInputController:SetAimMode(p: string)
	self.AimMode = Device:Get() ~= "Mobile" and "Tap" or p
	self.DragFrom = nil
	self.DragAngle = nil
end

function PoolInputController:SetDragSensitivity(p: number?)
	local v = math.clamp(math.floor(tonumber(p) or PoolConstants.DefaultDragAimLevel), 1, #PoolConstants.DragAimGain)

	self.DragGain = PoolConstants.DragAimGain[v] or DEFAULT_DRAG_AIM_GAIN
end

function PoolInputController:EndMatch()
	self.Resume = nil
	self.ReadyAt = 0
	self.Dragging = false
	self.AimLocked = false

	self.ChargeLocked = false

	self.Muted = false
	self.CanPlaceCueBall = false

	PoolInputController.SetState(self, "GameOver")

	PoolViewController.SetCueStickVisible(self.View, false)
	PoolAimOverlay.SetStickVisible(self.Overlay, false)
end

local function aimWouldReverse(state): boolean -- 2 equivalent calls inferred from this helper
	local ball = state.Simulation.Balls[PoolPhysics.CueNumber(state.Simulation)]

	if not ball then
		return false
	end

	local v = pointerInTableSpace(state) - ball.Position -- inferred equivalent call

	return v.Magnitude <= PoolConstants.BallRadius or v.Unit:Dot(state.Direction) < 0
end

local function aimsWhileCharging(data): boolean -- 1 equivalent call inferred from this helper
	return data.State == "Charging"
		and data.ChargeMode == "Dial"
		and data.Power > 0
		and not data.AimLocked
		and Device:Get() == "Console"
end

local function canSteer(state) -- 2 equivalent calls inferred from this helper
	if state.State == "Aiming" then
		return not state.AimLocked
	end

	return aimsWhileCharging(state) and not state.AimLocked -- inferred equivalent call
end

function PoolInputController:SetState(p: string)
	if self.State == "Camera" and p ~= "Camera" and not self.LeavingCamera then
		self.CameraReturn = p

		return
	end

	local v = self.State == "Charging"

	self.State = p

	if p == "Aiming" and v then
		if aimWouldReverse(self) then -- inferred equivalent call
			self.AimAnchor = pointerPosition(self) -- inferred equivalent call
		elseif "Aiming" == "Aiming" then
			self.AimAnchor = nil
		end
	elseif p == "Aiming" then
		self.AimAnchor = nil
	end

	local v2

	if Device:Get() == "Console" and self.ChargeMode == "Dial" then
		v2 = v and p == "Aiming" and true or not v and p == "Charging"
	else
		v2 = false
	end

	if not v2 then
		self.Nudge = 0
		self.NudgeAnchor = nil
	end

	if p ~= "Charging" then
		self.Dial = 0
	end

	if p == "Aiming" or p == "BallInHand" then
		local cue

		if self.CueName then
			cue = PoolConstants.CueEffects(self.CueName)
		else
			cue = PoolSkins.GetCueEffects()
		end

		self.Cue = cue
	end

	PoolAimOverlay.SetVisible(self.Overlay, p == "Aiming" or p == "Charging" or p == "BallInHand")
end

function PoolInputController:Hold(p: number, resume)
	self.ReadyAt = os.clock() + p
	self.Resume = resume

	PoolInputController.SetState(self, "Simulating")
end

function PoolInputController:GiveBallInHand()
	self.CanPlaceCueBall = true
	self.Dragging = Device:Get() ~= "Mobile"

	PoolInputController.SetState(self, "BallInHand")
end

function PoolInputController:OfferBallInHand()
	self.CanPlaceCueBall = true
	self.Dragging = false

	PoolInputController.SetState(self, "Aiming")
end

local dragGain = PoolConstants.DragAimGain[PoolConstants.DefaultDragAimLevel] or 1

local BallDiameter = PoolConstants.BallDiameter

local v = PoolConstants.DragAimGain[1] or 0.3

local function onActivated(state, flag: boolean)
	if not Mouses.PressReachedWorld(flag) then
		return
	end

	local dragFrom = pointerPosition(state) -- inferred equivalent call

	if PoolHudRenderer.IsUsingSpinWidget(state.Hud, dragFrom) then
		return
	end

	if state.State == "BallInHand" then
		state.Dragging = true

		return
	end

	if state.State ~= "Aiming" then
		return
	end

	if state.ChargeLocked or not PoolHudRenderer.IsUsingPowerMeter(state.Hud, dragFrom) then
		local ball = state.Simulation.Balls[PoolPhysics.CueNumber(state.Simulation)]

		if
			ball
			and state.CanPlaceCueBall
			and (pointerInTableSpace(state) - ball.Position).Magnitude <= PoolConstants.BallDiameter -- inferred equivalent call
		then
			state.Dragging = true

			PoolInputController.SetState(state, "BallInHand")
		elseif Device:Get() == "Mobile" then
			if state.AimMode == "Drag" then
				state.DragFrom = dragFrom

				state.DragAngle = nil
			end
		else
			if state.ChargeLocked then
				return
			end

			state.ChargeMode = "Drag"
			state.Anchor = pointerInTableSpace(state) -- inferred equivalent call
			state.Power = 0

			PoolInputController.SetState(state, "Charging")
		end
	else
		state.ChargeMode = "Meter"

		state.MeterGrab = PoolHudRenderer.PowerFromPosition(state.Hud, dragFrom) - state.Power

		PoolHudRenderer.SetPower(state.Hud, state.Power)
		PoolInputController.SetState(state, "Charging")
	end
end

local function nudgeAim(state, p: number)
	if not canSteer(state) or state.BallHeld then -- inferred equivalent call
		return
	end

	local v2 = state.AimOnLegalBall and 0.003490658503988659 or 0.013962634015954637
	local v3 = math.atan2(state.Direction.Y, state.Direction.X) + p * v2

	state.Direction = Vector2.new(math.cos(v3), (math.sin(v3)))

	state.NudgeAnchor = pointerPosition(state) -- inferred equivalent call

	state.DragAngle = nil
end

local function stepDial(state, p: number)
	if state.State == "Aiming" then
		if p <= 0 or state.ChargeLocked or state.AimLocked or state.BallHeld then
			return
		end

		state.ChargeMode = "Dial"
		state.Power = 0
		PoolInputController.SetState(state, "Charging")
	elseif state.State ~= "Charging" or state.ChargeMode ~= "Dial" then
		return
	end

	local power = math.clamp(math.round((state.Power + p * 0.05) / 0.05) * 0.05, 0, 1)

	state.Power = power
	PoolHudRenderer.SetPower(state.Hud, power)

	if power <= 0 then
		PoolInputController.SetState(state, "Aiming")
	end
end

local function onDeactivated(state)
	state.DragFrom = nil
	state.DragAngle = nil

	if state.State == "BallInHand" then
		local ball = state.Simulation.Balls[PoolPhysics.CueNumber(state.Simulation)]

		if ball then
			ball.Position = resolvePlacement(state, ball.Position)
			PoolViewController.SetBall(state.View, ball.Number, ball.Position)
		end

		state.Dragging = false
		PoolInputController.SetState(state, "Aiming")
	else
		if state.State ~= "Charging" then
			return
		end

		local releasePower = state.ReleasePower
		local v2

		if releasePower then
			v2 = math.clamp(releasePower, 0, 1)
		else
			v2 = state.Power
		end

		state.Power = 0
		PoolHudRenderer.SetPower(state.Hud, 0)

		if not releasePower and v2 < Input.MinimumPower then
			PoolInputController.SetState(state, "Aiming")
			return
		end

		state.CanPlaceCueBall = false

		PoolInputController.SetState(state, "Simulating")
		state.ShotBindable:Fire(state.Direction, v2, state.Hud.Spin)
	end
end

local set = { [Enum.KeyCode.ButtonR2] = true, [Enum.KeyCode.ButtonY] = true }

local function pressFire(data)
	if data.State == "Charging" and data.ChargeMode == "Dial" then
		onDeactivated(data)
		return
	end

	if data.State ~= "Aiming" or data.AimLocked or data.BallHeld or data.ChargeLocked then
		return
	end

	Notifications.new("TextNotification", {
		message = "Charge the power bar using the D-Pad ▲ ▼",
		colour = Color3.fromRGB(255, 216, 96)
	})
end

function PoolInputController.new(view, hud, overlay, simulation, cueName: string?)
	local maid = Maid.new()
	local mouse = Mouses.new()

	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local v2 = {}
	v2.State = "Aiming"
	v2.View = view
	v2.Hud = hud
	v2.Overlay = overlay
	v2.Simulation = simulation
	v2.Mouse = mouse
	v2.Direction = Vector2.new(1, 0)
	v2.Power = 0
	v2.BallHeld = false
	v2.ChargeMode = "Drag"
	v2.MeterGrab = 0
	v2.ReleasePower = nil
	v2.ChargeLocked = false
	v2.Muted = false
	v2.AimMode = "Tap"
	v2.DragFrom = nil
	v2.DragAngle = nil
	v2.DragGain = dragGain
	v2.AimOnBall = false
	v2.AimOnLegalBall = false
	v2.Anchor = Vector2.zero
	v2.Dragging = false
	v2.CanPlaceCueBall = true
	v2.CueName = cueName
	local cue

	if cueName then
		cue = PoolConstants.CueEffects(cueName)
	else
		cue = PoolSkins.GetCueEffects()
	end

	v2.Cue = cue
	v2.IsLegalTarget = nil
	v2.AimAnchor = nil
	v2.AimLocked = false
	v2.Nudge = 0
	v2.NudgeNextAt = 0
	v2.Dial = 0
	v2.DialNextAt = 0
	v2.NudgeAnchor = nil
	v2.ReadyAt = 0
	v2.Resume = nil
	v2.ClampPlacement = nil
	v2.ShotBindable = bindableEvent
	v2.Shot = bindableEvent.Event
	v2.Maid = maid

	maid:GiveTask(mouse.Activated:Connect(function(p)
		onActivated(v2, p)
	end))

	maid:GiveTask(mouse.Deactivated:Connect(function()
		if v2.State == "Charging" and v2.ChargeMode == "Dial" then
			return
		end

		onDeactivated(v2)
	end))

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not set[input.KeyCode] then
			return
		end

		pressFire(v2)
	end))

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		local nudge = input.KeyCode == Enum.KeyCode.DPadLeft and -1
			or input.KeyCode == Enum.KeyCode.DPadRight and 1
			or 0

		if nudge == 0 then
			return
		end

		v2.Nudge = nudge
		v2.NudgeNextAt = os.clock() + 0.32

		nudgeAim(v2, nudge)
	end))

	maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		local v3 = input.KeyCode == Enum.KeyCode.DPadLeft and -1 or input.KeyCode == Enum.KeyCode.DPadRight and 1 or 0

		if v3 ~= 0 and v2.Nudge == v3 then
			v2.Nudge = 0
		end
	end))

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		local dial = input.KeyCode == Enum.KeyCode.DPadUp and 1 or input.KeyCode == Enum.KeyCode.DPadDown and -1 or 0

		if dial == 0 then
			return
		end

		stepDial(v2, dial)

		if v2.State == "Charging" and v2.ChargeMode == "Dial" then
			v2.Dial = dial
			v2.DialNextAt = os.clock() + 0.3
		end
	end))

	maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		local v3 = input.KeyCode == Enum.KeyCode.DPadUp and 1 or input.KeyCode == Enum.KeyCode.DPadDown and -1 or 0

		if v3 ~= 0 and v2.Dial == v3 then
			v2.Dial = 0
		end
	end))

	return v2
end

function PoolInputController:Update(p: number)
	local simulation = self.Simulation

	if self.Resume and os.clock() >= self.ReadyAt then
		local resume = self.Resume
		self.Resume = nil

		resume()
	end

	local v2 = self.State == "BallInHand" or self.BallHeld
	local v3

	if self.State == "Aiming" or self.State == "Charging" then
		v3 = not v2
	else
		v3 = false
	end

	if not self.Muted then
		PoolViewController.SetCueStickVisible(self.View, v3)
		PoolAimOverlay.SetStickVisible(self.Overlay, v3 and self.View.Mode == "2D")
	end

	if self.State == "GameOver" or self.State == "Camera" then
		PoolAimOverlay.HideGuides(self.Overlay)
	elseif self.State == "Simulating" then
		if simulation.Settled and self.Resume == nil and os.clock() >= self.ReadyAt then
			PoolInputController.SetState(self, "Aiming")
		end
	else
		if self.Muted then
			return
		end

		local ball = simulation.Balls[PoolPhysics.CueNumber(simulation)]

		if not ball then
			return
		end

		if v2 then
			if self.State == "BallInHand" and self.Dragging then
				ball.Position = clampFor(self, pointerInTableSpace(self)) -- inferred equivalent call
				PoolViewController.SetBall(self.View, ball.Number, ball.Position)
			end

			PoolAimOverlay.ShowHeldBall(self.Overlay, ball.Position)

			self.AimOnBall = false
			self.AimOnLegalBall = false
		else
			PoolAimOverlay.HideHeldBall(self.Overlay)
			local v4 = canSteer(self) -- inferred equivalent call

			if v4 then
				if self.Nudge ~= 0 then
					local now = os.clock()

					if self.NudgeNextAt <= now then
						self.NudgeNextAt = now + 1 / 26

						nudgeAim(self, self.Nudge)
					end
				end

				if self.NudgeAnchor and (pointerPosition(self) - self.NudgeAnchor).Magnitude > 24 then -- inferred equivalent call
					self.NudgeAnchor = nil
				end
			end

			if v4 and not self.NudgeAnchor then
				if self.AimMode == "Drag" then
					local v5 = pointerInTableSpace(self) - ball.Position -- inferred equivalent call

					if BallDiameter <= v5.Magnitude then
						local dragAngle = math.atan2(v5.Y, v5.X)

						if self.DragAngle then
							local v6 = dragAngle - self.DragAngle

							while v6 > 3.141592653589793 do
								v6 -= 6.283185307179586
							end

							while v6 < -3.141592653589793 do
								v6 += 6.283185307179586
							end

							if v6 ~= 0 then
								local v7

								if self.AimOnBall then
									v7 = math.min(v, self.DragGain)
								else
									v7 = self.DragGain
								end

								local v8 = math.atan2(self.Direction.Y, self.Direction.X) + v6 * v7

								self.Direction = Vector2.new(math.cos(v8), (math.sin(v8)))
							end
						end

						self.DragAngle = dragAngle
					elseif self.DragAngle then
						self.DragAngle = nil
					end
				else
					if self.AimAnchor then
						local magnitude = (pointerPosition(self) - self.AimAnchor).Magnitude -- inferred equivalent call

						if not aimWouldReverse(self) or magnitude > 8 then -- inferred equivalent call
							self.AimAnchor = nil
						end
					end

					if not self.AimAnchor then
						local v5 = pointerInTableSpace(self) - ball.Position -- inferred equivalent call

						if v5.Magnitude > PoolConstants.BallRadius then
							self.Direction = v5.Unit
						end
					end
				end
			end

			if self.State == "Charging" then
				if self.ChargeMode == "Dial" then
					if self.Dial ~= 0 and os.clock() >= self.DialNextAt then
						self.DialNextAt = os.clock() + 0.05

						stepDial(self, self.Dial)
					end
				elseif self.ChargeMode == "Meter" then
					local powerFromPosition = PoolHudRenderer.PowerFromPosition
					local hud = self.Hud
					self.Power = math.clamp(powerFromPosition(hud, pointerPosition(self)) - self.MeterGrab, 0, 1) -- inferred equivalent call
				else
					self.Power = math.clamp(
						-(pointerInTableSpace(self) - self.Anchor):Dot(self.Direction) / Input.MaxPullDistance, -- inferred equivalent call
						0,
						1
					)
				end

				PoolHudRenderer.SetPower(self.Hud, self.Power)
			end

			local predictShot = PoolPhysics.PredictShot(simulation, self.Direction, self.Power, self.Hud.Spin, p)

			self.AimOnBall = predictShot.Kind == "Ball"

			local v5 = predictShot.Kind ~= "Ball"
				or not (predictShot.Other and self.IsLegalTarget)
				or self.IsLegalTarget(predictShot.Other)

			self.AimOnLegalBall = self.AimOnBall and v5

			PoolAimOverlay.Update(
				self.Overlay,
				ball.Position,
				self.Direction,
				predictShot,
				self.Power,
				PoolConstants.BasePredictionLength * self.Cue.Aim,
				v5
			)

			PoolViewController.SetCueStick(self.View, ball.Position, self.Direction, self.Power)
		end
	end
end

function PoolInputController.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolInputController