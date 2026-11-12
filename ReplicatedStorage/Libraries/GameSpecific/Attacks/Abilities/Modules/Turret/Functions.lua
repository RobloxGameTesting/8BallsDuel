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
require(ReplicatedStorage.Libraries.Modules.HealthHandler)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(_)
	if not isServer then
		return
	end

	local part = Instance.new("Part")
	part.Parent = workspace
end

function Functions.onDestroy(_)
	if isServer then
	end
end

return Functions