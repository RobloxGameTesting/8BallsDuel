local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()

local v = { "CharacterModelUpdate" }

local Angles = CFrame.Angles
local asin = math.asin
local atan = math.atan

local CharacterUpdate = {}

function CharacterUpdate.Init()
	if isServer then
		RemoteSignals.OnServerEvent("CharacterUpdate", function(player, p, p2, p3, p4, p5, p6)
			if not (table.find(v, p) and player.Character) then
				return
			end

			local userId = player and tostring(player.UserId)

			for _, v2 in Players:GetPlayers(), nil, nil do
				if tostring(v2.UserId) ~= userId then
					RemoteSignals.FireClient(v2, "CharacterUpdate", "CharacterModelUpdate", player, p2, p3, p4, p5, p6)
				end
			end
		end)
		return
	end

	local localPlayer = Players.LocalPlayer
	local userId = tostring(localPlayer.UserId)

	local currentCamera = nil
	local character = nil
	local head = nil
	local humanoid = nil
	local humanoidRootPart = nil
	local torso = nil
	local neck = nil
	local c0 = nil

	local function update()
		currentCamera = workspace.CurrentCamera
		character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		humanoid = character:WaitForChild("Humanoid")

		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			return
		end

		head = character:WaitForChild("Head")
		humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		torso = character:WaitForChild("Torso")
		neck = torso:WaitForChild("Neck")
		c0 = neck.C0

		character:WaitForChild("Right Arm")
		character:WaitForChild("Left Arm")
	end

	update()
	localPlayer.CharacterAdded:Connect(update)

	RemoteSignals.OnClientEvent("CharacterUpdate", function(p, p2, p3, p4, p5, p6, p7)
		if not table.find(v, p) then
			return
		end

		CharacterUpdate.Position(p2, p3, p4, p5, p6, p7)
	end)

	Scheduler.BindHeartbeat(function()
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			return
		end

		local cframe = currentCamera.CFrame
		local position = localPlayer:GetMouse().Origin.Position

		local health = HealthHandler.GetHealth(userId)

		if health and health > 0 then
			CharacterUpdate.Position(localPlayer, cframe, 0, 1, 0.5, position)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(1 / 30)
			local health = HealthHandler.GetHealth(userId)

			if not (health and health > 0) then
				continue
			end

			local cframe = currentCamera.CFrame
			local position = localPlayer:GetMouse().Origin.Position

			RemoteSignals.FireServer("CharacterUpdate", "CharacterModelUpdate", cframe, 0, 1, 0.5, position)
		end
	end)
end

function CharacterUpdate.Position(player, cframe: CFrame, p: number, p2: number, p3: number, vector3: Vector3)
	if not (cframe and p and p2 and p3) then
		return
	end

	if not vector3 then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")
	local leftArm = character:FindFirstChild("Left Arm")
	local rightArm = character:FindFirstChild("Right Arm")
	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("Torso")
	local neck = torso:FindFirstChild("Neck")

	if neck then
		local _c0 = neck.C0
	end

	local rightShoulder = torso:FindFirstChild("Right Shoulder")
	local _c1 = rightShoulder.C1
	local leftShoulder = torso:FindFirstChild("Left Shoulder")
	local _c1_2 = leftShoulder.C1

	if not (head and leftArm and rightArm and humanoid) then
		return
	end

	if not (humanoidRootPart and torso and rightShoulder and leftShoulder) then
		return
	end

	if humanoid.Health > 0 then
		local _magnitude = (head.CFrame.Position - cframe.Position).Magnitude
		local _ = head.CFrame.Y - cframe.Y

		local _position = head.CFrame.Position

		local _position2 = leftArm.CFrame.Position

		local _position3 = rightArm.CFrame.Position

		local _lookVector = humanoidRootPart.CFrame.LookVector

		local v2 = -math.asin((vector3 - cframe.Position).Unit.Y) * -1

		local _, v3, v4 = neck.C0:ToEulerAnglesXYZ()
		neck.C0 = CFrame.new(neck.C0.Position) * CFrame.Angles(v2 - 1.5, v3, v4)

		local _, v5, v6 = rightShoulder.C0:ToEulerAnglesXYZ()
		local _c0 = rightShoulder.C0
		rightShoulder.C0 = CFrame.new(rightShoulder.C0.Position) * CFrame.Angles(v2, v5, v6)

		local _, v7, v8 = leftShoulder.C0:ToEulerAnglesXYZ()
		leftShoulder.C0 = CFrame.new(leftShoulder.C0.Position) * CFrame.Angles(v2, v7, v8)
	end
end

return CharacterUpdate