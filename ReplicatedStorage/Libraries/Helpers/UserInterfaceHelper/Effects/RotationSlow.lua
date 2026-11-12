game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper.EffectTypes)

local RotationSlow = {}

function RotationSlow:new()
	local v = { maid = Maid.new() }

	v.maid.effectConnection = RunService.Heartbeat:Connect(function(dt: number)
		if not UserInterfaceHelper:IsVisible(self.Parent) then
			return
		end

		if self.Offset ~= Vector2.new(0, 0) then
			self.Rotation = -90
			return
		end

		self.Rotation += dt * 27
	end)

	v.maid.parentConnection = self.Destroying:Connect(function()
		RotationSlow.Destroy(v)
	end)

	return v
end

function RotationSlow.Destroy(p)
	p.maid:Destroy()
end

return RotationSlow