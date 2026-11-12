local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
require(script.Parent.Parent)
local Died = {}
Died.name = "Died"

function Died.Enter(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local model = enemyById.model
	ModelHelper.SetNetworkOwner(enemyById.model, nil)

	if model then
		ModelHelper:Properties(model, { Anchored = true })
	end

	Sounds.Play(enemyById.sounds.died, nil, false)
end

function Died.Exit(_) end

function Died.Update(_, _: number): nil
	return nil
end

return Died