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
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
game:GetService("Players")
require(ReplicatedStorage.Libraries.Modules.Profiles)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(p)
	local position = p.position
	Visuals.Play(Visuals.new({ "Raygun", "Explosion" }, position), nil, true)
	Sounds.Play(Sounds.new({ "HealingPotion" }, position), nil, true)
	Sounds.Play(Sounds.new({ "SplashPotion" }, position), nil, true)
end

function Functions.onEnemyHit(p, _: string)
	parentModule.GetModule(p)

	if isServer then
	end
end

function Functions.onPlayerHit(p, p2: string)
	if not isServer then
		return
	end

	local module = parentModule.GetModule(p)

	local ownerId = p.ownerId

	HealthHandler.Heal(ownerId, p2, module.damage)
end

function Functions.onDestroy(_)
	if isServer then
	end
end

return Functions