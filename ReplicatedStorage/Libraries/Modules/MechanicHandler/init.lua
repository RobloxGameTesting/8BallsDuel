local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Modules.Profiles)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
local Knockback = require(ReplicatedStorage.Libraries.Modules.Knockback)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
game:GetService("UserInputService")
local MechanicEvents = require(script.MechanicEvents)
local StarterPlayer = game:GetService("StarterPlayer")
local MechanicConstants = require(script.MechanicConstants)
local MobileHelper = require(ReplicatedStorage.Libraries.Helpers.MobileHelper)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local isServer = RunService:IsServer()
local v = Maid.new()
local v2 = Maid.new()

local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = true
local flag = false

local v8 = { dash = true, sprint = true, crouch = true, doubleJump = true }

local context = {
	cachedJump = nil,
	cachedWalk = nil,
	lastDash = 0,
	crouching = false,
	dashing = false,
	sprinting = false,
	index = 0
}

local SPRINT_STAMINA = MechanicConstants.SPRINT_STAMINA
local SPRINT_STAMINA2 = MechanicConstants.SPRINT_STAMINA
local flag2 = false

local MechanicHandler = {}

function MechanicHandler.Init()
	if not isServer then
		local localPlayer = Players.LocalPlayer
		local userId = tostring(localPlayer.UserId)
		local character = nil
		local humanoid = nil
		local animator = nil

		task.spawn(function()
			local function respawn()
				character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
				humanoid = character:WaitForChild("Humanoid")
				animator = humanoid:WaitForChild("Animator")

				v.inAirConnection = humanoid.StateChanged:Connect(function(_, p)
					if p == Enum.HumanoidStateType.Freefall or p == Enum.HumanoidStateType.Jumping then
						flag2 = true
					else
						flag2 = false
					end
				end)
			end

			respawn(localPlayer)

			local dash = humanoid.RigType == Enum.HumanoidRigType.R6 and 15329943194 or 119146893611853
			local sprint = humanoid.RigType == Enum.HumanoidRigType.R6 and 117744652135068 or 117195582811067
			local crouch = humanoid.RigType == Enum.HumanoidRigType.R6 and 84246387699591 or 126344859169195
			local jump = humanoid.RigType == Enum.HumanoidRigType.R6 and 9734192704 or 98182948291432

			v3 = Animations.new({ dash = dash }, animator)

			v4 = Animations.new({ sprint = sprint }, animator)

			v5 = Animations.new({ crouch = crouch }, animator)

			v6 = Animations.new({ jump = jump }, animator)

			v.characterAdded = localPlayer.CharacterAdded:Connect(function()
				respawn(localPlayer)
			end)

			if MechanicConstants.SPRINT_ON_INIT then
				MechanicHandler.Sprint(localPlayer, true)
			end

			local v9 = { "Knockback" }

			RemoteSignals.OnClientEvent("Knockback", function(p, p2, p3, p4)
				if not table.find(v9, p) then
					return
				end

				local character2 = localPlayer.Character
				local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					return
				end

				Knockback:Recoil(localPlayer, function()
					return humanoidRootPart.CFrame
				end, p2, p3, p4, {})
			end)
		end)

		local function setDowned() -- 1 equivalent call inferred from this helper
			if HealthHandler.IsDowned(userId) then
				return
			end

			if context.sprinting then
				MechanicHandler.Sprint(localPlayer, true)
			else
				MechanicHandler.Sprint(localPlayer, false)
			end
		end

		setDowned() -- inferred equivalent call
		localPlayer.CharacterAdded:Connect(setDowned)
		localPlayer:GetAttributeChangedSignal("IsDowned"):Connect(setDowned)
	end
end

function MechanicHandler.Dash(player, p: number, p2: number, vector3: Vector3)
	if not v8.dash or context.crouching then
		return
	end

	local v9 = p / p2

	tostring(player.UserId)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid) then
		return
	end

	if context.lastDash and tick() - context.lastDash < v9 + 0.1 then
		return
	end

	MechanicEvents.Dash:Fire(true)
	context.lastDash = tick()
	local v10 = Maid.new()
	local v11 = Knockback:Start(function()
		return humanoidRootPart.CFrame
	end, p, p2, vector3, true, { character, workspace.CurrentCamera })

	humanoid.AutoRotate = false
	Animations.Play(v3, {
		{ animation = "dash", speed = 1 }
	})

	Animations.Stop(v6)

	context.dashing = true

	v10.changeListener = v11:Connect(function(cframe)
		character:PivotTo(cframe)
	end)

	local v12 = { "WalkSpeed" }

	for _, v13 in v12 do
		CharacterHelper.SetHumanoidProperty(player, v13, 0)
	end

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

	local function stopDash()
		v10:Destroy()
		humanoid.AutoRotate = true
		context.dashing = false

		for _, v13 in v12 do
			v[v13] = nil
			CharacterHelper.ResetHumanoidProperty(player, v13)
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

		MechanicHandler.Sprint(player, context.sprinting)
		MechanicEvents.Dash:Fire(false)
	end

	local total = 0

	v10.stopConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if v9 <= total then
			stopDash()
		end
	end)

	local function applyDashMomentum()
		if vector3.Magnitude <= 0 then
			return
		end

		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		local v13 = Vector3.new(vector3.X, 0, vector3.Z).Unit * p2 * 1

		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(v13.X, assemblyLinearVelocity.Y, v13.Z) * 1.5
	end
end

