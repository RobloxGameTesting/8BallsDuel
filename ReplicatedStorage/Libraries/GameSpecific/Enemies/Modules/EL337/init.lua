local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local EL337 = {
	places = { 97585580559722 },
	wave = -1,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies.EL337.AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies.EL337.BodyHitbox,
	maxHealth = 5000,
	walkSpeed = 10,
	hipHeight = 13.1,
	chance = 0,
	class = "Boss",
	canKnockback = false,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 16743501838, walk = 16743499943 },
	overlapAnimations = { attack = 16772217324, shoot = 16743497120, jump = 17074923629 },
	sounds = {
		shoot = {
			id = { "Golem", "Shoot" },
			parent = { "Minigun", "Origin" }
		},
		eye = {
			id = { "Golem", "Eye" },
			parent = { "Meshes", "H", "Origin" }
		},
		attack = {
			id = { "Golem", "Land" },
			parent = { "Meshes", "Land" }
		},
		died = {
			id = { "Enemies", "Died4" },
			parent = { "Head" }
		}
	},
	visuals = {
		shoot = {
			id = { "Golem", "Shoot" },
			parent = { "Minigun", "Origin" }
		},
		smoke = {
			id = { "Golem", "Smoke" },
			parent = { "Minigun", "Origin" }
		},
		rightStomp = {
			id = { "Golem", "Stomp" },
			parent = { "Meshes", "RL", "Origin" }
		},
		leftStomp = {
			id = { "Golem", "Stomp" },
			parent = { "Meshes", "LL", "Origin" }
		},
		attack = {
			id = { "Golem", "Land" },
			parent = { "Meshes", "Land" }
		},
		eye = {
			id = { "Golem", "Eye" },
			parent = { "Meshes", "H", "Origin" }
		}
	},
	money = 500,
	currency1 = 10,
	currency2 = 3,
	experience = 50,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		chaseStopRange = 50,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 4,
			delay = 0.7,
			damage = 8,
			knockbackInfo = { distance = 30, speed = 100 }
		},
		pathfinding = {
			rate = 0.5,
			agentParameters = {
				AgentRadius = 5,
				AgentHeight = 20,
				AgentCanJump = true,
				AgentCanClimb = true,
				WaypointSpacing = 1,
				Costs = { Avoid = 1e999 }
			}
		},
		bulletSpray = {
			{
				count = 1,
				status = "Cooldown",
				cooldown = 3,
				origin = { "Meshes", "JumpOrigin" },
				flat = true,
				down = false,
				noTarget = false,
				spread = { min = -0, max = 0 },
				spreadY = { min = -0, max = 0 },
				pattern = {}
			},
			{
				count = 50,
				status = "Minigun",
				cooldown = 0.15,
				origin = { "Minigun", "Origin" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -20, max = 20 },
				spreadY = { min = -3, max = 10 },
				pattern = {
					{ class = "Bullet", bullet = "Enemy", angle = 0 }
				}
			},
			{
				count = 1,
				status = "Cooldown",
				cooldown = 2,
				origin = { "Meshes", "JumpOrigin" },
				flat = true,
				down = false,
				noTarget = false,
				spread = { min = -0, max = 0 },
				spreadY = { min = -0, max = 0 },
				pattern = {}
			},
			{
				count = 1,
				status = "Jump",
				cooldown = 3,
				origin = { "Meshes", "JumpOrigin" },
				flat = true,
				down = false,
				noTarget = false,
				spread = { min = -0, max = 0 },
				spreadY = { min = -0, max = 0 },
				pattern = {}
			},
			{
				count = 1,
				status = "Jump",
				cooldown = 0.7,
				origin = { "Meshes", "JumpOrigin" },
				flat = true,
				down = false,
				noTarget = false,
				spread = { min = -0, max = 0 },
				spreadY = { min = -0, max = 0 },
				pattern = {}
			},
			{
				count = 3,
				status = "Jump",
				cooldown = 0.5,
				origin = { "Meshes", "JumpOrigin" },
				flat = true,
				down = false,
				noTarget = false,
				spread = { min = -0, max = 0 },
				spreadY = { min = -0, max = 0 },
				pattern = {
					{ class = "Bullet", bullet = "Enemy", angle = 0 },
					{ class = "Bullet", bullet = "Enemy", angle = 10 },
					{ class = "Bullet", bullet = "Enemy", angle = 20 },
					{ class = "Bullet", bullet = "Enemy", angle = 30 },
					{ class = "Bullet", bullet = "Enemy", angle = 40 },
					{ class = "Bullet", bullet = "Enemy", angle = 50 },
					{ class = "Bullet", bullet = "Enemy", angle = 60 },
					{ class = "Bullet", bullet = "Enemy", angle = 70 },
					{ class = "Bullet", bullet = "Enemy", angle = 80 },
					{ class = "Bullet", bullet = "Enemy", angle = 90 },
					{ class = "Bullet", bullet = "Enemy", angle = 100 },
					{ class = "Bullet", bullet = "Enemy", angle = 110 },
					{ class = "Bullet", bullet = "Enemy", angle = 120 },
					{ class = "Bullet", bullet = "Enemy", angle = 130 },
					{ class = "Bullet", bullet = "Enemy", angle = 140 },
					{ class = "Bullet", bullet = "Enemy", angle = 150 },
					{ class = "Bullet", bullet = "Enemy", angle = 160 },
					{ class = "Bullet", bullet = "Enemy", angle = 170 },
					{ class = "Bullet", bullet = "Enemy", angle = 180 },
					{ class = "Bullet", bullet = "Enemy", angle = 190 },
					{ class = "Bullet", bullet = "Enemy", angle = 200 },
					{ class = "Bullet", bullet = "Enemy", angle = 210 },
					{ class = "Bullet", bullet = "Enemy", angle = 220 },
					{ class = "Bullet", bullet = "Enemy", angle = 230 },
					{ class = "Bullet", bullet = "Enemy", angle = 240 },
					{ class = "Bullet", bullet = "Enemy", angle = 250 },
					{ class = "Bullet", bullet = "Enemy", angle = 260 },
					{ class = "Bullet", bullet = "Enemy", angle = 270 },
					{ class = "Bullet", bullet = "Enemy", angle = 280 },
					{ class = "Bullet", bullet = "Enemy", angle = 290 },
					{ class = "Bullet", bullet = "Enemy", angle = 300 },
					{ class = "Bullet", bullet = "Enemy", angle = 310 },
					{ class = "Bullet", bullet = "Enemy", angle = 320 },
					{ class = "Bullet", bullet = "Enemy", angle = 330 },
					{ class = "Bullet", bullet = "Enemy", angle = 340 },
					{ class = "Bullet", bullet = "Enemy", angle = 350 }
				}
			}
		}
	}
}

for i, child in EnemyAssets.Enemies.EL337.Variations:GetChildren(), nil, nil do
	table.insert(EL337.instances, child)

	if i == 1 then
		EL337.boundingBox = child:GetExtentsSize()
	end
end

return EL337