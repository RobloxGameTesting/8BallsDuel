local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.GameSpecific.Explosions.ExplosionTypes)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(_) end

function Functions.onDestroy(_)
	if isServer then
	end
end

return Functions