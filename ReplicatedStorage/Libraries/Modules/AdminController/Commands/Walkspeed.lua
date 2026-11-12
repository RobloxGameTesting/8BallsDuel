local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()

return {
	command = "Walkspeed",
	commandType = "Server",
	searchTerms = { "Walkspeed" },
	icon = "rbxassetid://104074516861351",
	layoutOrder = 60,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = { "10", "16 (default)", "20", "30", "40", "50" }
		},
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]
		local item2 = list[2]
		local walkSpeed = string.match(item, "%d+")

		local function apply(player) -- 2 equivalent calls inferred from this helper
			local character = player.Character
			local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

			if not humanoid then
				return
			end

			humanoid.WalkSpeed = walkSpeed
		end

		if item2 == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v) -- inferred equivalent call
				end
			end

			return `Admin set walkspeed to {walkSpeed} for <font color="#FF0000">everyone</font>!`
		else
			local playerByUserId = Players:GetPlayerByUserId(item2)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font>'s walkspeed to {walkSpeed}!`
		end
	end
}