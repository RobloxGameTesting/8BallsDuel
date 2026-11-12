local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local isServer = RunService:IsServer()
local v = { Baby = 0.4, Dwarf = 0.6, Short = 0.8, Normal = 1 }

return {
	command = "Shrink",
	commandType = "Server",
	searchTerms = { "Shrink" },
	icon = "rbxassetid://99502249858217",
	layoutOrder = 90,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = { "Baby", "Dwarf", "Short", "Normal" }
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

		local function apply(player) -- 2 equivalent calls inferred from this helper
			local character = player.Character

			if character and character:FindFirstChildWhichIsA("Humanoid") then
				character:ScaleTo(v[item])
			end
		end

		if item2 == "Everyone" then
			for _, v2 in Players:GetPlayers(), nil, nil do
				if tostring(v2.UserId) ~= p then
					apply(v2) -- inferred equivalent call
				end
			end

			return `Admin set size to {item} for <font color="#FF0000">everyone</font>!`
		else
			local playerByUserId = Players:GetPlayerByUserId(item2)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font>'s size to {item}!`
		end
	end
}