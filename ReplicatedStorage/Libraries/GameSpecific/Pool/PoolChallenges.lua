local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolMatchSession = require(Pool.PoolMatchSession)
local PoolMatchmaking = require(Pool.PoolMatchmaking)
local PoolBotMatchmaking = require(Pool.PoolBotMatchmaking)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolVip = require(Pool.PoolVip)

local PoolChallenges = {}

local isServer = RunService:IsServer()

PoolChallenges.Seconds = 20

local v = {}

local function venueById(p: string) -- 1 equivalent call inferred from this helper
	return PoolConstants.GetVenue(p)
end

local v2 = {}

function PoolChallenges.SetLocalMatch(p, flag: boolean)
	v2[p.UserId] = flag and true or nil
end

Players.PlayerRemoving:Connect(function(player)
	v2[player.UserId] = nil
end)

function PoolChallenges.IsBusy(p)
	return PoolMatchSession.IsBusy(p)
		or PoolMatchmaking.IsQueued(p)
		or PoolBotMatchmaking.IsQueued(p)
		or v2[p.UserId] == true
end

function PoolChallenges.BuildRoster()
	local roster = {}

	for _, v3 in Players:GetPlayers() do
		table.insert(roster, {
			UserId = v3.UserId,
			Name = v3.Name,
			DisplayName = v3.DisplayName,
			Level = PoolPlayerData.GetLevel(v3.UserId),
			Coins = PoolPlayerData.GetCoins(v3.UserId),
			WinStreak = PoolPlayerData.GetWinStreak(v3.UserId),
			Vip = PoolVip.Owns(v3.UserId),
			Busy = PoolChallenges.IsBusy(v3)
		})
	end

	return roster
end

local function sweep()
	local now = os.clock()

	for k, v3 in v do
		for k2, v4 in v3 do
			if v4.ExpiresAt + 2 < now then
				v3[k2] = nil
			end
		end

		if next(v3) == nil then
			v[k] = nil
		end
	end
end

function PoolChallenges.Open(p, player, p2: string)
	if not isServer then
		return false, "Server only"
	end

	sweep()

	if p == player then
		return false, "You cannot challenge yourself"
	end

	local v3 = venueById(p2) -- inferred equivalent call

	if not v3 then
		return false, "That venue does not exist"
	end

	if PoolChallenges.IsBusy(p) then
		return false, "You are already in a game"
	end

	if PoolChallenges.IsBusy(player) then
		return false, string.format("%s is already in a game", player.DisplayName)
	end

	if not PoolPlayerData.CanAfford(p.UserId, v3.EntryFee) then
		return false, "You cannot afford that table"
	end

	if not PoolPlayerData.CanAfford(player.UserId, v3.EntryFee) then
		return false, string.format("%s cannot afford that table", player.DisplayName)
	end

	local v4 = v[player.UserId]

	if not v4 then
		v4 = {}
		v[player.UserId] = v4
	end

	v4[p.UserId] = {
		FromUserId = p.UserId,
		ToUserId = player.UserId,
		VenueId = v3.Id,
		ExpiresAt = os.clock() + PoolChallenges.Seconds
	}

	return true
end

function PoolChallenges.Take(p: number, p2: number)
	local v3 = v[p]

	if not v3 then
		return nil
	end

	local v4 = v3[p2]

	if not v4 then
		return nil
	end

	v3[p2] = nil

	if next(v3) == nil then
		v[p] = nil
	end

	return if not (os.clock() > v4.ExpiresAt + 2) then v4 else nil
end

function PoolChallenges.DropAll(p: number)
	local result = {}

	local v3 = v[p]

	if v3 then
		for _, v4 in v3 do
			table.insert(result, v4)
		end

		v[p] = nil
	end

	for k, v4 in v do
		local v5 = v4[p]

		if v5 then
			table.insert(result, v5)
			v4[p] = nil
		end

		if next(v4) == nil then
			v[k] = nil
		end
	end

	return result
end

return PoolChallenges