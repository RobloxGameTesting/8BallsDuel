local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)
local Players = game:GetService("Players")

local effectUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")

local ParticleExplosion = {}

function ParticleExplosion.new(data, image: string)
	local v = { maid = Maid.new() }

	for i = 1, 30 do
		local clone = script.Particle:Clone()
		clone.Image = image
		clone.Rotation = Random.new():NextInteger(0, 360)
		clone.Size = UDim2.fromOffset(data.AbsoluteSize.X * 0.75, data.AbsoluteSize.Y * 0.75)
		clone.Position = UDim2.fromOffset(
			data.AbsolutePosition.X + data.AbsoluteSize.X / 2,
			data.AbsolutePosition.Y + data.AbsoluteSize.Y
		)
		clone.ZIndex = data.ZIndex - 1
		clone.ImageTransparency = 1
		clone.Parent = effectUI
		v.maid["burst" .. i] = clone

		task.spawn(function()
			clone.ImageTransparency = 0

			TweenService:Create(clone, TweenInfo.new(1), {
				Position = clone.Position + UDim2.fromOffset(
					Random.new():NextNumber(-200, 200),
					Random.new():NextNumber(-200, 200)
				),
				ImageTransparency = 1,
				Rotation = Random.new():NextInteger(0, 360)
			}):Play()
		end)
	end

	task.spawn(function()
		task.wait(3)
		ParticleExplosion.Destroy(v)
	end)

	return v
end

function ParticleExplosion.Destroy(p)
	p.maid:Destroy()
end

return ParticleExplosion