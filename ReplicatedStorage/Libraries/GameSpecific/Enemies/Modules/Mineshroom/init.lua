local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Classes.Animations)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local RunService = game:GetService("RunService")
local parentModule = require(script.Parent.Parent.Parent)
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
require(ReplicatedStorage.Libraries.Modules.Collisions)
require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
require(ReplicatedStorage.Libraries.Modules.Device)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
local ItemDrops = require(ReplicatedStorage.Libraries.Modules.ItemDrops)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Modules.Probability)

local isServer = RunService:IsServer()
local v = {
	Luckshroom = "BoostLuck",
	Mineshroom = "BoostPickaxe",
	Packshroom = "BoostCapacity",
	Runshroom = "BoostWalkspeed",
	Slashshroom = "BoostDamage"
}

local v2 = { 10, 50, 150, 400, 800 }

local Mineshroom = {}

function Mineshroom.onCreate(data)
	if isServer then
		local module = EnemyHelpers.GetModule(data)
		local model = data.model
		local pivot = model:GetPivot()
		local name = model.Name
		local integer = Random.new():NextInteger(1, 5)

		local v3 = math.floor(module.maxHealth * math.pow(5, integer / 1.5))
		parentModule.SetValue(data, "miscData", { level = integer, mineshroom = name })
		parentModule.SetValue(data, "health", v3)
		parentModule.SetValue(data, "maxHealth", v3)

		model:ScaleTo(1 + (integer - 1) * 0.5)

		local v4 = Sounds.new({ "AdminAbuseSounds", "Fart" }, pivot.Position)
		Sounds.Play(v4, nil, true)
	else
		EnemyHelpers.GetModule(data)
		local _model = data.model
		local level = data.miscData.level
		local mineshroom = data.miscData.mineshroom

		local clone = script.MineshroomUI:Clone()
		clone.StudsOffsetWorldSpace = Vector3.new(0, 8 + 3 * (level - 1), 0)
		clone.Title.Text = `{string.upper(mineshroom)} Lv. {level}`
		clone.Parent = data.model
		data.maid.mineshroomHealthUI = clone
	end
end

function Mineshroom.onUpdateHealthUI(data)
	if not isServer then
		local v3 = math.clamp(data.health, 0, data.maxHealth) / data.maxHealth
		data.maid.mineshroomHealthUI.Bar.Percent.Size = UDim2.fromScale(v3, 1)

		if v3 > 0 then
			data.maid.mineshroomHealthUI.Bar.Percent.Display.Size = UDim2.fromScale(1 / v3, 1)
		end
	end
end

function Mineshroom.onDestroy(data)
	if isServer then
		local mineshroom = data.miscData.mineshroom
		local level = data.miscData.level
		local pivot = data.model:GetPivot()
		local v3 = Sounds.new({ "AdminAbuseSounds", "Ahhh (Disappearing Scream Meme)" }, pivot.Position)
		Sounds.Play(v3, nil, true)

		local v4 = Visuals.new({ "MineshroomDestroy" }, pivot)
		Visuals.Play(v4, nil, true)

		local v5 = v[mineshroom]
		local v6 = v2[level]

		for k, _ in data.damageFrom do
			local playerByUserId = Players:GetPlayerByUserId((tonumber(k)))

			if playerByUserId then
				ItemDrops.Create(playerByUserId, pivot.Position, {
					Coin = { amount = 10, value = v6 },
					[v5] = {
						amount = 1,
						value = 60 * level
					}
				}, "Easy")
			end
		end
	end
end

return Mineshroom