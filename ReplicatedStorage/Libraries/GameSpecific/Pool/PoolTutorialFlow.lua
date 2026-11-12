local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")

local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolTutorialPopup = require(Pool.PoolTutorialPopup)
local PoolTutorialScene = require(Pool.PoolTutorialScene)

local PoolTutorialFlow = {}

local Tutorial = PoolConstants.Tutorial

local ObjectBallNumber = Tutorial.ObjectBallNumber

local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = Maid.new()

local v6 = false
local v7 = false
local v8 = false
local v9 = false

local direction = nil
local flag = false

local function pointerAims(): boolean -- 2 equivalent calls inferred from this helper
	return Device:Get() ~= "Mobile"
end

local function usesGamepad(): boolean -- 2 equivalent calls inferred from this helper
	return Device:Get() == "Console"
end

function PoolTutorialFlow.Register(p)
	v = p
end

function PoolTutorialFlow.IsRegistered(): boolean
	return v ~= nil
end

function PoolTutorialFlow.WaitForParts()
	while not v do
		task.wait()
	end

	return v
end

local function overlay()
	if not v2 then
		local poolTutorialUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PoolTutorialUI")

		poolTutorialUI.Enabled = true

		local tutorialPopup = poolTutorialUI:FindFirstChild("TutorialPopup")

		if tutorialPopup and tutorialPopup:IsA("GuiObject") then
			tutorialPopup.Visible = false
		end

		v2 = poolTutorialUI

		function v5.overlay()
			poolTutorialUI.Enabled = false
		end
	end

	local v10 = v2
	v10.Enabled = true

	return v10
end

local function popup() -- 4 equivalent calls inferred from this helper
	local v10 = overlay()

	if not v3 then
		v3 = PoolTutorialPopup.new(v10)
		function v5.popup()
			if v3 then
				PoolTutorialPopup.Destroy(v3)
				v3 = nil
			end
		end
	end

	return v3
end

local function banner()
	local parent = overlay()

	if v4 then
		return v4
	end

	local tutorialBanner = Instance.new("TextLabel")
	tutorialBanner.Name = "TutorialBanner"
	tutorialBanner.AnchorPoint = Vector2.new(0.5, 0)
	tutorialBanner.Position = UDim2.fromScale(0.5, 0.04)
	tutorialBanner.Size = UDim2.fromScale(0.6, 0.08)
	tutorialBanner.BackgroundColor3 = Color3.fromRGB(18, 21, 24)
	tutorialBanner.BackgroundTransparency = 0.25
	tutorialBanner.BorderSizePixel = 0
	tutorialBanner.Font = Enum.Font.GothamBold
	tutorialBanner.TextScaled = true

	tutorialBanner.TextWrapped = true
	tutorialBanner.TextColor3 = Color3.fromRGB(247, 246, 241)
	tutorialBanner.Text = ""
	tutorialBanner.Visible = false
	tutorialBanner.ZIndex = 400
	tutorialBanner.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.25, 0)
	uiCorner.Parent = tutorialBanner

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0.18, 0)
	uiPadding.PaddingBottom = UDim.new(0.18, 0)
	uiPadding.PaddingLeft = UDim.new(0.03, 0)
	uiPadding.PaddingRight = UDim.new(0.03, 0)
	uiPadding.Parent = tutorialBanner

	v4 = tutorialBanner
	v5.banner = tutorialBanner

	return v4
end

function PoolTutorialFlow.SetBanner(text: string)
	local v10 = banner()

	v10.Text = text
	v10.Visible = text ~= ""
end

local function setDeviceBanner(fn) -- 2 equivalent calls inferred from this helper
	PoolTutorialFlow.SetBanner(fn())

	v5.bannerDevice = Device.Changed:Connect(function()
		if v4 and v4.Visible then
			PoolTutorialFlow.SetBanner(fn())
		end
	end)
end

local function waitForTableFree(p)
	while p.UI:GetAttribute("MatchActive") and p.UI:GetAttribute("MatchMode") ~= "Tutorial" do
		task.wait()
	end
