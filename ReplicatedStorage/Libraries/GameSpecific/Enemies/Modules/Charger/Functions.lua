local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(p)
	if isServer then
		Sounds.Play(p.sounds.attack, nil, false)
	end

	EnemyHelpers.onCreate(p)
end

function Functions.onCharge(p)
	if not isServer then
		return
	end

	Sounds.SetDistortion(p.sounds.charge, Random.new():NextNumber(0, 0.3))
	Sounds.Play(p.sounds.charge, nil, false)
end

function Functions.onDestroy(p)
	EnemyHelpers.onDestroy(p)
end

return Functions