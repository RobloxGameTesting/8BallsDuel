local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Level = require(ReplicatedStorage.Libraries.Modules.Level)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolBotProfiles = require(Pool.PoolBotProfiles)
local PoolConstants = require(Pool.PoolConstants)
local PoolMatchmakingConstants = require(Pool.PoolMatchmakingConstants)
local PoolVenueProgress = require(Pool.PoolVenueProgress)
local PoolWorldPass = require(Pool.PoolWorldPass)

local PoolPlayerStats = {}

local function whole(p) -- 21 equivalent calls inferred from this helper
	local v = tonumber(p)

	if v and v == v and v ~= 1e999 then
		return (math.max(math.floor(v), 0))
	end

	return 0
end

local function venuesUnlocked(p: number, poolVenueWins, flag: boolean) -- 1 equivalent call inferred from this helper
	return PoolVenueProgress.CountUnlocked(p, poolVenueWins, flag)
end

local function botsBeaten(poolBotWins)
	if typeof(poolBotWins) ~= "table" then
		return 0
	end

	local count = 0

	for _, level in PoolConstants.Bots.Levels do
		if whole(poolBotWins[level.Id]) >= PoolConstants.BotUnlockWins then -- inferred equivalent call
			count += 1
		end
	end

	return count
end

local function levelOf(p: number) -- 1 equivalent call inferred from this helper
	local level, v, v2 = Level:GetLevel(p, "LEVEL_EQUATION")
	local v3 = tonumber(v) or 0
	local v4 = math.max((tonumber(v2) or v3 + 1) - v3, 1)

	return math.max(tonumber(level) or 1, 1), (math.clamp((p - v3) / v4, 0, 1))
end

function PoolPlayerStats.FromData(p, p2: number?)
	local v = typeof(p) ~= "table" and {} or p
	local v2 = typeof(v.poolStats) ~= "table" and {} or v.poolStats
	local v3 = typeof(v.poolLifetime) ~= "table" and {} or v.poolLifetime
	local level, levelProgress = levelOf(whole(v.experience)) -- inferred equivalent call
	local winStreak = whole(v.winStreak) -- inferred equivalent call

	return {
		Wins = whole(v2.wins), -- inferred equivalent call
		Losses = whole(v2.losses), -- inferred equivalent call
		WinStreak = winStreak,
		BestStreak = math.max(whole(v3.bestWinStreak), winStreak), -- inferred equivalent call
		BallsPotted = whole(v3.ballsPotted), -- inferred equivalent call
		BreakPots = whole(v3.breakPots), -- inferred equivalent call
		Level = level,
		LevelProgress = levelProgress,
		VenuesUnlocked = venuesUnlocked(level, v.poolVenueWins, PoolWorldPass.Owns(p2)), -- inferred equivalent call
		VenuesTotal = #PoolConstants.Venues,
		BotsBeaten = botsBeaten(v.poolBotWins),
		BotsTotal = #PoolConstants.Bots.Levels,
		MemberSince = whole(v.firstPlay) -- inferred equivalent call
	}
end

function PoolPlayerStats.ForLocal(p: number)
	local playerReplica = Profiles.GetPlayerReplica((tostring(p)))

	if playerReplica and typeof(playerReplica.Data) == "table" then
		return PoolPlayerStats.FromData(playerReplica.Data, p)
	end

	return nil
end

local v = {}

local function prune()
	local count = 0

	for _ in v do
		count += 1
	end

	if count < 200 then
		return
	end

	local v2 = os.clock() - 7200

	for k, v3 in v do
		if v3.At < v2 then
			v[k] = nil
		end
	end
end

function PoolPlayerStats.ForUser(value: number)
	if typeof(value) ~= "number" or value <= 0 then
		return nil
	end

	local playerReplica = Profiles.GetPlayerReplica((tostring(value)))

	if playerReplica and typeof(playerReplica.Data) == "table" then
		local snapshot = PoolPlayerStats.FromData(playerReplica.Data, value)

		v[value] = { At = os.clock(), Snapshot = snapshot }
		prune()

		return snapshot
	else
		local v2 = v[value]

		return if v2 then v2.Snapshot else nil
	end
end

