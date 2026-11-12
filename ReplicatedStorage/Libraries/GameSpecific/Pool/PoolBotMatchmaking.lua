local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAI = require(Pool.PoolAI)
local PoolBotProfiles = require(Pool.PoolBotProfiles)
local PoolConstants = require(Pool.PoolConstants)
local PoolMatchSession = require(Pool.PoolMatchSession)
local PoolMatchmakingConstants = require(Pool.PoolMatchmakingConstants)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolPlayerStats = require(Pool.PoolPlayerStats)
local PoolSkill = require(Pool.PoolSkill)
local PoolVip = require(Pool.PoolVip)

local random = Random.new()

local v = {}

local v2 = {}

local function enumerateFriends(p)
	local v3 = nil
	local total = 0
	local result = {}
	local v4 = nil

	for i = 1, 3 do
		local success, result2 = pcall(function()
			return Players:GetFriendsAsync(p.UserId)
		end)

		if success then
			v3 = result2
			break
		end

		task.wait(i)
		v4 = result2
	end

	if not v3 then
		error("GetFriendsAsync failed: " .. tostring(v4))
	end

	for _ = 1, 3 do
		local currentPage = v3:GetCurrentPage()
		total += #currentPage

		for _, v5 in currentPage do
			if not (typeof(v5) == "table" and tonumber(v5.Id) and v5.Username) then
				continue
			end

			table.insert(result, {
				UserId = tonumber(v5.Id),
				Name = tostring(v5.Username),
				DisplayName = tostring(v5.DisplayName or v5.Username),
				Level = nil
			})

			if #result >= 50 then
				return result, total
			end
		end

		if v3.IsFinished or not pcall(function()
			v3:AdvanceToNextPageAsync()
		end) then
			break
		end
	end

	return result, total
end

local function resolveFallbackFriends(object)
	local v3 = {}

	for _, friendFallbackUserId in PoolMatchmakingConstants.FriendFallbackUserIds do
		if not (tonumber(friendFallbackUserId) and friendFallbackUserId ~= object.UserId) then
			continue
		end

		local success, result = pcall(function()
			return object:IsFriendsWith(friendFallbackUserId)
		end)

		if success and result then
			table.insert(v3, friendFallbackUserId)
		end
	end

	if #v3 == 0 then
		if not RunService:IsStudio() then
			return {}
		end

		for _, studioPlaceholderUserId in PoolMatchmakingConstants.StudioPlaceholderUserIds do
			if tonumber(studioPlaceholderUserId) and studioPlaceholderUserId ~= object.UserId then
				table.insert(v3, studioPlaceholderUserId)
			end
		end
	end

	if #v3 == 0 then
		return {}
	end

	local success, result = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync(v3)
	end)

	if not success or typeof(result) ~= "table" then
		error("GetUserInfosByUserIdsAsync failed: " .. tostring(result))
	end

	local result2 = {}

	for _, v4 in result do
		if not (typeof(v4) == "table" and tonumber(v4.Id) and v4.Username) then
			continue
		end

		table.insert(result2, {
			UserId = tonumber(v4.Id),
			Name = tostring(v4.Username),
			DisplayName = tostring(v4.DisplayName or v4.Username),
			Level = nil
		})
	end

	return result2
end

local function prefetchFriends(p)
	local v3 = v[p.UserId]

	if v3 then
		local v4 = #v3.List > 0 and 300 or 20

		if v3.InFlight or os.clock() - v3.FetchedAt < v4 then
			return
		end
	else
		v3 = { List = {}, FetchedAt = -1e999, InFlight = false }
		v[p.UserId] = v3
	end

	v3.InFlight = true

	task.spawn(function()
		local list = {}
		local lastTime = os.clock()
		local v4 = 0

		local success, result = pcall(function()
			list, v4 = enumerateFriends(p)
		end)

		if not success then
			warn(string.format("[PoolBotMatchmaking] friends lookup for %s failed: %s", p.Name, (tostring(result))))
			list = {}
		end

		if #list == 0 then
			local success2, result2 = pcall(resolveFallbackFriends, p)

			if success2 and typeof(result2) == "table" then
				list = result2
			elseif not success2 then
				warn(string.format(
					"[PoolBotMatchmaking] friend fallback for %s failed: %s",
					p.Name,
					(tostring(result2))
				))
			end

			if #list == 0 then
				local name = p.Name
				local v5 = v4
				warn(string.format(
					"[PoolBotMatchmaking] no borrowable face for %s: enumeration returned %d, fallback returned 0 (%.2fs). Bots will use a generated country name.",
					name,
					v5,
					os.clock() - lastTime
				))
			end
		end

		if v[p.UserId] == v3 then
			v3.List = list
			v3.FetchedAt = os.clock()
			v3.InFlight = false
		end
	end)
