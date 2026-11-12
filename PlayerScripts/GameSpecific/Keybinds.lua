local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
game:GetService("RunService")
local Players = game:GetService("Players")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local MobileHelper = require(ReplicatedStorage.Libraries.Helpers.MobileHelper)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local KeybindHelper = require(ReplicatedStorage.Libraries.Helpers.KeybindHelper)
local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Helpers.StringHelper)
require(ReplicatedStorage.Libraries.Modules.Button)
game:GetService("TweenService")
local MobileButtonImages = require(ReplicatedStorage.Assets.Images.MobileButtonImages)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local KeybindConstants = require(ReplicatedStorage.Libraries.Constants.KeybindConstants)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
local MechanicHandler = require(ReplicatedStorage.Libraries.Modules.MechanicHandler)
local UserInputService = game:GetService("UserInputService")
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local v2 = Maid.new()

local toggleable = data.configuration[string.lower(Device:Get()) .. "Keybinds"].toggleable

local function dash(_, begin)
	if begin == Enum.UserInputState.Begin then
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (character and humanoid and humanoidRootPart) then
			return
		end

		local lookVector = humanoid.MoveDirection.Magnitude == 0 and humanoidRootPart.CFrame.LookVector
			or humanoid.MoveDirection

		MechanicHandler.Dash(LocalPlayer, 30, 43, lookVector)
	end
end

local function crouch(_, p)
	if p == Enum.UserInputState.Begin then
		if toggleable then
			MechanicHandler.Crouch(LocalPlayer, not MechanicHandler.GetContext().crouching)
		else
			MechanicHandler.Crouch(LocalPlayer, true)
		end
	elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
		if toggleable then
			return
		end

		MechanicHandler.Crouch(LocalPlayer, false)
	end
end

local function sprint(_, p)
	if p == Enum.UserInputState.Begin then
		if toggleable then
			MechanicHandler.Sprint(LocalPlayer, not MechanicHandler.GetContext().sprinting)
		else
			MechanicHandler.Sprint(LocalPlayer, true)
		end
	elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
		if toggleable then
			return
		end

		MechanicHandler.Sprint(LocalPlayer, false)
	end
end

local function mouselock(_, begin) -- 1 equivalent call inferred from this helper
	if begin == Enum.UserInputState.Begin then
		Mouselock:Toggle()
	end
end

local function doubleJump(_, p) -- 2 equivalent calls inferred from this helper
	if p == Enum.UserInputState.Begin then
		MechanicHandler.DoubleJump(LocalPlayer)
	end
end

local v3 = {
	dash = {
		onActivated = function(object)
			dash("dash", Enum.UserInputState.Begin)
			object:Press()
		end,
		onDeactivated = function(object)
			object:Release()
		end
	},
	crouch = {
		onActivated = function(object)
			crouch("crouch", Enum.UserInputState.Begin)
			object:Press()
		end,
		onDeactivated = function(object)
			crouch("crouch", Enum.UserInputState.End)
			object:Release()
		end,
		onDestroyed = function(object)
			crouch("crouch", Enum.UserInputState.Cancel)
			object:Release()
		end
	},
	sprint = {
		onActivated = function(object)
			sprint("sprint", Enum.UserInputState.Begin)
			object:Press()
		end,
		onDeactivated = function(object)
			sprint("sprint", Enum.UserInputState.End)
			object:Release()
		end
	},
	mouselock = {
		onActivated = function(_)
			mouselock(nil, Enum.UserInputState.Begin) -- inferred equivalent call
		end
	}
}

local v4 = false
local v5 = "None"

