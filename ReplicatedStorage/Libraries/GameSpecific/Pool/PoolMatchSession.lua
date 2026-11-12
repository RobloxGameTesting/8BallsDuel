local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserService = game:GetService("UserService")

local TextService = game:GetService("TextService")

local Level = require(ReplicatedStorage.Libraries.Modules.Level)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local StatsHelper = require(ReplicatedStorage.Libraries.Helpers.StatsHelper)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolMatchmakingConstants = require(Pool.PoolMatchmakingConstants)
local PoolConstants = require(Pool.PoolConstants)
local PoolGeometry = require(Pool.PoolGeometry)
local PoolProgressionAnalytics = require(Pool.PoolProgressionAnalytics)
local PoolVenueProgress = require(Pool.PoolVenueProgress)
local PoolMatchTypes = require(Pool.PoolMatchTypes)
local PoolPhysics = require(Pool.PoolPhysics)
local PoolCardRewards = require(Pool.PoolCardRewards)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolPlayerStats = require(Pool.PoolPlayerStats)
local PoolRules = require(Pool.PoolRules)

local PoolEmotes = require(Pool.PoolEmotes)
local PoolSkill = require(Pool.PoolSkill)
local PoolAI = require(Pool.PoolAI)
local PoolStepper = require(Pool.PoolStepper)
local PoolVip = require(Pool.PoolVip)

local PoolMatchSession = {}

local isServer = RunService:IsServer()
local CueBallNumber = PoolConstants.CueBallNumber
local EightBallNumber = PoolConstants.EightBallNumber
local CueBallKey = PoolMatchTypes.CueBallKey

local v = {}
local v2 = {}
local count = 0

local count2 = 0

local function nextArrival() -- 7 equivalent calls inferred from this helper
	count2 += 1

	return count2
end

local classToken

if isServer then
	local success, result = pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")
		return require(ServerScriptService.Libraries.Classes.ReplicaService).NewClassToken("PoolMatch")
	end)
	classToken = if success then result else nil

	if not success then
		warn("[PoolMatchSession] could not create the PoolMatch replica class: " .. tostring(result))
	end
else
	classToken = nil
end

local function sessionFor(p) -- 12 equivalent calls inferred from this helper
	return v2[p.UserId]
end

local function pendingSessionFor(p: string)
	for _, v3 in v do
		if v3.Running or v3.Finished or v3.PendingVenueId ~= p then
			continue
		end

		local count3 = 0

		for _ in v3.Arrived do
			count3 += 1
		end

		if count3 < 2 then
			return v3
		end
	end

	return nil
end

local function newSession(pendingVenueId: string)
	count += 1

	local session = {
		Id = count,
		Replica = nil,
		Venue = nil,
		Sim = nil,
		Match = nil,
		Context = nil,
		State = nil,
		Seats = {},
		Arrived = {},
		Paid = {},
		PendingTakeover = nil,
		TurnTouched = {},
		IdleTurns = {},
		PendingVenueId = pendingVenueId,
		ShotIndex = 0,
		PlaybackUntil = 0,
		LastAimAt = 0,
		LastChatAt = {},
		Bot = nil,
		Running = false,
		Finished = false,
		Pocketed = {},
		BreakPots = {},
		SeriesWins = {},
		Accepted = {},
		Declined = false,
		RematchCount = 0,
		LastBreaker = 0,
		ExpectedOpponents = {},
		Left = {},
		VsBot = nil,
		BotRematch = nil
	}

	v[session.Id] = session

	return session
end

local function openReplica(state, items, empty)
	if not classToken then
		return
	end

	local set = {}

	for _, item in items do
		set[item] = true
	end

	local ServerScriptService = game:GetService("ServerScriptService")
	state.Replica = require(ServerScriptService.Libraries.Classes.ReplicaService).NewReplica({
		ClassToken = classToken,
		Tags = { MatchId = tostring(state.Id) },
		Data = { poolMatch = empty },
		Replication = set,
		WriteLib = ReplicatedStorage.Libraries.WriteLibraries.PoolMatch
	})
end

local function subscribe(state, items)
	local replica = state.Replica

	if not replica then
		return
	end

	for _, item in items do
		pcall(function()
			replica:ReplicateFor(item)
		end)
	end
end

local function closeSession(state)
	for k in state.Seats do
		if v2[k] == state then
			v2[k] = nil
		end
	end

	for k in state.Arrived do
		if v2[k] == state then
			v2[k] = nil
		end
	end

	if state.Replica then
		pcall(function()
			state.Replica:Destroy()
		end)

		state.Replica = nil
	end

	v[state.Id] = nil
end

local bindableEvent = Instance.new("BindableEvent")
PoolMatchSession.Abandoned = bindableEvent.Event

local function venueById(p: string) -- 5 equivalent calls inferred from this helper
	return PoolConstants.GetVenue(p)
end

local function gameTypeOf(p): string
	local venue = p.Venue

	if venue and venue.GameType == "NineBall" then
		return "NineBall"
	end

	return "EightBall"
end

local function isHighStakes(p): boolean -- 2 equivalent calls inferred from this helper
	local venue = p.Venue

	return venue ~= nil and (tonumber(venue.Prize) or 0) >= 5000 and p.Private ~= true
end

local function now() -- 4 equivalent calls inferred from this helper
	return workspace:GetServerTimeNow()
end

local function charge(p, p2, p3): boolean -- 3 equivalent calls inferred from this helper
	if p.Paid[p2.UserId] then
		return true
	end

	if not PoolPlayerData.CanAfford(p2.UserId, p3.EntryFee) then
		return false
	end

	PoolPlayerData.AddCoins(p2.UserId, -p3.EntryFee)
	p.Paid[p2.UserId] = p3.EntryFee

	return true
end

local function refundArrival(p, p2: number) -- 4 equivalent calls inferred from this helper
	local v3 = p.Paid[p2]

	if not v3 then
		return
	end

	p.Paid[p2] = nil
	PoolPlayerData.AddCoins(p2, v3)
end

local function tellPlayer(p, p2: string) -- 3 equivalent calls inferred from this helper
	RemoteSignals.FireClient(p, RemoteEnums.Pool, "Notice", p2)
end

local function bounce(instance, p: string) -- 4 equivalent calls inferred from this helper
	task.delay(PoolMatchmakingConstants.TakeoverNoticeDelay, function()
		if not instance.Parent then
			return
		end

		tellPlayer(instance, p) -- inferred equivalent call
		PoolMatchSession.ReturnToLobby(instance)
	end)
end

local function turnSeconds(_) -- 1 equivalent call inferred from this helper
	return PoolConstants.Rules.DefaultTurnTime
end

local function snapshot(p)
	local sim = p.Sim
	local result = {}

	for _, v3 in sim.Order do
		local ball = sim.Balls[v3]

		result[tostring(v3)] = { X = ball.Position.X, Y = ball.Position.Y, P = ball.Pocketed }
	end

	return result
end

local function groupStrings(p) -- 3 equivalent calls inferred from this helper
	local match = p.Match

	return { match.Groups[1] or "", match.Groups[2] or "" }
end

local function publish(p, p2) -- 9 equivalent calls inferred from this helper
	if p.Replica then
		p.Replica:Write("PoolMatchResolve", p2)
	end
end

local function resolvePlacement(p, vector2: Vector2)
	local sim = p.Sim
	local match = p.Match

	local placement = PoolRules.ClampPlacement(match, vector2)

	for _ = 1, 6 do
		local v3 = false

		for _, v4 in PoolPhysics.GetActiveBalls(sim) do
			if v4.Number == CueBallNumber then
				continue
			end

			local v5 = placement - v4.Position
			local magnitude = v5.Magnitude

			if not (magnitude < PoolConstants.BallDiameter) then
				continue
			end

			local v6

			if magnitude > 0.001 then
				v6 = v5.Unit
			else
				v6 = Vector2.new(1, 0)
			end

			placement += v6 * (PoolConstants.BallDiameter - magnitude + 0.01)
			v3 = true
		end

		placement = PoolRules.ClampPlacement(match, PoolGeometry.ClampToPlayArea(placement))

		if not v3 then
			break
		end
	end

	return placement
end

local function returnCueBall(p)
	local ball = p.Sim.Balls[CueBallNumber]

	if not ball then
		return
	end

	ball.Pocketed = false
	ball.Sinking = false
	ball.PocketId = nil
	ball.Velocity = Vector2.zero
	ball.Spin = Vector2.zero
	ball.Position = resolvePlacement(p, PoolGeometry.RespotSpot)
end

local driveBot

local applyTakeover

local afkBot

local function botOnSeat(p, turn: number) -- 1 equivalent call inferred from this helper
	local bot = p.Bot

	if bot and bot.Seat == turn then
		return bot
	end

	local afkBot2 = p.AfkBot

	return if afkBot2 and afkBot2.Seat == turn then afkBot2 else nil
end

local function botOnTurn(p) -- 2 equivalent calls inferred from this helper
	local match = p.Match

	if not match then
		return nil
	end

	return botOnSeat(p, match.Turn) -- inferred equivalent call
end

local function sendEmote(p, seat: number, p2: string)
	local state = p.State

	if not state then
		return
	end

	for k, seat2 in state.Seats do
		if not (k ~= seat and seat2.UserId > 0) then
			continue
		end

		local playerByUserId = Players:GetPlayerByUserId(seat2.UserId)

		if playerByUserId then
			RemoteSignals.FireClient(playerByUserId, RemoteEnums.Pool, "Emote", seat, p2)
		end
	end
end

