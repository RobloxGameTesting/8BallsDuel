local PoolMatchmakingConstants = {}
PoolMatchmakingConstants.SkillBracketCutoff = 50
PoolMatchmakingConstants.LowerFactor = 0.5
PoolMatchmakingConstants.UpperFactor = 2
PoolMatchmakingConstants.MinLevelDifference = 5
PoolMatchmakingConstants.BandWidenAfter = 15
PoolMatchmakingConstants.WidenPerStep = 0.25
PoolMatchmakingConstants.MinLowerFactor = 0.1
PoolMatchmakingConstants.MaxUpperFactor = 20
PoolMatchmakingConstants.PollInterval = 2
PoolMatchmakingConstants.EntryExpiry = 90
PoolMatchmakingConstants.StaleAfter = 60
PoolMatchmakingConstants.QueuePrefix = "PoolQueue_"
PoolMatchmakingConstants.MessagingTopic = "PoolMatchFound"
PoolMatchmakingConstants.MutualWeight = 0.6
PoolMatchmakingConstants.MinOpponentWinRate = 0.25
PoolMatchmakingConstants.WinRateFloorGames = 10
PoolMatchmakingConstants.FloorRelaxAfter = 45
PoolMatchmakingConstants.WaitBonusPerSecond = 0.002
PoolMatchmakingConstants.MaxWaitBonus = 0.15
PoolMatchmakingConstants.MatchExperience = 150
PoolMatchmakingConstants.PocketExperience = 15
PoolMatchmakingConstants.WinExperienceMultiplier = 1.5
PoolMatchmakingConstants.ResultDelay = 1.5
PoolMatchmakingConstants.TurnStartDelay = 0.75
PoolMatchmakingConstants.RackDelay = 1
PoolMatchmakingConstants.TakeoverNoticeDelay = 2
PoolMatchmakingConstants.IntroSeconds = 5
PoolMatchmakingConstants.TurnGrace = 1.5
PoolMatchmakingConstants.PublishAttempts = 3
PoolMatchmakingConstants.PublishRetryDelay = 1
PoolMatchmakingConstants.SubscribeRetryDelay = 5
PoolMatchmakingConstants.AimRate = 60
PoolMatchmakingConstants.BotAimRate = PoolMatchmakingConstants.AimRate

PoolMatchmakingConstants.BotTheatreReserve = 3

function PoolMatchmakingConstants.GetLevelRange(p: number, p2: number)
	if PoolMatchmakingConstants.SkillBracketCutoff < p then
		return 1, 1e999
	end

	local v = 1 + math.floor(math.max(p2, 0) / PoolMatchmakingConstants.BandWidenAfter) * PoolMatchmakingConstants.WidenPerStep

	local v2 = math.max(PoolMatchmakingConstants.LowerFactor / v, PoolMatchmakingConstants.MinLowerFactor)

	local v3 = math.min(PoolMatchmakingConstants.UpperFactor * v, PoolMatchmakingConstants.MaxUpperFactor)

	local minLevelDifference = PoolMatchmakingConstants.MinLevelDifference
	local v4 = math.min(math.floor(p * v2), p - minLevelDifference)
	local v5 = math.max(math.ceil(p * v3), p + minLevelDifference)

	return math.max(1, v4), (math.max(1, v5))
end

function PoolMatchmakingConstants.IsCompatible(p: number, p2: number, p3: number, p4: number): boolean
	local levelRange, v = PoolMatchmakingConstants.GetLevelRange(p, p2)
	local levelRange2, v2 = PoolMatchmakingConstants.GetLevelRange(p3, p4)

	return levelRange <= p3 and p3 <= v and levelRange2 <= p and p <= v2
end

PoolMatchmakingConstants.ChatMaxLength = 100

PoolMatchmakingConstants.ChatCooldown = 1.5

PoolMatchmakingConstants.ChatEnabled = false

PoolMatchmakingConstants.BotMatchmakingMaxLevel = 10000

PoolMatchmakingConstants.BotSearchMinSeconds = 2
PoolMatchmakingConstants.BotSearchMaxSeconds = 3.5

