local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Explode",
	commandType = "Server",
	searchTerms = { "Explode" },
	icon = "rbxassetid://139384600374657",
	layoutOrder = 180,
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

			local explosion = Instance.new("Explosion")
			explosion.Position = humanoidRootPart.Position
			explosion.Parent = humanoidRootPart
		end

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v) -- inferred equivalent call
				end
			end

			return "Admin exploded <font color=\"#FF0000\">everyone</font>!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin exploded <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
		end
	end
}