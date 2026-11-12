local RunService = game:GetService("RunService")

for _, uiStroke in script.Parent:GetChildren(), nil, nil do
	if uiStroke:IsA("UIStroke") then
		RunService.Heartbeat:Connect(function(dt: number)
			uiStroke.UIGradient.Rotation += dt * 60
		end)
	end
end