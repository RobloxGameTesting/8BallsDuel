local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
local parentModule = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local Attack = {}
Attack.name = "Attack"

function Attack.Enter(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local model = enemyById.model
	local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")
	local overlapAnimations = enemyById.overlapAnimations
	local module = EnemyHelpers.GetModule(enemyById)
	ModelHelper.SetNetworkOwner(enemyById.model, nil)

	if humanoid and humanoidRootPart then
		humanoid:MoveTo(humanoidRootPart.Position)
		Animations.Play(overlapAnimations, {
			{ animation = "attack", priority = Enum.AnimationPriority.Action4 }
		})

		Enemies.SetValue(enemyById, "damageStateActive", true)
		enemyById.damageCooldownReady.Attack = false
		Enemies.SetValue(enemyById, "damageCooldownReady", enemyById.damageCooldownReady)

		task.spawn(function()
			task.wait(module.enemyConfiguration.attackState.delay)
			Enemies.SetValue(enemyById, "damageStateActive", false)
			Enemies.Attack(enemyById, "Attack", false)
		end)
		task.spawn(function()
			task.wait(module.enemyConfiguration.attackState.cooldown)
			enemyById.damageCooldownReady.Attack = true
			Enemies.SetValue(enemyById, "damageCooldownReady", enemyById.damageCooldownReady)
		end)
	end
end

function Attack.Exit(p)
	local model = Enemies._getEnemyById(p.stateContext.npcId).model

	if model then
		model:FindFirstChildWhichIsA("Humanoid")
	end

	if model then
		model:FindFirstChild("HumanoidRootPart")
	end
end

function Attack.Update(p, _: number)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)

	if EnemyHelpers.IsDead(enemyById) then
		return "Died"
	end

	EnemyHelpers.GetModule(enemyById)
	EnemyHelpers.GetFunctionsModule(enemyById)
	local model = enemyById.model

	model:FindFirstChildWhichIsA("Humanoid")
	model:FindFirstChild("HumanoidRootPart")

	return parentModule.FindNextState(p)
end

return Attack