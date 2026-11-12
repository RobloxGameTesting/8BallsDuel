local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.Classes.Animations)

local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Pets = require(ReplicatedStorage.Libraries.GameSpecific.Pets)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local PetHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetHelpers)
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)
local parentModule2 = require(script.Parent.Parent)

local function pickWanderTarget(position: Vector3, filterDescendantsInstances, p: number, radius)
	for _ = 1, p do
		local integer = Random.new():NextInteger(radius.min, radius.max)
		local randomPointAround = VectorHelper.RandomPointAround(position, integer)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances

		local v = randomPointAround + Vector3.new(0, 30, 0)
		local raycastResult = workspace:Raycast(v, Vector3.new(0, -200, 0), raycastParams)

		if raycastResult then
			return raycastResult.Position
		end
	end

	return Vector3.new(0, 0, 0)
end

local Wander = {}
Wander.name = "Wander"

function Wander.Enter(p)
	local pet = parentModule.GetPetFromStateMachine(p)
	local module = PetHelpers.GetModule(pet)
	local playerByUserId = pet.ownerId and Players:GetPlayerByUserId((tonumber(pet.ownerId)))
	local character = playerByUserId and playerByUserId.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	local status = p.stateContext.status
	status.wanderElapsed = 0

	local primaryPart = pet.model and pet.model.PrimaryPart

	if not (pet.model and primaryPart) then
		status.wanderTarget = nil
		return
	end

	ModelHelper.SetNetworkOwner(pet.model, nil)

	local position = humanoidRootPart and humanoidRootPart.Position or Pets.GetCFrame(pet).Position
	status.wanderAnchor = position

	local wanderTarget = pickWanderTarget(position, { pet.model, character }, 10, module.configuration.radius) + Vector3.new(0, pet.size.Y / 2, 0)
	status.wanderTarget = wanderTarget

	local cframe = Pets.GetCFrame(pet)
	local magnitude = (cframe.Position - wanderTarget).Magnitude
	local lookVector = CFrame.new(cframe.Position, wanderTarget).LookVector
	status.wanderMaxTime = math.min(magnitude / module.configuration.walkSpeed, 6)

	Pets.SetCFrame(pet, CFrame.new(cframe.Position, cframe.Position + lookVector), 0, true)
	Pets.SetCFrame(
		pet,
		CFrame.new(wanderTarget, wanderTarget + lookVector),
		magnitude / module.configuration.walkSpeed,
		true
	)
	Pets.SetAnimation(pet, {
		{ animation = "walk", looped = true }
	})

	Pets.SetState(pet, "Wander")
end

function Wander.Exit(p)
	parentModule.GetPetFromStateMachine(p)
	local status = p.stateContext.status

	status.wanderElapsed = nil
	status.wanderMaxTime = nil
end

function Wander.Update(p, p2: number)
	local pet = parentModule.GetPetFromStateMachine(p)
	local status = p.stateContext.status
	local playerByUserId = pet.ownerId and Players:GetPlayerByUserId((tonumber(pet.ownerId)))
	local character = playerByUserId and playerByUserId.Character

	if character then
		character:FindFirstChild("HumanoidRootPart")
	end

	status.wanderElapsed += p2

	if status.wanderElapsed >= status.wanderMaxTime then
	end

	return parentModule2.FindNextState(p)
end

return Wander