local function spamWhileWatching(state)
	state.EmoteTurn = (state.EmoteTurn or 0) + 1

	local emoteTurn = state.EmoteTurn
	local bot = state.Bot
	local match = state.Match

	if not bot or not match or match.Turn == bot.Seat or PoolEmotes.StyleOf(bot.AI) ~= "Spammer" then
		return
	end

	task.spawn(function()
		local random = Random.new()

		local function stillWatching() -- 2 equivalent calls inferred from this helper
			local v3

			if state.EmoteTurn == emoteTurn then
				v3 = state.Running and not state.Finished

				if v3 then
					if state.Bot == bot and state.Match == match then
						return match.Turn ~= bot.Seat
					end

					return false
				end
			else
				return false
			end

			return v3
		end

		while true do
			task.wait(PoolEmotes.Between(PoolEmotes.BurstEvery, random))

			if not stillWatching() then -- inferred equivalent call
				break
			end

			for _ = 1, random:NextInteger(PoolEmotes.BurstSize.Min, PoolEmotes.BurstSize.Max) do
				if not stillWatching() then -- inferred equivalent call
					return
				end

				sendEmote(state, bot.Seat, PoolEmotes.Pick(PoolEmotes.SpammerEmotes, random))
				task.wait(PoolEmotes.Between(PoolEmotes.BurstGap, random))
			end
		end
	end)
end

local function beginTurn(state, value: string?, flag: boolean?, data)
	local sim = state.Sim
	local match = state.Match

	local v3 = false
	local pendingTakeover = state.PendingTakeover

	if pendingTakeover then
		state.PendingTakeover = nil

		if pendingTakeover.Parent then
			v3 = applyTakeover(state, pendingTakeover)
		end
	end

	local turn = match.Turn

	state.TurnTouched[turn] = false

	local v4 = false
	local v5 = state.Bot

	if not v5 or v5.Seat ~= turn then
		v5 = state.AfkBot

		if not v5 or v5.Seat ~= turn then
			v5 = nil
		end
	end

	if not v5 and (state.IdleTurns[turn] or 0) >= PoolMatchmakingConstants.AfkTurnsBeforeCover then
		v4 = afkBot(state, turn)
	end

	state.Context = PoolRules.BeginShot(match, sim)

	spamWhileWatching(state)

	local v6 = {
		Phase = "Playing",
		Turn = match.Turn,
		Seats = 0,
		Groups = 0,
		BallInHand = 0,
		BehindHeadString = 0,
		RulesPhase = 0,
		CueRespotted = 0,
		Balls = 0,
		TurnEndsAt = 0,
		Notice = 0,
		Foul = 0,
		FoulSeat = 0,
		Respotted = 0
	}
	local seats

	if v3 or v4 then
		seats = state.State.Seats
	end

	v6.Seats = seats
	v6.Groups = groupStrings(state) -- inferred equivalent call
	v6.BallInHand = match.BallInHand
	v6.BehindHeadString = match.BehindHeadString

	v6.RulesPhase = match.Phase
	v6.CueRespotted = flag == true
	v6.Balls = snapshot(state)
	v6.TurnEndsAt = now() + turnSeconds() + PoolMatchmakingConstants.TurnGrace -- inferred equivalent call
	v6.Notice = value or ""
	local foul

	if data then
		foul = data.Kind
	end

	v6.Foul = foul
	local foulSeat

	if data then
		foulSeat = data.Seat
	end

	v6.FoulSeat = foulSeat
	local respotted

	if data then
		respotted = data.Respotted
	end

	v6.Respotted = respotted
	publish(state, v6) -- inferred equivalent call

	if botOnTurn(state) then -- inferred equivalent call
		driveBot(state)
	end
end

local function recordPockets(data, turn: number, shot)
	if not shot.Legal or shot.Rerack then
		return
	end

	local state = data.State
	local v3 = state and state.Seats[turn]

	if not v3 or v3.UserId <= 0 or v3.IsBot then
		return
	end

	local v4 = data.Pocketed[turn]

	if not v4 then
		v4 = {}
		data.Pocketed[turn] = v4
	end

	local context = data.Context
	local v5

	if context == nil then
		v5 = false
	else
		v5 = context.WasBreak == true
	end

	local count3 = 0
	local count4 = 0

	for _, v6 in shot.Potted do
		if v6 == CueBallNumber then
			continue
		end

		if not v4[v6] then
			count4 += 1
		end

		v4[v6] = true

		if v5 then
			count3 += 1
		end
	end

	if count3 > 0 then
		data.BreakPots[turn] = (data.BreakPots[turn] or 0) + count3
	end

	local playerByUserId = Players:GetPlayerByUserId(v3.UserId)

	if playerByUserId and (count4 > 0 or count3 > 0) then
		local success, result = pcall(function()
			if count4 > 0 then
				StatsHelper.IncrementMission(playerByUserId, "PotBalls", count4)

				if isHighStakes(data) then -- inferred equivalent call
					StatsHelper.IncrementMission(playerByUserId, "HighStakesPots", count4)
				end

				if count4 >= 2 and not v5 then
					StatsHelper.IncrementMission(playerByUserId, "MultiPots", 1)
				end
			end

			if count3 > 0 then
				StatsHelper.IncrementMission(playerByUserId, "BreakPots", count3)
			end
		end)

		if not success then
			warn("[PoolMatchSession] potting quest tracking failed: " .. tostring(result))
		end
	end

	if count4 > 0 or count3 > 0 then
		local success, result = pcall(function()
			if count4 > 0 then
				PoolPlayerData.AddLifetime(v3.UserId, "ballsPotted", count4)
			end

			if count3 > 0 then
				PoolPlayerData.AddLifetime(v3.UserId, "breakPots", count3)
			end
		end)

		if not success then
			warn("[PoolMatchSession] lifetime stat tracking failed: " .. tostring(result))
		end
	end
end

local function matchExperience(data, i: number, flag: boolean)
	local match = data.Match
	local v3 = match and match.Groups[i]
	local count3 = 0
	local venue = data.Venue

	if (venue and venue.GameType == "NineBall" and "NineBall" or "EightBall") == "NineBall" then
		for k in data.Pocketed[i] or {} do
			if k ~= PoolConstants.NineBall.BallNumber or flag then
				count3 += 1
			end
		end
	else
		for k in data.Pocketed[i] or {} do
			if k == EightBallNumber then
				if flag then
					count3 += 1
				end
			elseif v3 and PoolConstants.GetGroup(k) == v3 then
				count3 += 1
			end
		end
	end

	local v4 = PoolMatchmakingConstants.MatchExperience + count3 * PoolMatchmakingConstants.PocketExperience

	if flag then
		v4 *= PoolMatchmakingConstants.WinExperienceMultiplier
	end

	return (math.round(v4))
end

local random = Random.new()

local function finish(state, p: number, p2: string)
	if state.Finished then
		return
	end

	state.Finished = true
	state.Running = false

	local state2 = state.State
	local venue = state.Venue
	local v3 = {}

	local function seriesKey(p3: number) -- 2 equivalent calls inferred from this helper
		local seat = state2.Seats[p3]

		if seat and seat.UserId > 0 then
			return seat.UserId
		end

		return -p3
	end

	if p == 1 or p == 2 then
		local v4 = seriesKey(p) -- inferred equivalent call
		state.SeriesWins[v4] = (state.SeriesWins[v4] or 0) + 1
	end

	if p == 1 or p == 2 then
		for i = 1, 2 do
			local seat = state2.Seats[i]

			if not (seat and seat.UserId <= 0) then
				continue
			end

			local v4 = PoolPlayerStats.SeedFor(seat.AvatarUserId, seat.Name or seat.DisplayName)

			PoolPlayerStats.RecordBotResult(v4, i == p)
		end
	end

	local v4 = {}

	for i = 1, 2 do
		local seat = state2.Seats[i]

		if seat and seat.UserId > 0 then
			v4[i] = PoolPlayerData.GetSkill(seat.UserId).Rating
		elseif state.Bot then
			v4[i] = state.Bot.Level.Rating
		else
			v4[i] = PoolSkill.BaseRating
		end
	end

	for i = 1, 2 do
		local seat = state2.Seats[i]
		local won = i == p
		local coins = (not won or state.Private == true) and 0 or venue.Prize
		local xp = matchExperience(state, i, won)
		v3[i] = {
			Xp = xp,
			Coins = coins,
			Won = won,
			SeriesWins = state.SeriesWins[seriesKey(i)] or 0 -- inferred equivalent call
		}

		if not (seat and seat.UserId > 0) then
			continue
		end

		local playerByUserId = Players:GetPlayerByUserId(seat.UserId)

		if coins > 0 then
			PoolPlayerData.AddCoins(seat.UserId, coins)
		end

		if playerByUserId then
			Level:GiveExperience(playerByUserId, xp)
		end

		PoolPlayerData.RecordResult(seat.UserId, v4[PoolMatchTypes.Opponent(i)], won)

		if not seat.IsBot then
			PoolPlayerData.RecordWinStreak(seat.UserId, won)

			if playerByUserId then
				local success, result = pcall(function()
					StatsHelper.IncrementMission(playerByUserId, "PoolMatches", 1)

					if won then
						StatsHelper.IncrementMission(playerByUserId, "PoolWins", 1)
					end

					if won and venue then
						StatsHelper.IncrementMission(playerByUserId, "VenueWin", 1)
					end

					if state.Private == true then
						StatsHelper.IncrementMission(playerByUserId, "FriendMatch", 1)
					end

					local venue2 = state.Venue

					if (venue2 and venue2.GameType == "NineBall" and "NineBall" or "EightBall") == "NineBall" then
						StatsHelper.IncrementMission(playerByUserId, "NineBallMatches", 1)

						if won then
							StatsHelper.IncrementMission(playerByUserId, "NineBallWins", 1)
						end
					end

					if won and isHighStakes(state) then -- inferred equivalent call
						StatsHelper.IncrementMission(playerByUserId, "HighStakesWins", 1)
					end
				end)

				if not success then
					warn("[PoolMatchSession] battlepass tracking failed: " .. tostring(result))
				end
			end

			if not state.Left[seat.UserId] then
				local v5

				if state.Private == true then
					v5 = PoolConstants.Venues[1] and PoolConstants.Venues[1].Prize or 0
				else
					v5 = venue.Prize
				end

				local success, result = pcall(PoolCardRewards.Award, seat.UserId, won, "Match", v5)

				if not success then
					warn("[PoolMatchSession] card reward failed: " .. tostring(result))
				end
			end
		end

		if not (won and venue) then
			continue
		end

		local replica = PoolPlayerData.GetReplica(seat.UserId)

		if not replica then
			continue
		end

		pcall(function()
			replica:Write("PoolVenueWins", venue.Id)
		end)

		local playerByUserId2 = Players:GetPlayerByUserId(seat.UserId)

		if not playerByUserId2 then
			continue
		end

		task.spawn(PoolProgressionAnalytics.LogVenueWin, playerByUserId2)

		task.spawn(pcall, PoolVenueProgress.GrantRewards, playerByUserId2, venue.Id)
	end

	if state.Replica then
		state.Replica:Write("PoolMatchEnd", p, p2, v3)
	end

	local bot = state.Bot
	local v5

	if bot then
		v5 = state2.Seats[bot.Seat]
	end

	if not (bot and v5 and v5.IsBot) then
		state.BotRematch = nil

		return
	end

	state.BotRematch = {
		Wants = state.VsBot ~= nil and random:NextNumber() < PoolMatchmakingConstants.BotRematchChance,
		Scheduled = false
	}
