local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolVenueProgress = require(Pool.PoolVenueProgress)

local isServer = RunService:IsServer()

local v = {}

local v2 = {}

local function reachedIndex(data) -- 2 equivalent calls inferred from this helper
	if typeof(data) == "table" then
		return PoolVenueProgress.ReachedIndex(PoolVenueProgress.LevelOf(data), data.poolVenueWins, false)
	end

	return 1
end

local function log(p, p2: number, p3)
	local venue = PoolConstants.Venues[p2]

	if not venue then
		return
	end

	local v3 = string.format("%d:%d:%s", p.UserId, p2, p3.Name)

	if v[v3] then
		return
	end

	v[v3] = true

	pcall(function()
		AnalyticsService:LogProgressionEvent(p, "VenueLadder", p3, p2, venue.Name, {
			CustomField01 = venue.Id
		})
	end)
end

if isServer then
	Players.PlayerRemoving:Connect(function(player)
		v2[player.UserId] = nil

		local v3 = tostring(player.UserId) .. ":"

		for k in v do
			if string.sub(k, 1, #v3) == v3 then
				v[k] = nil
			end
		end
	end)
end

local PoolProgressionAnalytics = {}

function PoolProgressionAnalytics.LogSession(p)
	if not isServer then
		return
	end

	local replica = PoolPlayerData.GetReplica(p.UserId)

	if not (replica and replica.Data) then
		return
	end

	local v3 = reachedIndex(replica.Data) -- inferred equivalent call

	v2[p.UserId] = v3

	log(p, v3, Enum.AnalyticsProgressionType.Start)
end

function PoolProgressionAnalytics.LogVenueWin(p)
	if not isServer then
		return
	end

	local replica = PoolPlayerData.GetReplica(p.UserId)

	if not (replica and replica.Data) then
		return
	end

	local v3 = reachedIndex(replica.Data) -- inferred equivalent call
	local v4 = v2[p.UserId] or v3

	if v3 <= v4 then
		return
	end

	v2[p.UserId] = v3

	for i = v4, v3 - 1 do
		log(p, i, Enum.AnalyticsProgressionType.Complete)
		log(p, i + 1, Enum.AnalyticsProgressionType.Start)
	end
end

return PoolProgressionAnalytics