local function venueIndex(p: string?) -- 2 equivalent calls inferred from this helper
	if not p then
		return nil
	end

	for k, venue in PoolConstants.Venues do
		if venue.Id == p then
			return k
		end
	end

	return nil
end

function PoolPlayerStats.SeedFor(value: number?, value2: string?)
	if typeof(value) == "number" and value > 0 then
		return (math.floor(value))
	end

	local v2 = 5381

	for i = 1, #(value2 or "") do
		v2 = (v2 * 33 + string.byte(value2, i)) % 2147483647
	end

	return v2
end

local function experienceForLevel(p: number)
	local v2 = 1
	local v3 = 0

	while true do
		local level, v4, v5 = Level:GetLevel(v2, "LEVEL_EQUATION")
		local v6 = tonumber(v4) or 0
		local v7 = math.max((tonumber(v5) or v6 + 1) - v6, 1)

		local v8 = math.max(tonumber(level) or 1, 1)
		math.clamp((v2 - v6) / v7, 0, 1)

		if not (v8 < p and v2 < 1000000000) then
			break
		end

		v2 *= 2
	end

	for _ = 1, 40 do
		if v2 - v3 <= 1 then
			break
		end

		local v4 = math.floor((v3 + v2) / 2)
		local level, v5, v6 = Level:GetLevel(v4, "LEVEL_EQUATION")
		local v7 = tonumber(v5) or 0
		local v8 = math.max((tonumber(v6) or v7 + 1) - v7, 1)

		local v9 = math.max(tonumber(level) or 1, 1)
		math.clamp((v4 - v7) / v8, 0, 1)

		if p <= v9 then
			v2 = v4
		else
			v3 = v4
		end
	end

	return v2
end

function PoolPlayerStats.LevelForRating(p: number, p2: number)
	local random = Random.new(p2 + 7)
	return (math.max(math.floor(math.max((p - 500) / 30, 2) * random:NextNumber(0.75, 1.3)), 1))
end

function PoolPlayerStats.LevelForVenue(p: string, p2: number)
	local record = PoolBotProfiles.GetRecord(p)
	local v2 = math.max(record.Levels.Min, 1)
	local v3 = math.max(record.Levels.Max, v2)
	local number = Random.new((p2 + (venueIndex(p) or 0) * 104729) % 2147483647):NextNumber() -- inferred equivalent call

	return (math.max(math.floor(math.exp(math.log(v2) + (math.log(v3) - math.log(v2)) * number) + 0.5), 1))
end

local v2 = {}

function PoolPlayerStats.RecordBotResult(value: number, flag: boolean)
	if typeof(value) ~= "number" then
		return
	end

	local v3 = v2[value]

	if not v3 then
		v3 = {}
		v2[value] = v3
	end

	table.insert(v3, flag == true)

	if #v3 > 200 then
		table.remove(v3, 1)
	end
end

local function withBotResults(p: number, state)
	local v3 = v2[p]

	if not v3 or #v3 == 0 then
		return state
	end

	local winStreak = state.WinStreak
	local bestStreak = state.BestStreak

	for _, v4 in v3 do
		if v4 then
			state.Wins += 1
			winStreak += 1
			bestStreak = math.max(bestStreak, winStreak)
		else
			state.Losses += 1
			winStreak = 0
		end
	end

	state.WinStreak = winStreak
	state.BestStreak = bestStreak

	return state
end