PoolMatchmakingConstants.AfkTurnsBeforeCover = 1

PoolMatchmakingConstants.AfkActiveWindow = 3

PoolMatchmakingConstants.AfkBotLevel = "Amateur"

PoolMatchmakingConstants.BotStepUpAfterGames = 5
PoolMatchmakingConstants.BotStepUpChance = 0.2

PoolMatchmakingConstants.BotBreakChance = 0.3

PoolMatchmakingConstants.BotRematchChance = 0.5
PoolMatchmakingConstants.BotRematchDelay = { Min = 1, Max = 4 }

PoolMatchmakingConstants.PrintBotProfiles = true

PoolMatchmakingConstants.BotStepUpWinRate = 0.8
PoolMatchmakingConstants.BotStepUpWinRateMinGames = 10

PoolMatchmakingConstants.BotStepDownWinRate = 0.65
PoolMatchmakingConstants.BotStepDownWinRateMinGames = 10
PoolMatchmakingConstants.BotStruggleWinRate = 0.55
PoolMatchmakingConstants.BotStruggleDifficulty = "Beginner"

PoolMatchmakingConstants.BotNewPlayerWins = 8
PoolMatchmakingConstants.BotNewPlayerEasierChance = 0.5

PoolMatchmakingConstants.BotWinRateBands = {
	Brazil = { Struggle = 0.64, StepDown = 0.74, StepUp = 0.89 },
	UnitedStates = { Struggle = 0.63, StepDown = 0.73, StepUp = 0.88 },
	Indonesia = { Struggle = 0.61, StepDown = 0.71, StepUp = 0.86 },
	Argentina = { Struggle = 0.6, StepDown = 0.7, StepUp = 0.85 },
	UnitedKingdom = { Struggle = 0.58, StepDown = 0.68, StepUp = 0.83 },
	Mexico = { Struggle = 0.57, StepDown = 0.67, StepUp = 0.82 },
	Canada = { Struggle = 0.55, StepDown = 0.65, StepUp = 0.8 },
	Philippines = { Struggle = 0.545, StepDown = 0.645, StepUp = 0.795 },
	Italy = { Struggle = 0.54, StepDown = 0.64, StepUp = 0.79 },
	Thailand = { Struggle = 0.52, StepDown = 0.62, StepUp = 0.77 },
	Germany = { Struggle = 0.515, StepDown = 0.615, StepUp = 0.765 },
	Monaco = { Struggle = 0.51, StepDown = 0.61, StepUp = 0.76 },
	Greece = { Struggle = 0.49, StepDown = 0.59, StepUp = 0.74 },
	Turkey = { Struggle = 0.48, StepDown = 0.58, StepUp = 0.73 },
	Spain = { Struggle = 0.46, StepDown = 0.56, StepUp = 0.71 }
}

PoolMatchmakingConstants.PreferFriendDisguise = false

PoolMatchmakingConstants.FriendFallbackUserIds = {}

PoolMatchmakingConstants.StudioPlaceholderUserIds = { 156, 1 }

PoolMatchmakingConstants.MatchmakingModes = {
	Auto = "Auto",
	RealOnline = "RealOnline",
	Bot = "Bot"
}

function PoolMatchmakingConstants.UsesBotMatchmaking(p: number, p2): boolean
	local matchmakingModes = PoolMatchmakingConstants.MatchmakingModes
	local matchmaking = p2 and p2.Matchmaking

	if matchmaking == matchmakingModes.RealOnline then
		return false
	end

	if matchmaking == matchmakingModes.Bot then
		return true
	end

	if matchmaking ~= nil and matchmaking ~= matchmakingModes.Auto then
		warn(string.format(
			"[PoolMatchmakingConstants] a venue has Matchmaking = %q, which is not one of Auto/RealOnline/Bot. Falling back to Auto.",
			(tostring(matchmaking))
		))
	end

	return p <= PoolMatchmakingConstants.BotMatchmakingMaxLevel
end

return PoolMatchmakingConstants