local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local PoolMatchmakingConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMatchmakingConstants)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolSkill = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolSkill)

local PoolMatchmaking = {}

local isServer = RunService:IsServer()

local v = {}
local sortedMaps = {}
local v2 = false

local function queueMap(p: string) -- 6 equivalent calls inferred from this helper
	if not sortedMaps[p] then
		sortedMaps[p] = MemoryStoreService:GetSortedMap(PoolMatchmakingConstants.QueuePrefix .. p)
	end

	return sortedMaps[p]
end

local function venueById(p: string) -- 2 equivalent calls inferred from this helper
	for _, venue in PoolConstants.Venues do
		if venue.Id == p then
			return venue
		end
	end

	return nil
end

local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")

PoolMatchmaking.Matched = bindableEvent.Event

PoolMatchmaking.Failed = bindableEvent2.Event

local bindableEvent3 = Instance.new("BindableEvent")

PoolMatchmaking.TimedOut = bindableEvent3.Event

local v3 = {}

local function awaitFree(userId: number)
	local v4 = os.clock() + 5

	while v3[userId] and os.clock() < v4 do
		task.wait()
	end
end

function PoolMatchmaking.IsQueued(p): boolean
	return v[p.UserId] ~= nil
end

function PoolMatchmaking.GetWaitTime(p)
	local v4 = v[p.UserId]

	if v4 then
		return os.time() - v4.QueuedAt
	end

	return 0
end

function PoolMatchmaking.Queue(player, venueId: string, level: number, p): boolean
	if not isServer or v[player.UserId] then
		return false
	end

	if not venueById(venueId) then -- inferred equivalent call
		bindableEvent2:Fire(player, "Unknown venue")

		return false
	end

	awaitFree(player.UserId)

	if v[player.UserId] then
		return false
	end

	local v4 = p or PoolSkill.NewStats()

	local v5 = {
		UserId = player.UserId,
		Name = player.Name,
		DisplayName = player.DisplayName,
		Level = level,
		VenueId = venueId,
		JobId = game.JobId,
		QueuedAt = os.time(),
		RefreshedAt = os.time(),
		Rating = v4.Rating,
		Streak = v4.Streak,
		Wins = v4.Wins,
		Losses = v4.Losses
	}

	v3[player.UserId] = true

	local success, result = pcall(function()
		queueMap(venueId):SetAsync(tostring(player.UserId), v5, PoolMatchmakingConstants.EntryExpiry, level) -- inferred equivalent call
	end)

	if success then
		v[player.UserId] = v5
		v3[player.UserId] = nil

		PoolMatchmaking.Start()

		return true
	end

	v3[player.UserId] = nil

	warn("[PoolMatchmaking] could not queue: " .. tostring(result))
	bindableEvent2:Fire(player, "Queue unavailable")

	return false
end

function PoolMatchmaking.Leave(p)
	awaitFree(p.UserId)

	local v4 = v[p.UserId]

	if not v4 then
		return
	end

	v[p.UserId] = nil
	GONE_SINCE[p.UserId] = nil
	v3[p.UserId] = true

	pcall(function()
		queueMap(v4.VenueId):RemoveAsync((tostring(v4.UserId))) -- inferred equivalent call
	end)

	v3[p.UserId] = nil
end

local function claim(venueId: string, userId: number)
	local v4 = nil
	local v5 = queueMap(venueId) -- inferred equivalent call
	local v6 = tostring(userId)

	if pcall(function()
		v5:UpdateAsync(v6, function(p, p2)
			v4 = nil

			if not (typeof(p) == "table" and p.ClaimedBy == nil) then
				return nil
			end

			p.ClaimedBy = game.JobId
			v4 = p

			return p, p2
		end, PoolMatchmakingConstants.EntryExpiry)
	end) and v4 then
		pcall(function()
			v5:RemoveAsync(v6)
		end)

		return v4
	end

	return nil
end

local v4 = {}

