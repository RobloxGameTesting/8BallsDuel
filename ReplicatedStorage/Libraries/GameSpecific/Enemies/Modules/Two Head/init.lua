local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)

local EnemyAssets = ReplicatedStorage.Assets.EnemyAssets

local TwoHead = {
	places = { 97585580559722 },
	wave = 8,
	id = script.Name,
	instances = {},
	boundingBox = Vector3.new(),
	attackHitbox = EnemyAssets.Enemies["Two Head"].AttackHitbox,
	bodyHitbox = EnemyAssets.Enemies["Two Head"].BodyHitbox,
	maxHealth = 200,
	walkSpeed = 10,
	hipHeight = 2.8,
	chance = 10,
	class = "Special",
	canKnockback = false,
	states = { "Freeze", "Idle", "Chase", "Attack", "Died" },
	initialState = "Freeze",
	animations = { idle = 80047983162284, walk = 72086444171170 },
	overlapAnimations = { attack = 125482146864985 },
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
	money = 1000,
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
			delay = 0.65,
			damage = 9,
			knockbackInfo = { distance = 1, speed = 100 }
		},
		chaseStopRange = 2.5,
		pathfinding = {
			rate = 0.5,
			agentParameters = {
				AgentRadius = 2.1,
				AgentHeight = 6,
				AgentCanJump = true,
				AgentCanClimb = true,
				WaypointSpacing = 1,
				Costs = { Avoid = 1e999 }
			}
		}
	}
}

for i, child in EnemyAssets.Enemies["Two Head"].Variations:GetChildren(), nil, nil do
	table.insert(TwoHead.instances, child)

	if i == 1 then
		TwoHead.boundingBox = child:GetExtentsSize()
	end
end

return TwoHead