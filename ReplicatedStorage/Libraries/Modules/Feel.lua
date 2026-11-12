local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraShaker = require(ReplicatedStorage.Libraries.Classes.CameraShaker)
local Lighting = game:GetService("Lighting")

local CurrentCamera = workspace.CurrentCamera

local v = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	CurrentCamera.CFrame *= p
end)

return {
	BlurBlast = function(_)
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 0
		blurEffect.Parent = Lighting

		TweenService:Create(
			blurEffect,
			TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{ Size = 20 }
		):Play()

		v:ShakeOnce(3, 15, 0.2, 0.4, 1, 1)
		v:Start()

		task.spawn(function()
			task.wait(0.1)
			blurEffect:Destroy()
		end)
	end
}