local function claimOwn(venueId: string, userId: number)
	local v5 = "error"
	local v6 = queueMap(venueId) -- inferred equivalent call
	local v7 = tostring(userId)

	v3[userId] = true

	if pcall(function()
		v6:UpdateAsync(v7, function(p, p2)
			if typeof(p) ~= "table" then
				v5 = "gone"

				return nil
			end

			if p.ClaimedBy ~= nil then
				v5 = "claimed"

				return nil
			end

			v5 = "taken"
			p.ClaimedBy = game.JobId

			return p, p2
		end, PoolMatchmakingConstants.EntryExpiry)
	end) then
		if v5 == "taken" then
			pcall(function()
				v6:RemoveAsync(v7)
			end)
		end
	else
		v5 = "error"
	end

	v3[userId] = nil

	return v5
end

local function restore(state) -- 8 equivalent calls inferred from this helper
	state.ClaimedBy = nil

	pcall(function()
		queueMap(state.VenueId):SetAsync( -- inferred equivalent call
			tostring(state.UserId),
			state,
			PoolMatchmakingConstants.EntryExpiry,
			state.Level
		)
	end)
end

local function opponentInfo(player) -- 3 equivalent calls inferred from this helper
	local v5 = {
		UserId = player.UserId,
		Name = player.Name,
		DisplayName = player.DisplayName,
		Level = 0
	}
	local level

	if player.Level and player.Level > 0 then
		level = player.Level
	end

	v5.Level = level
	return v5
end

local function sendToMatch(p, player, reservedServerAccessCode: string, venueId: string)
	bindableEvent:Fire(p, player.UserId, reservedServerAccessCode)

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = reservedServerAccessCode
	teleportOptions:SetTeleportData({
		VenueId = venueId,
		OpponentUserId = player.UserId,
		Opponents = { [tostring(p.UserId)] = opponentInfo(player) } -- inferred equivalent call
	})

	local success, result = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, { p }, teleportOptions)
	end)

	if not success then
		warn("[PoolMatchmaking] teleport failed: " .. tostring(result))
		bindableEvent2:Fire(p, "Could not reach the match server")
	end

	return success
end

local function sendPairToMatch(player, playerByUserId, data, player2, reservedServerAccessCode: string, venueId: string)
	bindableEvent:Fire(player, playerByUserId.UserId, reservedServerAccessCode)
	bindableEvent:Fire(playerByUserId, player.UserId, reservedServerAccessCode)
	local v5 = opponentInfo(data) -- inferred equivalent call
	v5.Name = player.Name
	v5.DisplayName = player.DisplayName
	local v6 = opponentInfo(player2) -- inferred equivalent call
	v6.Name = playerByUserId.Name
	v6.DisplayName = playerByUserId.DisplayName

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = reservedServerAccessCode
	teleportOptions:SetTeleportData({
		VenueId = venueId,
		Opponents = { [tostring(player.UserId)] = v6, [tostring(playerByUserId.UserId)] = v5 }
	})

	local success, result = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, { player, playerByUserId }, teleportOptions)
	end)

	if not success then
		warn("[PoolMatchmaking] pair teleport failed: " .. tostring(result))

		bindableEvent2:Fire(player, "Could not reach the match server")
		bindableEvent2:Fire(playerByUserId, "Could not reach the match server")
	end

	return success
end

local function statsOf(data) -- 3 equivalent calls inferred from this helper
	return {
		Wins = data.Wins or 0,
		Losses = data.Losses or 0,
		Streak = data.Streak or 0,
		Rating = data.Rating or PoolSkill.BaseRating
	}
end

local function isProtected(p, p2: number): boolean -- 1 equivalent call inferred from this helper
	if
		PoolSkill.Games(p) < PoolMatchmakingConstants.WinRateFloorGames
		or PoolMatchmakingConstants.FloorRelaxAfter <= p2
	then
		return false
	end

	return PoolSkill.WinRate(p) < PoolMatchmakingConstants.MinOpponentWinRate
end

