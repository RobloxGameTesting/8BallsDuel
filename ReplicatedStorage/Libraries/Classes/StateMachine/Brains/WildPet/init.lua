local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)
local parentModule = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local Pets = require(ReplicatedStorage.Libraries.GameSpecific.Pets)
local PetHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetHelpers)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)

local States = script.States

local WildPet = {}

function WildPet.Init(_) end

function WildPet.new(p)
	local petById = Pets._getPetById(p.stateContext.npcId)
	p.maid.petObjects = Maid.new()
	p.maid.petObjects[p.stateContext.npcId] = Maid.new()
	p.maid.petObjects[p.stateContext.npcId].pet = petById

	for _, childName in PetHelpers.GetModule(petById).states do
		local child = States:FindFirstChild(childName)

		if not child then
			continue
		end

		local addState = parentModule.AddState
		local module = require(child)
		addState(p, childName, module)
	end

	local owner = Pets.GetOwner(petById)

	if not owner then
		p.stateContext.status.distance = Vector3.new(0, 0, 0)
		return
	end

	local v = nil

	p.maid.petObjects[p.stateContext.npcId].moveDirConnection = RunService.Heartbeat:Connect(function(dt)
		local character = owner.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			p.stateContext.status.distance = Vector3.new(0, 0, 0)
			return
		end

		local zeroVector3 = VectorHelper.ZeroVector3(humanoidRootPart.Position)

		if not v then
			v = zeroVector3
		end

		local magnitude = (v - zeroVector3).Magnitude
		v = zeroVector3
		p.stateContext.status.distance = magnitude / dt
	end)
end

function WildPet.GetPetFromStateMachine(p)
	return p.maid.petObjects[p.stateContext.npcId].pet
end

function WildPet.CanIdle(p): boolean
	PetHelpers.GetModule(p)
	local _stateMachine = p.stateMachine

	return true
end

function WildPet.CanWander(p)
	PetHelpers.GetModule(p)
	local stateMachine = p.stateMachine
	local wanderElapsed = stateMachine.stateContext.status.wanderElapsed
	local wanderMaxTime = stateMachine.stateContext.status.wanderMaxTime
	local v = wanderElapsed and wanderMaxTime and wanderElapsed < wanderMaxTime

	return WildPet.CanIdle(p) and v
end

function WildPet.FindNextState(p): nil | string
	local pet = WildPet.GetPetFromStateMachine(p)
	local model = pet.model
	local primaryPart = model and model.PrimaryPart

	if not (model and primaryPart) then
		return nil
	end

	if WildPet.CanWander(pet) then
		return "Wander"
	end

	return if WildPet.CanIdle(pet) then "Idle" else nil
end

function WildPet.Clear(p)
	p.maid.petObjects[p.stateContext.npcId] = nil
end

return WildPet