local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Maid)
require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("TweenService")
local RunService = game:GetService("RunService")

RunService:IsServer()
script:GetChildren()

return {
	command = "Taco Tuesday",
	commandType = "Server",
	searchTerms = { "Taco" },
	icon = "rbxassetid://116244196218817",
	layoutOrder = 260,
	maxActivationDistance = 1e999,
	cooldown = 60,
	cost = 0,
	options = {},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, _): string
		local music = workspace.Regions.Map:GetAttribute("Music")
		workspace.Regions.Map:SetAttribute("Music", "Parry Gripp - Raining Tacos")

		local clone = script.GameScript:Clone()
		clone.Parent = workspace
		clone.Enabled = true

		task.spawn(function()
			task.wait(30)

			if workspace.Regions.Map:GetAttribute("Music", "Parry Gripp - Raining Tacos") then
				workspace.Regions.Map:SetAttribute("Music", music)
			end

			clone:Destroy()
		end)

		return "The admin started Taco Tuesday!"
	end
}