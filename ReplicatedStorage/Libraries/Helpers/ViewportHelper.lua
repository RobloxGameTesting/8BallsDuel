local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RunService = game:GetService("RunService")
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)

local Assets = ReplicatedStorage.Assets

local v = Maid.new()
local ViewportHelper = {}

function ViewportHelper.Emote(_, instance, parent, p: number, p2: number, idle: number)
	local camera = Instance.new("Camera")
	camera.Parent = parent

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = parent

	local clone = instance:Clone()
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	local animator = clone:FindFirstChild("Animator", true)

	camera.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(p), 0) * CFrame.new(0, 0, p2)

	parent.CurrentCamera = camera
	clone.Parent = workspace

	local v2 = Animations.new({ idle = idle }, animator)

	Animations.Play(v2, {
		{ animation = "idle", fadeIn = 0, looped = true }
	})

	clone.Parent = worldModel

	v[parent] = function()
		Animations.Destroy(v2)
		clone:Destroy()
		worldModel:Destroy()
		camera:Destroy()
	end
end

function ViewportHelper.Model(_, parent, instance, cframe)
	local clone = instance:Clone()
	clone.Parent = parent

	if not clone.PrimaryPart then
		return
	end

	local camera = Instance.new("Camera")
	camera.Parent = parent
	camera.CFrame = cframe

	parent.CurrentCamera = camera

	v[parent] = function()
		clone:Destroy()
		camera:Destroy()
	end
end

function ViewportHelper.SetCamera(_, instance, p)
	local currentCamera = instance.CurrentCamera
	local model = instance:FindFirstChildWhichIsA("Model")

	if not (currentCamera and model and model.PrimaryPart) then
		return
	end

	currentCamera.CFrame = model.PrimaryPart.CFrame * p
end

function ViewportHelper.SpinModel(_, parent, instance, p: number, p2: number)
	local clone = instance:Clone()
	clone.Parent = parent

	if not clone.PrimaryPart then
		return
	end

	local camera = Instance.new("Camera")
	camera.CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, 0, p)
	camera.Parent = parent

	parent.CurrentCamera = camera

	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local v2 = p2 * dt

		clone:PivotTo(clone.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(v2), 0))
	end)

	v[parent] = function()
		heartbeatConnection:Disconnect()
		clone:Destroy()
		camera:Destroy()
	end
end

function ViewportHelper.SpinCamera(_, parent, instance, p: number, p2: number)
	local clone = instance:Clone()
	clone.Parent = parent

	if not clone.PrimaryPart then
		return
	end

	local camera = Instance.new("Camera")
	camera.Parent = parent

	local total = 0

	parent.CurrentCamera = camera

	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += p2 * dt

		camera.CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, p)
	end)

	v[parent] = function()
		heartbeatConnection:Disconnect()
		clone:Destroy()
		camera:Destroy()
	end
end

function ViewportHelper.Clear(_, p)
	v[p] = nil
end

return ViewportHelper