local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("TextService")
require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()

return {
	command = "Global Message",
	commandType = "Global",
	searchTerms = { "Global", "Announcement", "Chat", "Text", "Message" },
	icon = "rbxassetid://93014908514222",
	layoutOrder = 100,
	maxActivationDistance = 1e999,
	cooldown = 5,
	cost = 0,
	options = {
		{ optionType = "UsernameTextBox", header = "Type Global Message" }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		if not isServer then
			return ""
		end

		local item = list[1]

		RemoteSignals.FireAllClients("Notification", "Notification", "GlobalAnnouncementNotification", {
			message = item,
			length = 8,
			parent = "TopNotifications"
		})

		return `Admin sent global message: {item}!`
	end
}