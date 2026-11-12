local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Ghost = {
	places = {},
	wave = 999,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Ghost.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Ghost.BodyHitbox,
	maxHealth = 10,
	walkSpeed = 14,
	hipHeight = 2,
	chance = 10,
	class = "Special",
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
	visuals = {
		poof = {
			id = { "Enemies", "Ghost" },
			parent = { "Torso" }
		}
	},
	money = 10,
	currency1 = 3,
	currency2 = 0,
	experience = 5,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 2,
			delay = 0.65,
			damage = 4,
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

for i, child in EnemyAssets.Enemies.Ghost.Variations:GetChildren(), nil, nil do
	table.insert(Ghost.instances, child)

	if i == 1 then
		Ghost.boundingBox = child:GetExtentsSize()
	end
end

return Ghost