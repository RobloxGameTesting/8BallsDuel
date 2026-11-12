local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Hypnotize = {
	places = { 97585580559722 },
	wave = 10,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Hypnotize.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Hypnotize.BodyHitbox,
	maxHealth = 100,
	walkSpeed = 20,
	hipHeight = 2,
	chance = 8,
	class = "Special",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Died" },
	initialState = "Freeze",
	animations = { idle = 133804244111529, walk = 96082434722338 },
	overlapAnimations = { attack = 72566916304868 },
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
	money = 500,
	currency1 = 3,
	currency2 = 0,
	experience = 5,
	enemyConfiguration = {
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 1,
			delay = 0.65,
			damage = 10,
			knockbackInfo = { distance = 1, speed = 100 }
		},
		chaseStopRange = 5,
		pathfinding = {
			rate = 0.1,
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

for i, child in EnemyAssets.Enemies.Hypnotize.Variations:GetChildren(), nil, nil do
	table.insert(Hypnotize.instances, child)

	if i == 1 then
		Hypnotize.boundingBox = child:GetExtentsSize()
	end
end

return Hypnotize