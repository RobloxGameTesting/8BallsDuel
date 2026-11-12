local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Pets = require(ReplicatedStorage.Libraries.GameSpecific.Pets)
require(ReplicatedStorage.Libraries.Modules.Probability)
local PetHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetHelpers)
require(ReplicatedStorage.Libraries.GameSpecific.Pets.PetTypes)
local Players = game:GetService("Players")
local parentModule2 = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local Spawn = {}
Spawn.name = "Load"

function Spawn.Enter(p)
	local pet = parentModule.GetPetFromStateMachine(p)
	local module = PetHelpers.GetModule(pet)
	local playerByUserId = pet.ownerId and Players:GetPlayerByUserId((tonumber(pet.ownerId)))
	local character = playerByUserId and playerByUserId.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and pet.model and character then
		local min = module.configuration.radius.min
		local max = module.configuration.radius.max
		local _ = Random.new():NextInteger(0, 1) == 1
		local _ = Random.new():NextInteger(0, 1) == 1
		local v = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
			0,
			math.rad((Random.new():NextInteger(0, 360))),
			0
		) * CFrame.new(Random.new():NextNumber(min, max), 0, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character, pet.model, workspace.Contents }

		local v2 = v.Position + Vector3.new(0, 25, 0)
		local raycastResult = workspace:Raycast(v2, Vector3.new(0, -300, 0), raycastParams)

		local v3 = v.Position

		if raycastResult then
			v3 = raycastResult.Position + Vector3.new(0, pet.size.Y / 2, 0)
		end

		ModelHelper.SetNetworkOwner(pet.model, nil)
		pet.model:PivotTo(CFrame.new(v3, v3 + humanoidRootPart.CFrame.LookVector))
		Pets.SetCFrame(pet, CFrame.new(v3, v3 + humanoidRootPart.CFrame.LookVector), 0, true)
	end
end

function Spawn.Exit(_) end

function Spawn.Update(p, _: number)
	return parentModule2.FindNextState(p)
end

return Spawn