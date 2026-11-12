local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local RunService = game:GetService("RunService")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.Modules.Device)
local Collisions = require(ReplicatedStorage.Libraries.Modules.Collisions)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Animations)

local isServer = RunService:IsServer()
local Assets = ReplicatedStorage.Assets
local Modules = script.Parent.Modules
local Cylinder = Assets.EnemyAssets.Cylinder

local EnemyHelpers = {}

function EnemyHelpers.GetModuleScript(p)
	return (Modules:FindFirstChild(p.npc))
end

function EnemyHelpers.GetFunctionsModule(p)
	local moduleScript = EnemyHelpers.GetModuleScript(p)
	local functions = moduleScript and moduleScript:FindFirstChild("Functions")

	local module = require(functions)

	return module
end

function EnemyHelpers.GetModule(p)
	local moduleScript = EnemyHelpers.GetModuleScript(p)
	local module = require(moduleScript)

	return module
end

function EnemyHelpers.IsDead(p): boolean
	local model = p.model
	local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")

	if p.health <= 0 or not model or not model.PrimaryPart then
		return true
	end

	return not humanoid or not humanoidRootPart or not humanoidRootPart:IsA("BasePart")
end

function EnemyHelpers.onCreate(p)
	if isServer then
		local module = EnemyHelpers.GetModule(p)
		local clone = Cylinder:Clone()
		local v = module.boundingBox.X + 1
		clone.Size = Vector3.new(0.1, v, v)

		local model = p.model
		local primaryPart = model and model.PrimaryPart

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Map }

		clone.Position = workspace:Raycast(
			model:GetPivot().Position + Vector3.new(0, 50, 0),
			Vector3.new(0, -100, 0),
			raycastParams
		).Position
		clone.Parent = workspace

		if primaryPart and model then
			task.spawn(function()
				primaryPart.Anchored = true
				ModelHelper:CFrame(
					model,
					model:GetPivot() * CFrame.new(0, 2 + module.boundingBox.Y + module.hipHeight, 0),
					TweenInfo.new(2.5)
				)

				task.wait(3.3)
				clone:Destroy()

				if primaryPart then
					primaryPart.Anchored = false
				end
			end)
		end
	end
end

function EnemyHelpers.onDestroy(data)
	if isServer then
		Sounds.Play(data.sounds.died, nil, false)
	else
		data.maid.hitMaid = nil

		if data.model and data.model:IsDescendantOf(workspace) then
			local hitbox = data.model:FindFirstChild("Hitbox")

			if hitbox then
				hitbox:Destroy()
			end

			local clone = data.model:Clone()
			local primaryPart = clone.PrimaryPart
			local humanoid = clone:FindFirstChildWhichIsA("Humanoid")
			primaryPart:Destroy()
			Collisions:AddToGroup(clone, "Ragdoll")
			clone.Parent = workspace.Contents.Ragdolls

			for _, descendant in clone:GetDescendants(), nil, nil do
				if descendant:IsA("Motor6D") then
					descendant.Enabled = false
				elseif descendant:IsA("BasePart") then
					descendant.CanCollide = true
					descendant.Anchored = false
					descendant.CanQuery = false
					descendant.CanTouch = false
				elseif descendant:IsA("BillboardGui") then
					descendant:Destroy()
				end
			end

			humanoid.PlatformStand = true

			local vectorForce = Instance.new("VectorForce")
			local attachment = Instance.new("Attachment")
			vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
			vectorForce.Attachment0 = attachment
			vectorForce.Force = ModelHelper.GetMass(clone) * Vector3.new(
				Random.new():NextInteger(-200, 200),
				Random.new():NextInteger(-200, 200),
				Random.new():NextInteger(-200, 200)
			)

			vectorForce.Parent = attachment
			attachment.Parent = clone:FindFirstChildWhichIsA("BasePart")

			task.spawn(function()
				task.wait(0.1)
				attachment:Destroy()
			end)

			task.spawn(function()
				task.wait(5)
				clone:Destroy()
			end)

			return clone
		end
	end

	return nil
end

return EnemyHelpers