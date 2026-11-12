local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parentModule = require(script.Parent.Parent)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local PlayerHelpers = require(ReplicatedStorage.Libraries.Helpers.PlayerHelpers)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local States = script.States

local Enemy = {}

function Enemy.Init(_) end

function Enemy.new(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	p.maid.enemyObjects = Maid.new()
	p.maid.enemyObjects[p.stateContext.npcId] = Maid.new()
	p.maid.enemyObjects[p.stateContext.npcId].enemy = enemyById

	for _, childName in EnemyHelpers.GetModule(enemyById).states do
		local child = States:FindFirstChild(childName)

		if not child then
			continue
		end

		local addState = parentModule.AddState
		local module = require(child)
		addState(p, childName, module)
	end
end

function Enemy.GetEnemyFromStateMachine(p)
	return p.maid.enemyObjects[p.stateContext.npcId].enemy
end

function Enemy.CanFreeze(p, list)
	local module = EnemyHelpers.GetModule(p)
	local item = list[1]

	local damageStateActive = p.damageStateActive
	local v = item and item.distance >= module.enemyConfiguration.freezeRange

	if not item or v then
		return not damageStateActive
	end

	return v
end

function Enemy.CanIdle(data, list): boolean
	local module = EnemyHelpers.GetModule(data)
	local item = list[1]

	if not item then
		return false
	end

	local damageStateActive = data.damageStateActive
	local v = item.distance < module.enemyConfiguration.idleRange
	local v2 = item.distance <= module.enemyConfiguration.chaseStopRange
	local alerted = data.alerted

	if data.damageCooldownReady.Attack ~= nil then
		local _attack = data.damageCooldownReady.Attack
	end

	if v and not v2 then
		return not (alerted or damageStateActive)
	end

	return not damageStateActive
end

function Enemy.CanChase(data, list)
	local module = EnemyHelpers.GetModule(data)
	local item = list[1]

	if not item then
		return false
	end

	local attack = data.attackHitbox and data.attackHitbox:FindFirstChild("Attack")
	local v

	if attack then
		v = #data.hitboxActive[attack.Name] > 0
	else
		v = false
	end

	local damageStateActive = data.damageStateActive
	local _ = item.distance < module.enemyConfiguration.idleRange
	local v2 = item.distance > module.enemyConfiguration.chaseStopRange
	local alerted = data.alerted

	return not v and v2 and not damageStateActive and alerted
end

function Enemy.CanAttack(data, list)
	local item = list[1]
	local module = EnemyHelpers.GetModule(data)

	if not item then
		return false
	end

	local attack = data.attackHitbox and data.attackHitbox:FindFirstChild("Attack")
	local playersInHitbox = PlayerHelpers.GetPlayersInHitbox(attack)
	local v = false

	for _, v2 in playersInHitbox do
		local character = v2.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		tostring(v2.UserId)

		if not (humanoid and humanoid.Health <= 0) then
			v = true
			break
		end
	end

	local v2 = table.find(module.states, "Attack") and true or false
	local v3 = data.damageCooldownReady.Attack == nil or data.damageCooldownReady.Attack
	local damageStateActive = data.damageStateActive
	local alerted = data.alerted

	return v2 and v and v3 and not damageStateActive and alerted
end

function Enemy.CanCharge(data, list)
	local item = list[1]
	local module = EnemyHelpers.GetModule(data)

	if not item then
		return false
	end

	local chargeState = module.enemyConfiguration.chargeState

	if not chargeState then
		return false
	end

	local child = data.attackHitbox and data.attackHitbox:FindFirstChild(chargeState.detectionHitboxArea)
	local v

	if child then
		v = #data.hitboxActive[child.Name] > 0
	else
		v = false
	end

	local v2 = table.find(module.states, "Charge") and true or false
	local damageStateActive = data.damageStateActive
	local v3 = data.damageCooldownReady.Charge == nil or data.damageCooldownReady.Charge
	local alerted = data.alerted

	return v2 and v and v3 and not damageStateActive and alerted
end

function Enemy.FindNextState(p): nil | string
	local enemy = Enemy.GetEnemyFromStateMachine(p)
	local model = enemy.model
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")

	if not (model and humanoidRootPart) then
		return nil
	end

	local closestCharacter = CharacterHelper.GetClosestCharacter(humanoidRootPart.Position, true)

	if Enemy.CanFreeze(enemy, closestCharacter) then
		return "Freeze"
	end

	if Enemy.CanAttack(enemy, closestCharacter) then
		return "Attack"
	end

	if Enemy.CanIdle(enemy, closestCharacter) then
		return "Idle"
	end

	if Enemy.CanCharge(enemy, closestCharacter) then
		return "Charge"
	end

	if Enemy.CanChase(enemy, closestCharacter) then
		return "Chase"
	end

	return nil
end

function Enemy.Clear(p)
	p.maid.enemyObjects[p.stateContext.npcId] = nil
end

return Enemy