end

local function rerack(data, notice: string)
	local sim = data.Sim
	local state = data.State

	local integer = Random.new():NextInteger(1, 2147483646)
	state.Seed = integer

	local reset = PoolPhysics.Reset
	local buildRackFor = PoolGeometry.BuildRackFor
	local venue = data.Venue

	reset(sim, buildRackFor(venue and venue.GameType == "NineBall" and "NineBall" or "EightBall", Random.new(integer)))

	publish(data, { Seed = integer, Balls = snapshot(data), Notice = notice }) -- inferred equivalent call
end

local function resolveShot(data)
	local sim = data.Sim
	local match = data.Match
	local context = data.Context

	local turn = match.Turn
	local shot = PoolRules.ResolveShot(match, sim, context)
	local flag = false

	for _, v3 in shot.Respot or {} do
		if not PoolRules.RespotBall(sim, v3) then
			continue
		end

		flag = true

		local index = table.find(shot.Potted, v3)

		if index then
			table.remove(shot.Potted, index)
		end
	end

	recordPockets(data, turn, shot)

	if shot.Winner then
		publish(data, { -- inferred equivalent call
			Balls = snapshot(data),
			Groups = groupStrings(data), -- inferred equivalent call
			RulesPhase = match.Phase,
			TurnEndsAt = 0
		})
		finish(data, shot.Winner, shot.LossReason or "")
	elseif shot.Rerack then
		rerack(data, "8-ball on the break — re-racking")
		beginTurn(data, "")
	else
		local v3

		if sim.Balls[CueBallNumber] == nil then
			v3 = false
		else
			v3 = sim.Balls[CueBallNumber].Pocketed
		end

		local v4 = v3 and data.Sim.Balls[CueBallNumber]

		if v4 then
			v4.Pocketed = false
			v4.Sinking = false
			v4.PocketId = nil
			v4.Velocity = Vector2.zero
			v4.Spin = Vector2.zero
			v4.Position = resolvePlacement(data, PoolGeometry.RespotSpot)
		end

		local v5 = ""
		local primaryFoul = PoolRules.PrimaryFoul(shot.Fouls)

		if shot.WrongPocket and not (primaryFoul or shot.GroupAssigned) then
			v5 = PoolRules.WrongPocketNotice
		elseif shot.GroupAssigned then
			v5 = PoolRules.GroupNotice
		elseif primaryFoul then
			local describeFoul = PoolRules.DescribeFoul
			local venue = data.Venue

			v5 = describeFoul(primaryFoul, venue and venue.GameType == "NineBall" and "NineBall" or "EightBall")
		end

		if flag then
			local respotNotice = PoolConstants.NineBall.RespotNotice

			if v5 == "" then
				v5 = respotNotice
			else
				v5 ..= " — " .. respotNotice
			end
		end

		beginTurn(data, v5, v3, primaryFoul and {
			Kind = primaryFoul,
			Seat = turn,
			Respotted = flag
		} or nil)
	end
end

local function performShot(state, vector2: Vector2, power: number, vector2_2: Vector2, vector2_3: Vector2?, calledPocket: string?)
	local sim = state.Sim
	local match = state.Match
	local ball = sim.Balls[CueBallNumber]

	if not ball then
		return
	end

	if match.BallInHand and vector2_3 then
		ball.Position = resolvePlacement(state, vector2_3)
	end

	if not (PoolRules.NeedsCall(match, sim) and PoolRules.IsPocket(sim, calledPocket)) then
		calledPocket = nil
	end

	local context = state.Context

	if context then
		context.CalledPocket = calledPocket
	end

	state.ShotIndex += 1

	state.Replica:Write("PoolMatchShot", {
		Index = state.ShotIndex,
		Seat = match.Turn,
		DirX = vector2.X,
		DirY = vector2.Y,
		Power = power,
		SpinX = vector2_2.X,
		SpinY = vector2_2.Y,
		CueX = ball.Position.X,
		CueY = ball.Position.Y,
		Call = calledPocket
	})

	PoolPhysics.Shoot(sim, vector2, power, vector2_2)

	local v3, v4 = PoolStepper.RunToSettle(sim)

	state.PlaybackUntil = os.clock() + (v4 or 0) * PoolStepper.FixedDelta

	if not v3 then
		warn("[PoolMatchSession] shot never settled; forcing the table to rest")

		for _, v5 in sim.Order do
			sim.Balls[v5].Velocity = Vector2.zero
		end

		sim.Settled = true
	end

	resolveShot(state)
end

local function botStillUp(data, p) -- 8 equivalent calls inferred from this helper
	local match = data.Match

	local v3 = data.Running and not data.Finished

	if v3 then
		if match == nil or match.Turn ~= p.Seat then
			return false
		end

		return data.Bot == p or data.AfkBot == p
	end

	return v3
end

local function publishBotAim(data, p, vector2: Vector2, value: number)
	local sim = data.Sim
	local v3 = sim and sim.Balls[CueBallNumber]

	if not data.Replica or not v3 or vector2.Magnitude < 0.0001 then
		return
	end

	data.Replica:Write("PoolMatchAim", {
		Seat = p.Seat,
		DirX = vector2.X,
		DirY = vector2.Y,
		Power = math.clamp(value, 0, 1),
		SpinX = 0,
		SpinY = 0,
		CueX = v3.Position.X,
		CueY = v3.Position.Y,
		Placing = false,
		Call = p.Call
	})
end

local function theatreTimeLeft(data) -- 3 equivalent calls inferred from this helper
	local state = data.State

	if state and not (state.TurnEndsAt <= 0) then
		return state.TurnEndsAt - now() - PoolMatchmakingConstants.BotTheatreReserve -- inferred equivalent call
	end

	return 1e999
end

local function sweepBotAim(data, p, vector2: Vector2, aim: Vector2, p2: number, p3: number, p4: number)
	local v3 = 1 / PoolMatchmakingConstants.BotAimRate

	local v4 = math.max(PoolAI.SweepSeconds(vector2, aim, p2), 0.001)
	local v5 = v3
	local total = 0

	while total < v4 do
		if not botStillUp(data, p) then -- inferred equivalent call
			return false
		end

		if v3 - 0.0001 <= v5 then
			publishBotAim(data, p, PoolAI.SweepAim(vector2, aim, PoolAI.Ease(total / v4)), p4)
			v5 = 0
		end

		local v6 = RunService.Heartbeat:Wait()

		total += v6

		v5 += v6 * 1.5
	end

	if not botStillUp(data, p) then -- inferred equivalent call
		return false
	end

	publishBotAim(data, p, aim, p4)
	local total2 = 0

	while total2 < p3 do
		if not botStillUp(data, p) then -- inferred equivalent call
			return false
		end

		total2 += RunService.Heartbeat:Wait()
	end

	return botStillUp(data, p) -- inferred equivalent call
end

local function chargeBotAim(data, p, vector2: Vector2, p2: number, charge2)
	local v3 = 1 / PoolMatchmakingConstants.BotAimRate

	local total = charge2.Total
	local v4 = v3
	local total2 = 0
	local maxValue = 0

	while total2 < total do
		if not botStillUp(data, p) then -- inferred equivalent call
			return false
		end

		if v3 - 0.0001 <= v4 then
			maxValue = math.max(maxValue, p2 * PoolAI.ChargeFraction(charge2, total2))
			publishBotAim(data, p, vector2, maxValue)
			v4 = 0
		end

		local v5 = RunService.Heartbeat:Wait()

		total2 += v5
		v4 += v5 * 1.5
	end

	return botStillUp(data, p) -- inferred equivalent call
end

local function substituteBot(state, seat4: number): boolean
	local state2 = state.State
	local match = state.Match

	if not state2 or not match or not state.Running or state.Finished then
		return false
	end

	if state.Bot and state.Bot.Seat ~= seat4 then
		return false
	end

	local opponent = PoolMatchTypes.Opponent(seat4)
	local seat = state2.Seats[opponent]
	local playerByUserId = seat and Players:GetPlayerByUserId(seat.UserId)

	if not playerByUserId then
		return false
	end

	local skill = PoolPlayerData.GetSkill(playerByUserId.UserId)
	local substituteOpponentRating = PoolSkill.SubstituteOpponentRating(skill)
	local levelForRating = PoolAI.LevelForRating(substituteOpponentRating)

	if not levelForRating then
		return false
	end

	state.Bot = {
		Seat = seat4,
		Level = levelForRating,
		AI = PoolAI.new(levelForRating),
		Pending = false,
		Played = false,
		Placeholder = false,
		Afk = false
	}

	local seat2 = state2.Seats[seat4]

	if seat2 then
		local skill2 = PoolPlayerData.GetSkill(playerByUserId.UserId)

		pcall(PoolPlayerData.RecordResult, seat2.UserId, skill2.Rating, false)

		pcall(PoolPlayerData.RecordWinStreak, seat2.UserId, false)
	end

	local seat3 = state2.Seats[seat4]

	if seat3 then
		seat3.IsBot = true
	end

	publish(state, { Seats = state2.Seats }) -- inferred equivalent call

	if match.Turn == seat4 then
		driveBot(state)
	end

	return true
end

