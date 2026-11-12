local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Crawler = {
	places = { 97585580559722 },
	wave = -1,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Crawler.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Crawler.BodyHitbox,
	maxHealth = 20,
	walkSpeed = 16,
	hipHeight = 2,
	chance = 10,
	class = "Normal",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 118495211258392, walk = 92459296152107 },
	overlapAnimations = { attack = 131619687978629 },
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
	money = 25,
	currency1 = 3,
	currency2 = 0,
	experience = 4,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 1.2,
			delay = 0.5,
			damage = 5,
			knockbackInfo = { distance = 1, speed = 100 }
		},
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		chaseStopRange = 0,
		pathfinding = {
			rate = 0.5,
			agentParameters = {
				AgentRadius = 2,
				AgentHeight = 3,
				AgentCanJump = true,
				AgentCanClimb = true,
				WaypointSpacing = 3,
				Costs = { Avoid = 1e999 }
			}
		}
	}
}

for i, child in EnemyAssets.Enemies.Crawler.Variations:GetChildren(), nil, nil do
	table.insert(Crawler.instances, child)

	if i == 1 then
		Crawler.boundingBox = child:GetExtentsSize()
	end
end

return Crawler