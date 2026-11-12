local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

local isServer = RunService:IsServer()

return {
	command = "Jumpheight+",
	commandType = "Server",
	searchTerms = { "Jumpheight" },
	icon = "rbxassetid://139371945302942",
	layoutOrder = 20,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = { "2", "4", "7.2 (default)", "10", "15", "20", "50" }
		},
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.AdminPlus },
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		if not isServer then
			return ""
		end

		local item = list[1]
		local item2 = list[2]
		local jumpHeight = string.match(item, "%d+")

		local function apply(player) -- 2 equivalent calls inferred from this helper
			local character = player.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if not humanoid then
				return
			end

			humanoid.JumpHeight = jumpHeight
		end

		if item2 == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v) -- inferred equivalent call
				end
			end

			return `Admin set jump height to {jumpHeight} for <font color="#FF0000">everyone</font>!`
		else
			local playerByUserId = Players:GetPlayerByUserId(item2)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font>'s jump height to {jumpHeight}!`
		end
	end
}