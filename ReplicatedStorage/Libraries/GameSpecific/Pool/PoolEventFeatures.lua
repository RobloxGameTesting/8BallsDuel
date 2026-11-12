local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage.Libraries.Modules.Events)

local PoolEventFeatures = {}

PoolEventFeatures.SkinCategory = {
	CueStick = "cueSticks",
	PoolTable = "poolTables",
	PoolEffect = "poolEffects"
}

local function season() -- 7 equivalent calls inferred from this helper
	return Events:GetActiveMission()
end

local function bucket(p) -- 5 equivalent calls inferred from this helper
	return Events:GetEventDatastore(p, false)
end

function PoolEventFeatures.HasFeatures(): boolean
	local v = season() -- inferred equivalent call
	return v ~= nil
		and Events:GetCurrencyInfo() ~= nil
		and (v.eventDaily ~= nil or v.eventShop ~= nil or v.eventRaffle ~= nil)
end

function PoolEventFeatures.Today()
	local v = season() -- inferred equivalent call

	if v then
		return math.floor((workspace:GetServerTimeNow() - v.eventStart) / 86400) + 1
	end

	return 0
end

function PoolEventFeatures.UntilTomorrow()
	local v = season() -- inferred equivalent call

	if v then
		return (math.max(0, 86400 - (workspace:GetServerTimeNow() - v.eventStart) % 86400))
	end

	return 0
end

function PoolEventFeatures.DailyRewards()
	local v = season() -- inferred equivalent call
	local eventDaily = v and v.eventDaily

	if typeof(eventDaily) == "table" then
		return eventDaily
	end

	return {}
end

function PoolEventFeatures.DailyState(p)
	local dailyRewards = PoolEventFeatures.DailyRewards()
	local v = bucket(p) -- inferred equivalent call
	local daily = v and v.daily
	local claimed = tonumber(daily and daily.claimed) or 0
	local lastDay = tonumber(daily and daily.lastDay) or 0
	local v2

	if v == nil then
		v2 = false
	else
		v2 = Events:IsActive()

		if v2 then
			if claimed < #dailyRewards then
				v2 = lastDay < PoolEventFeatures.Today()
			else
				v2 = false
			end
		end
	end

	return claimed, v2
end

function PoolEventFeatures.ShopItems()
	local v = season() -- inferred equivalent call
	local eventShop = v and v.eventShop

	if typeof(eventShop) == "table" then
		return eventShop
	end

	return {}
end

function PoolEventFeatures.ShopItem(p: string)
	for _, v in PoolEventFeatures.ShopItems() do
		if v.id == p then
			return v
		end
	end

	return nil
end

function PoolEventFeatures.Bought(p, p2: string)
	local v = bucket(p) -- inferred equivalent call
	local shop = v and v.shop

	return tonumber(shop and shop[p2]) or 0
end

local function ladderDone(p)
	local v = bucket(p) -- inferred equivalent call
	local progress = tonumber(v and v.progress) or 0
	local success, result = pcall(function()
		return Events:GetHighestPoints()
	end)

	return success and (tonumber(result) or 1e999) <= progress
end

function PoolEventFeatures.ShopBlock(p, data): nil | string
	if not Events:IsActive() then
		return "ENDED"
	end

	local reward = data.reward or {}
	local v = PoolEventFeatures.SkinCategory[reward.writeLib]

	if v and reward.itemName then
		local PoolSkins = require(script.Parent.PoolSkins)

		if PoolSkins.Owns(p.UserId, v, reward.itemName) then
			return "OWNED"
		end
	end

	if data.limit and PoolEventFeatures.Bought(p, data.id) >= data.limit then
		return if data.limit == 1 then "OWNED" else "SOLD OUT"
	elseif reward.writeLib == "TierSkip" and ladderDone(p) then
		return "MAXED"
	else
		return nil
	end
end

function PoolEventFeatures.Raffle()
	local v = season() -- inferred equivalent call
	local eventRaffle = v and v.eventRaffle

	if typeof(eventRaffle) == "table" and eventRaffle.enabled ~= false then
		return eventRaffle
	end

	return nil
end

function PoolEventFeatures.Prize(p: string)
	local raffle = PoolEventFeatures.Raffle()

	for _, v in raffle and raffle.prizes or {} do
		if v.id == p then
			return v
		end
	end

	return nil
end

function PoolEventFeatures.FreeSpinReady(p): boolean
	local raffle = PoolEventFeatures.Raffle()
	local v = bucket(p) -- inferred equivalent call

	if not (raffle and v and Events:IsActive()) or (tonumber(raffle.freePerDay) or 0) <= 0 then
		return false
	end

	local raffle2 = v.raffle

	return (tonumber(raffle2 and raffle2.freeDay) or 0) < PoolEventFeatures.Today()
end

function PoolEventFeatures.Odds()
	local raffle = PoolEventFeatures.Raffle()
	local prizes = raffle and raffle.prizes or {}
	local total = 0

	for _, priz in prizes do
		total += math.max(tonumber(priz.weight) or 0, 0)
	end

	local result = {}

	for _, priz in prizes do
		local v = math.max(tonumber(priz.weight) or 0, 0)

		table.insert(result, {
			prize = priz,
			percent = not (total > 0) and 0 or v / total * 100
		})
	end

	return result
end

function PoolEventFeatures.TierPercent(p: string)
	local total = 0

	for _, v in PoolEventFeatures.Odds() do
		if v.prize.tier == p then
			total += v.percent
		end
	end

	return total
end

function PoolEventFeatures.Roll(object)
	local raffle = PoolEventFeatures.Raffle()
	local prizes = raffle and raffle.prizes or {}
	local total = 0

	for _, priz in prizes do
		total += math.max(tonumber(priz.weight) or 0, 0)
	end

	if total <= 0 then
		return nil
	end

	local v = object:NextNumber() * total

	for _, priz in prizes do
		v -= math.max(tonumber(priz.weight) or 0, 0)

		if v <= 0 then
			return priz
		end
	end

	return prizes[#prizes]
end

function PoolEventFeatures.RewardName(data)
	local v = PoolEventFeatures.SkinCategory[data.writeLib]

	if v and data.itemName then
		local PoolSkins = require(script.Parent.PoolSkins)
		local item = PoolSkins.GetItem(v, data.itemName)

		if item and item.name then
			return item.name
		end

		return (tostring(data.itemName))
	else
		local function separate(value: number)
			local v2 = tostring((math.floor(value)))

			repeat
				local v3
				v2, v3 = v2:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
			until v3 == 0

			return v2
		end

		local value = tonumber(data.value) or 0

		if data.writeLib == "Currency1" then
			return separate(value) .. " Coins"
		end

		if data.writeLib == "Currency2" then
			return separate(value) .. (value == 1 and " Gem" or " Gems")
		end

		if data.writeLib == "TierSkip" then
			return "+" .. value .. " Tier Skip"
		end

		if data.writeLib ~= "EventCurrency" then
			return (tostring(data.writeLib))
		end

		local currencyInfo = Events:GetCurrencyInfo()

		return separate(value) .. " " .. (not currencyInfo and "Event Gems" or currencyInfo.name)
	end
end

function PoolEventFeatures.HypePending(p)
	local v = season() -- inferred equivalent call
	local v2 = bucket(p) -- inferred equivalent call
	local v3

	if v == nil or typeof(v.hype) ~= "table" then
		return false
	end

	v3 = Events:IsActive()

	if v3 then
		if v2 == nil then
			return false
		end

		return v2.hypeSeen ~= true
	end

	return v3
end

return PoolEventFeatures