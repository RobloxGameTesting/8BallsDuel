local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Chase = {}
Chase.name = "Chase"

function Chase.Enter(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local animations = enemyById.animations
	ModelHelper.SetNetworkOwner(enemyById.model, nil)
	local humanoid = enemyById.model and enemyById.model:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	Animations.Play(animations, {
		{ animation = "walk", looped = true }
	})
end

function Chase.Exit(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local animations = enemyById.animations

	Animations.Stop(animations)
	Enemies.StopPathfinding(enemyById)
end

function Chase.Update(p, _: number)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)

	if EnemyHelpers.IsDead(enemyById) then
		return "Died"
	end

	local model = enemyById.model
	model:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
	local animations = enemyById.animations

	local v = CharacterHelper.GetClosestCharacter(humanoidRootPart.Position, true)[1]
	EnemyHelpers.GetModule(enemyById)

	local v2 = v and CharacterHelper.GetPredictedPosition(v.character)

	if v2 then
		Enemies.StartPathfinding(enemyById, v2)

		local sequence = Animations.GetSequence(animations)

		if not sequence or not sequence.sequence[1] or sequence.sequence[1].animation ~= "walk" then
			Animations.Play(animations, {
				{ animation = "walk", looped = true }
			})
		end
	end

	return parentModule.FindNextState(p)
end

return Chase