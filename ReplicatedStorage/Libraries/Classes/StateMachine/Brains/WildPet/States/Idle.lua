local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Pets = require(ReplicatedStorage.Libraries.GameSpecific.Pets)
local Probability = require(ReplicatedStorage.Libraries.Modules.Probability)
local PetHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetHelpers)
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)
local Players = game:GetService("Players")
local parentModule2 = require(script.Parent.Parent)
local Idle = {}
Idle.name = "Idle"

function Idle.Enter(p)
	local pet = parentModule.GetPetFromStateMachine(p)
	local module = PetHelpers.GetModule(pet)
	local playerByUserId = pet.ownerId and Players:GetPlayerByUserId((tonumber(pet.ownerId)))
	local character = playerByUserId and playerByUserId.Character

	if character then
		character:FindFirstChild("HumanoidRootPart")
	end

	ModelHelper.SetNetworkOwner(pet.model, nil)

	local status = p.stateContext.status
	status.idleTimer = 0
	status.nextIdleDecision = Random.new():NextNumber(2, 3)

	local v = {
		{ animation = "idle", looped = true }
	}

	local item = Probability.GetItem(module.configuration.idle.animations)

	if item ~= "None" then
		table.insert(v, 1, { animation = item, looped = false })
	end

	Pets.SetAnimation(pet, {
		{ animation = "idle", looped = true }
	})

	Pets.SetState(pet, "Idle")
end

function Idle.Exit(p)
	parentModule.GetPetFromStateMachine(p)
end

function Idle.Update(p, p2: number)
	local status = p.stateContext.status
	status.idleTimer += p2

	local nextState = parentModule2.FindNextState(p)

	if status.idleTimer < status.nextIdleDecision then
		return nextState
	end

	status.idleTimer = 0
	status.nextIdleDecision = Random.new():NextNumber(2, 3)

	if math.random() < 0.6 and nextState == "Idle" then
		return "Wander"
	end

	return nextState
end

return Idle