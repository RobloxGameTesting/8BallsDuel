local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Chat = game:GetService("Chat")
local StringHelper = require(ReplicatedStorage.Libraries.Helpers.StringHelper)
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

local isServer = RunService:IsServer()

return {
	command = "Troll Bubble Chat",
	commandType = "Server",
	searchTerms = { "Troll Bubble Chat" },
	icon = "rbxassetid://119576873567549",
	layoutOrder = 11,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "PlayerList", extra = nil },
		{ optionType = "TextBox" }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.Troll },
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list): string
		if not isServer then
			return ""
		end

		local item = list[1]
		local item2 = list[2]

		local filtered = StringHelper.Filter(item2, p)
		local v = filtered and StringHelper.FilterForBroadcast(filtered)

		local function apply(player) -- 2 equivalent calls inferred from this helper
			local character = player.Character

			if v then
				Chat:Chat(character, item2)
			end
		end

		if item == "Everyone" then
			for _, v2 in Players:GetPlayers(), nil, nil do
				apply(v2) -- inferred equivalent call
			end
		else
			apply(Players:GetPlayerByUserId(item)) -- inferred equivalent call
		end

		return ""
	end
}