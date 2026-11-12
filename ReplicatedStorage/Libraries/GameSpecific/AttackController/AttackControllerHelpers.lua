local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local HttpService = game:GetService("HttpService")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Modules.TimeSync)
require(ReplicatedStorage.Libraries.Helpers.OptimizationHelper)
local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities.AbilityTypes)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local AttackControllerHelpers = {}

function AttackControllerHelpers.CreateBullet(data, data2, _, p)
	local WeaponAttacks = require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponAttacks)
	local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
	require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets)

	local character = p and p.character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local angle = data2.angle
	local bullet = data2.bullet
	local _class = data2.class

	local enemyById = Enemies._getEnemyById(data.enemyId)
	local v = data.spray[data.shootIndex]

	local flat = v.flat
	local down = v.down
	local noTarget = v.noTarget
	HttpService:GenerateGUID()
	local number = Random.new():NextNumber(v.spread.min, v.spread.max)
	local v2 = Random.new():NextNumber(v.spreadY.min, v.spreadY.max) or 0
	local model = enemyById.model
	local position = ModelHelper.GetChildrenByParentString(model, v.origin).Position
	local lookVector

	if flat then
		lookVector = (CFrame.lookAt(
			VectorHelper.ZeroVector3(position),
			VectorHelper.ZeroVector3(humanoidRootPart.Position)
		) * CFrame.Angles(math.rad(v2), math.rad(angle + number), 0)).LookVector
	elseif down then
		lookVector = (CFrame.lookAt(position, position + Vector3.new(0, -1, 0)) * CFrame.Angles(math.rad(v2), math.rad(angle + number), 0)).LookVector
	elseif noTarget then
		lookVector = (CFrame.lookAt(position, position + Vector3.new(1, 0, 0)) * CFrame.Angles(math.rad(v2), math.rad(angle + number), 0)).LookVector
	else
		lookVector = (CFrame.lookAt(position, humanoidRootPart.Position) * CFrame.Angles(math.rad(v2), math.rad(angle + number), 0)).LookVector
	end

	WeaponAttacks.CreateBullet(position, lookVector, nil, bullet, "")
end

function AttackControllerHelpers.CreateAbility(data, p, _, p2)
	local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
	local Abilities = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities)

	local character = p2 and p2.character

	if character then
		character:FindFirstChild("HumanoidRootPart")
	end

	local ability = p.ability
	local _class = p.class

	local enemyById = Enemies._getEnemyById(data.enemyId)
	local v = data.spray[data.shootIndex]
	HttpService:GenerateGUID()
	local model = enemyById.model

	for _, childName in v.origin do
		model = model:FindFirstChild(childName)
	end

	local position = model.Position

	local v2 = {
		id = tostring(Random.new():NextInteger(1, 1000000)),
		loadId = "",
		masteryType = nil,
		maid = nil,
		abilityType = ability,
		owner = nil,
		ownerId = nil,
		origin = position,
		isOwner = true,
		isEnemy = false
	}

	Abilities.newServer(v2)
end

return AttackControllerHelpers