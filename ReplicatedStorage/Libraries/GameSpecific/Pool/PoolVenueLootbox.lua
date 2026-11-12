local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)

local PoolVenueLootbox = {}

local isServer = RunService:IsServer()

PoolVenueLootbox.Odds = {
	{ Kind = "Coins", Weight = 40 },
	{ Kind = "Gems", Weight = 50 },
	{ Kind = "Table", Weight = 6 },
	{ Kind = "Cue", Weight = 4 }
}

PoolVenueLootbox.Tables = {
	"PoolTable2",
	"PoolTable3",
	"PoolTable4",
	"PoolTable5",
	"PoolTable6",
	"PoolTable7",
	"PoolTable13"
}

PoolVenueLootbox.Cues = {
	"CueStick2",
	"CueStick3",
	"CueStick5",
	"CueStick6",
	"CueStick7",
	"CueStick8",
	"Arctic Breath",
	"Crimson Dragon",
	"Rainbow Prism",
	"Skyfeather",
	"SciFi",
	"Trident",
	"EmeraldFracture",
	"SpiderCue",
	"Flaming",
	"MoonblossomCue",
	"Longblade",
	"CamoCue",
	"RazorsteelCue",
	"AlchemyCue",
	"GoldenCoreCue",
	"IroncladCue",
	"DragonSummonerCue"
}

local function count(p) -- 3 equivalent calls inferred from this helper
	local v = tonumber(p)

	if v and v == v and v ~= 1e999 then
		return (math.max(math.floor(v), 0))
	end

	return 0
end

local function ladders() -- 2 equivalent calls inferred from this helper
	return { PoolConstants.Venues, PoolConstants.NineBallVenues }
end

local function rung(p: string?)
	for _, v in ladders() do -- inferred equivalent call
		for k, v2 in v do
			if v2.Id == p then
				return k, #v
			end
		end
	end

	return nil, 0
end

local function height(p: string?) -- 2 equivalent calls inferred from this helper
	local v, v2 = rung(p)

	if not v then
		return 0
	end

	if v2 > 1 then
		return (v - 1) / (v2 - 1)
	end

	return 1
end

local function tidy(p: number) -- 3 equivalent calls inferred from this helper
	local v = math.max(p, 0)

	if v < 100 then
		return (math.floor(v + 0.5))
	end

	local v2 = 10 ^ (math.floor((math.log10(v))) - 1)

	return math.floor(v / v2 + 0.5) * v2
end

local function skins() -- 2 equivalent calls inferred from this helper
	local PoolSkins = require(Pool.PoolSkins)
	return PoolSkins
end

function PoolVenueLootbox.WinsPerBox()
	return (math.max(count(PoolConstants.VenueRewardWins), 1)) -- inferred equivalent call
end

function PoolVenueLootbox.IsBoxVenue(p: string?): boolean
	return rung(p) ~= nil
end

function PoolVenueLootbox.AllVenues()
	local result = {}

	for _, v in ladders() do -- inferred equivalent call
		for _, v2 in v do
			table.insert(result, v2)
		end
	end

	return result
end

function PoolVenueLootbox.BoxName(p: string)
	local venue = PoolConstants.GetVenue(p)

	if not venue then
		return p
	end

	if venue.GameType == "NineBall" then
		return venue.Name .. " 9 BALL"
	end

	return venue.Name
end

function PoolVenueLootbox.Wins(p, p2: string)
	local poolVenueWins

	if typeof(p) == "table" then
		poolVenueWins = p.poolVenueWins
	end

	if typeof(poolVenueWins) ~= "table" then
		return 0
	end

	return count(poolVenueWins[p2]) -- inferred equivalent call
end

function PoolVenueLootbox.Earned(p, p2: string)
	if PoolVenueLootbox.IsBoxVenue(p2) then
		return (math.floor(PoolVenueLootbox.Wins(p, p2) / PoolVenueLootbox.WinsPerBox()))
	end

	return 0
