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
require(ReplicatedStorage.Libraries.GameSpecific.AttackController.AttackControllerTypes)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(p)
	if isServer then
		Sounds.Play(p.sounds.spawn, nil, false)
	end

	EnemyHelpers.onCreate(p)
end

function Functions.onShoot(data)
	EnemyHelpers.GetModule(data)
	local attackController = data.attackController
	local newStatus = attackController.newStatus
	local prevStatus = attackController.prevStatus

	if newStatus == "Attack" then
		if prevStatus ~= "Attack" then
			data.model.rock2_low.Transparency = 0
			Animations.Play(data.overlapAnimations, {
				{ animation = "rockThrow", looped = false }
			})

			Sounds.Play(data.sounds.grunt, nil, false)
		end
	elseif newStatus == "Idle" then
		data.model.rock2_low.Transparency = 1
		Animations.Stop(data.overlapAnimations)
	end
end

function Functions.onCharge(p)
	if not isServer then
		return
	end

	Sounds.SetDistortion(p.sounds.charge, Random.new():NextNumber(0, 0.1))
	Sounds.Play(p.sounds.charge, nil, false)
end

function Functions.onDestroy(p)
	EnemyHelpers.onDestroy(p)
end

return Functions