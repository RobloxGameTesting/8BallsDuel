local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService:IsServer()

return {
	command = "Teleport",
	commandType = "Server",
	searchTerms = { "Teleport" },
	icon = "rbxassetid://89079280665747",
	layoutOrder = 190,
	maxActivationDistance = 1e999,
	cooldown = 10,
	cost = 0,
	options = {
		{ optionType = "MultiplePlayerList", extra = nil, header = "Pick Players To Teleport" },
		{ optionType = "PlayerListNoEveryone", extra = nil, header = "Teleport To" }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]
		local _ = list[2]
		local playerByUserId = Players:GetPlayerByUserId(p)
		local character = playerByUserId and playerByUserId.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			for k, v in item do
				local playerByUserId2 = Players:GetPlayerByUserId(v)
				local character2 = playerByUserId2 and playerByUserId2.Character

				if character2 then
					character2:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(45 * k), 0) * CFrame.new(10, 0, 0))
				end
			end
		end

		return `Teleported to {playerByUserId.DisplayName}`
	end
}