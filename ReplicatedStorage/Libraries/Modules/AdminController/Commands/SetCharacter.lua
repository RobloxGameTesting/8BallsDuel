local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Set Character",
	commandType = "Server",
	searchTerms = { "Character" },
	icon = "rbxassetid://115081414552587",
	layoutOrder = 182,
	maxActivationDistance = 1e999,
	cooldown = 10,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil },
		{ optionType = "TextBox", header = "Insert user id of who to transform info" }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		if not isServer then
			return ""
		end

		local item = list[1]
		local item2 = list[2]
		local v = nil

		local success, result = pcall(function()
			return (Players:GetHumanoidDescriptionFromUserIdAsync(item2))
		end)

		if success then
			v = result
		else
			error(result)
		end

		v.Parent = workspace

		local function apply(player)
			if not v then
				return
			end

			local character = player.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if not (humanoid and humanoidRootPart) then
				return
			end

			local _, _ = pcall(function()
				humanoid:ApplyDescriptionAsync(v)
			end)
		end

		if item == "Everyone" then
			for _, v2 in Players:GetPlayers(), nil, nil do
				if tostring(v2.UserId) ~= p then
					apply(v2)
				end
			end

			return "Admin transformed <font color=\"#FF0000\">everyone</font>!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			apply(playerByUserId)

			return `Admin transformed <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
		end
	end
}