local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

RunService:IsServer()

return {
	command = "Invisible",
	commandType = "Server",
	searchTerms = { "Invisible" },
	icon = "rbxassetid://94401972520284",
	layoutOrder = 10,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.Troll },
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]

		local function apply(player) -- 2 equivalent calls inferred from this helper
			local character = player.Character

			ModelHelper.Invisible(character)
		end

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v) -- inferred equivalent call
				end
			end

			return "Admin set <font color=\"#FF0000\">everyone</font> invisible!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font> to invisible!`
		end
	end
}