function PoolPlayerStats.Fake(p: number, p2: number?, p3: number?, p4: string?)
	local random = Random.new(p)
	local level = math.max(math.floor(tonumber(p2) or 1), 1)
	local k = venueIndex(p4) -- inferred equivalent call
	local number = random:NextNumber(-0.05, 0.05)
	local v3

	if k then
		local winRate = PoolBotProfiles.GetRecord(p4).WinRate

		v3 = math.clamp(winRate.Min + (winRate.Max - winRate.Min) * random:NextNumber(), 0.3, 0.8)
	else
		v3 = math.clamp((not p3 and 0.5 or math.clamp(0.5 + (p3 - 1200) / 2600, 0.34, 0.7)) + number, 0.3, 0.74)
	end

	local pocketExperience = PoolMatchmakingConstants.PocketExperience
	local v4 = PoolMatchmakingConstants.MatchExperience + 3 * pocketExperience
	local v5 = v4 + v3 * ((PoolMatchmakingConstants.MatchExperience + 7 * pocketExperience) * PoolMatchmakingConstants.WinExperienceMultiplier - v4)

	local v6 = experienceForLevel(level)
	local v7 = experienceForLevel(level + 1)
	local number2 = random:NextNumber(0.08, 0.92)
	local v8 = math.max(math.floor((v6 + (v7 - v6) * number2) * random:NextNumber(0.85, 1.02) / v5 + 0.5), 0)
	local wins = math.clamp(math.floor(v8 * v3 + random:NextNumber(-0.5, 0.5) + 0.5), 0, v8)
	local losses = v8 - wins
	local count = 0

	while count < math.min(wins, 9) and random:NextNumber() < v3 do
		count += 1
	end

	local bestStreak = math.clamp(
		math.max(
			math.floor((not (v8 > 0) and 0 or math.log((math.max(v8 * (1 - v3), 1))) / math.log(1 / v3)) + random:NextNumber(-0.4, 1.6) + 0.5),
			count,
			(math.min(wins, 1))
		),
		0,
		wins
	)

	local ballsPotted = math.floor(v8 * random:NextNumber(4.3, 5.4) * (v3 * 0.3 + 0.85) + 0.5)
	local breakPots = math.floor(v8 * random:NextNumber(0.45, 0.85) + 0.5)

	local count2 = #PoolConstants.Venues
	local venuesUnlocked2 = math.clamp(PoolVenueProgress.CountUnlocked(level, nil, false), math.min(count2, 1), count2)

	if k then
		venuesUnlocked2 = math.clamp(math.max(venuesUnlocked2, k), 1, count2)
	end

	local count3 = #PoolConstants.Bots.Levels
	local botsBeaten2 = math.clamp(math.floor(level / random:NextNumber(3, 6)) + random:NextInteger(0, 1), 0, count3)

	local v9 = math.clamp(math.floor(v8 / random:NextNumber(25, 60)) + random:NextInteger(0, 2), 0, 8)
	local v10 = os.date("!*t")
	local month = v10.month - v9
	local year = v10.year

	while month < 1 do
		month += 12
		year -= 1
	end

	local integer = random:NextInteger(1, 28)

	if v9 == 0 then
		integer = math.min(integer, v10.day)
	end

	return withBotResults(p, {
		Wins = wins,
		Losses = losses,
		WinStreak = count,
		BestStreak = bestStreak,
		BallsPotted = ballsPotted,
		BreakPots = breakPots,
		Level = level,
		LevelProgress = number2,
		VenuesUnlocked = venuesUnlocked2,
		VenuesTotal = count2,
		BotsBeaten = botsBeaten2,
		BotsTotal = count3,
		MemberSince = os.time({ year = year, month = month, day = integer, hour = 12 })
	})
end

function PoolPlayerStats.Games(p)
	return p.Wins + p.Losses
end

function PoolPlayerStats.WinRate(p)
	local games = PoolPlayerStats.Games(p)

	if games <= 0 then
		return nil
	end

	return p.Wins / games
end

function PoolPlayerStats.Sanitize(data)
	if typeof(data) ~= "table" then
		return nil
	end

	local levelProgress = tonumber(data.LevelProgress) or 0
	local v3 = levelProgress ~= levelProgress and 0 or levelProgress
	return {
		Wins = whole(data.Wins), -- inferred equivalent call
		Losses = whole(data.Losses), -- inferred equivalent call
		WinStreak = whole(data.WinStreak), -- inferred equivalent call
		BestStreak = whole(data.BestStreak), -- inferred equivalent call
		BallsPotted = whole(data.BallsPotted), -- inferred equivalent call
		BreakPots = whole(data.BreakPots), -- inferred equivalent call
		Level = math.max(whole(data.Level), 1), -- inferred equivalent call
		LevelProgress = math.clamp(v3, 0, 1),
		VenuesUnlocked = whole(data.VenuesUnlocked), -- inferred equivalent call
		VenuesTotal = whole(data.VenuesTotal), -- inferred equivalent call
		BotsBeaten = whole(data.BotsBeaten), -- inferred equivalent call
		BotsTotal = whole(data.BotsTotal), -- inferred equivalent call
		MemberSince = whole(data.MemberSince) -- inferred equivalent call
	}
end

return PoolPlayerStats