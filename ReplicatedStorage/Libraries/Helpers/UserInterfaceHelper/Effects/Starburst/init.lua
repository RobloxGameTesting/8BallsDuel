local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)

local Starburst = {}

function Starburst.new(parent)
	local v = { maid = Maid.new() }

	local clone = script.Starburst:Clone()
	clone.ZIndex = parent.ZIndex + 1
	clone.Parent = parent
	v.maid.starburst = clone

	v.maid.effectConnection = RunService.Heartbeat:Connect(function(dt: number)
		if not UserInterfaceHelper:IsVisible(parent) then
			return
		end

		clone.Rotation += dt * 27
	end)

	v.maid.parentConnection = parent.Destroying:Connect(function()
		Starburst.Destroy(v)
	end)

	return v
end

function Starburst.SetZIndex(p, zIndex: number)
	p.maid.starburst.ZIndex = zIndex
end

function Starburst.SetColor(p, imageColor: Color3)
	p.maid.starburst.ImageColor3 = imageColor
end

function Starburst.SetTransparency(p, imageTransparency: number)
	p.maid.starburst.ImageTransparency = imageTransparency
end

function Starburst.TweenTransparency(p, imageTransparency: number, tweenInfo)
	TweenService:Create(p.maid.starburst, tweenInfo, { ImageTransparency = imageTransparency }):Play()
end

function Starburst.Destroy(p)
	p.maid:Destroy()
end

return Starburst