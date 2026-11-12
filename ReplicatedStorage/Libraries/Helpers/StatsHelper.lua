local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local RunService = game:GetService("RunService")
local Events = require(ReplicatedStorage.Libraries.Modules.Events)

local isServer = RunService:IsServer()
local StatsHelper = {}

function StatsHelper.AddValues(_, p: string, p2, p3: string)
	local playerReplica = Profiles.GetPlayerReplica(p)
	local v = playerReplica and playerReplica.Data[p3]

	if not (playerReplica and v) then
		return nil
	end

	local total = 0

	for k, v2 in v do
		if p2 then
			if p2.startTime <= k and k <= p2.endTime then
				total += v2
			end
		else
			total += v2
		end
	end

	return total
end

function StatsHelper.HighestValue(_, p: string, p2, p3: string)
	local playerReplica = Profiles.GetPlayerReplica(p)
	local v = playerReplica and playerReplica.Data[p3]

	if not (playerReplica and v) then
		return nil
	end

	local v2 = 0
	local v3 = 0

	for k, v4 in v do
		if p2 then
			if v4.timer >= p2.startTime and v4.timer <= p2.endTime and v2 < v4.amount then
				v2 = v4.amount
				v3 = k
			end
		elseif v2 < v4.amount then
			v2 = v4.amount
			v3 = k
		end
	end

	return v3, v2
end

function StatsHelper.IncrementMission(p, p2: string, p3)
	if not isServer then
		return
	end

	local userId = tostring(p.UserId)
	local playerReplica = Profiles.GetPlayerReplica(userId)

	if not (playerReplica and playerReplica:IsActive()) then
		return
	end

	playerReplica:Write("IncrementMission", p2, p3, Events:IsActive())
end

return StatsHelper