local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Grow",
	commandType = "Server",
	searchTerms = { "Grow" },
	icon = "rbxassetid://97846828969242",
	layoutOrder = 80,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = { "Big", "Giant", "Humongous", "Normal" }
		},
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
		local item2 = list[2]

		local function apply(player)
			local character = player.Character

			if character and character:FindFirstChildWhichIsA("Humanoid") then
				character:ScaleTo(({ Big = 1.5, Giant = 2, Humongous = 4, Normal = 1 })[item])
			end
		end

		if item2 == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v)
				end
			end

			return `Admin set size to {item} for <font color="#FF0000">everyone</font>!`
		else
			local playerByUserId = Players:GetPlayerByUserId(item2)
			apply(playerByUserId)

			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font>'s size to {item}!`
		end
	end
}