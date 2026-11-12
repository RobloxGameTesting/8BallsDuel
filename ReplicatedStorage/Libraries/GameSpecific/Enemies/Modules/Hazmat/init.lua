local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local Hazmat = {
	places = { 97585580559722 },
	wave = 4,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.Hazmat.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.Hazmat.BodyHitbox,
	maxHealth = 100,
	walkSpeed = 18,
	hipHeight = 2,
	chance = 12,
	class = "Special",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 85304642482290, walk = 97911528045838 },
	overlapAnimations = { attack = 103858221175767, spray = 99782059717220 },
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
	money = 5000,
	currency1 = 3,
	currency2 = 0,
	experience = 5,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		chaseStopRange = 30,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 5,
			delay = 0.35,
			damage = 4,
			knockbackInfo = { distance = 5, speed = 100 }
		},
		pathfinding = {
			rate = 2,
			agentParameters = {
				AgentRadius = 2,
				AgentHeight = 6,
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
				origin = { "Backpack", "Spray", "Neon" },
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
				cooldown = 1,
				origin = { "Backpack", "Spray", "Neon" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {}
			},
			{
				count = 4,
				status = "Attack",
				cooldown = 0.1,
				origin = { "Backpack", "Spray", "Neon" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {
					{ class = "Bullet", bullet = "EnemySmall", angle = 0 }
				}
			},
			{
				count = 1,
				status = "Idle",
				cooldown = 0,
				origin = { "Backpack", "Spray", "Neon" },
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
				origin = { "Backpack", "Spray", "Neon" },
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

for i, child in EnemyAssets.Enemies.Hazmat.Variations:GetChildren(), nil, nil do
	table.insert(Hazmat.instances, child)

	if i == 1 then
		Hazmat.boundingBox = child:GetExtentsSize()
	end
end

return Hazmat