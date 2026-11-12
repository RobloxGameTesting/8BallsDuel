local RunService = game:GetService("RunService")

local PoolConstants = require(script.Parent.PoolConstants)

local PoolStarPacks = {}

PoolStarPacks.StarsPerPack = PoolConstants.StarsPerPresent or 100
PoolStarPacks.DuplicateCoins = 1000
PoolStarPacks.FlagPrefix = "StarPack"
PoolStarPacks.Finish = "Gold"
local drops = {
	{ Category = "cueSticks", Item = "SpiderCue", Weight = 1 },
	{ Category = "cueSticks", Item = "Flaming", Weight = 1 },
	{ Category = "cueSticks", Item = "MoonblossomCue", Weight = 1 },
	{ Category = "cueSticks", Item = "Longblade", Weight = 1 }
}

PoolStarPacks.Drops = drops

function PoolStarPacks.TotalStars(p)
	local poolLevels = p and p.poolLevels
	local total = 0

	if typeof(poolLevels) ~= "table" then
		return 0
	end

	for _, poolLevel in poolLevels do
		if typeof(poolLevel) == "number" then
			total += math.clamp(math.floor(poolLevel), 0, 4)
		end
	end

	return total
end

function PoolStarPacks.FlagKey(p: number)
	return PoolStarPacks.FlagPrefix .. tostring(p)
end

function PoolStarPacks.Earned(p)
	return (math.floor(PoolStarPacks.TotalStars(p) / math.max(PoolStarPacks.StarsPerPack, 1)))
end

function PoolStarPacks.IsOpened(p, p2: number): boolean
	local poolOnboardingRewards = p and p.poolOnboardingRewards

	return typeof(poolOnboardingRewards) == "table" and poolOnboardingRewards[PoolStarPacks.FlagKey(p2)] == true
end

function PoolStarPacks.NextUnopened(p)
	for i = 1, PoolStarPacks.Earned(p) do
		if not PoolStarPacks.IsOpened(p, i) then
			return i
		end
	end

	return nil
end

function PoolStarPacks.Ready(p)
	local count = 0

	for i = 1, PoolStarPacks.Earned(p) do
		if not PoolStarPacks.IsOpened(p, i) then
			count += 1
		end
	end

	return count
end

function PoolStarPacks.StarsToNext(p)
	local v = math.max(PoolStarPacks.StarsPerPack, 1)

	return v - PoolStarPacks.TotalStars(p) % v
end

function PoolStarPacks.Roll(p, p2)
	local v = p2 or drops
	local total = 0

	for _, v2 in v do
		total += math.max(v2.Weight, 0)
	end

	if total <= 0 then
		return nil
	end

	local number = (p or Random.new()):NextNumber(0, total)

	for _, v2 in v do
		number -= math.max(v2.Weight, 0)

		if number <= 0 then
			return v2
		end
	end

	return v[#v]
end

function PoolStarPacks.Claim(p: number)
	if not RunService:IsServer() then
		return nil, "Server only"
	end

	local PoolPlayerData = require(script.Parent.PoolPlayerData)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil, "Your data hasn't loaded yet, try again!"
	end

	local unopened = PoolStarPacks.NextUnopened(replica.Data)

	if not unopened then
		local starsToNext = PoolStarPacks.StarsToNext(replica.Data)

		return nil, string.format("%d more star%s to your next pack!", starsToNext, starsToNext == 1 and "" or "s")
	end

	local PoolSkins = require(script.Parent.PoolSkins)
	local v = {}

	for _, v2 in drops do
		if not PoolSkins.Owns(p, v2.Category, v2.Item) then
			table.insert(v, v2)
		end
	end

	local roll = PoolStarPacks.Roll

	if not (#v > 0) then
		v = nil
	end

	local v2 = roll(nil, v)

	if not v2 then
		warn("[PoolStarPacks] DROPS is empty")

		return nil, "Packs aren't set up yet, report to dev!"
	end

	replica:Write("PoolOnboardingReward", PoolStarPacks.FlagKey(unopened))

	local v3 = PoolPlayerData.GrantSkin(p, v2.Category, v2.Item)

	if not v3 then
		PoolPlayerData.AddCoins(p, PoolStarPacks.DuplicateCoins)
	end

	return {
		Pack = unopened,
		Category = v2.Category,
		Item = v2.Item,
		Duplicate = not v3,
		Coins = v3 and 0 or PoolStarPacks.DuplicateCoins,
		Finish = PoolStarPacks.Finish
	}, nil
end

return PoolStarPacks