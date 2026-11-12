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
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local BulletHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Attacks.Bullets.BulletHelpers)

RunService:IsServer()

local Functions = {}

function Functions.onHitEnemy(_, _) end

function Functions.onCreate(p)
	local integer = Random.new():NextInteger(180, 360)
	local total = 0

	p.maid.visualEffectConnection = RunService.RenderStepped:Connect(function(dt: number)
		total += integer * dt

		p.maid.object.CFrame *= CFrame.Angles(math.rad(total), math.rad(total), (math.rad(total)))
	end)
end

function Functions.onHitPart(_, _) end

function Functions.onDestroy(p)
	BulletHelpers.onDestroy(p)
end

return Functions