local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolSkins = require(Pool.PoolSkins)

local PoolCardRewards = {}

local isServer = RunService:IsServer()
local random = Random.new()

PoolCardRewards.MaxPending = 10

PoolCardRewards.Tiers = {
	{
		Id = "Wood",
		Name = "WOOD",
		CoinsLow = 60,
		CoinsHigh = 120,
		ItemChance = 0,
		Colour = Color3.fromRGB(158, 106, 62)
	},
	{
		Id = "Silver",
		Name = "SILVER",
		CoinsLow = 120,
		CoinsHigh = 240,
		ItemChance = 0,
		Colour = Color3.fromRGB(206, 214, 226)
	},
	{
		Id = "Gold",
		Name = "GOLD",
		CoinsLow = 120,
		CoinsHigh = 240,
		ItemChance = 0,
		Colour = Color3.fromRGB(255, 206, 74)
	}
}

PoolCardRewards.WinDrops = { Silver = 100 }
PoolCardRewards.LossDrops = { Wood = 100 }

PoolCardRewards.FirstMatchTier = "Silver"

PoolCardRewards.GemChance = 0.2
PoolCardRewards.GemsLow = 1
PoolCardRewards.GemsHigh = 5
PoolCardRewards.WinShare = { Low = 0.05, High = 0.1 }
PoolCardRewards.LossShare = { Low = 0.01, High = 0.02 }
PoolCardRewards.LossTier = "Wood"
PoolCardRewards.MinCoins = 1

local weights = {
	Tier1 = 40,
	Tier2 = 28,
	Tier3 = 18,
	Tier4 = 10,
	Tier5 = 4
}

PoolCardRewards.ItemPools = {
	{
		Category = "cueSticks",
		Weights = weights,
		Items = {
			"CueStick1",
			"CueStick2",
			"CueStick3",
			"CueStick4",
			"CueStick5",
			"CueStick6",
			"CueStick7",
			"CueStick8"
		}
	},
	{
		Category = "poolTables",
		Weights = weights,
		Items = {
			"PoolTable1",
			"PoolTable2",
			"PoolTable3",
			"PoolTable4",
			"PoolTable5",
			"PoolTable6",
			"PoolTable7"
		}
	},
	{
		Category = "poolEffects",
		Weights = weights,
		Items = {
			"Toxic",
			"Tentacles",
			"Sunburst",
			"Sunbeams",
			"Starburst",
			"Spiral",
			"Snowflake",
			"Smoke",
			"Seer",
			"Saturns Rings",
			"Rising Flames",
			"Red Energy",
			"Red Dwarf",
			"Radioactive",
			"RGB",
			"Power Charge",
			"Possessed",
			"Pink Explosion",
			"Lightshow",
			"Lightning Blast",
			"Inferno",
			"Headshot",
			"Green Disperse",
			"Golden",
			"Geometric",
			"Fractal",
			"Flame",
			"Electrocute",
			"Darkness",
			"Dark Aura",
			"Black Hole",
			"Big Ben",
			"Aurora Burst"
		}
	}
}

PoolCardRewards.FirstOpeningCues = { "Rainbow Prism", "Arctic Breath", "Crimson Dragon" }

PoolCardRewards.FirstOpeningDuplicateCoins = 1000

function PoolCardRewards.GetTier(p: string?)
	for _, tier in PoolCardRewards.Tiers do
		if tier.Id == p then
			return tier
		end
	end

	return nil
end

function PoolCardRewards.PendingList(p)
	local poolCardPicks = p and p.poolCardPicks
	local pending = poolCardPicks and poolCardPicks.pending
	local result = {}

	if typeof(pending) ~= "table" then
		return result
	end

	for k, v in pending do
		if not (typeof(v) == "table" and PoolCardRewards.GetTier(v.Tier)) then
			continue
		end

		table.insert(result, {
			Id = tostring(k),
			Tier = v.Tier,
			Source = tostring(v.Source),
			EarnedAt = tonumber(v.EarnedAt) or 0,
			Prize = tonumber(v.Prize)
		})
	end

	table.sort(result, function(a, b): boolean
		return (tonumber(a.Id) or 0) < (tonumber(b.Id) or 0)
	end)

	return result
end

function PoolCardRewards.NextPending(p)
	return PoolCardRewards.PendingList(p)[1]
