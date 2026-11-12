local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Maid)
local parentModule = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("RunService")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")

RunService:IsServer()

return {
	command = "Trap",
	commandType = "Server",
	searchTerms = { "Trap" },
	icon = "rbxassetid://78752442191573",
	layoutOrder = 280,
	maxActivationDistance = 1e999,
	cooldown = 15,
	cost = 0,
	options = {
		{ optionType = "PlayerListNoEveryone", extra = nil }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		local playerByUserId = Players:GetPlayerByUserId(list[1])
		local character = playerByUserId and playerByUserId.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local clone = script.Model:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 2, 0))
			clone.Parent = workspace

			local total = 0
			local heartbeatConnection = nil

			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				total += dt

				local v = math.ceil(10 - total)
				clone.BillboardGui.TextLabel.Text = `{NumberHelper.FormatTimerMS(v)}s`

				if total >= 10 then
					clone:Destroy()
					heartbeatConnection:Disconnect()
				end
			end)

			parentModule.AddToMaid(clone)
			parentModule.AddToMaid(heartbeatConnection)
		end

		return `The admin trapped {playerByUserId.DisplayName}!`
	end
}