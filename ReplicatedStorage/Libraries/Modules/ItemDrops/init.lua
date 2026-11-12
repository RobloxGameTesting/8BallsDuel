local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local LootConstants = require(script.Loots.LootConstants)
require(script.Loots.LootTypes)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()

local ItemDrops = {}

local v = {}

function ItemDrops.Init()
	if isServer then
		Players.PlayerAdded:Connect(function(player)
			local userId = tostring(player.UserId)

			v[userId] = {}

			for k, _ in LootConstants.DISPLAY_ICONS do
				v[userId][k] = {}
			end
		end)

		Players.PlayerRemoving:Connect(function(player)
			local userId = tostring(player.UserId)

			v[userId] = nil
		end)

		RemoteSignals.OnServerEvent(RemoteEnums.ItemDrops, function(p, p2, ...)
			local userId = tostring(p.UserId)
			local playerReplica = Profiles.GetPlayerReplica(userId)

			if not playerReplica then
				return
			end

			if p2 == "ItemDropsCollect" then
				local v2, mantissa = ...

				if not (v and v[userId] and v[userId][v2] and v[userId][v2][mantissa]) then
					return
				end

				v[userId][v2][mantissa] -= 1

				if v[userId][v2][mantissa] == 0 then
					v[userId][v2][mantissa] = nil
				end

				if v2 == "Coin" then
					playerReplica:Write("Currency1", { mantissa = mantissa, exponent = 0 })
				elseif
					v2 == "BoostCapacity"
					or v2 == "BoostDamage"
					or v2 == "BoostLuck"
					or v2 == "BoostPickaxe"
					or v2 == "BoostWalkspeed"
				then
					playerReplica:Write("Boost", v2, mantissa)
				end
			end
		end)
	else
		local localPlayer = Players.LocalPlayer

		RemoteSignals.OnClientEvent(RemoteEnums.ItemDrops, function(p: string, ...)
			if p == "ItemDropsCreate" then
				local v2, v3, v4 = ...

				ItemDrops.Create(localPlayer, v2, v3, v4)
			end
		end)
	end
end

function ItemDrops.Create(p, vector3: Vector3, items, p2)
	local userId = tostring(p.UserId)

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

		for k, item in items do
			if v and v[userId] and v[userId][k] then
				v[userId][k][item.value] = (v[userId][k][item.value] or 0) + item.amount
			end
		end

		Loaded.FireClientGuarantee(p, RemoteEnums.ItemDrops, "ItemDropsCreate", vector3, items, p2)
	else
		local Loots = require(script.Loots)

		for k, item in items do
			for _ = 1, item.amount do
				Loots.new(k, vector3, item.value, 5)
			end
		end

		Visuals.Play(Visuals.new({ "Drop" }, vector3), nil, true)
		Visuals.Play(Visuals.new({ "Sparks" }, vector3), nil, true)
		Visuals.Play(Visuals.new({ "Shine" }, vector3), nil, true)
		Sounds.Play(Sounds.new({ "CodeRedeem" }, vector3), nil, true)
		Sounds.Play(Sounds.new({ p2 }, vector3), nil, true)
	end
end

return ItemDrops