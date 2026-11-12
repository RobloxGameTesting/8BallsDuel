local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Maid)
local parentModule = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

return {
	command = "Spawn Zombie",
	commandType = "Server",
	searchTerms = { "Zombie" },
	icon = "rbxassetid://78011709636751",
	layoutOrder = 220,
	maxActivationDistance = 1e999,
	cooldown = 20,
	cost = 0,
	options = {},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, _): string
		if not isServer then
			return "The admin spawned a zombie!"
		end

		for _ = 1, 1 do
			local cframe = CFrame.new(Random.new():NextInteger(-200, 200), 20, Random.new():NextInteger(-200, 200))

			local clone = script.Zombie:Clone()
			clone:PivotTo(cframe)
			clone.Parent = workspace

			local total = 0
			local heartbeatConnection = nil

			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				total += dt

				math.ceil(30 - total)

				if total >= 30 then
					clone:Destroy()
					heartbeatConnection:Disconnect()
				end
			end)

			parentModule.AddToMaid(clone)
			parentModule.AddToMaid(heartbeatConnection)
		end

		return "The admin spawned a zombie!"
	end
}