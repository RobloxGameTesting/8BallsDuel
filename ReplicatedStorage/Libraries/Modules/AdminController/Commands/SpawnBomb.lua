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

return {
	command = "Spawn Bombs",
	commandType = "Server",
	searchTerms = { "Bomb" },
	icon = "rbxassetid://78011709636751",
	layoutOrder = 220,
	maxActivationDistance = 1e999,
	cooldown = 60,
	cost = 0,
	options = {
		{
			optionType = "List",
			extra = { "1", "2", "3", "4", "5", "10" }
		}
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(p, list)
		local item = list[1]

		if isServer then
			for i = 1, item do
				local v = CFrame.new(Random.new():NextInteger(-200, 200), 20, Random.new():NextInteger(-200, 200))

				if i == 1 then
					local playerByUserId = Players:GetPlayerByUserId(p)
					local character = playerByUserId and playerByUserId.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						v = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 15
					end
				end

				local clone = script.Bomb:Clone()
				clone:PivotTo(v)
				clone.Parent = workspace

				local total = 0
				local heartbeatConnection = nil

				heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
					total += dt

					local v2 = math.ceil(15 - total)
					clone.BillboardGui.TextLabel.Text = `{NumberHelper.FormatTimerMS(v2)}s`

					if total >= 15 then
						local explosion = Instance.new("Explosion")
						explosion.Position = clone.PrimaryPart.Position
						explosion.Parent = workspace

						parentModule.AddToMaid(explosion)
						clone:Destroy()
						heartbeatConnection:Disconnect()
					end
				end)

				parentModule.AddToMaid(clone)
				parentModule.AddToMaid(heartbeatConnection)
			end
		end

		return `The admin has spawned {item} bombs!`
	end
}