end

function PoolVenueLootbox.HasRecord(p, p2: string): boolean
	local poolVenueBoxes

	if typeof(p) == "table" then
		poolVenueBoxes = p.poolVenueBoxes
	end

	return typeof(poolVenueBoxes) == "table" and poolVenueBoxes[p2] ~= nil
end

function PoolVenueLootbox.Opened(p, p2: string)
	local poolVenueBoxes

	if typeof(p) == "table" then
		poolVenueBoxes = p.poolVenueBoxes
	end

	local v

	if typeof(poolVenueBoxes) == "table" then
		v = poolVenueBoxes[p2]
	end

	if v == nil then
		return (math.max(PoolVenueLootbox.Earned(p, p2) - 1, 0))
	end

	return count(v) -- inferred equivalent call
end

function PoolVenueLootbox.Waiting(p, p2: string)
	return (math.max(PoolVenueLootbox.Earned(p, p2) - PoolVenueLootbox.Opened(p, p2), 0))
end

function PoolVenueLootbox.TotalWaiting(p)
	local total = 0

	for _, v in PoolVenueLootbox.AllVenues() do
		total += PoolVenueLootbox.Waiting(p, v.Id)
	end

	return total
end

function PoolVenueLootbox.NextWaiting(p)
	for _, v in PoolVenueLootbox.AllVenues() do
		if PoolVenueLootbox.Waiting(p, v.Id) > 0 then
			return v.Id
		end
	end

	return nil
end

function PoolVenueLootbox.Progress(p, p2: string)
	return PoolVenueLootbox.Wins(p, p2) % PoolVenueLootbox.WinsPerBox()
end

function PoolVenueLootbox.CoinRange(p: string)
	local venue = PoolConstants.GetVenue(p)
	local v = not venue and 0 or venue.Prize

	return math.max(tidy(v * 1), 10), (math.max(tidy(v * 3), 10)) -- inferred equivalent call
end

function PoolVenueLootbox.GemRange(p: string)
	local v = height(p) * 45 + 5 -- inferred equivalent call

	return math.max(math.floor(v * 0.6 + 0.5), 1), (math.max(math.floor(v * 1.4 + 0.5), 1))
end

local v = nil

function PoolVenueLootbox.RankedCues()
	if v then
		return v
	end

	local PoolSkins = skins() -- inferred equivalent call
	local v2 = {}

	for _, cue in PoolVenueLootbox.Cues do
		local item = PoolSkins.GetItem("cueSticks", cue)
		local v3 = item and PoolConstants.Cues[item.cue]

		if v3 then
			table.insert(v2, {
				Key = cue,
				Total = (v3.Time or 0) + (v3.Spin or 0) + (v3.Aim or 0) + (v3.Force or 0)
			})
		else
			warn("[PoolVenueLootbox] " .. cue .. " is not a cue with stats; left out of the box")
		end
	end

	table.sort(v2, function(a, b): boolean
		if a.Total == b.Total then
			return a.Key < b.Key
		end

		return a.Total < b.Total
	end)

	local result = {}

	for _, v3 in v2 do
		table.insert(result, v3.Key)
	end

	v = result

	return result
end