end

local function drawAvoiding(list, p: number?)
	if #list == 0 then
		return nil
	end

	if #list == 1 then
		return list[1]
	end

	local v3 = {}

	for _, item in list do
		if item.UserId ~= p then
			table.insert(v3, item)
		end
	end

	if #v3 == 0 then
		v3 = list
	end

	return v3[random:NextInteger(1, #v3)]
end

local function pickDisguise(instance)
	local userIdSet = {}
	local v3 = {}

	for _, v4 in Players:GetPlayers() do
		userIdSet[v4.UserId] = true

		if v4 == instance then
			continue
		end

		local level = PoolPlayerData.GetLevel(v4.UserId)

		local v5 = { UserId = v4.UserId, Name = v4.Name, DisplayName = v4.DisplayName, Level = 0 }

		if typeof(level) ~= "number" or not (level > 0) then
			level = nil
		end

		v5.Level = level
		table.insert(v3, v5)
	end

	local v4 = {}
	local v5 = v[instance.UserId]

	if v5 then
		for _, item in v5.List do
			if not userIdSet[item.UserId] then
				table.insert(v4, item)
			end
		end
	end

	if PoolMatchmakingConstants.PreferFriendDisguise then
		v4, v3 = v3, v4
	end

	local v6 = v2[instance.UserId]
	local disguise = drawAvoiding(v3, v6) or drawAvoiding(v4, v6)

	if disguise then
		v2[instance.UserId] = disguise.UserId
	end

	return disguise
end

Players.PlayerAdded:Connect(function(player)
	task.delay(2, function()
		if player:IsDescendantOf(Players) then
			prefetchFriends(player)
		end
	end)
end)
local PoolBotMatchmaking = {}

local v3 = {}

local v4 = {}
local count = 0

for _, v5 in Players:GetPlayers() do
	task.spawn(prefetchFriends, v5)
end

Players.PlayerRemoving:Connect(function(player)
	v[player.UserId] = nil
	v2[player.UserId] = nil
end)

local bindableEvent = Instance.new("BindableEvent")
PoolBotMatchmaking.Failed = bindableEvent.Event

local function venueById(p: string) -- 2 equivalent calls inferred from this helper
	return PoolConstants.GetVenue(p)
end

function PoolBotMatchmaking.AppliesTo(p, p2: string?)
	local v5

	if p2 then
		v5 = venueById(p2) -- inferred equivalent call
	end

	return PoolMatchmakingConstants.UsesBotMatchmaking(PoolPlayerData.GetLevel(p.UserId), v5)
end

function PoolBotMatchmaking.IsQueued(p): boolean
	return v3[p.UserId] ~= nil
end

function PoolBotMatchmaking.WinRateBands(p: string?)
	local botWinRateBands = PoolMatchmakingConstants.BotWinRateBands
	local tuningVenueId = PoolConstants.TuningVenueId(p)
	local v5

	if p then
		v5 = botWinRateBands[p] or tuningVenueId and botWinRateBands[tuningVenueId]
	end

	return {
		Struggle = v5 and v5.Struggle or PoolMatchmakingConstants.BotStruggleWinRate,
		StepDown = v5 and v5.StepDown or PoolMatchmakingConstants.BotStepDownWinRate,
		StepUp = v5 and v5.StepUp or PoolMatchmakingConstants.BotStepUpWinRate
	}
end

function PoolBotMatchmaking.WinningTooOften(p, p2: string?)
	local games = PoolSkill.Games(p)

	if games <= 0 then
		return false, 0
	end

	local v5 = p.Wins / games

	return
		PoolMatchmakingConstants.BotStepUpWinRateMinGames <= games and PoolBotMatchmaking.WinRateBands(p2).StepUp < v5,
		v5
end

function PoolBotMatchmaking.LosingTooOften(p, p2: string?)
	local games = PoolSkill.Games(p)

	if games <= 0 then
		return false, 0
	end

	local v5 = p.Wins / games

	return
		PoolMatchmakingConstants.BotStepDownWinRateMinGames <= games and v5 < PoolBotMatchmaking.WinRateBands(p2).StepDown,
		v5
end

function PoolBotMatchmaking.IsNewPlayer(p): boolean
	return (p.Wins or 0) < PoolMatchmakingConstants.BotNewPlayerWins
end

function PoolBotMatchmaking.DecideStep(p, p2: string?, p3)
	local v5 = p3 or random
	local games = PoolSkill.Games(p)
	local wins = p.Wins or 0
	local winningTooOften, winRate = PoolBotMatchmaking.WinningTooOften(p, p2)

	if PoolBotMatchmaking.IsNewPlayer(p) then
		return {
			NewPlayer = true,
			StepUp = false,
			StepDown = v5:NextNumber() < PoolMatchmakingConstants.BotNewPlayerEasierChance,
			Struggling = false,
			WinningTooOften = false,
			WinRate = winRate,
			Games = games,
			Wins = wins
		}
	end

	local stepDown = not winningTooOften and PoolBotMatchmaking.LosingTooOften(p, p2)
	local stepUp

	if winningTooOften then
		stepUp = winningTooOften
	else
		stepUp = not stepDown

		if stepUp then
			if PoolMatchmakingConstants.BotStepUpAfterGames < games then
				stepUp = v5:NextNumber() < PoolMatchmakingConstants.BotStepUpChance
			else
				stepUp = false
			end
		end
	end

	return {
		NewPlayer = false,
		StepUp = stepUp,
		StepDown = stepDown,
		Struggling = stepDown and winRate < PoolBotMatchmaking.WinRateBands(p2).Struggle,
		WinningTooOften = winningTooOften,
		WinRate = winRate,
		Games = games,
		Wins = wins
	}
end

local function complete(instance, p: number)
	local v5 = v3[instance.UserId]

	if not v5 or v5.Token ~= p then
		return
	end

	v3[instance.UserId] = nil

	if not instance:IsDescendantOf(Players) then
		return
	end

	local v6 = venueById(v5.VenueId) -- inferred equivalent call

	if not v6 then
		bindableEvent:Fire(instance, "That venue does not exist")

		return
	end

	local skill = PoolPlayerData.GetSkill(instance.UserId)
	local decideStep = PoolBotMatchmaking.DecideStep(skill, v6.Id, random)
	local games = decideStep.Games
	local winRateBands = PoolBotMatchmaking.WinRateBands(v6.Id)
	local winningTooOften = decideStep.WinningTooOften
	local winRate = decideStep.WinRate
	local struggling = decideStep.Struggling

	local pick = PoolBotProfiles.Pick
	local id = v6.Id

	local stepUp = decideStep.StepUp
	local stepDown = decideStep.StepDown
	local v7

	if struggling then
		v7 = PoolMatchmakingConstants.BotStruggleDifficulty
	end

	local v8 = pick(id, random, stepUp, stepDown, v7)

	local function percent(p2: number) -- 5 equivalent calls inferred from this helper
		return (math.round(p2 * 100))
	end

	local v9

	if decideStep.NewPlayer then
		local wins = decideStep.Wins
		local botNewPlayerWins = PoolMatchmakingConstants.BotNewPlayerWins
		local v10

		if v8.SteppedDown then
			v10 = string.format("one rung down (%s)", v8.Difficulty)
		else
			v10 = string.format("the venue's own (%s)", v8.Difficulty)
		end

		v9 = string.format(
			"NEW PLAYER (%d wins, under %d): %s -- coin flip between the venue's difficulty and one rung down",
			wins,
			botNewPlayerWins,
			v10
		)
	elseif v8.SteppedDown and struggling then
		v9 = string.format(
			"playing VERY POORLY (%s): win rate under %d%%",
			v8.Difficulty,
			percent(winRateBands.Struggle) -- inferred equivalent call
		)
	elseif v8.SteppedDown then
		v9 = string.format("playing POORLY (%s): win rate under %d%%", v8.Difficulty, percent(winRateBands.StepDown)) -- inferred equivalent call
	elseif v8.SteppedUp then
		v9 = not winningTooOften and "stepped UP: random roll"
			or string.format("ABOVE AVERAGE (%s): win rate over %d%%", v8.Difficulty, percent(winRateBands.StepUp)) -- inferred equivalent call
	else
		v9 = string.format(
			"the venue's own difficulty (normal band %d-%d%%)",
			percent(winRateBands.StepDown), -- inferred equivalent call
			percent(winRateBands.StepUp) -- inferred equivalent call
		)
	end

	local v10 = PoolAI.GetLevel(v8.Difficulty)

	if not v10 then
		warn(string.format("[PoolBotMatchmaking] unknown difficulty %q for %s; using Beginner", v8.Difficulty, v6.Id))
		v10 = PoolAI.GetLevel("Beginner") or PoolAI.GetLevels()[1]
	end

	if RunService:IsStudio() then
		print(string.format(
			"[PoolBotMatchmaking] %s at %s: %s (%d games, %.0f%% wins) -- %s",
			instance.Name,
			v6.Id,
			v8.Difficulty,
			games,
			winRate * 100,
			v9
		))
	end

	local v11 = pickDisguise(instance)
	local vip

	if v11 then
		v4[instance.UserId] = p
		vip = PoolVip.OwnsAnyAsync(v11.UserId)

		local v12 = v4[instance.UserId] == p

		v4[instance.UserId] = nil

		if not (v12 and instance:IsDescendantOf(Players)) then
			return
		end
	else
		vip = false
	end

	local source = v11
		and (Players:GetPlayerByUserId(v11.UserId) and "a player in this server" or "one of the player's friends")
		or "country profile name"
	local v12

	if v11 then
		v12 = PoolPlayerStats.SeedFor(v11.UserId, v11.Name)
	else
		v12 = PoolPlayerStats.SeedFor(nil, v8.Name)
	end

	local levelForVenue = PoolPlayerStats.LevelForVenue(v6.Id, v12)

	local reason = string.format("%s (%d online games, %.0f%% wins, venue %s)", v9, games, winRate * 100, v6.Id)
	local v13

	if v11 then
		v13 = {
			UserId = v11.UserId,
			Name = v11.Name,
			DisplayName = v11.DisplayName,
			Level = math.max(v11.Level or 0, levelForVenue),
			Vip = vip,
			Source = source,
			Reason = reason
		}
	else
		v13 = {
			UserId = 0,
			Name = v8.Name,
			DisplayName = v8.DisplayName,
			Level = levelForVenue,
			Source = source,
			Reason = reason
		}
	end

	local success, result, v14 = pcall(PoolMatchSession.StartVsBot, instance, v6.Id, v13, v10)

	if success then
		if not result then
			bindableEvent:Fire(instance, v14 or "Could not start that match")
		end
	else
		warn("[PoolBotMatchmaking] could not open a bot table: " .. tostring(result))
		bindableEvent:Fire(instance, "Could not start that match")
	end
end

function PoolBotMatchmaking.Queue(p, venueId: string, p2: number?): boolean
	if v3[p.UserId] or v4[p.UserId] then
		return false
	end

	count += 1

	local token = count

	v3[p.UserId] = { Token = token, VenueId = venueId }

	prefetchFriends(p)

	local v5 = p2
		or random:NextNumber(
			PoolMatchmakingConstants.BotSearchMinSeconds,
			(math.max(PoolMatchmakingConstants.BotSearchMinSeconds, PoolMatchmakingConstants.BotSearchMaxSeconds))
		)

	task.delay(math.max(v5, 0), complete, p, token)

	return true
end

function PoolBotMatchmaking.Leave(p)
	v3[p.UserId] = nil

	v4[p.UserId] = nil
end

return PoolBotMatchmaking