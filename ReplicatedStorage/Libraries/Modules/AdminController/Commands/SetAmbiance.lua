local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Set Ambiance",
	commandType = "Server",
	searchTerms = { "Ambiance" },
	icon = "rbxassetid://139749037245348",
	layoutOrder = 130,
	maxActivationDistance = 1e999,
	cooldown = 10,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = {
				"None",
				"Suburban Ambiance",
				"Snowy Winds",
				"Windy Ambiance",
				"Rain Ambiance",
				"San Francisco Ambiance"
			}
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

		workspace.Regions.Map:SetAttribute("Music", item)

		return `Admin set the ambiance to {item}`
	end
}