local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Charger = {
	places = { 97585580559722 },
	wave = 6,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Charger.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Charger.BodyHitbox,
	maxHealth = 500,
	walkSpeed = 10,
	hipHeight = 6.8,
	chance = 5,
	class = "Special",
	canKnockback = false,
	states = { "Freeze", "Idle", "Chase", "Attack", "Charge", "Died" },
	initialState = "Freeze",
	animations = { idle = 137110290784551, walk = 132814355621662, run = 109308919128682 },
	overlapAnimations = { attack = 124365390818291 },
	sounds = {
		attack = {
			id = { "Enemies", "ChargerPunch" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		},
		charge = {
			id = { "Enemies", "Charge" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 2500,
	currency1 = 5,
	currency2 = 1,
	experience = 20,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 2.5,
			delay = 0.55,
			damage = 5,
			knockbackInfo = { distance = 12, speed = 100 }
		},
		chargeState = {
			detectionHitboxArea = "Charge",
			hitboxArea = "Attack",
			damage = 5,
			knockbackInfo = { distance = 20, speed = 100 },
			cooldown = 12,
			walkSpeed = 30,
			runDistance = 69
		},
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		chaseStopRange = 7,
		pathfinding = {
			rate = 0.4,
			agentParameters = {
				AgentRadius = 4,
				AgentHeight = 11,
				AgentCanJump = true,
				AgentCanClimb = true,
				WaypointSpacing = 1,
				Costs = { Avoid = 1e999 }
			}
		}
	}
}

for i, child in EnemyAssets.Enemies.Charger.Variations:GetChildren(), nil, nil do
	table.insert(Charger.instances, child)

	if i == 1 then
		Charger.boundingBox = child:GetExtentsSize()
	end
end

return Charger