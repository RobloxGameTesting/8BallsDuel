local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Miner = {
	places = {},
	wave = -1,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Miner.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Miner.BodyHitbox,
	maxHealth = 30,
	walkSpeed = 18,
	hipHeight = 2,
	chance = 10,
	class = "Normal",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 111079991791339, walk = 95906721467789 },
	overlapAnimations = { attack = 125034097127006 },
	sounds = {
		attack = {
			id = { "Enemies", "Attack17" },
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
			delay = 0.55,
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

for i, child in EnemyAssets.Enemies.Miner.Variations:GetChildren(), nil, nil do
	table.insert(Miner.instances, child)

	if i == 1 then
		Miner.boundingBox = child:GetExtentsSize()
	end
end

return Miner