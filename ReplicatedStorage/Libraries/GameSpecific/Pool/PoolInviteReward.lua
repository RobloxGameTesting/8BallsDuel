local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolSkins = require(Pool.PoolSkins)

local PoolInviteReward = {}

local isServer = RunService:IsServer()

PoolInviteReward.Category = "cueSticks"
PoolInviteReward.Item = "Royal Sapphire"

PoolInviteReward.DuplicateCoins = 1000

PoolInviteReward.MinAccountAgeDays = 30

PoolInviteReward.FlagKey = "InviteFriendCue"

PoolInviteReward.Title = "INVITE CUE!"
PoolInviteReward.Body = "Play with a FRIEND to get this FREE cue stick!"
PoolInviteReward.ClaimedBody = "Unlocked! Thanks for playing with a friend."
PoolInviteReward.Notification = "Cue stick unlocked for inviting your friend!"

function PoolInviteReward.GetItem()
	return PoolSkins.GetItem(PoolInviteReward.Category, PoolInviteReward.Item)
end

function PoolInviteReward.IsClaimed(p): boolean
	local poolOnboardingRewards = p and p.poolOnboardingRewards

	return typeof(poolOnboardingRewards) == "table" and poolOnboardingRewards[PoolInviteReward.FlagKey] == true
end

function PoolInviteReward.PairQualifies(p, p2): boolean
	if not p or not p2 or p.Parent == nil or p2.Parent == nil then
		return false
	end

	local minAccountAgeDays = PoolInviteReward.MinAccountAgeDays

	return minAccountAgeDays <= p.AccountAge and minAccountAgeDays <= p2.AccountAge
end

function PoolInviteReward.Grant(p: number)
	if not isServer then
		return false, false, 0
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica or PoolInviteReward.IsClaimed(replica.Data) then
		return false, false, 0
	end

	if not PoolInviteReward.GetItem() then
		warn("[PoolInviteReward] Item is not a real cue stick: " .. tostring(PoolInviteReward.Item))

		return false, false, 0
	end

	replica:Write("PoolOnboardingReward", PoolInviteReward.FlagKey)

	if
		PoolSkins.Owns(p, PoolInviteReward.Category, PoolInviteReward.Item)
		or not PoolPlayerData.GrantSkin(p, PoolInviteReward.Category, PoolInviteReward.Item)
	then
		PoolPlayerData.AddCoins(p, PoolInviteReward.DuplicateCoins)

		return true, true, PoolInviteReward.DuplicateCoins
	end

	return true, false, 0
end

return PoolInviteReward