function PoolVenueLootbox.CuesFor(p: string)
	local rankedCues = PoolVenueLootbox.RankedCues()
	local v2 = math.min(6, #rankedCues)
	local v3 = math.floor(height(p) * (#rankedCues - v2) + 0.5) + 1 -- inferred equivalent call
	local result = {}

	for i = v3, v3 + v2 - 1 do
		table.insert(result, rankedCues[i])
	end

	return result
end

local function rollKind(random)
	local total = 0

	for _, odd in PoolVenueLootbox.Odds do
		total += math.max(odd.Weight, 0)
	end

	local number = random:NextNumber(0, total)

	for _, odd in PoolVenueLootbox.Odds do
		number -= math.max(odd.Weight, 0)

		if number <= 0 then
			return odd.Kind
		end
	end

	return "Coins"
end

function PoolVenueLootbox.RollCoins(p: string, p2)
	local coinRange, v2 = PoolVenueLootbox.CoinRange(p)

	return (math.max(tidy((p2 or Random.new()):NextNumber(coinRange, v2)), 10)) -- inferred equivalent call
end

function PoolVenueLootbox.RollGems(p: string, p2)
	local gemRange, v2 = PoolVenueLootbox.GemRange(p)

	return (p2 or Random.new()):NextInteger(gemRange, v2)
end

function PoolVenueLootbox.EnsureRecord(p: number)
	if not isServer then
		return
	end

	local PoolPlayerData = require(Pool.PoolPlayerData)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica or typeof(replica.Data) ~= "table" then
		return
	end

	for _, v2 in PoolVenueLootbox.AllVenues() do
		if not PoolVenueLootbox.HasRecord(replica.Data, v2.Id) then
			replica:Write("PoolVenueBoxes", v2.Id, PoolVenueLootbox.Opened(replica.Data, v2.Id))
		end
	end
end

function PoolVenueLootbox.Claim(p: number, venue: string?)
	if not isServer then
		return nil, "Server only"
	end

	local PoolPlayerData = require(Pool.PoolPlayerData)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica or typeof(replica.Data) ~= "table" then
		return nil, "Your data hasn't loaded yet, try again!"
	end

	local data = replica.Data

	if typeof(venue) ~= "string" or not (PoolVenueLootbox.Waiting(data, venue) > 0) then
		venue = PoolVenueLootbox.NextWaiting(data)
	end

	if not venue then
		return nil, string.format("Win %d times at a country to earn a lootbox!", PoolVenueLootbox.WinsPerBox())
	end

	replica:Write("PoolVenueBoxes", venue, PoolVenueLootbox.Opened(data, venue) + 1)

	local random = Random.new()
	local kind = rollKind(random)
	local v2 = {
		Venue = venue,
		VenueName = PoolVenueLootbox.BoxName(venue),
		Kind = kind,
		Category = nil,
		Item = nil,
		Amount = 0,
		Duplicate = false,
		Coins = 0
	}

	if kind == "Gems" then
		v2.Amount = PoolVenueLootbox.RollGems(venue, random)
		PoolPlayerData.AddGems(p, v2.Amount)
	else
		if kind == "Table" or kind == "Cue" then
			local PoolSkins = skins() -- inferred equivalent call
			local category = kind == "Table" and "poolTables" or "cueSticks"
			local v3

			if kind == "Table" then
				v3 = PoolVenueLootbox.Tables
			else
				v3 = PoolVenueLootbox.CuesFor(venue)
			end

			local v4 = {}
			local v5 = {}

			for _, v6 in v3 do
				if not PoolSkins.GetItem(category, v6) then
					continue
				end

				table.insert(v4, v6)

				if not PoolSkins.Owns(p, category, v6) then
					table.insert(v5, v6)
				end
			end

			if #v4 > 0 then
				if #v5 > 0 then
					v4 = v5
				end

				local v6 = v4[random:NextInteger(1, #v4)]

				v2.Category = category
				v2.Item = v6

				if #v5 > 0 and PoolPlayerData.GrantSkin(p, category, v6) then
					return v2, nil
				end

				v2.Duplicate = true
				v2.Coins = PoolVenueLootbox.RollCoins(venue, random)
				PoolPlayerData.AddCoins(p, v2.Coins)

				return v2, nil
			end

			warn("[PoolVenueLootbox] no valid " .. category .. " in the box; paying coins")
			v2.Kind = "Coins"
		end

		v2.Amount = PoolVenueLootbox.RollCoins(venue, random)
		PoolPlayerData.AddCoins(p, v2.Amount)
	end

	return v2, nil
end

return PoolVenueLootbox