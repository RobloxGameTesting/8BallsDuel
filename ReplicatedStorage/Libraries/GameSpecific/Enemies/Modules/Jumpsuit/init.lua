local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Jumpsuit = {
	places = { 97585580559722 },
	wave = -1,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Jumpsuit.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Jumpsuit.BodyHitbox,
	maxHealth = 30,
	walkSpeed = 25,
	hipHeight = 2,
	chance = 10,
	class = "Normal",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 117479621593957, walk = 83112056010217 },
	overlapAnimations = { attack = 76218684160580 },
	sounds = {
		attack = {
			id = { "Enemies", "Attack7" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 10,
	currency1 = 2,
	currency2 = 0,
	experience = 5,
	enemyConfiguration = {
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 2,
			delay = 0.6,
			damage = 5,
			knockbackInfo = { distance = 1, speed = 100 }
		},
		chaseStopRange = 2,
		pathfinding = {
			rate = 0.5,
			agentParameters = {
				AgentRadius = 2,
				AgentHeight = 6,
				AgentCanJump = true,
				AgentCanClimb = true,
				WaypointSpacing = 1,
				Costs = { Avoid = 1e999 }
			}
		}
	}
}

for i, child in EnemyAssets.Enemies.Jumpsuit.Variations:GetChildren(), nil, nil do
	table.insert(Jumpsuit.instances, child)

	if i == 1 then
		Jumpsuit.boundingBox = child:GetExtentsSize()
	end
end

return Jumpsuit