afkBot = function(state, turn: number): boolean
	local state2 = state.State
	local match = state.Match

	if not state2 or not match or not state.Running or state.Finished then
		return false
	end

	if state.AfkBot then
		return false
	end

	local v3 = state.Bot

	if not v3 or v3.Seat ~= turn then
		v3 = state.AfkBot

		if not v3 or v3.Seat ~= turn then
			v3 = nil
		end
	end

	if v3 then
		return false
	end

	local seat = state2.Seats[turn]

	if not seat or seat.UserId <= 0 or seat.IsBot or not Players:GetPlayerByUserId(seat.UserId) then
		return false
	end

	local seat2 = state2.Seats[PoolMatchTypes.Opponent(turn)]
	local playerByUserId

	if seat2 and seat2.UserId > 0 then
		playerByUserId = Players:GetPlayerByUserId(seat2.UserId)
	end

	if not (playerByUserId or seat2 and seat2.IsBot) then
		return false
	end

	local level = PoolAI.GetLevel(PoolMatchmakingConstants.AfkBotLevel)

	if not level then
		warn(string.format(
			"[PoolMatchSession] no bot level %q for the AFK cover; falling back to the player's rating",
			(tostring(PoolMatchmakingConstants.AfkBotLevel))
		))

		level = PoolAI.LevelForRating(PoolPlayerData.GetSkill(seat.UserId).Rating)
	end

	if not level then
		return false
	end

	state.AfkBot = {
		Seat = turn,
		Level = level,
		AI = PoolAI.new(level),
		Pending = false,
		Played = false,
		Placeholder = false,
		Afk = true
	}

	seat.IsBot = true

	local playerByUserId2 = Players:GetPlayerByUserId(seat.UserId)

	if playerByUserId2 then
		RemoteSignals.FireClient(playerByUserId2, RemoteEnums.Pool, "BotCovering")
	end

	if playerByUserId then
		tellPlayer(playerByUserId, "Your opponent went quiet. A bot is covering their turns.") -- inferred equivalent call
	end

	return true
end

local function releaseAfkBot(state, p): boolean
	local afkBot2 = state.AfkBot

	if not (afkBot2 and afkBot2.Afk) then
		return false
	end

	local state2 = state.State
	local seat2 = state2 and state.Seats[p.UserId]

	if not state2 or seat2 ~= afkBot2.Seat then
		return false
	end

	state.AfkBot = nil

	local seat = state2.Seats[seat2]

	if seat then
		seat.IsBot = false
	end

	publish(state, { Seats = state2.Seats }) -- inferred equivalent call

	local sim = state.Sim
	local v3 = sim and sim.Balls[CueBallNumber]
	local aim = afkBot2.Aim

	if state.Replica and v3 and aim and aim.Magnitude > 0.0001 then
		state.Replica:Write("PoolMatchAim", {
			Seat = seat2,
			DirX = aim.X,
			DirY = aim.Y,
			Power = 0,
			SpinX = 0,
			SpinY = 0,
			CueX = v3.Position.X,
			CueY = v3.Position.Y,
			Placing = false
		})
	end

	RemoteSignals.FireClient(p, RemoteEnums.Pool, "BotReleased")

	return true
end

local function noteAimInput(p, p2, p3: number, flag: boolean?)
	if p.TurnTouched[p3] then
		return releaseAfkBot(p, p2)
	end

	if flag ~= nil and flag ~= true then
		return false
	end

	p.TurnTouched[p3] = true
	p.IdleTurns[p3] = 0

	return releaseAfkBot(p, p2)
end

local function botPickupSpot(data) -- 2 equivalent calls inferred from this helper
	local ball = data.Sim.Balls[CueBallNumber]

	if ball and not ball.Pocketed then
		return ball.Position
	end

	return resolvePlacement(data, PoolGeometry.RespotSpot)
end

local function pickUpCueBall(data)
	local v3 = botOnTurn(data) -- inferred equivalent call
	local match = data.Match

	if not v3 or not match or not data.Running or data.Finished then
		return
	end

	if match.Turn ~= v3.Seat or not match.BallInHand or PoolAI.StaysForBreak(v3.AI, data.Sim, match) then
		return
	end

	local v4 = botPickupSpot(data) -- inferred equivalent call
	publish(data, { -- inferred equivalent call
		CuePickup = { X = v4.X, Y = v4.Y }
	})
end

local function takeBotTurn(data)
	local match = data.Match
	local v3

	if match then
		local turn = match.Turn
		v3 = data.Bot

		if not v3 or v3.Seat ~= turn then
			v3 = data.AfkBot

			if not v3 or v3.Seat ~= turn then
				v3 = nil
			end
		end
	else
		v3 = nil
	end

	if not v3 or not data.Running or data.Finished then
		return
	end

	local sim = data.Sim
	local match2 = data.Match

	if not sim or not match2 or match2.Turn ~= v3.Seat then
		return
	end

	v3.EarliestChargeAt = os.clock() + PoolConstants.Bots.MinimumTurn

	local turn = PoolAI.BuildTurn(v3.AI)

	local v4 = nil

	if match2.BallInHand and not PoolAI.StaysForBreak(v3.AI, sim, match2) then
		task.wait(turn.PlaceHold)

		if not data.Running or data.Finished or match2.Turn ~= v3.Seat then
			return
		end

		local position = nil
		local v5 = nil
		local success, result = pcall(PoolAI.PlaceCueBallOptions, v3.AI, sim, match2, turn.Reconsider and 2 or 1)

		if success and typeof(result) == "table" and typeof(result[1]) == "Vector2" then
			position = resolvePlacement(data, result[1])

			if typeof(result[2]) == "Vector2" then
				v5 = resolvePlacement(data, result[2])
			end
		else
			local success2, result2 = pcall(PoolAI.PlaceCueBall, v3.AI, sim, match2)

			if success2 and typeof(result2) == "Vector2" then
				position = resolvePlacement(data, result2)
			end
		end

		if position then
			local ball = sim.Balls[CueBallNumber]
			local v6 = botPickupSpot(data) -- inferred equivalent call

			if ball then
				ball.Position = position
			end

			local placementLegs = PoolAI.BuildPlacementLegs(v3.AI, sim, turn, position, v5, function(vector2: Vector2)
				return resolvePlacement(data, vector2)
			end)
			v4 = position

			for _, placementLeg in placementLegs do
				local to = placementLeg.To
				local seed = math.random(1, 1000000000)
				local carry = PoolAI.BuildCarry(Random.new(seed), v6, to, placementLeg.Seconds)

				publish(data, { -- inferred equivalent call
					CuePlacement = {
						X = to.X,
						Y = to.Y,
						Seed = seed,
						Seconds = carry.Seconds,
						Held = placementLeg.Held and true or nil
					}
				})

				task.wait(carry.Seconds)

				if not data.Running or data.Finished or match2.Turn ~= v3.Seat then
					return
				end

				if placementLeg.Held then
					task.wait(placementLeg.HoldAfter)

					if not data.Running or data.Finished or match2.Turn ~= v3.Seat then
						return
					end
				end

				v6 = to
			end
		end
	end

	local success, result = pcall(PoolAI.Plan, v3.AI, sim, match2, v3.Seat)
	local v5, v6, v7

	if success and result then
		v5, v6, v7 = PoolAI.Commit(v3.AI, result, sim, true)

		if PoolMatchmakingConstants.PrintBotProfiles and result.Break and v5 then
			local ball = sim.Balls[CueBallNumber]
			local v8 = if ball then ball.Position else Vector2.zero
			local target = result.Choice and result.Choice.Target

			print(string.format(
				"[PoolBot] Breaking (%s, seat %d): %s from (%.1f, %.1f) at the %s ball | power %d%% | spin (%.2f, %.2f) | %s",
				v3.AI.Level.Id,
				v3.Seat,
				PoolAI.BreakKindName(result.BreakKind),
				v8.X,
				v8.Y,
				tostring(target),
				math.round((v6 or 0) * 100),
				v7 and v7.X or 0,
				v7 and v7.Y or 0,
				(tostring(result.BreakNote or ""))
			))
		end
	end

	if not (v5 and v6) then
		local success2, result2, v8 = pcall(PoolAI.FallbackShot, sim, match2)

		if success2 then
			v6 = v8
			v5 = result2
		end
	end

	if not v5 or not v6 or v5.Magnitude < 0.0001 then
		warn("[PoolMatchSession] the substitute bot could not find a shot")

		return
	end

	if not botStillUp(data, v3) then -- inferred equivalent call
		return
	end

	local unit = v5.Unit
	local power = math.clamp(v6, PoolConstants.Input.MinimumPower, 1)
	local v8

	if success and result then
		v8 = result.ShowDirection
	end

	local aim2 = v8 or unit

	v3.Call = nil

	if PoolRules.NeedsCall(match2, sim) then
		local call

		if success and result and result.Choice then
			call = result.Choice.Pocket
		end

		local ball = sim.Balls[CueBallNumber]

		if not PoolRules.IsPocket(sim, call) then
			call = PoolRules.AimedPocket(sim, unit)

			if not call then
				if ball then
					call = PoolRules.NearestPocket(sim, ball.Position)
				else
					call = nil
				end
			end
		end

		v3.Call = call
	end

	local theatre = PoolConstants.Bots.Theatre

	local v9 = v3.Aim or unit
	local v10 = false

	local function moveTo(aim: Vector2, p: number, p2: number): boolean
		if not v10 then
			v10 = true
			v3.EarliestChargeAt = math.max(v3.EarliestChargeAt or 0, os.clock() + PoolConstants.Bots.MinimumTurn)
		end

		if not sweepBotAim(data, v3, v9, aim, p, p2, 0) then
			return false
		end

		v9 = aim
		v3.Aim = aim

		return true
	end

	for _, v11 in not (success and result) and {} or PoolAI.BuildLookSequence(v3.AI, result, turn, v9, aim2) do
		local v12 = theatreTimeLeft(data) -- inferred equivalent call
		local sweepSeconds = PoolAI.SweepSeconds
		local v13 = v9

		if v12 <= sweepSeconds(v13, v11.Direction, v11.Sweep) + v11.Rest then
			break
		end

		if not moveTo(v11.Direction, v11.Sweep, v11.Rest) then
			return
		end
	end

	local v11 = not (success and result) and 0.5 or PoolAI.Confidence(result.Choice)
	local v12

	if success and result and result.Choice and not result.Break then
		v12 = result.Choice.Direction
	end

	for _, v13 in PoolAI.BuildSettleSequence(v3.AI, aim2, v11, turn, v12) do
		local v14 = theatreTimeLeft(data) -- inferred equivalent call
		local sweepSeconds = PoolAI.SweepSeconds
		local v15 = v9

		if v14 <= sweepSeconds(v15, v13.Direction, v13.Sweep) + v13.Rest then
			break
		end

		if not moveTo(v13.Direction, v13.Sweep, v13.Rest) then
			return
		end
	end

	if not v10 then
		v10 = true
		v3.EarliestChargeAt = math.max(v3.EarliestChargeAt or 0, os.clock() + PoolConstants.Bots.MinimumTurn)
	end

	local sweepSeconds = PoolAI.SweepSeconds
	local v13 = v9
	local v14 = sweepSeconds(v13, aim2, theatre.CommitSweep)

	if not moveTo(aim2, v14, math.max((v3.EarliestChargeAt or 0) - (os.clock() + v14), 0)) then
		return
	end

	if
		success
		and result
		and data.Bot == v3
		and PoolEmotes.StyleOf(v3.AI) == "Winner"
		and PoolEmotes.IsGameBallShot(match2, result)
	then
		sendEmote(data, v3.Seat, PoolEmotes.Pick(PoolEmotes.WinnerEmotes))

		local between = PoolEmotes.Between(PoolEmotes.WinnerPause)
		local total = 0

		while total < between do
			if not botStillUp(data, v3) then -- inferred equivalent call
				return
			end

			total += RunService.Heartbeat:Wait()
		end
	end

	if not chargeBotAim(data, v3, aim2, power, PoolAI.BuildCharge(v3.AI, turn, (math.max(theatreTimeLeft(data), 0)))) then -- inferred equivalent call
		return
	end

	v3.Pending = false

	v3.Played = true

	performShot(data, unit, power, v7 or Vector2.zero, v4, v3.Call)