end

function PoolTutorialFlow.StartOffer()
	v6 = false

	local v10 = PoolTutorialFlow.WaitForParts()

	waitForTableFree(v10)

	v10.BeginScene()
	v10.SetTableIdle(true)
	local v11 = popup() -- inferred equivalent call
	local confirmedConnection = nil

	confirmedConnection = v11.Confirmed:Connect(function()
		v6 = true
		confirmedConnection:Disconnect()
	end)

	function v5.offer()
		if confirmedConnection.Connected then
			confirmedConnection:Disconnect()
		end
	end

	PoolTutorialPopup.Show(v11, {
		Title = "QUICK TUTORIAL",
		Body = string.format("Learn to shoot in one minute and earn %d coins.", Tutorial.CompletionReward),
		Confirm = string.format("PLAY FOR %d", Tutorial.CompletionReward)
	})
end

function PoolTutorialFlow.OfferAnswered()
	return v6
end

function PoolTutorialFlow.EndOffer()
	v5.offer = nil
	PoolTutorialPopup.Hide(popup()) -- inferred equivalent call
end

function PoolTutorialFlow.StartAim()
	local v10 = PoolTutorialFlow.WaitForParts()

	v10.BeginScene()

	v10.SetTableIdle(false)

	v10.Input.ChargeLocked = true

	function v5.chargeLock()
		v10.Input.ChargeLocked = false
	end

	if pointerAims() then -- inferred equivalent call
		local function fn()
			if usesGamepad() then -- inferred equivalent call
				return string.format(
					"AIM AT THE %d BALL\nMove the cursor to aim  ·  D-Pad ◄ ► for precise aim",
					ObjectBallNumber
				)
			end

			return string.format("AIM AT THE %d BALL", ObjectBallNumber)
		end

		setDeviceBanner(fn) -- inferred equivalent call
		v10.Input.AimLocked = false

		v7 = true
		direction = v10.Input.Direction
		flag = false
	else
		PoolTutorialFlow.SetBanner(string.format("DRAG TO AIM AT THE %d BALL", ObjectBallNumber))

		v7 = false

		v5.hand = PoolTutorialScene.ShowHand(v10.Input, v10.Simulation, overlay(), function()
			v7 = true

			direction = v10.Input.Direction
			flag = false
		end)
	end
end

function PoolTutorialFlow.AimIsValid()
	local v10 = v

	if not (v10 and v7) then
		return false
	end

	local direction2 = v10.Input.Direction

	if flag then
		return PoolTutorialScene.IsAimOnLine(direction2, v10.Simulation)
			or PoolTutorialScene.IsAimOnBall(direction2, v10.Simulation)
	end

	local v11 = direction

	if not v11 or direction2.Magnitude < 0.001 or v11.Magnitude < 0.001 then
		return false
	end

	if math.acos((math.clamp(direction2.Unit:Dot(v11.Unit), -1, 1))) < 0.017453292519943295 then
		return false
	end

	flag = true

	return PoolTutorialScene.IsAimOnLine(direction2, v10.Simulation)
		or PoolTutorialScene.IsAimOnBall(direction2, v10.Simulation)
end

function PoolTutorialFlow.EndAim()
	v5.hand = nil
	v5.bannerDevice = nil

	local v10 = v

	local direction2 = v10 and PoolTutorialScene.PottingAim(v10.Simulation)

	if direction2 then
		v10.Input.Direction = direction2
	end
end

