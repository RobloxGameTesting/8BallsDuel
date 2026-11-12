local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolGalaxySet = require(Pool.PoolGalaxySet)
local PoolSkins = require(Pool.PoolSkins)

local coinsByProductId = {}
local gemsByProductId = {}
local tiersByProductId = {}
local PoolGifting = {}

for _, v in MonetizationConstants.POOL_COIN_PACKS do
	coinsByProductId[v.productId] = v.coins
end

for _, v in MonetizationConstants.POOL_GEM_PACKS do
	if v.productId then
		gemsByProductId[v.productId] = v.gems
	end
end

for _, tier in PoolGalaxySet.Tiers do
	tiersByProductId[tier.ProductId] = tier
end

local v = nil

local function events() -- 5 equivalent calls inferred from this helper
	if not v then
		local Events = require(ReplicatedStorage.Libraries.Modules.Events)
		v = Events
	end

	return v
end

local function seasonKind(value: number) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function(): nil | string
		local v2 = events() -- inferred equivalent call

		if table.find(v2:GetSeasonPassIds(), value) then
			return "Pass"
		end

		if value == v2:GetSkip1Id() or value == v2:GetSkip10Id() or value == v2:GetSkipAllId() then
			return "Skip"
		end

		return nil
	end)
	return if success then result else nil
end

function PoolGifting.Kind(value: number?)
	if typeof(value) ~= "number" then
		return nil
	end

	if coinsByProductId[value] then
		return "Coins"
	end

	if gemsByProductId[value] then
		return "Gems"
	end

	if tiersByProductId[value] then
		return "Galaxy"
	end

	return seasonKind(value) -- inferred equivalent call
end

function PoolGifting.IsGiftable(p: number?): boolean
	return PoolGifting.Kind(p) ~= nil
end

function PoolGifting.Describe(p: number)
	local kind = PoolGifting.Kind(p)

	if kind == "Coins" then
		return NumberHelper:Separate(coinsByProductId[p]) .. " Coins"
	elseif kind == "Gems" then
		return NumberHelper:Separate(gemsByProductId[p]) .. " Gems"
	end

	if kind == "Galaxy" then
		local v2 = tiersByProductId[p]
		local item = PoolSkins.GetItem(PoolGalaxySet.Category, v2.Item)

		if item and item.name then
			return (tostring(item.name))
		end

		return v2.Item
	elseif kind == "Pass" then
		local success, result = pcall(function(): boolean
			return p == events():GetExclusiveSeasonPassId() -- inferred equivalent call
		end)

		if success and result then
			return "the Ultra Gold Pass"
		end

		return "the Gold Pass"
	else
		if kind ~= "Skip" then
			return "a gift"
		end

		local v2 = events() -- inferred equivalent call

		if p == v2:GetSkip1Id() then
			return "1 season tier"
		end

		if p == v2:GetSkip10Id() then
			return "10 season tiers"
		end

		return "every remaining season tier"
	end
end

function PoolGifting.Title(p: number)
	local describe = PoolGifting.Describe(p)

	if describe == "every remaining season tier" then
		return "ALL REMAINING TIERS"
	end

	return string.upper((describe:gsub("^the ", "")))
end

local function ownsSeasonPass(p: number): (nil | boolean, nil | string) -- 1 equivalent call inferred from this helper
	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return nil, "LOADING"
	end

	local success, result = pcall(function()
		return events():OwnsSeasonPass(playerByUserId) -- inferred equivalent call
	end)

	if success then
		return result == true, nil
	end

	return nil, "LOADING"
end

local function seasonFinished(playerReplica): (nil | boolean, nil | string) -- 1 equivalent call inferred from this helper
	local success, result = pcall(function(): boolean
		local v2 = events() -- inferred equivalent call
		local datastoreKey = v2:GetDatastoreKey()
		local v3 = playerReplica.Data.events and playerReplica.Data.events[datastoreKey]
		return ((not v3 or typeof(v3.progress) ~= "number") and 0 or v3.progress) >= v2:GetHighestPoints()
	end)

	if success then
		return result == true, nil
	end

	return nil, "LOADING"
end

function PoolGifting.CanReceive(p: number, p2: number)
	local kind = PoolGifting.Kind(p)

	if not kind then
		return false, "UNGIFTABLE"
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(p2)))

	if not playerReplica then
		return false, "LOADING"
	end

	if kind == "Galaxy" then
		if PoolSkins.Owns(p2, PoolGalaxySet.Category, tiersByProductId[p].Item) then
			return false, "OWNED"
		end
	elseif kind == "Pass" then
		local v2, v3 = ownsSeasonPass(p2) -- inferred equivalent call

		if v3 then
			return false, v3
		end

		if v2 then
			return false, "OWNED"
		end
	elseif kind == "Skip" then
		local v2, v3 = seasonFinished(playerReplica) -- inferred equivalent call

		if v3 then
			return false, v3
		end

		if v2 then
			return false, "MAXED"
		end
	end

	return true, nil
end

function PoolGifting.ReasonText(p: string?, p2: number)
	if p == "OWNED" then
		return "already owns " .. PoolGifting.Describe(p2)
	elseif p == "MAXED" then
		return "has already reached every season tier"
	elseif p == "LOADING" then
		return "hasn't finished loading in"
	end

	return "can't be sent that"
end

return PoolGifting