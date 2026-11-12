local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local RunService = game:GetService("RunService")
require(script.RoleTypes)
local HealthHandlerEvents = require(ReplicatedStorage.Libraries.Modules.HealthHandler.HealthHandlerEvents)

local isServer = RunService:IsServer()

local Roles = {}

function Roles.Init()
	if not isServer then
		return
	end

	Players.PlayerAdded:Connect(function(player)
		local userId = tostring(player.UserId)
		Roles.GetRoleModule(userId).onJoin(userId)

		player.CharacterAdded:Connect(function(_)
			Roles.GetRoleModule(userId).onSpawn(userId)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local userId = tostring(player.UserId)
		Roles.GetRoleModule(userId).onLeave(userId)
	end)

	HealthHandlerEvents.TakeDamage.Event:Connect(function(p, p2, p3)
		Roles.GetRoleModule(p).onTakeDamage(p, p2, p3)
	end)

	HealthHandlerEvents.Healed.Event:Connect(function(p, p2, p3)
		Roles.GetRoleModule(p).onHeal(p, p2, p3)
	end)

	HealthHandlerEvents.Downed.Event:Connect(function(p, p2)
		local roleModule = Roles.GetRoleModule(p)

		if p2 then
			roleModule.onDowned(p)
		else
			roleModule.onRevive(p)
		end
	end)
end

function Roles.GetRole(p)
	local v = Profiles.GetPlayerReplica(p) or Profiles.WaitForPlayerReplica(p)

	return v and v.Data.roleSlots[v.Data.selectedSlot] and v.Data.roleSlots[v.Data.selectedSlot].role
end

function Roles.GetRoleModule(p)
	local role = Roles.GetRole(p)

	return InventoryHelpers.GetItemData("Roles", role)
end

return Roles