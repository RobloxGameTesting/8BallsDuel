local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

local isServer = RunService:IsServer()

return {
	command = "Kick",
	commandType = "Server",
	searchTerms = { "Kick" },
	icon = "rbxassetid://104074516861351",
	layoutOrder = 10,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.Owner },
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		if not isServer then
			return ""
		end

		local playerByUserId = Players:GetPlayerByUserId(list[1])
		playerByUserId:Kick("Rejoin the game if you want. Owner admin kicked you")
		return `Admin kicked <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
	end
}