local function bind()
	local v6 = Device:Get()

	if v6 == "Mobile" and not v4 then
		v4 = true

		for k, button in data.configuration.mobileKeybinds.buttons do
			local v7 = v3[k]
			local size = button.size
			local vector2 = Vector2.new(button.offsetX, button.offsetY)
			local button2 = MobileHelper:CreateButton(
				k,
				MobileButtonImages[k].image,
				MobileButtonImages[k].imageDown,
				size,
				vector2,
				button.imageCountdown,
				MobileButtonImages[k].text
			)

			if v7 then
				for _, v8 in {
					"onActivated",
					"onDeactivated",
					"onDisabled",
					"onChanged",
					"onDestroyed"
				} do
					local v9 = v8:sub(3, 3) .. v8:sub(4)

					if not v7[v8] then
						continue
					end

					local v10 = v8
					button2[v9]:Connect(function(p)
						v7[v10](button2, p)
					end)
				end

				button2:SetVisible(true)
			else
				button2:SetVisible(false)
			end
		end
	end

	if v6 == "Mobile" then
		for k, mobileControl in KeybindConstants.mobileControlsList do
			local button = MobileHelper:GetButton(k)

			if button then
				button:SetVisible(mobileControl)
			end
		end

		PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton"):GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
			doubleJump(nil, Enum.UserInputState.Begin) -- inferred equivalent call
		end)
	else
		local copy = TableHelper:DeepCopy(v6 == "Desktop" and data.configuration.desktopKeybinds.buttons or data.configuration.consoleKeybinds.buttons)

		for k, v7 in copy do
			local correspondingKeybindFrame = KeybindHelper:FindCorrespondingKeybindFrame(k)

			for _, v8 in correspondingKeybindFrame do
				local v9 = Enum.KeyCode:FromValue(v7)

				if v9 then
					v8:SetAttribute("Keybind", v9.Name)
				end
			end
		end

		local function defaultKeybinds()
			ContextActionService:BindActionAtPriority(
				"dash",
				dash,
				false,
				1,
				KeybindHelper:ConvertValueToDesktop(v, "dash"),
				KeybindHelper:ConvertValueToConsole(v, "dash")
			)
			ContextActionService:BindActionAtPriority(
				"crouch",
				crouch,
				false,
				1,
				KeybindHelper:ConvertValueToDesktop(v, "crouch"),
				KeybindHelper:ConvertValueToConsole(v, "crouch")
			)
			ContextActionService:BindActionAtPriority(
				"sprint",
				sprint,
				false,
				1,
				KeybindHelper:ConvertValueToDesktop(v, "sprint"),
				KeybindHelper:ConvertValueToConsole(v, "sprint")
			)
			ContextActionService:BindActionAtPriority(
				"mouselock",
				mouselock,
				false,
				1,
				KeybindHelper:ConvertValueToDesktop(v, "mouselock"),
				KeybindHelper:ConvertValueToConsole(v, "mouselock"),
				Enum.KeyCode.RightShift
			)
			ContextActionService:BindActionAtPriority("doubleJump", doubleJump, false, 1, Enum.KeyCode.Space)

			v2.consoleKeybindConnection = UserInputService.InputBegan:Connect(function(input, _: boolean)
				if input.UserInputState ~= Enum.UserInputState.Begin then
					return
				end

				if input.KeyCode == Enum.KeyCode.ButtonA then
					doubleJump(nil, input.UserInputState) -- inferred equivalent call
				end
			end)

			v5 = "Player"
		end

		if v5 == "None" then
			defaultKeybinds()
		end
	end
end

local function unbind()
	for _, v6 in MobileHelper:GetButtonsById(v3), nil, nil do
		v6:SetVisible(false)
	end

	v5 = "None"
	ContextActionService:UnbindAction("dash")
	ContextActionService:UnbindAction("crouch")
	ContextActionService:UnbindAction("mouselock")
	ContextActionService:UnbindAction("doubleJump")
end

local function handleKeybinds() -- 1 equivalent call inferred from this helper
	toggleable = data.configuration[string.lower(Device:Get()) .. "Keybinds"].toggleable
	bind()
end

handleKeybinds() -- inferred equivalent call
Device.Changed:Connect(handleKeybinds)
Menu.FunctionOnOpen(handleKeybinds)
Menu.FunctionOnClose(handleKeybinds)
v:ListenToWrite("SetConfig", handleKeybinds)