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
game:GetService("Players")
local parentModule2 = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local Spawn = {}
Spawn.name = "Load"

function Spawn.Enter(p)
	local pet = parentModule.GetPetFromStateMachine(p)
	local module = PetHelpers.GetModule(pet)

	if pet.model then
		local _min = module.configuration.radius.min
		local _max = module.configuration.radius.max
		local _ = Random.new():NextInteger(0, 1) == 1
		local _ = Random.new():NextInteger(0, 1) == 1
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { pet.model, workspace.Contents }

		local v = pet.cframe.Position + Vector3.new(0, 25, 0)
		local raycastResult = workspace:Raycast(v, Vector3.new(0, -300, 0), raycastParams)

		local v2 = pet.cframe.Position

		if raycastResult then
			v2 = raycastResult.Position + Vector3.new(0, pet.size.Y / 2, 0)
		end

		ModelHelper.SetNetworkOwner(pet.model, nil)
		pet.model:PivotTo(CFrame.new(v2))
		Pets.SetCFrame(pet, CFrame.new(v2), 0, true)
	end
end

function Spawn.Exit(_) end

function Spawn.Update(p, _: number)
	return parentModule2.FindNextState(p)
end

return Spawn