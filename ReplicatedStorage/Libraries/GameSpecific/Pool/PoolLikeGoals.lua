local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local rewards = {
	{ Likes = 100, Item = "Skyfeather" },
	{ Likes = 500, Item = "SciFi" },
	{ Likes = 2500, Item = "Trident" },
	{ Likes = 25000, Item = "EmeraldFracture" }
}

local likes = {}
local v = {}
local PoolLikeGoals = {}
PoolLikeGoals.LikesAttribute = "PoolLikes"
PoolLikeGoals.Category = "cueSticks"
PoolLikeGoals.DuplicateCoins = 1000
PoolLikeGoals.FlagPrefix = "LikeGoal"

for _, v2 in rewards do
	table.insert(likes, v2.Likes)
	v[v2.Likes] = v2.Item
end

PoolLikeGoals.Rewards = rewards
PoolLikeGoals.Milestones = likes

function PoolLikeGoals.GetProgress(likes2: number)
	local previous = 0
	local reached = 0

	for k, nextNode in likes do
		if likes2 < nextNode then
			return {
				Likes = likes2,
				Previous = previous,
				Next = nextNode,
				Fraction = math.clamp((likes2 - previous) / (nextNode - previous), 0, 1),
				Reached = reached
			}
		end

		reached = k
		previous = nextNode
	end

	return {
		Likes = likes2,
		Previous = previous,
		Next = nil,
		Fraction = 1,
		Reached = reached
	}
end

function PoolLikeGoals.GetLikes()
	local attribute = ReplicatedStorage:GetAttribute(PoolLikeGoals.LikesAttribute)

	return if typeof(attribute) == "number" then attribute else nil
end

function PoolLikeGoals.GetRewardItem(p: number)
	return v[p]
end

function PoolLikeGoals.GetRewardData(p: number)
	local rewardItem = PoolLikeGoals.GetRewardItem(p)

	if not rewardItem then
		return nil
	end

	local PoolSkins = require(script.Parent.PoolSkins)

	return PoolSkins.GetItem(PoolLikeGoals.Category, rewardItem)
end

function PoolLikeGoals.FlagKey(p: number)
	return PoolLikeGoals.FlagPrefix .. tostring(p)
end

function PoolLikeGoals.IsClaimed(p, p2: number): boolean
	local poolOnboardingRewards = p and p.poolOnboardingRewards

	return typeof(poolOnboardingRewards) == "table" and poolOnboardingRewards[PoolLikeGoals.FlagKey(p2)] == true
end

function PoolLikeGoals.GetClaimable(p, value: number?)
	if typeof(value) ~= "number" or p == nil then
		return nil
	end

	local v2 = nil

	for _, v3 in likes do
		if value < v3 then
			break
		end

		v2 = v3
	end

	return if v2 and not PoolLikeGoals.IsClaimed(p, v2) then v2 else nil
end

function PoolLikeGoals.Claim(p: number)
	if not RunService:IsServer() then
		return nil, "Server only"
	end

	local PoolPlayerData = require(script.Parent.PoolPlayerData)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil, "Your data hasn't loaded yet, try again!"
	end

	local likes2 = PoolLikeGoals.GetLikes()

	if not likes2 then
		return nil, "Couldn't check the like count, try again soon!"
	end

	local claimable = PoolLikeGoals.GetClaimable(replica.Data, likes2)

	if not claimable then
		return nil, "No like reward to claim yet!"
	end

	local rewardItem = PoolLikeGoals.GetRewardItem(claimable)

	if not rewardItem then
		warn("[PoolLikeGoals] no cue stick available as the reward for " .. claimable .. " likes")

		return nil, "This reward isn't set up yet, report to dev!"
	end

	replica:Write("PoolOnboardingReward", PoolLikeGoals.FlagKey(claimable))

	local v2 = PoolPlayerData.GrantSkin(p, PoolLikeGoals.Category, rewardItem)

	if not v2 then
		PoolPlayerData.AddCoins(p, PoolLikeGoals.DuplicateCoins)
	end

	return {
		Milestone = claimable,
		Item = rewardItem,
		Duplicate = not v2,
		Coins = v2 and 0 or PoolLikeGoals.DuplicateCoins
	}, nil
end

return PoolLikeGoals