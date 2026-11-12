local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Helpers.DateHelper)
local PlaceHelper = require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)

local isServer = RunService:IsServer()

local v = {
	LEVEL_EQUATION = function(p: number)
		return math.max(p - 1, 0) * 250
	end,
	MASTERY_EQUATION = function(p: number)
		if p == 0 then
			return 0
		end

		return (math.min(p * ((p * 0.5 + 1) * 250) + 500, 100000))
	end
}

local Level = {}

function Level:GetLevel(p: number, p2: string)
	local v2 = v[p2]
	local v3 = 1
	local v4 = 9999
	local v5 = 0

	while v3 <= v4 do
		local v6 = math.floor((v3 + v4) / 2)

		if v2(v6) <= p then
			v3 = v6 + 1
			v5 = v6
		else
			v4 = v6 - 1
		end
	end

	return v5, v2(v5), (v2(v5 + 1))
end

function Level.GiveExperience(_, p, p2: number)
	if not (isServer and PlaceHelper.GetServerType() ~= "PrivateServer") then
		return 0
	end

	local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

	local playerReplica = Profiles.GetPlayerReplica((tostring(p.UserId)))

	if not playerReplica then
		return 0
	end

	local level = Level:GetLevel(playerReplica.Data.experience, "LEVEL_EQUATION")
	local experience = playerReplica.Data.experience

	task.spawn(function()
		experience += p2
		playerReplica:Write("Experience", experience, p2)
		local _experience = playerReplica.Data.experience
		local v2 = Level:GetLevel(playerReplica.Data.experience, "LEVEL_EQUATION") - level

		if v2 > 0 then
			local ServerEvents = require(ServerScriptService.Scripts.Main.Events.ServerEvents)
			ServerEvents.LevelUp:Fire(p, v2)
		end
	end)

	return p2
end

function Level.GetLevelCap(): number
	return 9999
end

return Level