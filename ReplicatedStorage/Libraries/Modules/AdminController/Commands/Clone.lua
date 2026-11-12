local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)

local isServer = RunService:IsServer()

return {
	command = "Clone",
	commandType = "Server",
	searchTerms = { "Clone" },
	icon = "rbxassetid://115081414552587",
	layoutOrder = 181,
	maxActivationDistance = 1e999,
	cooldown = 10,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		if not isServer then
			return ""
		end

		local item = list[1]

		local function apply(player) -- 2 equivalent calls inferred from this helper
			local character = player.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not (character and character:FindFirstChildWhichIsA("Humanoid") and humanoidRootPart) then
				return
			end

			local clone = CharacterHelper.Clone(character)
			clone.Parent = workspace
		end

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v) -- inferred equivalent call
				end
			end

			return "Admin cloned <font color=\"#FF0000\">everyone</font>!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin cloned <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
		end
	end
}