local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)

local Burst = {}

function Burst.new(parent)
	local v = { maid = Maid.new() }

	local clone = script.Starburst:Clone()
	clone.Size = UDim2.fromScale(0, 0)
	clone.ZIndex = parent.ZIndex + 1
	clone.Parent = parent
	v.maid.starburst = clone

	v.maid.rotationConnection = RunService.Heartbeat:Connect(function(dt)
		clone.Rotation += dt * 100
	end)
	TweenService:Create(clone, TweenInfo.new(1), {
		Size = UDim2.fromScale(5, 5),
		ImageTransparency = 1
	}):Play()

	task.spawn(function()
		task.wait(0.5)

		task.wait(0.5)
		Burst.Destroy(v)
	end)

	return v
end

function Burst.Destroy(p)
	p.maid:Destroy()
end

return Burst