local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "SetWorldGravity",
	commandType = "Global",
	searchTerms = { "Gravity" },
	icon = "rbxassetid://132828715174649",
	layoutOrder = 170,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = { "10", "25", "50", "100", "196.2 (default)", "300" }
		}
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		if not isServer then
			return ""
		end

		local item = list[1]
		local _ = list[2]
		local gravity = string.match(item, "%d+")

		workspace.Gravity = gravity

		return `Admin set world's gravity to {gravity}!`
	end
}