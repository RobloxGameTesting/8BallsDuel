local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local GraveDiggerZombie = {
	places = { 97585580559722 },
	wave = -1,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies["Grave Digger Zombie"].AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies["Grave Digger Zombie"].BodyHitbox,
	maxHealth = 20,
	walkSpeed = 18,
	hipHeight = 2,
	chance = 0,
	class = "Minion",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 130519760938695, walk = 100376295678322 },
	overlapAnimations = { attack = 105007795502900 },
	sounds = {
		attack = {
			id = { "Enemies", "Attack" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 20,
	currency1 = 1,
	currency2 = 0,
	experience = 2,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 2,
			delay = 0.65,
			damage = 5,
			knockbackInfo = { distance = 1, speed = 100 }
		},
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
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

for i, child in EnemyAssets.Enemies["Grave Digger Zombie"].Variations:GetChildren(), nil, nil do
	table.insert(GraveDiggerZombie.instances, child)

	if i == 1 then
		GraveDiggerZombie.boundingBox = child:GetExtentsSize()
	end
end

return GraveDiggerZombie