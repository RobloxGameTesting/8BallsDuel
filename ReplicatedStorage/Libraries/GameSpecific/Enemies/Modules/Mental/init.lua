local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Mental = {
	places = { 97585580559722 },
	wave = 14,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Mental.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Mental.BodyHitbox,
	maxHealth = 900,
	walkSpeed = 55,
	hipHeight = 2.6,
	chance = 3,
	class = "Special",
	canKnockback = false,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 114677107773751, walk = 114781452271915 },
	overlapAnimations = { attack = 80234998148596, coverEyeIdle = 135907198944010 },
	sounds = {
		attack = {
			id = { "Enemies", "Attack20" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 30,
	currency1 = 4,
	currency2 = 1,
	experience = 10,
	enemyConfiguration = 0
}

local enemyConfiguration = {
	alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
	freezeRange = 1000,
	idleRange = 800,
	attackState = {
		hitboxArea = "Attack",
		cooldown = 1.5,
		delay = 0.5,
		damage = 15,
		knockbackInfo = { distance = 1, speed = 100 }
	},
	chaseStopRange = 1,
	pathfinding = 0
}

enemyConfiguration.alertRequirement = { requiresDamage = true }

enemyConfiguration.pathfinding = {
	rate = 0.1,
	agentParameters = {
		AgentRadius = 3,
		AgentHeight = 6.5,
		AgentCanJump = true,
		AgentCanClimb = true,
		WaypointSpacing = 4,
		Costs = { Avoid = 1e999 }
	}
}
Mental.enemyConfiguration = enemyConfiguration

for i, child in EnemyAssets.Enemies.Mental.Variations:GetChildren(), nil, nil do
	table.insert(Mental.instances, child)

	if i == 1 then
		Mental.boundingBox = child:GetExtentsSize()
	end
end

return Mental