function MechanicHandler.Crouch(player, crouching: boolean)
	if not v8.crouch or context.dashing then
		return
	end

	tostring(player.UserId)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid) then
		return
	end

	MechanicEvents.Crouch:Fire(crouching)
	context.crouching = crouching

	if crouching then
		if context.sprinting then
			MechanicHandler.Sprint(player, false)
		end

		for _, v9 in { "WalkSpeed" } do
			CharacterHelper.SetHumanoidProperty(player, v9, 10)
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		Animations.Play(v5, {
			{
				animation = "crouch",
				looped = true,
				speed = 0.8,
				priority = Enum.AnimationPriority.Action4
			}
		})

		v.crouchMoveConnection = RunService.Heartbeat:Connect(function()
			if humanoid.MoveDirection.Magnitude == 0 then
				Animations.AdjustSpeed(v5, 0)
			else
				Animations.AdjustSpeed(v5, 1)
			end
		end)
	else
		Animations.Stop(v5)
		CharacterHelper.ResetHumanoidProperty(player, "WalkSpeed")
		v.crouchMoveConnection = nil
		v.crouchWalkspeedConnection = nil
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end

	MechanicHandler.UpdateMobileButtons()
end

function MechanicHandler.DoubleJump(player)
	require(ReplicatedStorage.Libraries.Modules.Device)

	tostring(player.UserId)
	local character = player.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and v8.doubleJump) then
		return
	end

	if context.crouching or context.dashing then
		return
	end

	if flag then
		v2.fallConnection = nil
		v7 = false
		flag = false

		CharacterHelper.SetHumanoidProperty(player, "JumpHeight", MechanicConstants.DOUBLE_JUMP_HEIGHT)
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		Animations.Play(v6, {
			{
				animation = "jump",
				looped = false,
				speed = 1,
				priority = Enum.AnimationPriority.Action4
			}
		})
	end

	v2.jumpConnection = nil
	v2.stateChangeConnection = nil
	v2.fallConnection = nil

	v2.stateChangeConnection = humanoid.StateChanged:Connect(function(_, p)
		if (p == Enum.HumanoidStateType.Jumping or p == Enum.HumanoidStateType.Freefall) and v7 then
			CharacterHelper.ResetHumanoidProperty(player, "JumpHeight")

			local position = nil

			v2.fallConnection = RunService.Heartbeat:Connect(function()
				if position and (humanoidRootPart.Position - position).Y < 0.5 then
					flag = true
					v2.fallConnection = nil
				end

				position = humanoidRootPart.Position
			end)
		elseif p == Enum.HumanoidStateType.Landed or p == Enum.HumanoidStateType.Swimming then
			v7 = true
			flag = false
		end
	end)
end

function MechanicHandler.Sprint(player, flag3: boolean)
	tostring(player.UserId)
	local character = player.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return
	end

	local function canSprintFunction(): boolean -- 2 equivalent calls inferred from this helper
		if SPRINT_STAMINA == 0 then
			return false
		end

		return if v8.sprint then true else false
	end

	if flag3 then
		if context.crouching then
			MechanicHandler.Crouch(player, false)
		end

		v.characterAddedSprintConnection = player.CharacterAdded:Connect(function(_)
			MechanicHandler.Sprint(player, flag3)
		end)

		if not canSprintFunction() then -- inferred equivalent call
			MechanicHandler.Sprint(player, false)
			return
		end

		context.sprinting = true

		if context.dashing then
			return
		end

		local function playSprintAnimation()
			Animations.Play(v4, {
				{
					animation = "sprint",
					priority = Enum.AnimationPriority.Movement,
					looped = true,
					speed = 1
				}
			})
		end

		playSprintAnimation()
		TweenService:Create(humanoid, TweenInfo.new(0.2), {
			WalkSpeed = MechanicConstants.SPRINT_SPEED
		}):Play()

		v.sprintConnection = RunService.Heartbeat:Connect(function(dt: number)
			if not canSprintFunction() then -- inferred equivalent call
				MechanicHandler.Sprint(player, false)
				return
			end

			if flag2 then
				Animations.AdjustSpeed(v4, 0.5)
			else
				Animations.AdjustSpeed(v4, 1)
			end

			if humanoid.MoveDirection.Magnitude <= 0.1 then
				Animations.Stop(v4)

				SPRINT_STAMINA += dt
			else
				if not Animations.GetSequence(v4) then
					playSprintAnimation()
				end

				SPRINT_STAMINA -= dt
			end

			SPRINT_STAMINA = math.clamp(SPRINT_STAMINA, 0, SPRINT_STAMINA2)
		end)
	else
		v.characterAddedSprintConnection = nil
		context.sprinting = false

		if context.dashing then
			return
		end

		Animations.Stop(v4)
		TweenService:Create(humanoid, TweenInfo.new(0.2), {
			WalkSpeed = StarterPlayer.CharacterWalkSpeed
		}):Play()

		v.sprintConnection = RunService.Heartbeat:Connect(function(dt: number)
			SPRINT_STAMINA += dt
			SPRINT_STAMINA = math.clamp(SPRINT_STAMINA, 0, SPRINT_STAMINA2)
		end)
	end

	MechanicHandler.UpdateMobileButtons()
end

function MechanicHandler.IsDashing()
	return context.dashing
end

function MechanicHandler.CanDash(dash)
	tostring(Players.LocalPlayer.UserId)

	v8.dash = dash
end

function MechanicHandler.CanSprint(sprint)
	v8.sprint = sprint
end

function MechanicHandler.CanCrouch(crouch)
	tostring(Players.LocalPlayer.UserId)

	v8.crouch = crouch
end

function MechanicHandler.GetContext()
	return context
end

function MechanicHandler.UpdateMobileButtons()
	local button = MobileHelper:GetButton("sprint")
	local button2 = MobileHelper:GetButton("crouch")

	if button then
		if context.sprinting then
			button:Press()
		else
			button:Release()
		end
	end

	if button2 then
		if context.crouching then
			button2:Press()
		else
			button2:Release()
		end
	end
end

return MechanicHandler