end

function PoolCardRewards.HasPending(p): boolean
	return PoolCardRewards.NextPending(p) ~= nil
end

function PoolCardRewards.Openings(p)
	local poolCardOpenings = tonumber(p and p.poolCardOpenings) or 0
	local poolOnboardingRewards = p and p.poolOnboardingRewards

	return poolCardOpenings == 0
		and typeof(poolOnboardingRewards) == "table"
		and poolOnboardingRewards.IntroductionCueCard
		and 1
		or poolCardOpenings
end

function PoolCardRewards.IsFirstOpening(p): boolean
	return PoolCardRewards.Openings(p) == 0
end

local function weighted(items)
	local total = 0

	for _, item in items do
		total += math.max(item, 0)
	end

	if total <= 0 then
		return nil
	end

	local v = random:NextNumber() * total
	local v2 = nil

	for k, item in items do
		if not (item > 0) then
			continue
		end

		v -= item

		if v <= 0 then
			return k
		end

		v2 = k
	end

	return v2
end

local function rarityOf(p)
	local result = p and p.rarity

	if typeof(result) == "function" then
		local success
		success, result = pcall(result, {}, p)

		if not success then
			result = nil
		end
	end

	return if typeof(result) == "string" then result else nil
end

local function rollItem(p: number, itemPool)
	local function group(flag: boolean)
		local result = {}
		local count = 0

		for _, item in itemPool.Items do
			if flag and PoolSkins.Owns(p, itemPool.Category, item) then
				continue
			end

			local v = rarityOf(PoolSkins.GetItem(itemPool.Category, item))

			if not v then
				continue
			end

			result[v] = result[v] or {}
			table.insert(result[v], item)
			count += 1
		end

		return result, count
	end

	local v, v2 = group(true)
	local v3

	if v2 == 0 then
		local v4
		v, v4 = group(false)

		if v4 == 0 then
			return nil, false
		end

		v3 = true
	else
		v3 = false
	end

	local v4 = {}

	for k, v5 in v do
		local v6 = itemPool.Weights and itemPool.Weights[k]

		if v6 and v6 > 0 and #v5 > 0 then
			v4[k] = v6
		end
	end

	if next(v4) == nil then
		for k, v5 in v do
			if #v5 > 0 then
				v4[k] = 1
			end
		end
	end

	local v5 = weighted(v4)
	local v6 = v5 and v[v5]

	if v6 and #v6 ~= 0 then
		return v6[random:NextInteger(1, #v6)], v3
	end

	return nil, false
end

local function coinsFor(data, value: number?)
	if typeof(value) ~= "number" or value <= 0 then
		return random:NextInteger(data.CoinsLow, data.CoinsHigh)
	end

	local v

	if data.Id == PoolCardRewards.LossTier then
		v = PoolCardRewards.LossShare
	else
		v = PoolCardRewards.WinShare
	end

	local v2 = v.Low + random:NextNumber() * (v.High - v.Low)

	return (math.max(PoolCardRewards.MinCoins, (math.round(value * v2))))
end

local function rollReward(p: number, p2, flag: boolean, p3: number?)
	if random:NextNumber() < PoolCardRewards.GemChance then
		local integer = random:NextInteger(PoolCardRewards.GemsLow, PoolCardRewards.GemsHigh)

		if flag then
			PoolPlayerData.AddGems(p, integer)
		end

		return { Coins = 0, Gems = integer }
	else
		local coins = coinsFor(p2, p3)
		local v = { Coins = coins }

		if p2.ItemChance > 0 and random:NextNumber() < p2.ItemChance then
			local itemPools = PoolCardRewards.ItemPools
			local itemPool = itemPools[random:NextInteger(1, #itemPools)]
			local v2, v3 = rollItem(p, itemPool)

			if v2 then
				v.Category = itemPool.Category
				v.Item = v2

				if flag and not (v3 or PoolPlayerData.GrantSkin(p, itemPool.Category, v2)) or v3 then
					v.Duplicate = true
					v.Coins += coins
				end
			end
		end

		if flag then
			PoolPlayerData.AddCoins(p, v.Coins)
		end

		return v
	end
end

local function shuffle(list)
	for i = #list, 2, -1 do
		local integer = random:NextInteger(1, i)
		local item = list[integer]
		local item2 = list[i]
		list[i] = item
		list[integer] = item2
	end
end

local function firstOpening(p: number, p2)
	local firstOpeningCues = {}

	for _, firstOpeningCue in PoolCardRewards.FirstOpeningCues do
		if PoolSkins.GetItem("cueSticks", firstOpeningCue) then
			table.insert(firstOpeningCues, firstOpeningCue)
		else
			warn("[PoolCardRewards] FirstOpeningCues has an unknown cue: " .. tostring(firstOpeningCue))
		end
	end

	if #firstOpeningCues == 0 then
		return rollReward(p, p2, true), { rollReward(p, p2, false), rollReward(p, p2, false) }
	end

	local v = {}

	for _, v2 in firstOpeningCues do
		if not PoolSkins.Owns(p, "cueSticks", v2) then
			table.insert(v, v2)
		end
	end

	local v2 = if #v > 0 then v else firstOpeningCues
	local v3 = v2[random:NextInteger(1, #v2)]
	local v4 = {
		Coins = random:NextInteger(p2.CoinsLow, p2.CoinsHigh),
		Category = "cueSticks",
		Item = v3
	}

	if #v == 0 or not PoolPlayerData.GrantSkin(p, "cueSticks", v3) then
		v4.Duplicate = true
		v4.Coins += PoolCardRewards.FirstOpeningDuplicateCoins
	end

	PoolPlayerData.AddCoins(p, v4.Coins)

	local result = {}

	for _, v5 in firstOpeningCues do
		if v5 ~= v3 then
			table.insert(result, { Coins = 0, Category = "cueSticks", Item = v5 })
		end
	end

	shuffle(result)

	while #result > 2 do
		table.remove(result)
	end

	while #result < 2 do
		table.insert(result, rollReward(p, p2, false))
	end

	return v4, result
end

function PoolCardRewards.Award(p: number, flag: boolean, value: string?, p2: number?)
	if not isServer then
		return nil, "Server only"
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil, "No profile"
	end

	if #PoolCardRewards.PendingList(replica.Data) >= PoolCardRewards.MaxPending then
		return nil, "Too many unopened cards"
	end

	local v

	if flag then
		v = PoolCardRewards.WinDrops
	else
		v = PoolCardRewards.LossDrops
	end

	local v2 = weighted(v)

	if not (v2 and PoolCardRewards.GetTier(v2)) then
		v2 = PoolCardRewards.Tiers[1].Id
	end

	replica:Write("PoolCardPicks", "Add", v2, value or "Match", p2)

	return v2
end

function PoolCardRewards.AwardFirstMatch(p: number)
	if not isServer then
		return
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return
	end

	local tutorials = replica.Data.tutorials

	if typeof(tutorials) ~= "table" or not tutorials.Introduction then
		return
	end

	local poolOnboardingRewards = replica.Data.poolOnboardingRewards

	if typeof(poolOnboardingRewards) == "table" and poolOnboardingRewards.IntroductionCueCardOwed then
		return
	end

	replica:Write("PoolOnboardingReward", "IntroductionCueCardOwed")
	replica:Write("PoolCardPicks", "Add", PoolCardRewards.FirstMatchTier, "FirstMatch")
end

function PoolCardRewards.Claim(p: number)
	if not isServer then
		return nil, "Server only"
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil, "Your data is still loading"
	end

	local pending = PoolCardRewards.NextPending(replica.Data)

	if not pending then
		return nil, "There are no cards to open"
	end

	local v = PoolCardRewards.GetTier(pending.Tier) or PoolCardRewards.Tiers[1]
	local isFirstOpening = PoolCardRewards.IsFirstOpening(replica.Data)

	replica:Write("PoolCardPicks", "Remove", pending.Id)
	replica:Write("PoolCardOpenings")
	local reward, others

	if isFirstOpening then
		reward, others = firstOpening(p, v)
	else
		reward = rollReward(p, v, true, pending.Prize)
		others = { rollReward(p, v, false, pending.Prize), rollReward(p, v, false, pending.Prize) }
	end

	return {
		Id = pending.Id,
		Tier = v.Id,
		First = isFirstOpening,
		Reward = reward,
		Others = others
	}
end

return PoolCardRewards