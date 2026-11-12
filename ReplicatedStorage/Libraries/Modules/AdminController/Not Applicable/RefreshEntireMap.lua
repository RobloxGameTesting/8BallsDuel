local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
local parentModule = require(script.Parent.Parent)
local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain

local isServer = RunService:IsServer()
local clone, v

if isServer then
	clone = workspace.Destroyable:Clone()
	v = workspace.Terrain:CopyRegion(workspace.Terrain.MaxExtents)
else
	clone = nil
	v = nil
end

return {
	command = "Refresh Entire Map",
	searchTerms = { "Refresh Entire Map", "Clear", "Map", "Refresh", "Reload", "Clean" },
	icon = "rbxassetid://78729451765155",
	layoutOrder = 290,
	maxActivationDistance = 1e999,
	cooldown = 180,
	cost = 0,
	options = {},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, _): string
		if not isServer then
			return "Admin refreshed the map!"
		end

		parentModule.ClearMaid()
		workspace.Destroyable:Destroy()
		local clone_2 = clone:Clone()
		clone_2.Parent = workspace

		Terrain:PasteRegion(v, workspace.Terrain.MaxExtents.Min, true)

		return "Admin refreshed the map!"
	end
}