end

local function playbackWait(data)
	local v3 = math.max((data.PlaybackUntil or 0) - os.clock(), 0)
	local maxValue = 0

	for _, seat in data.Seats do
		local playerByUserId

		if typeof(seat) == "number" and seat > 0 then
			playerByUserId = Players:GetPlayerByUserId(seat)
		end

		if not playerByUserId then
			continue
		end

		local v4 = playerByUserId
		local success, result = pcall(function()
			return v4:GetNetworkPing()
		end)

		if success and typeof(result) == "number" then
			maxValue = math.max(maxValue, result)
		end
	end

	return v3 + maxValue + 0.35
end

driveBot = function(data)
	local match = data.Match
	local v3

	if match then
		local turn = match.Turn
		v3 = data.Bot

		if not v3 or v3.Seat ~= turn then
			v3 = data.AfkBot

			if not v3 or v3.Seat ~= turn then
				v3 = nil
			end
		end
	else
		v3 = nil
	end

	if not v3 or not data.Running or data.Finished or v3.Pending then
		return
	end

	v3.Pending = true

	task.delay(playbackWait(data), function()
		local success, result = pcall(function()
			pickUpCueBall(data)
			task.wait(v3.Level.ThinkTime)
			takeBotTurn(data)
		end)

		v3.Pending = false

		if not success then
			warn("[PoolMatchSession] substitute bot turn failed: " .. tostring(result))
		end
	end)
end

local function takeoverSessionFor(p: string)
	for _, v3 in v do
		local bot = v3.Bot
		local venue = v3.Venue

		if
			v3.Running
			and not v3.Finished
			and bot
			and bot.Placeholder
			and not v3.PendingTakeover
			and venue
			and venue.Id == p
		then
			return v3
		end
	end

	return nil
end

applyTakeover = function(state, pendingTakeover): boolean
	local state2 = state.State
	local bot = state.Bot

	if not (state2 and bot and bot.Placeholder) then
		return false
	end

	if not state.Running or state.Finished then
		return false
	end

	local seat = bot.Seat
	local seat2 = state2.Seats[seat]
	local describe = PoolPlayerData.Describe(pendingTakeover)

	describe.Group = not seat2 and "" or seat2.Group

	state2.Seats[seat] = describe
	state.Bot = nil

	state.Seats[pendingTakeover.UserId] = seat
	v2[pendingTakeover.UserId] = state
	local arrived = state.Arrived
	local userId = pendingTakeover.UserId
	arrived[userId] = {
		Player = pendingTakeover,
		VenueId = state2.VenueId,
		At = os.clock(),
		Index = nextArrival() -- inferred equivalent call
	}

	state.Paid[pendingTakeover.UserId] = nil

	subscribe(state, { pendingTakeover })

	if bot.Played then
		task.delay(PoolMatchmakingConstants.TakeoverNoticeDelay, function()
			if pendingTakeover.Parent then
				tellPlayer(pendingTakeover, "The match started without you. A bot covered your turn.") -- inferred equivalent call
			end
		end)
	end

	return true
end

local function seatLateArrival(state, pendingTakeover): boolean
	local sim = state.Sim

	if sim and sim.Settled then
		if not applyTakeover(state, pendingTakeover) then
			return false
		end

		publish(state, { Seats = state.State.Seats, Groups = groupStrings(state) }) -- inferred equivalent call

		return true
	end

	state.PendingTakeover = pendingTakeover
	v2[pendingTakeover.UserId] = state

	return true
end

local function seatOf(p, p2) -- 3 equivalent calls inferred from this helper
	return p.Seats[p2.UserId]
end

local function canAct(data, p): boolean
	if not data.Running or data.Finished or not (data.Sim and data.Match) then
		return false
	end

	local state = data.State

	if not state or state.Phase ~= "Playing" or not data.Context then
		return false
	end

	local v3 = seatOf(data, p) -- inferred equivalent call
	return v3 ~= nil and v3 == data.Match.Turn
end

local function allFinite(...): boolean
	for i = 1, select("#", ...) do
		local v3 = select(i, ...)

		if typeof(v3) ~= "number" or v3 ~= v3 or v3 == 1e999 or v3 == -1e999 then
			return false
		end
	end

	return true
end

function PoolMatchSession.Emote(p, p2)
	if not PoolEmotes.IsPlayerChoice(p2) then
		return
	end

	local v3 = sessionFor(p) -- inferred equivalent call

	if not (v3 and v3.State) then
		return
	end

	local seat = v3.Seats[p.UserId]

	if not seat then
		return
	end

	v3.EmoteTimes = v3.EmoteTimes or {}

	local nows = v3.EmoteTimes[p.UserId] or {}
	local now2 = os.clock()

	while nows[1] and now2 - nows[1] > 1 do
		table.remove(nows, 1)
	end

	if #nows >= PoolEmotes.MaxPerSecond then
		return
	end

	table.insert(nows, now2)
	v3.EmoteTimes[p.UserId] = nows

	sendEmote(v3, seat, p2)
end

function PoolMatchSession.Chat(p, value: string)
	if not (PoolMatchmakingConstants.ChatEnabled and typeof(value) == "string") then
		return
	end

	local v3 = sessionFor(p) -- inferred equivalent call

	if not v3 then
		return
	end

	local state = v3.State
	local seat = v3.Seats[p.UserId]

	if not (state and seat) then
		return
	end

	local now2 = os.clock()

	if now2 - (v3.LastChatAt[p.UserId] or 0) < PoolMatchmakingConstants.ChatCooldown then
		return
	end

	local v4 = string.sub(string.gsub(value, "^%s*(.-)%s*$", "%1"), 1, PoolMatchmakingConstants.ChatMaxLength)

	if v4 == "" then
		return
	end

	v3.LastChatAt[p.UserId] = now2

	local success, result = pcall(function()
		return TextService:FilterStringAsync(v4, p.UserId, Enum.TextFilterContext.PublicChat):GetNonChatStringForBroadcastAsync()
	end)

	if not success or typeof(result) ~= "string" then
		warn("[PoolMatchSession] could not filter a chat message: " .. tostring(result))

		return
	end

	if result == "" then
		return
	end

	for _, seat2 in state.Seats do
		local playerByUserId

		if seat2.UserId > 0 then
			playerByUserId = Players:GetPlayerByUserId(seat2.UserId)
		end

		if playerByUserId then
			RemoteSignals.FireClient(playerByUserId, RemoteEnums.Pool, "Chat", seat, result)
		end
	end
end

function PoolMatchSession.Aim(p, p2: number, p3: number, value: number, value2: number, value3: number, cueX: number, cueY: number, flag: boolean?, flag2: boolean?, call)
	if not allFinite(p2, p3, value, value2, value3, cueX, cueY) then
		return
	end

	local v3 = sessionFor(p) -- inferred equivalent call

	if not (v3 and (canAct(v3, p) and v3.Sim.Settled)) then
		return
	end

	local vector2 = Vector2.new(p2, p3)

	if vector2.Magnitude < 0.0001 then
		return
	end

	local unit = vector2.Unit
	local seat = seatOf(v3, p) -- inferred equivalent call
	local power = math.clamp(value, 0, 1)
	local vector2_2 = Vector2.new(math.clamp(value2, -1, 1), (math.clamp(value3, -1, 1)))

	if typeof(flag2) ~= "boolean" then
		flag2 = nil
	end

	local v4 = noteAimInput(v3, p, seat, flag2)

	local afkBot2 = v3.AfkBot

	if afkBot2 and afkBot2.Afk and afkBot2.Seat == seat then
		return
	end

	local now2 = os.clock()

	if not v4 and now2 - v3.LastAimAt < 1 / PoolMatchmakingConstants.AimRate then
		return
	end

	v3.LastAimAt = now2

	local replica = v3.Replica
	local v5 = {
		Seat = seat,
		DirX = unit.X,
		DirY = unit.Y,
		Power = power,
		SpinX = vector2_2.X,
		SpinY = vector2_2.Y,
		CueX = cueX,
		CueY = cueY,
		Placing = flag == true,
		Call = 0
	}

	if not (PoolRules.NeedsCall(v3.Match, v3.Sim) and PoolRules.IsPocket(v3.Sim, call)) then
		call = nil
	end

	v5.Call = call
	replica:Write("PoolMatchAim", v5)
