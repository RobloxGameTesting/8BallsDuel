local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)
local Players = game:GetService("Players")

local effectUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")

local ParticleRain = {}

function ParticleRain.new(p, image: string)
	local v = { maid = Maid.new() }

	for i = 1, 30 do
		local clone = script.Particle:Clone()
		clone.Image = image
		clone.Rotation = Random.new():NextInteger(0, 360)
		clone.Size = UDim2.fromOffset(p.AbsoluteSize.X * 0.075, p.AbsoluteSize.Y * 0.075)
		local v2 = p.AbsolutePosition.X + Random.new():NextInteger(0, p.AbsoluteSize.X)
		clone.Position = UDim2.fromOffset(v2, 0)
		clone.ImageTransparency = 1
		clone.Parent = effectUI
		v.maid["burst" .. i] = clone

		task.spawn(function()
			clone.ImageTransparency = 0

			TweenService:Create(clone, TweenInfo.new(Random.new():NextNumber(2, 4)), {
				Position = clone.Position + UDim2.fromOffset(
					Random.new():NextInteger(-p.AbsoluteSize.X / 2, p.AbsoluteSize.X / 2),
					Random.new():NextInteger(p.AbsoluteSize.Y, p.AbsoluteSize.Y + 200)
				),
				ImageTransparency = 0.5,
				Size = UDim2.fromScale(
					clone.Size.X.Scale * 0.5,
					clone.Size.X.Offset * 0.5,
					clone.Size.Y.Scale * 0.5,
					clone.Size.Y.Offset * 0.5
				),
				Rotation = Random.new():NextInteger(0, 360)
			}):Play()
		end)
	end

	task.spawn(function()
		task.wait(3)
		ParticleRain.Destroy(v)
	end)

	return v
end

function ParticleRain.Destroy(p)
	p.maid:Destroy()
end

return ParticleRain