local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)

local Shine = {}

function Shine.new(parent)
	local v = { maid = Maid.new() }

	local clone = script.Shine:Clone()
	clone.UIGradient.Offset = Vector2.new(-2, 0)
	clone.ZIndex = parent.ZIndex + 1
	clone.BackgroundTransparency = 0
	clone.Parent = parent
	v.maid.shine = clone

	TweenService:Create(clone.UIGradient, TweenInfo.new(1.2), { Offset = Vector2.new(2.5, 0) }):Play()

	task.spawn(function()
		task.wait(1.2)
		Shine.Destroy(v)
	end)

	return v
end

function Shine.SetImage(p, image: string)
	p.maid.shine.Image = image
end

function Shine.Destroy(p)
	p.maid:Destroy()
end

return Shine