end

function PoolMatchSession.Shoot(p, p2: number, p3: number, value: number, value2: number, value3: number, p4: number, p5: number, value4)
	if not allFinite(p2, p3, value, value2, value3, p4, p5) then
		return
	end

	local v3 = sessionFor(p) -- inferred equivalent call

	if not (v3 and canAct(v3, p)) then
		return
	end

	local sim = v3.Sim
	local _match = v3.Match

	if not sim.Settled then
		return
	end

	local vector2 = Vector2.new(p2, p3)

	if vector2.Magnitude < 0.0001 then
		return
	end

	local power = math.clamp(value, PoolConstants.Input.MinimumPower, 1)
	local vector2_2 = Vector2.new(math.clamp(value2, -1, 1), (math.clamp(value3, -1, 1)))
	local v4 = seatOf(v3, p) -- inferred equivalent call

	if v4 then
		v3.TurnTouched[v4] = true
		v3.IdleTurns[v4] = 0

		if releaseAfkBot(v3, p) then
			return
		end
	end

	if not sim.Balls[CueBallNumber] then
		return
	end

	local vector2_3 = Vector2.new(p4, p5)

	if typeof(value4) ~= "string" then
		value4 = nil
	end

	performShot(v3, vector2, power, vector2_2, vector2_3, value4)
end

local function onTimeout(data)
	local sim = data.Sim
	local context = data.Context

	local match = data.Match
	local state = data.State
	local turn = match and match.Turn
	local v3 = turn and state and state.Seats[turn]

	if turn and v3 and v3.UserId > 0 and not v3.IsBot then
		if data.TurnTouched[turn] then
			data.IdleTurns[turn] = 0
		else
			data.IdleTurns[turn] = (data.IdleTurns[turn] or 0) + 1
		end
	end

	sim.Events = {}
	context.TimedOut = true

	resolveShot(data)
end

local function startClock(data) -- 1 equivalent call inferred from this helper
	local match = data.Match

	task.spawn(function()
		while data.Running and not data.Finished do
			task.wait(0.25)

			local state = data.State
			local sim = data.Sim

			if not data.Running or data.Finished or not state or not sim or data.Match ~= match then
				break
			end

			if not (state.Phase == "Playing" and sim.Settled and state.TurnEndsAt > 0 and now() > state.TurnEndsAt) then -- inferred equivalent call
				continue
			end

			onTimeout(data)
		end
	end)
end

local function seatOrder(state)
	local players = {}

	for _, v3 in state.Arrived do
		table.insert(players, v3.Player)
	end

	table.sort(players, function(a, b): boolean
		return a.UserId < b.UserId
	end)

	return players
end

local function standInIdentity(p, p2)
	local expectedOpponent = p.ExpectedOpponents[p2.UserId]

	if not expectedOpponent then
		return "Opponent", "Opponent", nil, nil, false
	end

	local displayName = expectedOpponent.DisplayName or expectedOpponent.Name or "Opponent"

	return
		expectedOpponent.Name or displayName,
		displayName,
		expectedOpponent.UserId,
		expectedOpponent.Level,
		expectedOpponent.Vip == true
end

local function printBotProfile(data, list, p: number, flag: boolean)
	local bot = data.Bot
	local state = data.State
	local item = list[1]

	if not (PoolMatchmakingConstants.PrintBotProfiles and bot and state and item) then
		return
	end

	local ai = bot.AI
	local level = ai.Level
	local traits = ai.Traits
	local style = ai.Style
	local seat = state.Seats[bot.Seat]
	local expectedOpponent = data.ExpectedOpponents[item.UserId]
	local venue = data.Venue
	local breakWeights = style.BreakWeights or PoolConstants.Bots.Break.DefaultWeights
	local v3 = {}

	local function add(p2: string) -- 11 equivalent calls inferred from this helper
		table.insert(v3, "[PoolBot] " .. p2)
	end

	local function yes(p2): string -- 4 equivalent calls inferred from this helper
		return if p2 then "yes" else "no"
	end

	add("==== Bot match started ====") -- inferred equivalent call
	add(string.format( -- inferred equivalent call
		"Player: %s (@%s, %d) in seat %d | Venue: %s | Bot in seat %d | %s",
		item.DisplayName,
		item.Name,
		item.UserId,
		data.Seats[item.UserId] or 0,
		tostring(venue and (venue.Name or venue.Id or "?") or "?"),
		bot.Seat,
		flag and "bot matchmaking (disguised)" or "stand-in for an opponent who has not loaded"
	))

	if seat then
		add(string.format( -- inferred equivalent call
			"Shown as: %s (@%s) | face userId %s | shown level %s | VIP tag: %s | face from: %s",
			tostring(seat.DisplayName),
			tostring(seat.Name),
			tostring(seat.AvatarUserId or "none"),
			tostring(seat.Level),
			yes(seat.Vip == true), -- inferred equivalent call
			not (expectedOpponent and expectedOpponent.Source) and "the opponent it is holding the chair for" or expectedOpponent.Source
		))
	end

	if expectedOpponent and expectedOpponent.Reason then
		add("Why this difficulty: " .. expectedOpponent.Reason) -- inferred equivalent call
	end

	local v4 = {}

	for _, v5 in level.SoftPowers or {} do
		table.insert(v4, string.format("%.2f", v5))
	end

	local dynamicMiss = PoolConstants.Bots.DynamicMiss
	local v5

	if dynamicMiss and dynamicMiss.Enabled and dynamicMiss.WinningShot then
		v5 = dynamicMiss.WinningShot[level.Id]
	end

	local v6

	if v5 then
		v6 = tostring(v5) .. "% miss"
	else
		v6 = not level.FinalBallSuccessChance and "no gate" or tostring(level.FinalBallSuccessChance) .. "% pot gate"
	end

	add(string.format( -- inferred equivalent call
		"Difficulty: %s (rating %d) | AimError %.3f | PowerError %.3f | MissAim %s%% | MissBadly %s | WinningShot %s | Candidates %d | PositionWeight %.2f | Think %.1fs | FullPower %s | SoftPowers %s",
		level.Id,
		level.Rating,
		level.AimError,
		level.PowerError,
		tostring(level.MissAimChance or 0),
		not level.MissBadly and "default" or string.format("%.2f", level.MissBadly),
		v6,
		level.Candidates,
		level.PositionWeight,
		level.ThinkTime,
		yes(level.FullPower), -- inferred equivalent call
		not (#v4 > 0) and "none" or table.concat(v4, ", ")
	))

	add(string.format( -- inferred equivalent call
		"Traits: turn %.1f-%.1fs | SpinUse %d | PositionDepth %s | Safeties %s | PressureError x%.2f",
		traits.TurnSeconds.Min,
		traits.TurnSeconds.Max,
		traits.SpinUse,
		yes(traits.PositionDepth), -- inferred equivalent call
		yes(traits.PlaysSafeties), -- inferred equivalent call
		traits.PressureError
	))

	add(string.format( -- inferred equivalent call
		"Personality: %s | Tempo %.2f | PowerBias %+.2f | Risk %.2f | BankLove %.2f | Fidget %.2f | Nerves %.2f | Pull %s",
		style.Id,
		style.Tempo,
		style.PowerBias,
		style.Risk,
		style.BankLove,
		style.Fidget,
		style.Nerves,
		not style.PullSeconds and "default" or string.format("%.2f-%.2fs", style.PullSeconds.Min, style.PullSeconds.Max)
	))

	add(string.format("Form this match: x%.3f on aim and power error", ai.Form)) -- inferred equivalent call
	add("Emotes: " .. PoolEmotes.StyleOf(ai) .. " (None 77% / Spammer 3% / Winner 20%)") -- inferred equivalent call
	add(string.format( -- inferred equivalent call
		"Break: %s | 100%% power | scratch guard %s | weights Head-On %s / Second-Ball %s / Control %s | side %s",
		level.BreakStrategic and "strategic (moves the white, picks a break)" or "from the racked spot, head-on into the apex",
		not level.BreakScratchChance and "off" or string.format("on (%.2f%% let through)", level.BreakScratchChance),
		tostring(breakWeights.HeadOn or 0),
		tostring(breakWeights.SecondBall or 0),
		tostring(breakWeights.Control or 0),
		ai.BreakSign < 0 and "-Y" or "+Y"
	))

	add(string.format( -- inferred equivalent call
		"Opening break: %s%s",
		p == bot.Seat and "BOT" or "PLAYER",
		not flag and "" or string.format(
			" (the bot breaks %d%% of these matches)",
			(math.round(PoolMatchmakingConstants.BotBreakChance * 100))
		)
	))

	print(table.concat(v3, "\n"))
end

local AnalyticsHelper = nil

local function logGamesPlayed(state, items, id: string, p: string) -- 1 equivalent call inferred from this helper
	if not isServer then
		return
	end

	local success, result = pcall(function()
		if not AnalyticsHelper then
			local ServerScriptService = game:GetService("ServerScriptService")
			AnalyticsHelper = require(ServerScriptService.Libraries.GameSpecific.AnalyticsHelper)
		end

		local v3 = p == "NineBall" and "9 Ball" or "8 Ball"

		local v4 = state.Private and "Friends" or state.VsBot and "Bot matchmaking" or "Online"

		for _, item in items do
			AnalyticsHelper.GamePlayed(item, v3, v4, id)
		end
	end)

	if not success then
		warn("[PoolMatchSession] could not log games played: " .. tostring(result))
	end
end

local random2 = Random.new()

local function startMatch(state, p: string, level2, flag: boolean?, flag2: boolean?, data)
	local venue2 = venueById(p) -- inferred equivalent call

	if not venue2 then
		warn("[PoolMatchSession] unknown venue: " .. p)

		return
	end

	state.Venue = venue2
	state.Finished = false

	state.Pocketed = {}
	state.BreakPots = {}

	table.clear(state.Accepted)
	state.Declined = false
	state.BotRematch = nil

	local v3 = seatOrder(state)
	local integer = Random.new():NextInteger(1, 2147483646)
	local venue = state.Venue

	local gameType = venue and venue.GameType == "NineBall" and "NineBall" or "EightBall"

	state.Sim = PoolPhysics.newSimulation()
	PoolPhysics.Reset(state.Sim, PoolGeometry.BuildRackFor(gameType, Random.new(integer)))

	if gameType == "NineBall" then
		for _, v4 in v3 do
			local replica = PoolPlayerData.GetReplica(v4.UserId)

			if replica then
				pcall(function()
					replica:Write("PoolNineBallMatches")
				end)
			end
		end
	end

	local seats = {}

	for k, v4 in v3 do
		state.Seats[v4.UserId] = k

		v2[v4.UserId] = state
		seats[k] = PoolPlayerData.Describe(v4)

		state.Paid[v4.UserId] = nil
	end

	if level2 and #v3 == 1 then
		local opponent = PoolMatchTypes.Opponent(state.Seats[v3[1].UserId])
		local v4 = v3[1]
		local expectedOpponent = state.ExpectedOpponents[v4.UserId]
		local displayName, name, userId, level, vip

		if expectedOpponent then
			displayName = expectedOpponent.DisplayName or expectedOpponent.Name or "Opponent"

			name = expectedOpponent.Name or displayName
			userId = expectedOpponent.UserId
			level = expectedOpponent.Level
			vip = expectedOpponent.Vip == true
		else
			name = "Opponent"
			displayName = "Opponent"
			vip = false
		end

		seats[opponent] = {
			UserId = 0,
			AvatarUserId = userId,
			Name = name,
			DisplayName = displayName,
			Level = level or PoolPlayerData.GetLevel(v3[1].UserId),
			Group = "",
			IsBot = true,
			Vip = vip
		}

		local ai = PoolAI.new(level2)

		if data then
			ai.Style = data.Style
			ai.BreakSign = data.BreakSign

			ai.EmoteStyle = data.EmoteStyle
		end

		state.Bot = {
			Seat = opponent,
			Level = level2,
			AI = ai,
			Pending = false,
			Played = false,
			Placeholder = true
		}
	else
		state.Bot = nil
	end

	local v4 = 1e999
	local v5 = 1

	for k, v6 in state.Arrived do
		local seat = state.Seats[k]

		if not (seat and v6.Index < v4) then
			continue
		end

		v4 = v6.Index
		v5 = seat
	end

	local bot = state.Bot

	if bot and (flag2 or flag and random2:NextNumber() < PoolMatchmakingConstants.BotBreakChance) then
		v5 = bot.Seat
	end

	state.LastBreaker = v5

	state.Match = PoolRules.newMatch(v5, nil, gameType, PoolConstants.CallPocketFor(venue2.Id))

	local empty = PoolMatchTypes.Empty()
	empty.Active = true
	empty.Phase = "Countdown"
	empty.VenueId = venue2.Id
	empty.GameType = gameType
	empty.Wager = venue2.EntryFee
	empty.Prize = venue2.Prize
	empty.Seed = integer
	empty.Turn = v5
	empty.Seats = seats
	empty.Balls = {}
	empty.RulesPhase = state.Match.Phase
	empty.BallInHand = state.Match.BallInHand
	empty.BehindHeadString = state.Match.BehindHeadString
	empty.StartsAt = now() + PoolMatchmakingConstants.IntroSeconds -- inferred equivalent call

	state.State = empty
	state.ShotIndex = 0
	state.PlaybackUntil = 0

	if state.Bot then
		local success, result = pcall(printBotProfile, state, v3, v5, flag == true or state.VsBot ~= nil)

		if not success then
			warn("[PoolMatchSession] could not print the bot profile: " .. tostring(result))
		end
	end

	state.PendingVenueId = nil

	if state.Replica then
		subscribe(state, v3)
		state.Replica:Write("PoolMatchInit", empty)
	else
		openReplica(state, v3, empty)
	end

	publish(state, { Balls = snapshot(state) }) -- inferred equivalent call

	state.Running = true
	startClock(state) -- inferred equivalent call
	logGamesPlayed(state, v3, venue2.Id, gameType) -- inferred equivalent call

	task.delay(PoolMatchmakingConstants.IntroSeconds, function()
		if state.Running and not state.Finished then
			beginTurn(state, "")
		end
	end)
end

local function awaitProfile(instance)
	if PoolPlayerData.GetReplica(instance.UserId) then
		return true
	end

	local userId = tostring(instance.UserId)
	local bindableEvent2 = Instance.new("BindableEvent")
	local v3 = false

	task.spawn(function()
		Profiles.WaitForPlayerReplica(userId)

		v3 = true
		bindableEvent2:Fire()
	end)

	local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		if player == instance then
			bindableEvent2:Fire()
		end
	end)

	if instance.Parent then
		bindableEvent2.Event:Wait()
		playerRemovingConnection:Disconnect()
		bindableEvent2:Destroy()

		return v3 and PoolPlayerData.GetReplica(instance.UserId) ~= nil
	end

	playerRemovingConnection:Disconnect()
	bindableEvent2:Destroy()

	return false
