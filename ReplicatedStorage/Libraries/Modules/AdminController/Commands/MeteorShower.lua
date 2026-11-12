local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Maid)
require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("TweenService")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Meteor Shower",
	commandType = "Server",
	searchTerms = { "Meteor" },
	icon = "rbxassetid://77242195871937",
	layoutOrder = 150,
	maxActivationDistance = 1e999,
	cooldown = 60,
	cost = 0,
	options = {},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, _): string
		if not isServer then
			return ""
		end

		local clone = script.GameScript:Clone()
		clone.Parent = workspace
		clone.Enabled = true

		task.spawn(function()
			task.wait(30)
			clone:Destroy()
		end)

		return "The admin started a meteor shower!"
	end
}