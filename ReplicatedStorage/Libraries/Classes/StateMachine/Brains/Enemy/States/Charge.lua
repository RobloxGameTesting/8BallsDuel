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
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Charge = {}
Charge.name = "Charge"

function Charge.Enter(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local model = enemyById.model
	local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")
	local animations = enemyById.animations
	local chargeState = EnemyHelpers.GetModule(enemyById).enemyConfiguration.chargeState
	ModelHelper.SetNetworkOwner(enemyById.model, nil)

	if chargeState and humanoid and humanoidRootPart then
		humanoid:MoveTo(humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * chargeState.runDistance)
		humanoid.WalkSpeed = chargeState.walkSpeed
		Animations.Play(animations, {
			{ animation = "run", looped = true }
		})

		Enemies.SetValue(enemyById, "damageStateActive", true)
		enemyById.damageCooldownReady.Charge = false
		Enemies.SetValue(enemyById, "damageCooldownReady", enemyById.damageCooldownReady)
		Enemies.Attack(enemyById, "Attack", true)

		task.spawn(function()
			task.wait(chargeState.runDistance / chargeState.walkSpeed)
			Enemies.SetValue(enemyById, "damageStateActive", false)
		end)
		task.spawn(function()
			task.wait(chargeState.cooldown)
			enemyById.damageCooldownReady.Charge = true
			Enemies.SetValue(enemyById, "damageCooldownReady", enemyById.damageCooldownReady)
		end)
	end
end

function Charge.Exit(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local model = enemyById.model
	local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")
	local animations = enemyById.animations
	local module = EnemyHelpers.GetModule(enemyById)

	if module.enemyConfiguration.chargeState and humanoid and humanoidRootPart then
		humanoid:MoveTo(humanoidRootPart.Position)
		humanoid.WalkSpeed = module.walkSpeed
		Animations.Stop(animations)
		Enemies.StopAttack(enemyById)
	end
end

function Charge.Update(p, _: number)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)

	if EnemyHelpers.IsDead(enemyById) then
		return "Died"
	end

	EnemyHelpers.GetModule(enemyById)
	EnemyHelpers.GetFunctionsModule(enemyById)
	local model = enemyById.model
	local _animations = enemyById.animations
	model:FindFirstChildWhichIsA("Humanoid")
	model:FindFirstChild("HumanoidRootPart")

	return parentModule.FindNextState(p)
end

return Charge