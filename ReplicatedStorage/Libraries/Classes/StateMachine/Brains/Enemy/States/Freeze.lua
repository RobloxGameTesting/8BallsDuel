local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Freeze = {}
Freeze.name = "Freeze"

function Freeze.Enter(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local model = enemyById.model
	ModelHelper.SetNetworkOwner(enemyById.model, nil)

	if model then
		ModelHelper:Properties(model, { Anchored = true })
	end
end

function Freeze.Exit(p)
	local model = Enemies._getEnemyById(p.stateContext.npcId).model

	if model then
		ModelHelper:Properties(model, { Anchored = false })
	end
end

function Freeze.Update(p, _: number)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)

	if EnemyHelpers.IsDead(enemyById) then
		return "Died"
	end

	EnemyHelpers.GetModule(enemyById)
	local humanoidRootPart = enemyById.model:FindFirstChild("HumanoidRootPart")
	CharacterHelper.GetClosestCharacter(humanoidRootPart.Position, true)

	return parentModule.FindNextState(p)
end

return Freeze