local function isLive(value): boolean
	if value.ClaimedBy ~= nil or value.JobId == game.JobId and not Players:GetPlayerByUserId(value.UserId) then
		return false
	end

	local refreshedAt = tonumber(value.RefreshedAt) or tonumber(value.QueuedAt) or 0

	return os.time() - refreshedAt <= PoolMatchmakingConstants.StaleAfter
end

local function pairingScore(data, value, p: number)
	local v5 = statsOf(data) -- inferred equivalent call
	local v6 = statsOf(value) -- inferred equivalent call
	local winChance = PoolSkill.WinChance(v5.Rating, v6.Rating)

	local v7 = math.abs(winChance - PoolSkill.TargetWinChance(v5))
	local v8 = math.abs(1 - winChance - PoolSkill.TargetWinChance(v6))

	local v9 = math.min(p * PoolMatchmakingConstants.WaitBonusPerSecond, PoolMatchmakingConstants.MaxWaitBonus)

	return v7 + v8 * PoolMatchmakingConstants.MutualWeight - v9
end

local function tryMatch(playerByUserId, entry): boolean
	local v5 = os.time() - entry.QueuedAt
	local levelRange, v6 = PoolMatchmakingConstants.GetLevelRange(entry.Level, v5)

	local rangeAsync = nil

	if not (pcall(function()
		rangeAsync = queueMap(entry.VenueId):GetRangeAsync(Enum.SortDirection.Ascending, 20, { -- inferred equivalent call
			key = "",
			sortKey = math.max(levelRange - 1, 0)
		}, v6 < 1e999 and {
			key = "",
			sortKey = v6 + 1
		} or nil)
	end) and rangeAsync) then
		return false
	end

	local v7 = {}

	for _, v8 in rangeAsync do
		local entry2 = v8.value

		if not (typeof(entry2) == "table" and entry2.UserId ~= entry.UserId and isLive(entry2)) then
			continue
		end

		if not PoolMatchmakingConstants.IsCompatible(entry.Level, v5, entry2.Level, os.time() - entry2.QueuedAt) then
			continue
		end

		local v9 = os.time() - (entry2.QueuedAt or os.time())

		if not isProtected(statsOf(entry2), v9) then -- inferred equivalent call
			table.insert(v7, {
				Entry = entry2,
				Score = pairingScore(entry, entry2, v9)
			})
		end
	end

	table.sort(v7, function(a, b): boolean
		return a.Score < b.Score
	end)

	for _, v8 in v7 do
		local entry2 = v8.Entry

		local v9 = claim(entry.VenueId, entry2.UserId)

		if not v9 then
			continue
		end

		local v10 = claim(entry.VenueId, entry.UserId)

		if v10 then
			v[entry.UserId] = nil

			local code = nil

			if pcall(function()
				code = TeleportService:ReserveServer(game.PlaceId)
			end) and code then
				local playerByUserId2 = Players:GetPlayerByUserId(v9.UserId)

				if playerByUserId2 then
					v[v9.UserId] = nil

					local reservedServerAccessCode = code

					if sendPairToMatch(
						playerByUserId,
						playerByUserId2,
						entry,
						v9,
						reservedServerAccessCode,
						entry.VenueId
					) then
						return true
					end

					restore(v9) -- inferred equivalent call
					restore(v10) -- inferred equivalent call
					v[entry.UserId] = entry
					v[v9.UserId] = v9

					return false
				else
					local jsonEncode = HttpService:JSONEncode({
						UserId = v9.UserId,
						JobId = v9.JobId,
						OpponentUserId = entry.UserId,
						OpponentName = playerByUserId.Name,
						OpponentDisplayName = playerByUserId.DisplayName,
						OpponentLevel = entry.Level,
						VenueId = entry.VenueId,
						Code = code
					})
					local v11 = false

					for i = 1, PoolMatchmakingConstants.PublishAttempts do
						v11 = pcall(function()
							MessagingService:PublishAsync(PoolMatchmakingConstants.MessagingTopic, jsonEncode)
						end)

						if v11 then
							break
						end

						if i < PoolMatchmakingConstants.PublishAttempts then
							task.wait(PoolMatchmakingConstants.PublishRetryDelay)
						end
					end

					if v11 then
						local reservedServerAccessCode = code
						sendToMatch(playerByUserId, v9, reservedServerAccessCode, entry.VenueId)

						return true
					end

					warn("[PoolMatchmaking] could not reach the opponent's server; both requeued")
					restore(v9) -- inferred equivalent call
					restore(v10) -- inferred equivalent call
					v[entry.UserId] = entry

					return false
				end
			else
				warn("[PoolMatchmaking] could not reserve a server")
				restore(v9) -- inferred equivalent call
				restore(v10) -- inferred equivalent call
				v[entry.UserId] = entry

				return false
			end
		else
			restore(v9) -- inferred equivalent call
			return false
		end
	end

	return false
