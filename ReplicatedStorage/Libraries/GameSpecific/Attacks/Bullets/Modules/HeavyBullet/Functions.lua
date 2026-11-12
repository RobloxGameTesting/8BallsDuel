local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletTypes)
require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local BulletHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletHelpers)

RunService:IsServer()

local Functions = {}

function Functions.onHitEnemy(_, _) end

function Functions.onCreate(_) end

function Functions.onHitPart(_, p)
	local cframe = CFrame.new(p.position, p.position + p.normal)

	local v = Visuals.new({ "Feel", "BulletHole" }, cframe)
	Visuals.Play(v, 4, true)
end

function Functions.onDestroy(p)
	BulletHelpers.onDestroy(p)
end

return Functions