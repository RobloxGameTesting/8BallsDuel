local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolSkins = require(Pool.PoolSkins)

local PoolCueUpgradeService = {}

local isServer = RunService:IsServer()

function PoolCueUpgradeService.GetOffer(p: number, itemKey: string)
	local item = PoolSkins.GetItem("cueSticks", itemKey)
	local cue = item and item.cue

	if typeof(cue) ~= "string" or cue == "" then
		return nil
	end

	local cueLevel = PoolSkins.GetCueLevel(p, itemKey)

	return {
		ItemKey = itemKey,
		CueName = cue,
		Level = cueLevel,
		MaxLevel = PoolConstants.CueMaxLevel(cue),
		Cost = PoolConstants.CueUpgradeCost(cue, cueLevel)
	}
end

function PoolCueUpgradeService.Buy(p: number, value: string)
	if not isServer then
		return false, "Server only"
	end

	if typeof(value) ~= "string" or value == "" then
		return false, "That cue does not exist"
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return false, "Your data is still loading"
	end

	if not PoolSkins.Owns(p, "cueSticks", value) then
		return false, "You do not own that cue"
	end

	local offer = PoolCueUpgradeService.GetOffer(p, value)

	if not offer then
		return false, "That cue does not exist"
	end

	if offer.MaxLevel <= 0 then
		return false, "That cue cannot be upgraded"
	end

	local cost = offer.Cost

	if not cost then
		return false, "That cue is already fully upgraded"
	end

	if not PoolPlayerData.CanAfford(p, cost) then
		return false, "You cannot afford that upgrade"
	end

	PoolPlayerData.AddCoins(p, -cost)

	replica:Write("PoolCueUpgrades", value, offer.CueName)

	return true
end

return PoolCueUpgradeService