end

function PoolMatchmaking.Start()
	if v2 or not isServer then
		return
	end

	v2 = true

	task.spawn(function()
		local count = 0

		while true do
			count += 1

			if pcall(function()
				MessagingService:SubscribeAsync(PoolMatchmakingConstants.MessagingTopic, function(p)
					local success, result = pcall(function()
						return HttpService:JSONDecode(p.Data)
					end)

					if not success or result.JobId ~= game.JobId then
						return
					end

					local playerByUserId = Players:GetPlayerByUserId(result.UserId)

					if not (playerByUserId and v[result.UserId]) then
						return
					end

					v[result.UserId] = nil

					local v5 = {
						UserId = result.OpponentUserId,
						Name = 0,
						DisplayName = 0,
						Level = 0,
						VenueId = 0,
						JobId = "",
						QueuedAt = 0,
						RefreshedAt = 0
					}
					local name

					if typeof(result.OpponentName) == "string" then
						name = result.OpponentName
					end

					v5.Name = name
					local displayName

					if typeof(result.OpponentDisplayName) == "string" then
						displayName = result.OpponentDisplayName
					end

					v5.DisplayName = displayName

					v5.Level = tonumber(result.OpponentLevel) or 0
					v5.VenueId = result.VenueId
					sendToMatch(playerByUserId, v5, result.Code, result.VenueId)
				end)
			end) then
				break
			end

			warn(string.format(
				"[PoolMatchmaking] could not subscribe (attempt %d); players matched here cannot be reached until this succeeds",
				count
			))

			task.wait(PoolMatchmakingConstants.SubscribeRetryDelay)
		end

		if count > 1 then
			warn(string.format("[PoolMatchmaking] subscribed after %d attempts", count))
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		PoolMatchmaking.Leave(player)
	end)

	task.spawn(function()
		while true do
			task.wait(PoolMatchmakingConstants.PollInterval)

			local v5 = {}

			for k, entry in v do
				table.insert(v5, { UserId = k, Entry = entry })
			end

			for _, v6 in v5 do
				local userId = v6.UserId
				local entry = v6.Entry
				local playerByUserId = Players:GetPlayerByUserId(userId)

				if v[userId] ~= entry then
					continue
				end

				if playerByUserId then
					local venue = venueById(entry.VenueId) -- inferred equivalent call
					local botFallbackSeconds = venue and venue.BotFallbackSeconds

					if typeof(botFallbackSeconds) == "number" and botFallbackSeconds <= os.time() - entry.QueuedAt then
						local v7 = claimOwn(entry.VenueId, userId)

						if v7 == "gone" then
							v4[userId] = v4[userId] or os.clock()

							v7 = os.clock() - v4[userId] >= 8 and "taken" or "gone"
						else
							v4[userId] = nil
						end

						if v7 == "taken" and v[userId] == entry then
							v[userId] = nil
							v4[userId] = nil
							bindableEvent3:Fire(playerByUserId, entry.VenueId)
						end
					else
						if os.time() - entry.RefreshedAt > PoolMatchmakingConstants.EntryExpiry / 2 then
							entry.RefreshedAt = os.time()
							restore(entry) -- inferred equivalent call
						end

						tryMatch(playerByUserId, entry)
					end
				else
					v[userId] = nil
				end
			end
		end
	end)
end

return PoolMatchmaking