function PoolTutorialFlow.StartPower()
	local v10 = PoolTutorialFlow.WaitForParts()

	v8 = false

	v5.chargeLock = nil

	v5.aimClamp = PoolTutorialScene.HoldAimInWindow(v10.Input, v10.Simulation)

	v10.Input.ReleasePower = 1

	function v5.releasePower()
		v10.Input.ReleasePower = nil
	end

	PoolTutorialScene.SetPowerMeterParked(v10.Hud, false, true)

	if usesGamepad() then -- inferred equivalent call
		local function fn()
			return string.format(
				"D-PAD ▲ ▼ TO SET POWER\nPress %s to shoot",
				Device.GetButtonLabel(Enum.KeyCode.ButtonR2)
			)
		end

		setDeviceBanner(fn) -- inferred equivalent call
	elseif pointerAims() then -- inferred equivalent call
		local function fn(): string
			return "DRAG BACK FROM THE BALL, RELEASE TO SHOOT"
		end

		PoolTutorialFlow.SetBanner("DRAG BACK FROM THE BALL, RELEASE TO SHOOT")

		v5.bannerDevice = Device.Changed:Connect(function()
			if v4 and v4.Visible then
				PoolTutorialFlow.SetBanner(fn())
			end
		end)

		v5.powerHand = PoolTutorialScene.ShowChargeHand(v10.Input, v10.View, v10.Simulation, overlay())
	else
		local function fn(): string
			return "DRAG THE BAR DOWN, RELEASE TO SHOOT"
		end

		PoolTutorialFlow.SetBanner("DRAG THE BAR DOWN, RELEASE TO SHOOT")

		v5.bannerDevice = Device.Changed:Connect(function()
			if v4 and v4.Visible then
				PoolTutorialFlow.SetBanner(fn())
			end
		end)

		v5.powerHand = PoolTutorialScene.ShowPowerHand(v10.Hud, overlay())
	end

	local shotConnection = nil

	shotConnection = v10.Input.Shot:Connect(function()
		v8 = true
		shotConnection:Disconnect()
	end)

	function v5.power()
		if shotConnection.Connected then
			shotConnection:Disconnect()
		end
	end
end

function PoolTutorialFlow.ShotTaken()
	return v8
end

function PoolTutorialFlow.EndPower()
	v5.power = nil
	v5.powerHand = nil
	v5.bannerDevice = nil

	v5.aimClamp = nil

	v5.releasePower = nil

	local v10 = v

	if v10 then
		v10.Input.AimLocked = false
	end
end

function PoolTutorialFlow.StartWatch()
	local v10 = PoolTutorialFlow.WaitForParts()

	v9 = false

	PoolTutorialFlow.SetBanner("")

	task.spawn(function()
		if PoolTutorialScene.WaitForPot(v10.Simulation) then
			v9 = true

			return
		end

		PoolTutorialScene.Apply(v10.Simulation)

		local pottingAim = PoolTutorialScene.PottingAim(v10.Simulation)

		if pottingAim then
			local PoolPhysics = require(Pool.PoolPhysics)

			PoolPhysics.Shoot(v10.Simulation, pottingAim, 0.45, Vector2.zero)
			PoolTutorialScene.WaitForPot(v10.Simulation)
		end

		v9 = true
	end)
end

function PoolTutorialFlow.EightPotted()
	return v9
end

function PoolTutorialFlow.EndWatch()
	PoolTutorialFlow.SetBanner("")
end

function PoolTutorialFlow.OfferFirstMatch()
	local v10 = PoolTutorialFlow.WaitForParts()
	local v11 = popup() -- inferred equivalent call
	PoolTutorialFlow.SetBanner("")

	PoolTutorialPopup.Ask(v11, {
		Title = "READY FOR A MATCH?",
		Body = "Play your first real game against an opponent your level.",
		Confirm = "FIND A MATCH"
	})

	v10.EndScene()
	v10.StartFirstMatch()
end

function PoolTutorialFlow.ShowConsolation()
	local v10 = popup() -- inferred equivalent call
	PoolTutorialPopup.Ask(v10, {
		Title = "DON'T GIVE UP",
		Body = string.format("Here's %d coins to help you get started.", Tutorial.ConsolationReward),
		Confirm = "THANKS"
	})
end

function PoolTutorialFlow.Cleanup()
	v5:DoCleaning()
	v2 = nil
	v3 = nil
	v4 = nil
end

return PoolTutorialFlow