end

local v3 = {}

local function completeOpponent(player)
	if not player or player.Name and player.DisplayName then
		return player
	end

	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({ player.UserId })
	end)
	local v4

	if success and typeof(result) == "table" then
		v4 = result[1]
	end

	if typeof(v4) == "table" then
		if not player.Name and typeof(v4.Username) == "string" then
			player.Name = v4.Username
		end

		if not player.DisplayName and typeof(v4.DisplayName) == "string" then
			player.DisplayName = v4.DisplayName
		end
	end

	if not player.Name then
		local success2, result2 = pcall(function()
			return Players:GetNameFromUserIdAsync(player.UserId)
		end)

		if success2 and typeof(result2) == "string" then
			player.Name = result2
		end
	end

	return player
end

function PoolMatchSession.Arrive(instance, venueId: string, p)
	if not isServer then
		return
	end

	local v4 = venueById(venueId) -- inferred equivalent call

	if v4 then
		if v3[instance.UserId] then
			return
		end

		v3[instance.UserId] = true

		local v5 = awaitProfile(instance)

		if v5 then
			p = completeOpponent(p)
		end

		if v5 and p then
			p.Vip = PoolVip.OwnsAnyAsync(p.UserId)
		end

		v3[instance.UserId] = nil

		if not instance.Parent then
			return
		end

		if v5 then
			local v6 = v2[instance.UserId]

			if v6 then
				if not v6.Finished then
					return
				end

				closeSession(v6)
			end

			local v7 = takeoverSessionFor(venueId)

			if v7 then
				if charge(v7, instance, v4) then -- inferred equivalent call
					if seatLateArrival(v7, instance) then
						return
					end

					refundArrival(v7, instance.UserId) -- inferred equivalent call
				else
					bounce(instance, "You can no longer afford that table") -- inferred equivalent call
					return
				end
			end

			local v8 = pendingSessionFor(venueId) or newSession(venueId)

			if charge(v8, instance, v4) then -- inferred equivalent call
				local arrived = v8.Arrived
				local userId = instance.UserId
				arrived[userId] = {
					Player = instance,
					VenueId = venueId,
					At = os.clock(),
					Index = nextArrival() -- inferred equivalent call
				}

				v2[instance.UserId] = v8

				v8.ExpectedOpponents[instance.UserId] = p
				local count3 = 0

				for _ in v8.Arrived do
					count3 += 1
				end

				if count3 >= 2 then
					startMatch(v8, venueId)

					return
				end

				local skill = PoolPlayerData.GetSkill(instance.UserId)
				local success, result = pcall(function()
					return PoolAI.LevelForRating(PoolSkill.SubstituteOpponentRating(skill))
				end)

				if success and result then
					startMatch(v8, venueId, result)

					if v8.Running then
						return
					end
				end

				PoolMatchSession.AbandonSession(v8, "That table could not be opened")
			else
				if not v8.Running and next(v8.Arrived) == nil then
					closeSession(v8)
				end

				bounce(instance, "You can no longer afford that table") -- inferred equivalent call
			end
		else
			warn("[PoolMatchSession] " .. instance.Name .. "'s profile is not active; cannot seat them")
			bounce(instance, "We could not load your account") -- inferred equivalent call
		end
	else
		warn("[PoolMatchSession] arrival at an unknown venue: " .. tostring(venueId))
		bounce(instance, "That table could not be opened") -- inferred equivalent call
	end
end

function PoolMatchSession.StartPrivate(player, player2, venueId: string)
	if not isServer then
		return false, "Server only"
	end

	if player == player2 then
		return false, "You cannot play yourself"
	end

	if not venueById(venueId) then -- inferred equivalent call
		return false, "That venue does not exist"
	end

	for _, v4 in { player, player2 } do
		local v5 = v2[v4.UserId]

		if not v5 then
			continue
		end

		if not v5.Finished then
			return false, string.format("%s is already in a game", v4.DisplayName)
		end

		closeSession(v5)
	end

	local v4 = newSession(venueId)

	v4.Private = true

	local arrived = v4.Arrived
	local userId = player.UserId
	arrived[userId] = { Player = player, VenueId = venueId, At = os.clock(), Index = nextArrival() } -- inferred equivalent call
	local arrived2 = v4.Arrived
	local userId2 = player2.UserId
	arrived2[userId2] = {
		Player = player2,
		VenueId = venueId,
		At = os.clock(),
		Index = nextArrival() -- inferred equivalent call
	}
	v2[player.UserId] = v4
	v2[player2.UserId] = v4

	startMatch(v4, venueId)

	if v4.Running then
		return true
	end

	closeSession(v4)

	return false, "Could not open a table"
end

