local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Force Jump",
	commandType = "Server",
	searchTerms = { "Jump" },
	icon = "rbxassetid://138844332413338",
	layoutOrder = 160,
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
					humanoid.Jump = true
				end
			end

			return "Admin made <font color=\"#FF0000\">everyone</font> jump!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			local character = playerByUserId and playerByUserId.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				humanoid.Jump = true
			end

			return `Admin made <font color="#FF0000">{playerByUserId.DisplayName}</font> jump!`
		end
	end
}