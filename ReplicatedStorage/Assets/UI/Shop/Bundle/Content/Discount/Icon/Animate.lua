local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function(dt)
	script.Parent.UIGradient.Rotation += dt * 180
end)