function PoolMatchSession.StartVsBot(player, venueId: string, p, vsBot)
	if not isServer then
		return false, "Server only"
	end

	local v4 = venueById(venueId) -- inferred equivalent call

	if not v4 then
		return false, "That venue does not exist"
	end

	local v5 = v2[player.UserId]

	if v5 then
		if not v5.Finished then
			return false, "You are already in a game"
		end

		closeSession(v5)
	end

	local v6 = newSession(venueId)

	if not charge(v6, player, v4) then -- inferred equivalent call
		closeSession(v6)

		return false, "You cannot afford that table"
	end

	local arrived = v6.Arrived
	local userId = player.UserId
	arrived[userId] = { Player = player, VenueId = venueId, At = os.clock(), Index = nextArrival() } -- inferred equivalent call

	v2[player.UserId] = v6
	v6.ExpectedOpponents[player.UserId] = p

	v6.VsBot = vsBot

	startMatch(v6, venueId, vsBot, true)

	if v6.Running then
		if v6.Bot then
			v6.Bot.Placeholder = false
		end

		return true
	end

	refundArrival(v6, player.UserId) -- inferred equivalent call
	closeSession(v6)

	return false, "Could not open a table"
end

local function setSeatCosmetic(p, p2: string, p3: string?)
	if not isServer then
		return
	end

	local v4 = sessionFor(p) -- inferred equivalent call

	if not v4 or not v4.Running or v4.Finished then
		return
	end

	local state = v4.State

	if not state then
		return
	end

	for k, seat in state.Seats do
		if seat.UserId == p.UserId then
			v4.Replica:Write("PoolMatchSeatSkin", k, p2, p3)
			break
		end
	end
end

function PoolMatchSession.SetSeatSkin(p, p2: string?)
	setSeatCosmetic(p, "TableSkin", p2)
end

function PoolMatchSession.SetSeatCue(p, p2: string?)
	setSeatCosmetic(p, "CueSkin", p2)
end

function PoolMatchSession:AbandonSession(p: string)
	if self.Finished then
		return
	end

	self.Finished = true
	self.Running = false

	local venue = self.Venue

	for k, v4 in self.Arrived do
		local v5

		if venue then
			v5 = venue
		else
			v5 = venueById(v4.VenueId) -- inferred equivalent call
		end

		refundArrival(self, k) -- inferred equivalent call

		if v4.Player and v4.Player.Parent then
			bindableEvent:Fire(v4.Player, v5, p)
		end
	end

	table.clear(self.Arrived)

	if self.Replica then
		self.Replica:Write("PoolMatchInit", PoolMatchTypes.Empty())
	end

	task.delay(2, function()
		closeSession(self)
	end)
end

local function tellRematch(p, p2: string, ...)
	local state = p.State

	if not state then
		return
	end

	for _, seat in state.Seats do
		local playerByUserId = Players:GetPlayerByUserId(seat.UserId)

		if playerByUserId then
			RemoteSignals.FireClient(playerByUserId, RemoteEnums.Pool, p2, ...)
		end
	end
end

local function tellRematchExcept(state, p: number?, p2: string, ...)
	local state2 = state.State

	if not state2 then
		return
	end

	for _, seat in state2.Seats do
		if seat.UserId == p then
			continue
		end

		local playerByUserId = Players:GetPlayerByUserId(seat.UserId)

		if playerByUserId then
			RemoteSignals.FireClient(playerByUserId, RemoteEnums.Pool, p2, ...)
		end
	end
end

local function declineRematch(state, p: number?)
	if state.Declined then
		return
	end

	state.Declined = true
	table.clear(state.Accepted)

	tellRematchExcept(state, p, "RematchDeclined")

	task.delay(2, function()
		closeSession(state)
	end)
end

function PoolMatchSession.PlayerLeft(p)
	local v4 = sessionFor(p) -- inferred equivalent call

	if not v4 then
		return
	end

	refundArrival(v4, p.UserId) -- inferred equivalent call

	if v4.PendingTakeover == p then
		v4.PendingTakeover = nil
	end

	v4.Arrived[p.UserId] = nil
	v2[p.UserId] = nil

	local seat = v4.Seats[p.UserId]

	if seat then
		if v4.Finished then
			declineRematch(v4, p.UserId)

			return
		end

		if not v4.Running then
			return
		end

		v4.Left[p.UserId] = true

		local afkBot2 = v4.AfkBot

		if afkBot2 and afkBot2.Seat == seat then
			v4.AfkBot = nil
		end

		local v5 = false

		if not v4.Bot then
			local success, result = pcall(substituteBot, v4, seat)

			if success then
				v5 = result == true
			else
				warn("[PoolMatchSession] could not substitute a bot: " .. tostring(result))
			end
		end

		if v5 then
			return
		end

		finish(v4, PoolMatchTypes.Opponent(seat), "Opponent left the match")
	else
		local count3 = 0

		for _ in v4.Arrived do
			count3 += 1
		end

		if count3 == 0 and not v4.Running then
			closeSession(v4)
		end
	end
end

local function beginRematch(state)
	local state2 = state.State
	local venue = state.Venue

	if not state2 or not venue or state.Declined then
		return
	end

	local playerByUserIds = {}

	for _, seat in state2.Seats do
		if not (not state.VsBot or not seat.IsBot or seat.UserId ~= 0) then
			continue
		end

		local playerByUserId = Players:GetPlayerByUserId(seat.UserId)

		if not playerByUserId then
			declineRematch(state)

			return
		end

		if PoolPlayerData.CanAfford(seat.UserId, venue.EntryFee) then
			table.insert(playerByUserIds, playerByUserId)
		else
			declineRematch(state)

			return
		end
	end

	for _, v4 in playerByUserIds do
		PoolPlayerData.AddCoins(v4.UserId, -venue.EntryFee)
	end

	state.RematchCount += 1
	table.clear(state.Accepted)
	table.clear(state.Arrived)

	local v4 = state.LastBreaker == 1 and 2 or 1
	local count3 = nextArrival() -- inferred equivalent call
	local count4 = nextArrival() -- inferred equivalent call

	for _, player in playerByUserIds do
		local seat = PoolMatchTypes.SeatOf(state2, player.UserId)

		local arrived = state.Arrived
		local userId = player.UserId
		local v5 = { Player = player, VenueId = venue.Id, At = os.clock(), Index = 0 }

		local v6 = if seat == v4 then count3 else count4
		v5.Index = v6
		arrived[userId] = v5
	end

	table.clear(state.Seats)
	state.Running = false

	tellRematch(state, "RematchStarting")

	local bot = state.Bot
	local vsBot = state.VsBot
	local v5

	if vsBot == nil or bot == nil then
		v5 = false
	else
		v5 = bot.Seat == v4
	end

	local v6

	if vsBot and bot then
		v6 = bot.AI
	end

	startMatch(state, venue.Id, vsBot, false, v5, v6)

	local bot2 = state.Bot

	if vsBot and bot2 then
		bot2.Placeholder = false
	end
end

local function scheduleBotRematch(data)
	local botRematch = data.BotRematch

	if not botRematch or botRematch.Scheduled or not data.Finished or data.Declined then
		return
	end

	botRematch.Scheduled = true

	local rematchCount = data.RematchCount
	local number = random:NextNumber(
		PoolMatchmakingConstants.BotRematchDelay.Min,
		(math.max(PoolMatchmakingConstants.BotRematchDelay.Min, PoolMatchmakingConstants.BotRematchDelay.Max))
	)

	task.delay(number, function()
		if
			v[data.Id] ~= data
			or data.BotRematch ~= botRematch
			or data.RematchCount ~= rematchCount
			or not data.Finished
			or data.Declined
		then
			return
		end

		if not botRematch.Wants then
			declineRematch(data)

			return
		end

		data.Accepted[0] = true
		local count3 = 0

		for _ in data.Accepted do
			count3 += 1
		end

		if count3 >= 2 then
			beginRematch(data)
		else
			tellRematch(data, "RematchWanted", 0)
		end
	end)
end

function PoolMatchSession.Rematch(p)
	local v4 = sessionFor(p) -- inferred equivalent call

	if not v4 or (not v4.Finished or v4.Declined) or not v4.Seats[p.UserId] then
		return
	end

	if v4.Accepted[p.UserId] then
		return
	end

	v4.Accepted[p.UserId] = true

	scheduleBotRematch(v4)
	local count3 = 0

	for _ in v4.Accepted do
		count3 += 1
	end

	if count3 >= 2 then
		beginRematch(v4)
	else
		tellRematch(v4, "RematchWanted", p.UserId)
	end
end

function PoolMatchSession.DeclineRematch(p)
	local v4 = sessionFor(p) -- inferred equivalent call

	if not (v4 and v4.Finished and v4.Seats[p.UserId]) then
		return
	end

	declineRematch(v4, p.UserId)
end

function PoolMatchSession.ResultShown(p)
	local v4 = sessionFor(p) -- inferred equivalent call

	if v4 and v4.Finished and v4.Seats[p.UserId] then
		scheduleBotRematch(v4)
	end
end

function PoolMatchSession.ReturnToLobby(p)
	if game.PrivateServerId == "" then
		return
	end

	local success, result = pcall(function()
		TeleportService:Teleport(game.PlaceId, p)
	end)

	if not success then
		warn("[PoolMatchSession] could not send " .. p.Name .. " back: " .. tostring(result))
	end
end

function PoolMatchSession.IsPlaying(p)
	local v4 = sessionFor(p) -- inferred equivalent call
	return v4 ~= nil and v4.Running and not v4.Finished
end

function PoolMatchSession.IsBusy(p): boolean
	local v4 = sessionFor(p) -- inferred equivalent call
	return v4 ~= nil and not v4.Finished
end

function PoolMatchSession.DescribeSeat(p, p2: number)
	local v4 = sessionFor(p) -- inferred equivalent call
	local state = v4 and v4.State

	if not v4 or not state or v4.Seats[p.UserId] == nil then
		return nil, nil, nil
	end

	local seat = state.Seats[p2]

	if not seat then
		return nil, nil, nil
	end

	local bot = v4.Bot
	local v5

	if bot == nil then
		v5 = false
	else
		v5 = bot.Seat == p2
	end

	local rating

	if bot and v5 then
		rating = bot.Level.Rating
	end

	local venue = v4.Venue
	local v6

	if v5 and venue then
		v6 = venue.Id
	end

	return table.clone(seat), rating, v6
end

function PoolMatchSession.CountRunning()
	local count3 = 0

	for _, v4 in v do
		if not v4.Running or v4.Finished then
			continue
		end

		count3 += 1
	end

	return count3
end

function PoolMatchSession.Init()
	if isServer then
	end
end

return PoolMatchSession