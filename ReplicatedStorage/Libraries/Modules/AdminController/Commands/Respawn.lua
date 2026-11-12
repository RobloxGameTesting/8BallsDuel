local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

local isServer = RunService:IsServer()

return {
	command = "Respawn",
	commandType = "Server",
	searchTerms = { "Respawn" },
	icon = "rbxassetid://119576873567549",
	layoutOrder = 11,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "PlayerList", extra = nil }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.Owner },
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		if not isServer then
			return ""
		end

		local item = list[1]

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				local userId = tostring(v.UserId)
				local character = v.Character
				local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

				if userId ~= p and humanoid then
					pcall(function()
						v:LoadCharacterAsync()
					end)
				end
			end

			return "Admin respawned <font color=\"#FF0000\">everyone</font>!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			local character = playerByUserId and playerByUserId.Character

			if character then
				character:FindFirstChildWhichIsA("Humanoid")
			end

			pcall(function()
				playerByUserId:LoadCharacterAsync()
			end)

			return `Admin respawned <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
		end
	end
}