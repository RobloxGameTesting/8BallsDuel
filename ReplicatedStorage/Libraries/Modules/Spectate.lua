local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local CurrentCamera = workspace.CurrentCamera

return {
	command = "Spectate",
	commandType = "Server",
	searchTerms = { "Spectate" },
	icon = "rbxassetid://119576873567549",
	layoutOrder = 230,
	maxActivationDistance = 1e999,
	cooldown = 1,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list): string
		if not isServer then
			return ""
		end

		local playerByUserId = Players:GetPlayerByUserId(list[1])
		local character = playerByUserId and playerByUserId.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

		if not isServer and humanoid then
			CurrentCamera.CameraSubject = humanoid
		end

		return ""
	end
}