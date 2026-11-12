local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
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
		Animations.Play(p.overlapAnimations, {
			{ animation = "coverEyeIdle", looped = true, priority = Enum.AnimationPriority.Action2 }
		})

		Sounds.Play(p.sounds.attack, nil, false)
	end

	EnemyHelpers.onCreate(p)
end

function Functions.onChase(p)
	if not isServer then
		return
	end

	Animations.Stop(p.overlapAnimations)
end

function Functions.onDestroy(p)
	EnemyHelpers.onDestroy(p)
end

return Functions