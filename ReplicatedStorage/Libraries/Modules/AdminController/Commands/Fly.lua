local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Fly",
	commandType = "Server",
	searchTerms = { "Fly" },
	icon = "rbxassetid://92304764192058",
	layoutOrder = 29,
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

				if not (userId ~= p and humanoid) then
					continue
				end

				local clone = script.Fly:Clone()
				clone.Parent = v.Backpack
			end

			return "Admin gave <font color=\"#FF0000\">everyone</font> fly!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			local character = playerByUserId and playerByUserId.Character

			if character then
				character:FindFirstChildWhichIsA("Humanoid")
			end

			local clone = script.Fly:Clone()
			clone.Parent = playerByUserId.Backpack
			return `Admin gave <font color="#FF0000">{playerByUserId.DisplayName}</font> fly!`
		end
	end
}