local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolSkins = require(Pool.PoolSkins)

local PoolDailyRewards = {}

local isServer = RunService:IsServer()

PoolDailyRewards.FinalCue = "DragonSummonerCue"

PoolDailyRewards.FinalCueOwnedGems = 50

PoolDailyRewards.Days = {
	{ Kind = "Coins", Amount = 2500 },
	{ Kind = "Gems", Amount = 5 },
	{
		Kind = "Cue",
		Category = "cueSticks",
		Item = "RazorsteelCue",
		Owned = { Kind = "Coins", Amount = 7500 }
	},
	{ Kind = "Gems", Amount = 10 },
	{ Kind = "Coins", Amount = 15000 },
	{ Kind = "Gems", Amount = 25 },
	{
		Kind = "Cue",
		Category = "cueSticks",
		Item = PoolDailyRewards.FinalCue,
		Owned = { Kind = "Gems", Amount = PoolDailyRewards.FinalCueOwnedGems }
	}
}

function PoolDailyRewards.Now()
	if isServer then
		return (os.time())
	end

	return (workspace:GetServerTimeNow())
end

function PoolDailyRewards.DayNumber(p: number)
	return (math.floor(p / 86400))
end

local function ownedFallback(p)
	local owned = p.Owned

	if owned then
		return { Kind = owned.Kind, Amount = owned.Amount }
	end

	return { Kind = "Gems", Amount = PoolDailyRewards.FinalCueOwnedGems }
end

function PoolDailyRewards.RewardFor(value: number, p: number?)
	local day = PoolDailyRewards.Days[math.clamp(value, 1, #PoolDailyRewards.Days)]

	if day.Kind ~= "Cue" then
		return day
	end

	local item = day.Item or PoolDailyRewards.FinalCue
	local category = day.Category or "cueSticks"

	if p and PoolSkins.Owns(p, category, item) then
		return ownedFallback(day)
	end

	return { Kind = "Cue", Category = category, Item = item, Owned = day.Owned }
end

function PoolDailyRewards.GetState(p, p2: number?)
	local poolDailyRewards = p and p.poolDailyRewards
	local lastDay = typeof(poolDailyRewards) == "table" and tonumber(poolDailyRewards.LastDay) or 0
	local step = typeof(poolDailyRewards) == "table" and tonumber(poolDailyRewards.Step) or 0
	local v = p2 or PoolDailyRewards.Now()
	local dayNumber = PoolDailyRewards.DayNumber(v)
	local nextAt = (dayNumber + 1) * 86400
	local count = #PoolDailyRewards.Days

	if lastDay <= 0 or step <= 0 or lastDay + 1 < dayNumber then
		return { Step = 1, Claimable = true, Claimed = 0, NextAt = nextAt }
	end

	if dayNumber <= lastDay then
		return {
			Step = step % count + 1,
			Claimable = false,
			Claimed = step,
			NextAt = nextAt
		}
	end

	local step2 = step % count + 1

	return {
		Step = step2,
		Claimable = true,
		Claimed = step2 == 1 and 0 or step,
		NextAt = nextAt
	}
end

function PoolDailyRewards.CanClaim(p)
	return PoolDailyRewards.GetState(p).Claimable
end

function PoolDailyRewards.Claim(p: number)
	if not isServer then
		return nil, "Server only"
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil, "Your data is still loading"
	end

	local state = PoolDailyRewards.GetState(replica.Data)

	if not state.Claimable then
		return nil, "Come back tomorrow for your next reward"
	end

	local rewardFor = PoolDailyRewards.RewardFor(state.Step, p)

	replica:Write("PoolDailyReward", PoolDailyRewards.DayNumber(PoolDailyRewards.Now()), state.Step)

	if rewardFor.Kind == "Coins" then
		PoolPlayerData.AddCoins(p, rewardFor.Amount or 0)
	elseif rewardFor.Kind == "Gems" then
		PoolPlayerData.AddGems(p, rewardFor.Amount or 0)
	elseif rewardFor.Kind == "Cue" and rewardFor.Item then
		local category = rewardFor.Category or "cueSticks"

		if PoolPlayerData.GrantSkin(p, category, rewardFor.Item) then
			PoolPlayerData.EquipSkin(p, category, rewardFor.Item)
		else
			rewardFor = ownedFallback(rewardFor)

			if rewardFor.Kind == "Coins" then
				PoolPlayerData.AddCoins(p, rewardFor.Amount or 0)
			else
				PoolPlayerData.AddGems(p, rewardFor.Amount or 0)
			end
		end
	end

	return state.Step, rewardFor
end

return PoolDailyRewards