local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.GameSpecific.AttackController.AttackControllerTypes)
require(ReplicatedStorage.Libraries.Modules.Scheduler)
require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(p)
	if not isServer then
		return
	end

	local _primaryPart = p.model.PrimaryPart

	Sounds.Play(p.sounds.attack, nil, false)
end

function Functions.onAttack(_): nil
	print("ON ATTACK")
	return nil
end

function Functions.onShoot(data)
	EnemyHelpers.GetModule(data)
	local attackController = data.attackController
	local newStatus = attackController.newStatus
	local prevStatus = attackController.prevStatus

	if newStatus == "Minigun" then
		if prevStatus == "Minigun" then
			if attackController.shootIndex == 50 then
				Animations.Stop(data.overlapAnimations)
				Sounds.Stop(data.sounds.shoot, 0.5)
				Visuals.Stop(data.visuals.shoot)
			end
		else
			Animations.Play(data.overlapAnimations, {
				{ animation = "shoot", looped = true }
			})

			Sounds.Play(data.sounds.shoot, "Manual", false, 1)
			Visuals.Play(data.visuals.shoot, "Manual", false)
		end
	else
		if newStatus == "Helmet" then
			return
		end

		if newStatus == "Jump" and prevStatus ~= "Jump" then
			Animations.Play(data.overlapAnimations, {
				{ animation = "jump", speed = 0.8 }
			})

			data.maid.overlapConnection = data.overlapAnimations.KeyframeEvent:Connect(function(p)
				if p == "Land" then
					Visuals.Play(data.visuals.attack, nil, false)
					Sounds.Play(data.sounds.attack, nil, false)
				end
			end)
		end
	end
end

function Functions.onDestroy(data)
	if isServer then
		Animations.Stop(data.overlapAnimations)
		Sounds.Destroy(data.sounds.shoot)
		Visuals.Destroy(data.visuals.shoot)
	end

	EnemyHelpers.onDestroy(data)
end

return Functions