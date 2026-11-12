local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Force Sit",
	commandType = "Server",
	searchTerms = { "Sit" },
	icon = "rbxassetid://137032323017862",
	layoutOrder = 161,
	maxActivationDistance = 1e999,
	cooldown = 1,
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

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				local userId = tostring(v.UserId)
				local character = v.Character
				local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

				if userId ~= p and humanoid then
					humanoid.Sit = true
				end
			end

			return "Admin made <font color=\"#FF0000\">everyone</font> sit!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			local character = playerByUserId and playerByUserId.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				humanoid.Sit = true
			end

			return `Admin made <font color="#FF0000">{playerByUserId.DisplayName}</font> sit!`
		end
	end
}