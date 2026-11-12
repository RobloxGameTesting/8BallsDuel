local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Clear Hats",
	commandType = "Server",
	searchTerms = { "Clear", "Hat", "Accessory", "Clothing" },
	icon = "rbxassetid://125566620092417",
	layoutOrder = 271,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{ optionType = "PlayerList", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]

		if not isServer then
			return ""
		end

		local function apply(player) -- 2 equivalent calls inferred from this helper
			local character = player.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if not humanoid then
				return
			end

			humanoid:RemoveAccessories()
		end

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v) -- inferred equivalent call
				end
			end

			return "Admin removed <font color=\"#FF0000\">everyone</font>'s hats!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin removed <font color="#FF0000">{playerByUserId.DisplayName}</font>'s hats!`
		end
	end
}