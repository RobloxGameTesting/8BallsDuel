local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Classes.Mouses)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.Helpers.OptimizationHelper)

local Modules = script.Parent.Modules

local WeaponHelpers = {}

function WeaponHelpers.GetAllModuleScripts()
	return Modules
end

function WeaponHelpers.GetAllModules()
	local modulesByName = {}

	for _, moduleScript in Modules:GetChildren(), nil, nil do
		local module = require(moduleScript)
		modulesByName[moduleScript.Name] = module
	end

	return modulesByName
end

function WeaponHelpers.GetModuleScript(p)
	return (Modules:FindFirstChild(p.weaponType))
end

function WeaponHelpers.GetModule(p)
	local moduleScript = WeaponHelpers.GetModuleScript(p)
	local module = require(moduleScript)

	return module
end

function WeaponHelpers.GetFunctionsModule(p)
	local functions = WeaponHelpers.GetModuleScript(p):FindFirstChild("Functions")
	local module = require(functions)

	return module
end

function WeaponHelpers.GiveWeapon(p: string, weaponType)
	local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)

	local playerByUserId = Players:GetPlayerByUserId((tonumber(p)))
	local weaponsByOwnerId = Tools._getWeaponsByOwnerId(p)
	local module = WeaponHelpers.GetModule({ weaponType = weaponType })

	for _, weapon in weaponsByOwnerId do
		if WeaponHelpers.GetModule(weapon).toolType == module.toolType then
			Tools.Destroy(weapon)
		end
	end

	Tools.newServer(playerByUserId, weaponType)
end

function WeaponHelpers.GetEquippedDatastoreOfType(p, p2: string)
	local userId = tostring(p.UserId)

	for _, tool in Profiles.GetPlayerReplica(userId).Data.equipped.tools do
		if InventoryHelpers.GetItemData("Tools", tool).toolType == p2 then
			return tool
		end
	end

	return nil
end

function WeaponHelpers.UnequipToolType(p, p2: string)
	local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)
	local userId = tostring(p.UserId)
	local weaponsByOwnerId = Tools._getWeaponsByOwnerId(userId)

	for _, weapon in weaponsByOwnerId do
		if WeaponHelpers.GetModule(weapon).toolType == p2 then
			Tools.Destroy(weapon)
		end
	end
end

function WeaponHelpers.EquipToolType(p, p2: string)
	local Tools = require(ReplicatedStorage.Libraries.GameSpecific.Tools)
	local userId = tostring(p.UserId)
	local weaponsByOwnerId = Tools._getWeaponsByOwnerId(userId)

	for _, weapon in weaponsByOwnerId do
		if InventoryHelpers.GetItemData("Tools", weapon.weaponType).toolType == p2 then
			Tools.Equip(weapon)
			break
		end
	end
end

return WeaponHelpers