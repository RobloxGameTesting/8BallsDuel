local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
require(script.Parent.Parent)
local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain

local isServer = RunService:IsServer()
local v

if isServer then
	v = Terrain:CopyRegion(Terrain.MaxExtents)
else
	v = nil
end

return {
	command = "Refresh Terrain",
	commandType = "Server",
	searchTerms = { "Refresh Terrain" },
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
			Terrain:PasteRegion(v, Terrain.MaxExtents.Min, true)
		end

		return "Admin refreshed the terrain!"
	end
}