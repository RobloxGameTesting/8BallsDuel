local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.StringHelper)
local AdminConstants = require(ReplicatedStorage.Libraries.Modules.AdminController.AdminConstants)

local isServer = RunService:IsServer()

return {
	command = "Show Name Tag",
	commandType = "Server",
	searchTerms = { "Name Tag" },
	icon = "rbxassetid://95079032934141",
	layoutOrder = 12,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone" }
	},
	robuxIds = { AdminConstants.PRODUCT_IDS.Troll },
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
			local nameUI = humanoidRootPart and humanoidRootPart:FindFirstChild("NameUI")

			if not (humanoidRootPart and nameUI) then
				return
			end

			nameUI.Enabled = false
		end

		if item == "Everyone" then
			for _, v in Players:GetPlayers(), nil, nil do
				if tostring(v.UserId) ~= p then
					apply(v) -- inferred equivalent call
				end
			end

			return "Admin hid <font color=\"#FF0000\">everyone</font>'s name tag!"
		else
			local playerByUserId = Players:GetPlayerByUserId(item)
			apply(playerByUserId) -- inferred equivalent call
			return `Admin hide <font color="#FF0000">{playerByUserId.DisplayName}</font>'s name tag!`
		end
	end
}