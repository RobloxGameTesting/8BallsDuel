local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local GraveDigger = {
	places = { 97585580559722 },
	wave = 12,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies["Grave Digger"].AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies["Grave Digger"].BodyHitbox,
	maxHealth = 50,
	walkSpeed = 8,
	hipHeight = 2,
	chance = 4,
	class = "Special",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 133857649642300, walk = 78382771378229 },
	overlapAnimations = { attack = 117376537976232, dig = 133905158159241 },
	sounds = {
		attack = {
			id = { "Enemies", "AttackGraveDigger" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 750,
	currency1 = 3,
	currency2 = 0,
	experience = 5,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 4,
			delay = 0.62,
			damage = 5,
			knockbackInfo = { distance = 1, speed = 100 }
		},
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		chaseStopRange = 30,
		pathfinding = {
			rate = 3,
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
				status = "Idle",
				cooldown = 7,
				origin = {},
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {}
			},
			{
				count = 1,
				status = "Dig",
				cooldown = 0,
				origin = {},
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {}
			},
			{
				count = 1,
				status = "Dig",
				cooldown = 2,
				origin = { "SpawnLocation" },
				flat = false,
				down = false,
				noTarget = false,
				spread = { min = -3, max = 3 },
				spreadY = { min = -3, max = 3 },
				pattern = {
					{ class = "Ability", ability = "GraveDiggerZombie", angle = 0 }
				}
			}
		}
	}
}

for i, child in EnemyAssets.Enemies["Grave Digger"].Variations:GetChildren(), nil, nil do
	table.insert(GraveDigger.instances, child)

	if i == 1 then
		GraveDigger.boundingBox = child:GetExtentsSize()
	end
end

return GraveDigger