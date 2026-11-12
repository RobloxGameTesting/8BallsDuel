local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StringHelper = require(ReplicatedStorage.Libraries.Helpers.StringHelper)
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

local isServer = RunService:IsServer()

return {
	command = "Rename",
	commandType = "Server",
	searchTerms = { "Rename" },
	icon = "rbxassetid://119576873567549",
	layoutOrder = 10,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone" },
		{ optionType = "TextBox", header = "Pick a Name" }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.AdminPlus },
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		if not isServer then
			return ""
		end

		local item = list[1]
		local item2 = list[2]

		local playerByUserId = Players:GetPlayerByUserId(item)
		local character = playerByUserId and playerByUserId.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local nameUI = humanoidRootPart and humanoidRootPart:FindFirstChild("NameUI")

		if nameUI then
			local filtered = StringHelper.Filter(item2, p)

			local text = filtered and StringHelper.FilterForBroadcast(filtered)

			if text then
				nameUI.DisplayName.Text = text
			end
		end

		return `Admin renamed <font color="#FF0000">{playerByUserId.DisplayName}</font>!`
	end
}