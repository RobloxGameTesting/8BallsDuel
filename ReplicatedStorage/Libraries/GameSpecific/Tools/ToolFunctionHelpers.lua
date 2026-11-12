local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.Classes.CameraShaker)
local WeaponHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponHelpers)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Classes.Mouses)
local WeaponConstants = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponConstants)
game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponAttacks)
require(ReplicatedStorage.Libraries.Modules.Knockback)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MobileHelper = require(ReplicatedStorage.Libraries.Helpers.MobileHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local TweenService = game:GetService("TweenService")
local Level = require(ReplicatedStorage.Libraries.Modules.Level)

RunService:IsServer()
local ToolFunctionHelpers = {}

function ToolFunctionHelpers.DisplayMastery(data)
	if data.isOwner then
		local mastery = data.owner:WaitForChild("PlayerGui"):WaitForChild("EffectUI"):WaitForChild("Toolbar"):WaitForChild("Mastery")

		local playerReplica = Profiles.GetPlayerReplica(data.ownerId)
		local module = WeaponHelpers.GetModule(data)

		if not playerReplica then
			return
		end

		mastery.Visible = true
		mastery.Position = UDim2.fromScale(-0.2, 0.9)
		TweenService:Create(mastery, TweenInfo.new(0.3), { Position = UDim2.fromScale(0.005, 0.9) }):Play()

		local function updateMastery()
			local v = playerReplica.Data.mastery[module.masteryType] or 0
			local level, v2, v3 = Level:GetLevel(v, "MASTERY_EQUATION")
			local v4 = (v - v2) / (v3 - v2)

			mastery.Title.Text = module.masteryType .. " Mastery"
			mastery.Reward.Text = `+{level}% DMG`
			mastery.Level.Label.Text = `{level}`
			mastery.Progress.Bar.Percent.Size = UDim2.new(v4, 0, 1, 0)

			if v4 > 0 then
				mastery.Progress.Bar.Percent.Display.Size = UDim2.new(1 / v4, 0, 1, 0)
			end
		end

		updateMastery()
		data.maid.equipMaid.masteryUpdateConnection = playerReplica:ListenToWrite("Mastery", updateMastery)
	end
end

function ToolFunctionHelpers.HideMastery(p)
	if p.isOwner then
		local mastery = p.owner:WaitForChild("PlayerGui"):WaitForChild("EffectUI"):WaitForChild("Toolbar"):WaitForChild("Mastery")

		mastery.Visible = false
	end
end

function ToolFunctionHelpers.Equip(p)
	local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)
	local Crosshair = require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)

	if p.isOwner then
		if WeaponConstants.AUTO_ROTATE_ON_EQUIP then
			CharacterHelper.AutoRotate(true, p.mouse)
		end

		if Device:Get() == "Desktop" then
			Crosshair.Enable(true, "Computer")
		elseif Device:Get() == "Console" then
			Crosshair.Enable(true, "Console")
			Mouselock:On()
		elseif Device:Get() == "Mobile" then
			Crosshair.Enable(true, "Mobile")
			Mouselock:On()
		end
	end
end

function ToolFunctionHelpers.Unequip(p)
	local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)
	local Crosshair = require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)

	if p.isOwner then
		CharacterHelper.StopAutoRotate()

		if Device:Get() == "Console" or UserInputService.GamepadEnabled then
			Crosshair.Enable(false, "Console")
			Mouselock:Off()
		elseif Device:Get() == "Mobile" then
			Crosshair.Enable(false, "Mobile")
			Mouselock:Off()

			local shoot = MobileHelper:WaitForButton("shoot")
			local reload = MobileHelper:WaitForButton("reload")

			shoot:SetVisible(false)
			reload:SetVisible(false)
		elseif Device:Get() == "Desktop" then
			Crosshair.Enable(false, "Computer")
		end

		Crosshair.ShowReload(p, false)
	end
end

return ToolFunctionHelpers