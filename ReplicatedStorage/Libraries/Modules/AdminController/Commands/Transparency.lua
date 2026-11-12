local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()

return {
	command = "Transparency",
	commandType = "Server",
	searchTerms = { "Transparency" },
	icon = "rbxassetid://94401972520284",
	layoutOrder = 270,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = {
				"0 (default)",
				"0.1",
				"0.2",
				"0.3",
				"0.4",
				"0.5",
				"0.6",
				"0.7",
				"0.8",
				"0.9",
				"1"
			}
		},
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]
		local item2 = list[2]
		local transparency = tonumber(string.match(item, "%d+"))

		local function apply(player)
			local character = player.Character

			if not (character and character:FindFirstChildWhichIsA("Humanoid")) then
				return
			end

			if transparency then
				for _, part in character:QueryDescendants("BasePart"), nil, nil do
					if part.Name ~= "HumanoidRootPart" and part:IsA("BasePart") then
						part.Transparency = transparency
					end
				end
			end
		end

		if item2 == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v)
				end
			end

			return `Admin set transparency to {transparency} for <font color="#FF0000">everyone</font>!`
		else
			local playerByUserId = Players:GetPlayerByUserId(item2)
			apply(playerByUserId)
			return `Admin set <font color="#FF0000">{playerByUserId.DisplayName}</font>'s transparency to {transparency}!`
		end
	end
}