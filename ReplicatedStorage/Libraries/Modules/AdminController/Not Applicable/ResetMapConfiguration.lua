local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
local parentModule = require(script.Parent.Parent)
local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain

local isServer = RunService:IsServer()

if isServer then
	workspace.Destroyable:Clone()
	workspace.Terrain:CopyRegion(workspace.Terrain.MaxExtents)
end

return {
	command = "Reset Map Configuration",
	searchTerms = { "Reset Map Configuration" },
	icon = "rbxassetid://78729451765155",
	layoutOrder = 291,
	maxActivationDistance = 1e999,
	cooldown = 180,
	cost = 0,
	options = {},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, _): string
		if isServer then
			parentModule.ClearMaid()
			workspace.Gravity = 196.2
		end

		return "Admin reset the map configuration!"
	end
}