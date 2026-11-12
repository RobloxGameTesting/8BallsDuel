local UserGameSettings = UserSettings():GetService("UserGameSettings")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Device)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local MobileHelper = require(ReplicatedStorage.Libraries.Helpers.MobileHelper)

Players.LocalPlayer:WaitForChild("PlayerGui")
local v = Maid.new()

local v2 = false

local flag = true
local v3 = false
local flag2 = false
local bindableEvent = Instance.new("BindableEvent")
local v4 = CFrame.new(0, 0, 0)
local v5 = false
local v6 = CFrame.new(0, 0, 0)

local Mouselock = {}

function Mouselock.Init()
	if flag2 then
		return
	end

	flag2 = true
	UserGameSettings.RotationType = Enum.RotationType.MovementRelative

	local function onStep(_: number)
		if v2 then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			currentCamera.CFrame *= v4
			currentCamera.Focus = CFrame.fromMatrix(
				currentCamera.Focus.Position,
				currentCamera.CFrame.RightVector,
				currentCamera.CFrame.UpVector
			) * v4
		end
	end

	RunService:BindToRenderStep("MouseLock", Enum.RenderPriority.Camera.Value + 1, onStep)
end

function Mouselock.Toggle()
	if not flag then
		return
	end

	local v7 = not v3

	Mouselock.Init()

	if v7 then
		Mouselock.On()
	else
		Mouselock.Off()
	end

	bindableEvent:Fire()
end

function Mouselock.Off()
	if not flag then
		return
	end

	Mouselock.Init()
	UserGameSettings.RotationType = Enum.RotationType.MovementRelative
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	v3 = false
	bindableEvent:Fire()

	Mouselock.StartOffset(CFrame.new(0, 0, 0), 0.2)
	local button = MobileHelper:GetButton("mouselock")

	if button then
		button:Release()
	end
end

function Mouselock.On()
	if not flag then
		return
	end

	Mouselock.Init()
	UserGameSettings.RotationType = Enum.RotationType.CameraRelative
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	v3 = true
	bindableEvent:Fire()

	Mouselock.StartOffset(CFrame.new(3, 1, 0), 0.3)
	local button = MobileHelper:GetButton("mouselock")

	if button then
		button:Press()
	end
end

function Mouselock.Disable()
	if not flag then
		return
	end

	v5 = v3
	Mouselock.Off()
	flag = false
end

function Mouselock.Enable()
	if flag then
		return
	end

	flag = true

	Mouselock.Cache()
end

function Mouselock.Cache()
	print("Cached: ", v5)

	if v5 then
		Mouselock.On()
	else
		Mouselock.Off()
	end
end

function Mouselock.StartOffset(cframe: CFrame, max: number)
	if v6 == cframe then
		return
	end

	v2 = false

	v6 = cframe
	local v7 = v4
	local _magnitude = (v7.Position - v6.Position).Magnitude
	local v8 = 0

	v.offsetTweenConnection = RunService.Heartbeat:Connect(function(dt: number)
		v8 += dt
		v8 = math.clamp(v8, 0, max)
		local v9 = v8 / max
		v4 = v7:Lerp(v6, v9)

		if v9 >= 1 then
			v.offsetTweenConnection = nil
		end
	end)
end

function Mouselock.PauseOffset(p)
	v2 = p
end

return Mouselock