local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions.ExplosionTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Abilities.AbilityTypes)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(_)
	if isServer then
	end
end

function Functions.onDestroy(p)
	if isServer and p.ownerId then
		HealthHandler.Heal(p.ownerId, p.ownerId, 50)
	end
end

return Functions