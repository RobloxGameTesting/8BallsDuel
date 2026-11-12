local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)

local YellowSparkles = {}

function YellowSparkles.new(parent)
	local v = { maid = Maid.new() }

	local total = 0

	v.maid.effectConnection = RunService.Heartbeat:Connect(function(dt)
		if not UserInterfaceHelper:IsVisible(parent) then
			return
		end

		total += dt

		if total >= 0.6 then
			total = 0

			local number = Random.new():NextNumber(2.5, 4)
			local clone = script["Sparkle" .. Random.new():NextInteger(1, 2)]:Clone()
			clone.ImageTransparency = 0.2
			clone.ZIndex = parent.ZIndex + Random.new():NextInteger(1, 2) * 2
			clone.Position = UDim2.new(Random.new():NextNumber(0.1, 0.9), 0, Random.new():NextNumber(0.5, 0.8), 0)
			clone.Size = UDim2.new(Random.new():NextNumber(0.05, 0.15), 0, 1, 0)
			clone.Parent = parent

			TweenService:Create(clone, TweenInfo.new(number, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(clone.Position.X.Scale, 0, Random.new():NextNumber(0.05, 0.1), 0),
				ImageTransparency = 1
			}):Play()

			task.wait(number)
			clone:Destroy()
		end
	end)

	v.maid.parentConnection = parent.Destroying:Connect(function()
		YellowSparkles.Destroy(v)
	end)

	return v
end

function YellowSparkles.Destroy(p)
	p.maid:Destroy()
end

return YellowSparkles