local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local HalfSkin = {
	places = { 97585580559722 },
	wave = 8,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies["Half Skin"].AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies["Half Skin"].BodyHitbox,
	maxHealth = 50,
	walkSpeed = 18,
	hipHeight = 2.4,
	chance = 30,
	class = "Normal",
	canKnockback = true,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 129561827804908, walk = 122160521064487 },
	overlapAnimations = { attack = 78775695698344 },
	sounds = {
		attack = {
			id = { "Enemies", "AttackJab" },
			parent = { "Head" }
		},
		died = {
			id = { "Enemies", "Died" },
			parent = { "Head" }
		}
	},
	visuals = {},
	money = 120,
	currency1 = 2,
	currency2 = 0,
	experience = 5,
	enemyConfiguration = {
		freezeRange = 1000,
		idleRange = 800,
		attackState = {
			hitboxArea = "Attack",
			cooldown = 2,
			delay = 0.45,
			damage = 6,
			knockbackInfo = { distance = 1, speed = 100 }
		},
		alertRequirement = { requiresTimer = true, timerDuration = 3.3 },
		chaseStopRange = 2,
		pathfinding = {
			rate = 0.5,
			agentParameters = {
				AgentRadius = 1.8,
				AgentHeight = 6,
				AgentCanJump = true,
				AgentCanClimb = true,
				WaypointSpacing = 1,
				Costs = { Avoid = 1e999 }
			}
		}
	}
}

for i, child in EnemyAssets.Enemies["Half Skin"].Variations:GetChildren(), nil, nil do
	table.insert(HalfSkin.instances, child)

	if i == 1 then
		HalfSkin.boundingBox = child:GetExtentsSize()
	end
end

return HalfSkin