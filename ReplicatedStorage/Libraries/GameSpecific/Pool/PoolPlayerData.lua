local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CurrencyHelper = require(ReplicatedStorage.Libraries.Helpers.CurrencyHelper)
local Level = require(ReplicatedStorage.Libraries.Modules.Level)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PoolSkill = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolSkill)
local PoolVip = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolVip)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local PoolPlayerData = {}

local isServer = RunService:IsServer()

function PoolPlayerData.GetReplica(p: number)
	return Profiles.GetPlayerReplica((tostring(p)))
end

function PoolPlayerData.GrantSkin(p: number, p2: string, p3: string): boolean
	if not isServer then
		return false
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return false
	end

	local PoolSkins = require(script.Parent.PoolSkins)

	if not PoolSkins.GetItem(p2, p3) then
		warn(string.format(
			"[PoolPlayerData] refused to grant %q in %s: no such skin in this build",
			tostring(p3),
			(tostring(p2))
		))

		return false
	end

	if PoolSkins.Owns(p, p2, p3) then
		return false
	end

	replica:Write("Inventory", p2, p3, { item = p3 })

	return true
end

function PoolPlayerData.EquipSkin(p: number, value: string, value2: string): boolean
	if not isServer or (typeof(value) ~= "string" or typeof(value2) ~= "string") then
		return false
	end

	local PoolSkins = require(script.Parent.PoolSkins)

	if not (PoolSkins.GetCategory(value) and PoolSkins.GetItem(value, value2)) then
		return false
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return false
	end

	replica:Write("Equipped", value, value2)

	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return true
	end

	local PoolMatchSession = require(script.Parent.PoolMatchSession)

	if value == "poolTables" then
		PoolMatchSession.SetSeatSkin(playerByUserId, PoolSkins.GetTableModelName(p))
	elseif value == "cueSticks" then
		PoolMatchSession.SetSeatCue(playerByUserId, PoolSkins.GetCueStickModelName(p))
	end

	return true
end

function PoolPlayerData.GetCoins(p: number)
	local replica = PoolPlayerData.GetReplica(p)

	if replica then
		return (math.round((CurrencyHelper.ToNumber(replica.Data.currency1))))
	end

	return 0
end

function PoolPlayerData.FormatCoins(p: number)
	return NumberHelper:Separate((math.round(p)))
end

function PoolPlayerData.GetLevel(p: number)
	local replica = PoolPlayerData.GetReplica(p)

	if replica then
		return (math.max(Level:GetLevel(replica.Data.experience or 0, "LEVEL_EQUATION"), 1))
	end

	return 1
end

function PoolPlayerData.GetProgress(p: number)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return 0, 0, 1
	end

	local experience = replica.Data.experience or 0
	local _, v, v2 = Level:GetLevel(experience, "LEVEL_EQUATION")

	return experience, v, v2
end

function PoolPlayerData.CanAfford(p: number, p2: number)
	local replica = PoolPlayerData.GetReplica(p)

	if replica then
		return CurrencyHelper.CanAfford(CurrencyHelper.FromNumber(p2), replica.Data.currency1)
	end

	return false
end

function PoolPlayerData.AddCoins(p: number, mantissa: number): boolean
	local replica = PoolPlayerData.GetReplica(p)

	if not replica or mantissa == 0 then
		return false
	end

	replica:Write("Currency1", { mantissa = mantissa, exponent = 0 })

	return true
end

function PoolPlayerData.GetGems(p: number)
	local replica = PoolPlayerData.GetReplica(p)

	if replica and typeof(replica.Data.currency2) == "table" then
		return (math.round((CurrencyHelper.ToNumber(replica.Data.currency2))))
	end

	return 0
end

function PoolPlayerData.AddGems(p: number, mantissa: number): boolean
	local replica = PoolPlayerData.GetReplica(p)

	if not replica or mantissa == 0 then
		return false
	end

	replica:Write("Currency2", { mantissa = mantissa, exponent = 0 })

	return true
end

function PoolPlayerData.Describe(player)
	local PoolSkins = require(script.Parent.PoolSkins)

	return {
		UserId = player.UserId,
		Name = player.Name,
		DisplayName = player.DisplayName,
		Level = PoolPlayerData.GetLevel(player.UserId),
		WinStreak = PoolPlayerData.GetWinStreak(player.UserId),
		Vip = PoolVip.Owns(player.UserId),
		Group = "",
		TableSkin = PoolSkins.GetTableModelName(player.UserId),
		CueSkin = PoolSkins.GetCueStickModelName(player.UserId),
		PotEffect = PoolSkins.GetPotEffectName(player.UserId)
	}
end

function PoolPlayerData.Thumbnail(p: number)
	if p <= 0 then
		return ""
	end

	return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", p)
end

function PoolPlayerData.GetPlayer(p: number)
	return Players:GetPlayerByUserId(p)
end

function PoolPlayerData.GetSkill(p: number)
	local replica = PoolPlayerData.GetReplica(p)

	if replica then
		return PoolSkill.FromData(replica.Data.poolStats)
	end

	return PoolSkill.NewStats()
end

function PoolPlayerData.GetBehavior(p: number)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil
	end

	local poolBehavior = replica.Data.poolBehavior

	return if typeof(poolBehavior) == "table" then poolBehavior else nil
end

function PoolPlayerData.SetBehavior(p: number, p2): boolean
	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return false
	end

	replica:Write("PoolBehavior", p2)

	return true
end

function PoolPlayerData.RecordResult(p: number, p2: number, flag: boolean)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil
	end

	local v = PoolSkill.Apply(PoolSkill.FromData(replica.Data.poolStats), p2, flag)

	replica:Write("PoolStats", PoolSkill.ToData(v))

	return v
end

function PoolPlayerData.GetWinStreak(p: number)
	local replica = PoolPlayerData.GetReplica(p)

	if replica then
		return (math.max(math.floor(tonumber(replica.Data.winStreak) or 0), 0))
	end

	return 0
end

function PoolPlayerData.RecordWinStreak(p: number, flag: boolean)
	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return nil
	end

	local winStreak = tonumber(replica.Data.winStreak) or 0
	local v = flag and 1 or -winStreak

	if v ~= 0 then
		replica:Write("WinStreak", v)
	end

	local v2 = winStreak + v

	if flag then
		local poolLifetime = replica.Data.poolLifetime

		if (typeof(poolLifetime) == "table" and tonumber(poolLifetime.bestWinStreak) or 0) < v2 then
			replica:Write("PoolLifetime", "Max", "bestWinStreak", v2)
		end
	end

	return v2
end

function PoolPlayerData.AddLifetime(p: number, p2: string, p3: number): boolean
	if not isServer or p3 <= 0 then
		return false
	end

	local replica = PoolPlayerData.GetReplica(p)

	if not replica then
		return false
	end

	replica:Write("PoolLifetime", "Add", p2, p3)

	return true
end

return PoolPlayerData