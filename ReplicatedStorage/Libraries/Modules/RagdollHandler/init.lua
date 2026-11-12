local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local buildRagdoll = require(script.buildRagdoll)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)

local isServer = RunService:IsServer()

local set = { [Enum.HumanoidStateType.Dead] = true, [Enum.HumanoidStateType.Physics] = true }

return {
	Init = function()
		if isServer then
			local function initCharacter(_, instance)
				task.wait(0.1)
				local humanoid = instance:WaitForChild("Humanoid")
				local v = nil

				if humanoid.RigType == Enum.HumanoidRigType.R15 then
					v = instance:WaitForChild("LowerTorso"):WaitForChild("Root")
				elseif humanoid.RigType == Enum.HumanoidRigType.R6 then
					v = instance:WaitForChild("HumanoidRootPart"):WaitForChild("RootJoint")
				end

				buildRagdoll(humanoid)

				v:GetPropertyChangedSignal("Parent"):Connect(function()
					if v.Parent then
						return
					end

					humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end)
			end

			local function playerAdded(player) -- 1 equivalent call inferred from this helper
				player.CharacterAdded:connect(function(p)
					initCharacter(player, p)
				end)

				if player.Character then
					initCharacter(player, player.Character)
				end
			end

			Players.PlayerAdded:connect(playerAdded)

			for _, v in pairs(Players:GetPlayers()) do
				playerAdded(v) -- inferred equivalent call
			end
		else
			local localPlayer = Players.LocalPlayer

			local function initCharacter(instance)
				local humanoid = instance:WaitForChild("Humanoid")
				local v = nil

				if humanoid.RigType == Enum.HumanoidRigType.R15 then
					v = instance:WaitForChild("LowerTorso"):WaitForChild("Root")
				elseif humanoid.RigType == Enum.HumanoidRigType.R6 then
					v = instance:WaitForChild("HumanoidRootPart"):WaitForChild("RootJoint")
				end

				v:GetPropertyChangedSignal("Parent"):Connect(function()
					if v.Parent then
						return
					end

					humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				end)
			end

			initCharacter(localPlayer.Character or localPlayer.CharacterAdded:Wait())
			localPlayer.CharacterAdded:connect(function(p)
				initCharacter(p)
			end)
		end

		local v = {}

		local function setRagdollEnabled(p, p2)
			local ragdollConstraints = p.Parent:WaitForChild("RagdollConstraints")

			for _, constraint in pairs(ragdollConstraints:GetChildren()) do
				if not constraint:IsA("Constraint") then
					continue
				end

				local value = constraint.RigidJoint.Value
				local parent

				if not p2 then
					parent = constraint.Attachment1.Parent or nil
				end

				if value and value.Part1 ~= parent then
					value.Part1 = parent
				end
			end
		end

		local function hasRagdollOwnership(p): boolean -- 1 equivalent call inferred from this helper
			if RunService:IsServer() then
				return true
			end

			return Players:GetPlayerFromCharacter(p.Parent) == Players.LocalPlayer
		end

		local function ragdollAdded(p) -- 1 equivalent call inferred from this helper
			v[p] = p.StateChanged:Connect(function(_, p2)
				if hasRagdollOwnership(p) then -- inferred equivalent call
					if set[p2] then
						setRagdollEnabled(p, true)
					else
						setRagdollEnabled(p, false)
					end
				end
			end)
		end

		local function ragdollRemoved(p)
			v[p]:Disconnect()
			v[p] = nil
		end

		CollectionService:GetInstanceAddedSignal("Ragdoll"):Connect(ragdollAdded)
		CollectionService:GetInstanceRemovedSignal("Ragdoll"):Connect(ragdollRemoved)

		for _, v2 in pairs(CollectionService:GetTagged("Ragdoll")) do
			ragdollAdded(v2) -- inferred equivalent call
		end
	end
}