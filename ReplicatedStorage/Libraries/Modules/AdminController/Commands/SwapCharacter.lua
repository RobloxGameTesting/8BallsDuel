local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()

return {
	command = "Swap Outfits",
	commandType = "Server",
	searchTerms = { "Swap Outfit" },
	icon = "rbxassetid://108629420942212",
	layoutOrder = 240,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil },
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		local item = list[1]
		local item2 = list[2]

		local playerByUserId = Players:GetPlayerByUserId(item)
		local character = playerByUserId and playerByUserId.Character

		local playerByUserId2 = Players:GetPlayerByUserId(item2)
		local character2 = playerByUserId2 and playerByUserId2.Character

		if character and character2 then
			playerByUserId.Character = character2
			playerByUserId2.Character = character
		end

		return `Admin swapped <font color="#FF0000">{playerByUserId.DisplayName}</font> and <font color="#FF0000">{playerByUserId2.DisplayName}</font>!`
	end
}