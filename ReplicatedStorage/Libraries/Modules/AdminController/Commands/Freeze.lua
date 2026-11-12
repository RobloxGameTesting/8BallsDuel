local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Maid)
local parentModule = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("RunService")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
script:GetChildren()

return {
	command = "Freeze",
	commandType = "Server",
	searchTerms = { "Freeze" },
	icon = "rbxassetid://92186771005345",
	layoutOrder = 101,
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
		if not isServer then
			return ""
		end

		local function apply(playerByUserId)
			local character = playerByUserId and playerByUserId.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				humanoidRootPart.Anchored = true
				local clone = script.Model:Clone()
				clone:PivotTo(humanoidRootPart.CFrame)
				clone.Parent = workspace

				local total = 0
				local heartbeatConnection = nil

				heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
					character:PivotTo(clone.PrimaryPart.CFrame)
					total += dt

					local v = math.ceil(10 - total)
					clone.BillboardGui.TextLabel.Text = `{NumberHelper.FormatTimerMS(v)}s`

					if total >= 10 then
						if humanoidRootPart then
							humanoidRootPart.Anchored = false
						end

						clone:Destroy()
						heartbeatConnection:Disconnect()
					end
				end)

				parentModule.AddToMaid(clone)
				parentModule.AddToMaid(heartbeatConnection)
			end
		end

		local playerByUserId = Players:GetPlayerByUserId(list[1])
		apply(playerByUserId)

		return `The admin jailed {playerByUserId.DisplayName}!`
	end
}