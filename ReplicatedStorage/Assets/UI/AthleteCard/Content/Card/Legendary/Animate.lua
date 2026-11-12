local TweenService = game:GetService("TweenService")

local Rotation = script.Parent.Rotation

TweenService:Create(script.Parent, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1e999, true), {
	Rotation = -Rotation
}):Play()