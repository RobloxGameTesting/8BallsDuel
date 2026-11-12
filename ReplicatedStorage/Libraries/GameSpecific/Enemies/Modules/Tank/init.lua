local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Tank = {
	places = { 97585580559722 },
	wave = 16,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Tank.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Tank.BodyHitbox,
	maxHealth = 2500,
	walkSpeed = 20,
	hipHeight = 10.4,
	chance = 2,
	class = "Special",
	canKnockback = false,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 80985003155198, walk = 87125640493150, run = 120109157635332 },
	overlapAnimations = { attack = 140544266118991, rockThrow = 94131037082519 },
	sounds = {
		spawn = {
			id = { "Enemies", "Spawn6" },
			parent = { "Head" }
		},
		attack = {
			id = { "Enemies", "Attack19" },
			parent = { "Head" }
		},
		grunt = {
			id = { "Enemies", "Attack17" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		},
		charge = {
			id = { "Enemies", "Spawn6" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 20000,
	currency1 = 15,
	currency2 = 2,
	experience = 15,
	enemyConfiguration = {
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 4,
			delay = 0.75,
			damage = 15,
			knockbackInfo = { distance = 15, speed = 100 }
		},
		chargeState = {
			detectionHitboxArea = "Charge",
			hitboxArea = "Attack",
			damage = 10,
			knockbackInfo = { distance = 40, speed = 100 },
			cooldown = 8,
			walkSpeed = 30,
			runDistance = 71
		},
		chaseStopRange = 5,
		pathfinding = {
			rate = 0.5,
			agentParameters = {
				AgentRadius = 6,
				AgentHeight = 14.5,
				AgentCanJump = true,
				AgentCanClimb = true,
				WaypointSpacing = 1,
				Costs = { Avoid = 1e999 }
			}
		},
		bulletSpray = {
			{
				count = 1,
				status = "Attack",
				cooldown = 0,
				origin = { "rock2_low" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {}
			},
			{
				count = 1,
				status = "Attack",
				cooldown = 2.5,
				origin = { "rock2_low" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {}
			},
			{
				count = 1,
				status = "Attack",
				cooldown = 0,
				origin = { "rock2_low" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -2, max = 2 },
				spreadY = { min = -5, max = 3 },
				pattern = {
					{ class = "Bullet", bullet = "EnemyRock", angle = 0 }
				}
			},
			{
				count = 1,
				status = "Idle",
				cooldown = 4,
				origin = { "rock2_low" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {}
			},
			{
				count = 1,
				status = "Idle",
				cooldown = 4,
				origin = { "rock2_low" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {}
			}
		}
	}
}

for i, child in EnemyAssets.Enemies.Tank.Variations:GetChildren(), nil, nil do
	table.insert(Tank.instances, child)

	if i == 1 then
		Tank.boundingBox = child:GetExtentsSize()
	end
end

return Tank