local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Level = require(ReplicatedStorage.Libraries.Modules.Level)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)

local PoolVenueProgress = {}

local isServer = RunService:IsServer()

local color = Color3.fromRGB(255, 206, 84)

local function count(p) -- 4 equivalent calls inferred from this helper
	local v = tonumber(p)

	if v and v == v and v ~= 1e999 then
		return (math.max(math.floor(v), 0))
	end

	return 0
end

function PoolVenueProgress.LevelFor(p: number)
	return (math.max(tonumber((Level:GetLevel(math.max(p, 0), "LEVEL_EQUATION"))) or 1, 1))
end

function PoolVenueProgress.LevelOf(p)
	local v

	if typeof(p) == "table" then
		v = count(p.experience) -- inferred equivalent call
	else
		v = 0
	end

	return PoolVenueProgress.LevelFor(v)
end

local v = {}

function PoolVenueProgress.ExperienceFor(p: number)
	local v2 = math.max(math.floor(p), 1)

	local v3 = v[v2]

	if v3 then
		return v3
	end

	local selected = 1
	local v4 = 0

	while PoolVenueProgress.LevelFor(selected) < v2 and selected < 1000000000000 do
		selected *= 2
	end

	for _ = 1, 60 do
		if selected - v4 <= 1 then
			break
		end

		local v5 = math.floor((v4 + selected) / 2)

		if v2 <= PoolVenueProgress.LevelFor(v5) then
			selected = v5
		else
			v4 = v5
		end
	end

	if v2 <= PoolVenueProgress.LevelFor(v4) then
		selected = v4
	end

	v[v2] = selected

	return selected
end

function PoolVenueProgress.LevelProgress(p: number, p2: number)
	local experienceFor = PoolVenueProgress.ExperienceFor(p2)

	if experienceFor <= 0 then
		return 1
	end

	return (math.clamp(p / experienceFor, 0, 1))
end

function PoolVenueProgress.UnlockLevel(p: string?)
	local v2

	if p then
		v2 = PoolConstants.GetVenue(p)
	end

	if not v2 then
		return 1
	end

	local unlockLevel = v2.UnlockLevel

	if typeof(unlockLevel) == "number" then
		return (math.max(math.floor(unlockLevel), 1))
	end

	local v3

	if v2.PlaysLike then
		v3 = PoolConstants.GetVenue(v2.PlaysLike)
	end

	local unlockLevel2 = v3 and v3.UnlockLevel

	if typeof(unlockLevel2) == "number" then
		return (math.max(math.floor(unlockLevel2), 1))
	end

	return 1
end

local function legacyPrevious(p: string)
	local venue = PoolConstants.GetVenue(p)

	if not venue then
		return nil
	end

	local v2

	if venue.GameType == "NineBall" then
		v2 = PoolConstants.LegacyNineBallLadder
	else
		v2 = PoolConstants.LegacyVenueLadder
	end

	for k, v3 in v2 do
		if v3 == p then
			if k > 1 then
				return v2[k - 1]
			end

			return nil
		end
	end

	return nil
end

function PoolVenueProgress.LegacyUnlocked(p: string, p2): boolean
	if typeof(p2) ~= "table" then
		return false
	end

	local v2 = legacyPrevious(p)

	return v2 ~= nil and count(p2[v2]) >= PoolConstants.VenueUnlockWins -- inferred equivalent call
end

function PoolVenueProgress.IsUnlocked(p: string, p2: number, p3, flag: boolean?)
	if flag == true or PoolVenueProgress.UnlockLevel(p) <= p2 then
		return true
	end

	return PoolVenueProgress.LegacyUnlocked(p, p3)
end

function PoolVenueProgress.IsUnlockedFor(p: string, p2, flag: boolean?)
	local v2

	if typeof(p2) == "table" then
		v2 = p2.poolVenueWins
	end

	return PoolVenueProgress.IsUnlocked(p, PoolVenueProgress.LevelOf(p2), v2, flag)
end

function PoolVenueProgress.CountUnlocked(p: number, p2, flag: boolean?)
	local count2 = 0

	for _, venue in PoolConstants.Venues do
		if PoolVenueProgress.IsUnlocked(venue.Id, p, p2, flag) then
			count2 += 1
		end
	end

	return count2
end

function PoolVenueProgress.ReachedIndex(p: number, p2, flag: boolean?)
	local v2 = 1

	for k, venue in PoolConstants.Venues do
		if k == 1 then
			continue
		end

		if not PoolVenueProgress.IsUnlocked(venue.Id, p, p2, flag) then
			break
		end

		v2 = k
	end

	return v2
end

function PoolVenueProgress.RewardWins()
	return (math.max(count(PoolConstants.VenueRewardWins), 1)) -- inferred equivalent call
end

function PoolVenueProgress.RewardCue(_: string?): nil
	return nil
end

function PoolVenueProgress.HasReward(p: string?)
	local PoolVenueLootbox = require(Pool.PoolVenueLootbox)

	return PoolVenueLootbox.IsBoxVenue(p)
end

function PoolVenueProgress.RewardName(p: string?)
	local rewardCue = PoolVenueProgress.RewardCue(p)

	if not rewardCue then
		return nil
	end

	local PoolSkins = require(Pool.PoolSkins)
	local item = PoolSkins.GetItem("cueSticks", rewardCue)

	if item and item.name then
		return (tostring(item.name))
	end

	return rewardCue
end

function PoolVenueProgress.Wins(p, p2: string)
	if typeof(p) ~= "table" then
		return 0
	end

	return count(p[p2]) -- inferred equivalent call
end

function PoolVenueProgress.GrantRewards(p, p2: string?): boolean
	if not isServer then
		return false
	end

	local PoolPlayerData = require(Pool.PoolPlayerData)
	local PoolVenueLootbox = require(Pool.PoolVenueLootbox)

	PoolVenueLootbox.EnsureRecord(p.UserId)

	local replica = PoolPlayerData.GetReplica(p.UserId)

	if not (p2 and replica and PoolVenueLootbox.IsBoxVenue(p2)) then
		return false
	end

	local wins = PoolVenueLootbox.Wins(replica.Data, p2)
	local winsPerBox = PoolVenueLootbox.WinsPerBox()

	if wins <= 0 or wins % winsPerBox ~= 0 or PoolVenueLootbox.Waiting(replica.Data, p2) <= 0 then
		return false
	end

	pcall(function()
		local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
		local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
		local boxName = PoolVenueLootbox.BoxName(p2)

		RemoteSignals.FireClient(p, RemoteEnums.Notification, "Notification", "TextNotification", {
			message = string.format("%d WINS IN %s! LOOTBOX EARNED!", wins, string.upper(boxName)),
			colour = color,
			length = 7
		})
	end)

	return true
end

return PoolVenueProgress