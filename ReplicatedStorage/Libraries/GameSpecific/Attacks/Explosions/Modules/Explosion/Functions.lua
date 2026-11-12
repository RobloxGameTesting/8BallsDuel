local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local parentModule = require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions.ExplosionTypes)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(p)
	local position = p.position
	Visuals.Play(Visuals.new({ "Weapons", "RocketLauncherExplosion" }, position), nil, true)
	Sounds.Play(Sounds.new({ "Weapons", "RocketLauncherExplosion" }, position), nil, true)
end

function Functions.onEnemyHit(data, p: string)
	local module = parentModule.GetModule(data)

	if isServer then
		local enemyById = Enemies._getEnemyById(p)
		local humanoidRootPart = enemyById.model and enemyById.model:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local lookVector = CFrame.new(
				NumberHelper:SetVector3(data.position, humanoidRootPart.Position.Y),
				humanoidRootPart.Position
			).LookVector
			Enemies.Knockback(enemyById, module.knockback, lookVector)
		end

		Enemies.TakeDamage(enemyById, module.damage, data.ownerId, data.masteryType)
	else
		local Crosshair = require(ReplicatedStorage.Libraries.GameSpecific.Crosshair)

		local enemyById = Enemies._getEnemyById(p)

		if data.isOwner then
			Crosshair:Hitmarker(false)
			Enemies.Indicator(enemyById, module.damage)
		end
	end
end

function Functions.onPlayerHit(_, _: string)
	if isServer then
	end
end

function Functions.onDestroy(_)
	if isServer then
	end
end

return Functions