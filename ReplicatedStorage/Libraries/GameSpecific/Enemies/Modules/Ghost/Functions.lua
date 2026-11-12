local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)

local isServer = RunService:IsServer()

local Functions = {}

local function changeTransparency(folder, ancestor, ancestor2, transparency)
	for _, part in folder:GetDescendants(), nil, nil do
		if not (part:IsA("BasePart") and (not (ancestor or ancestor2) or ancestor and ancestor2 and not (part:IsDescendantOf(ancestor) or part:IsDescendantOf(ancestor2)))) then
			continue
		end

		if
			part.Name == "HumanoidRootPart"
			or (part:FindFirstChildWhichIsA("Sound") or part:FindFirstChildWhichIsA("ParticleEmitter"))
			or part.Name == "No"
		then
			continue
		end

		if part.Parent == folder then
			continue
		end

		part.Transparency = transparency
	end
end

function Functions.onCreate(data)
	if isServer then
		local model = data.model

		changeTransparency(model, data.attackHitbox, data.bodyHitbox, 0)

		task.spawn(function()
			local v = 0

			while data.health > 0 do
				v = v == 0 and 1 or 0
				changeTransparency(model, data.attackHitbox, data.bodyHitbox, v)

				if v == 1 then
					Visuals.Play(data.visuals.poof, nil, false)
					task.wait(3)
				elseif v == 0 then
					task.wait(3)
				end
			end
		end)

		Sounds.Play(data.sounds.attack, nil, false)
	end

	EnemyHelpers.onCreate(data)
end

function Functions.onDestroy(p)
	local v = EnemyHelpers.onDestroy(p)

	if isServer then
		return
	end

	if v then
		changeTransparency(v, nil, nil, 0)
	end
end

return Functions