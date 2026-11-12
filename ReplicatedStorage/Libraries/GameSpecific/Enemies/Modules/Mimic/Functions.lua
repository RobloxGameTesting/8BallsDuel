local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.GameSpecific.Tools)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.WeaponEvents)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)

local isServer = RunService:IsServer()

local Functions = {}

function Functions.onCreate(p)
	if isServer then
		local model = p.model

		local cachedCharacters = ReplicatedStorage.Assets.CachedCharacters

		if #cachedCharacters:GetChildren() > 0 then
			for _, child in cachedCharacters:GetChildren()[Random.new():NextInteger(1, #cachedCharacters:GetChildren())]:GetChildren(), nil, nil do
				if not (child:IsA("Accessory") or child:IsA("Accoutrement") or child:IsA("BodyColors") or child:IsA("Shirt") or child:IsA("ShirtGraphic") or child:IsA("Pants")) then
					continue
				end

				local clone = child:Clone()
				clone.Parent = model
			end
		end

		Sounds.Play(p.sounds.attack, nil, false)
	end

	EnemyHelpers.onCreate(p)
end

function Functions.onDestroy(p)
	EnemyHelpers.onDestroy(p)
end

return Functions