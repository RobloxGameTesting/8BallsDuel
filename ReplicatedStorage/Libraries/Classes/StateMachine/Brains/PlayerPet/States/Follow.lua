local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Players = game:GetService("Players")
local Pets = require(ReplicatedStorage.Libraries.GameSpecific.Pets)
require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
local parentModule2 = require(script.Parent.Parent)
local PetHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetHelpers)
local Follow = {}
Follow.name = "Follow"

function Follow.Enter(p)
	local pet = parentModule.GetPetFromStateMachine(p)

	local playerByUserId = pet.ownerId and Players:GetPlayerByUserId((tonumber(pet.ownerId)))
	local character = playerByUserId and playerByUserId.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local status = p.stateContext.status

	if humanoidRootPart and pet.model and pet.model.PrimaryPart then
		status.followOffsetWorld = Pets.GetCFrame(pet).Position - humanoidRootPart.Position
	else
		warn("No pet hrp or chr hrp")
		status.followOffsetWorld = Vector3.new(0, 0, -5)
	end

	ModelHelper.SetNetworkOwner(pet.model, nil)

	Pets.SetAnimation(pet, {
		{ animation = "walk", looped = true }
	})

	local playerByUserId2 = pet.ownerId and Players:GetPlayerByUserId((tonumber(pet.ownerId)))
	local character2 = playerByUserId2 and playerByUserId2.Character

	if character2 then
		character2:FindFirstChild("HumanoidRootPart")
	end

	local followOffsetWorld = status.followOffsetWorld

	local max = PetHelpers.GetModule(pet).configuration.radius.max

	if max < followOffsetWorld.Magnitude then
		followOffsetWorld = followOffsetWorld.Unit * max
		status.followOffsetWorld = followOffsetWorld
	end

	Pets.SetPositionOffset(pet, followOffsetWorld)
	Pets.SetState(pet, "Follow")
end

function Follow.Exit(p)
	parentModule.GetPetFromStateMachine(p)
end

function Follow.Update(p, _: number)
	local pet = parentModule.GetPetFromStateMachine(p)
	local _status = p.stateContext.status

	local playerByUserId = pet.ownerId and Players:GetPlayerByUserId((tonumber(pet.ownerId)))
	local character = playerByUserId and playerByUserId.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (character and humanoidRootPart and pet.model and pet.model.PrimaryPart) then
		return "Spawn"
	end

	local v = humanoidRootPart.Position + pet.offsetWorld

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character, pet.model }

	local v2 = v + Vector3.new(0, 25, 0)
	local raycastResult = workspace:Raycast(v2, Vector3.new(0, -300, 0), raycastParams)

	if raycastResult then
		v = raycastResult.Position
	end

	local v3

	if (Pets.GetCFrame(pet).Position - v).Magnitude < 0.0001 then
		v3 = humanoidRootPart.CFrame.LookVector
	else
		v3 = CFrame.new(Pets.GetCFrame(pet).Position, v).LookVector
	end

	local cframe = CFrame.new(v, v + v3)

	Pets.SetCFrame(pet, cframe, 0.1, false)
	return parentModule2.FindNextState(p)
end

return Follow