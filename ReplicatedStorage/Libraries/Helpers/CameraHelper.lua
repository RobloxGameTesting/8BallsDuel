local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()
local CurrentCamera = workspace.CurrentCamera
local Track = Enum.CameraType.Track
local v = Maid.new()

local v2 = nil
local v3 = false

local CameraHelper = {}

function CameraHelper.Init()
	if isServer then
		return
	end

	local v4 = { "CameraSetScriptableSubject", "CameraSetSubject", "CameraFollowPart" }

	local localPlayer = Players.LocalPlayer
	tostring(localPlayer.UserId)
	localPlayer:WaitForChild("PlayerGui")

	RemoteSignals.OnClientEvent("Camera", function(p, ...)
		if not table.find(v4, p) then
			return
		end

		local v5 = { ... }

		if p == "CameraSetSubject" then
			local v6 = v5[1]

			CameraHelper.SetSubject(nil, v6)
		elseif p == "CameraSetScriptableSubject" then
			local v6 = v5[1]
			local v7 = v5[2]

			CameraHelper.SetScriptableSubject(nil, v6, v7)
		elseif p == "CameraFollowPart" then
			local v6 = v5[1]

			CameraHelper.FollowPart(nil, v6)
		end
	end)
end

function CameraHelper.SetSubject(p, cameraSubject)
	if isServer then
		RemoteSignals.FireClient(p, "Camera", "CameraSetSubject", cameraSubject)
	else
		if v3 then
			return
		end

		local character = Players.LocalPlayer.Character

		if character then
			character:FindFirstChild("HumanoidRootPart")
		end

		CurrentCamera.CameraSubject = cameraSubject
	end

	print("Set subject to :", cameraSubject)
end

function CameraHelper.SetScriptableSubject(p, p2, flag: boolean)
	if isServer then
		RemoteSignals.FireClient(p, "Camera", "CameraSetScriptableSubject", p2, flag)
		return
	end

	if v3 then
		return
	end

	local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)
	Mouselock:PauseOffset(true)
	CameraHelper.StopTween()
	v.cameraResetConnection = nil
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	CurrentCamera.CFrame = p2.CFrame

	if flag and Device:Get() == "Desktop" then
		local mouse = Players.LocalPlayer:GetMouse()

		v.tiltConnection = RunService.RenderStepped:Connect(function()
			CurrentCamera.CFrame = p2.CFrame * CFrame.Angles(
				math.rad((mouse.Y - mouse.ViewSizeY / 2) / mouse.ViewSizeY * -10),
				math.rad((mouse.X - mouse.ViewSizeX / 2) / mouse.ViewSizeX * -10),
				0
			)
		end)
	end
end

function CameraHelper.IsFirstPerson(): boolean
	return (CurrentCamera.Focus.Position - CurrentCamera.CFrame.Position).Magnitude <= 1
end

function CameraHelper.FieldOfView(_, fieldOfView: number)
	if v3 then
		return
	end

	CurrentCamera.FieldOfView = fieldOfView
end

function CameraHelper.Watch(callback)
	if v3 then
		return
	end

	if callback then
		CameraHelper:SetToType(false)
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		v.watchConnection = RunService.RenderStepped:Connect(function()
			if not callback then
				CameraHelper.Watch()
			end

			local cframe = callback()

			if cframe then
				CurrentCamera.CFrame = cframe
			else
				CameraHelper.Watch()
			end
		end)
	else
		v.watchConnection = nil
		CameraHelper:Reset()
	end
end

function CameraHelper.StopTween()
	if v3 then
		return
	end

	if v2 then
		v2:Cancel()
		v2:Destroy()
	end
end

function CameraHelper:Tween(p, tweenInfo)
	if v3 then
		return
	end

	self:StopTween()
	v2 = TweenService:Create(CurrentCamera, tweenInfo, { CFrame = p.CFrame })

	v2:Play()
end

function CameraHelper:Reset(cframe: CFrame?)
	if v3 then
		return
	end

	local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)
	Mouselock:PauseOffset(false)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character
	local humanoid = character and character:WaitForChild("Humanoid")

	v.tiltConnection = nil
	self:StopTween()
	CurrentCamera.CameraSubject = humanoid
	CameraHelper:SetToType(true)

	if cframe then
		CurrentCamera.CFrame = cframe
	end

	v.resetCameraOnJoin = localPlayer.CharacterAdded:Connect(function()
		CameraHelper:Reset(cframe)
	end)
end

function CameraHelper:SetToType(flag: boolean)
	if v3 then
		return
	end

	if not flag then
		v.cameraResetConnection = nil

		return
	end

	local function setToType() -- 1 equivalent call inferred from this helper
		CurrentCamera.CameraType = Track
	end

	setToType() -- inferred equivalent call
	v.cameraResetConnection = CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(setToType)
end

function CameraHelper.FollowPart(p, p2)
	if isServer then
		RemoteSignals.FireClient(p, "Camera", "CameraFollowPart", p2)
		return
	end

	if v3 then
		return
	end

	local Mouselock = require(ReplicatedStorage.Libraries.Modules.Mouselock)
	Mouselock:PauseOffset(true)
	CameraHelper.StopTween()
	v.cameraResetConnection = nil
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	CurrentCamera.CFrame = p2.CFrame

	RunService.Heartbeat:Connect(function()
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		CurrentCamera.CFrame = p2.CFrame
	end)
end

function CameraHelper.Lock(_, flag: boolean)
	v3 = flag
end

return CameraHelper