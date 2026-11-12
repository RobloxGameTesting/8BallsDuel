local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Throwables.ThrowableTypes)
require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions)
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Explosions.ExplosionTypes)
local ThrowableHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Throwables.ThrowableHelpers)

RunService:IsServer()

local Functions = {}

function Functions.onHitEnemy(_, _) end

function Functions.onHitPart(_, _) end

function Functions.onDestroy(p)
	ThrowableHelpers.onDestroy(p)
end

return Functions