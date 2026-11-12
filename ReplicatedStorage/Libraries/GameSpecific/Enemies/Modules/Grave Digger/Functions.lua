local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
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

function Functions.onCreate(_)
	if isServer then
	end
end

function Functions.onShoot(p)
	EnemyHelpers.GetModule(p)
	local attackController = p.attackController
	local newStatus = attackController.newStatus
	local prevStatus = attackController.prevStatus

	if newStatus == "Dig" then
		if prevStatus ~= "Dig" then
			Animations.Play(p.overlapAnimations, {
				{ animation = "dig", priority = Enum.AnimationPriority.Action2 }
			})
		end
	elseif newStatus == "Idle" then
		Animations.Stop(p.overlapAnimations)
	end

	EnemyHelpers.onCreate(p)
end

function Functions.onDestroy(p)
	EnemyHelpers.onDestroy(p)
end

return Functions