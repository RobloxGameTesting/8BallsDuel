local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)
require(script.Parent.Parent.Parent)
local BulletHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletHelpers)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

RunService:IsServer()

local Functions = {}

function Functions.onHitEnemy(_, _) end

function Functions.onCreate(_) end

function Functions.onHitPart(_, p)
	CFrame.new(p.position, p.position + p.normal)
end

function Functions.onDestroy(p)
	BulletHelpers.onDestroy(p)
end

return Functions