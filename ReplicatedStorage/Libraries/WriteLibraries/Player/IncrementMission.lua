local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Achievements = require(ReplicatedStorage.Libraries.GameSpecific.Achievements)

RunService:IsServer()

local function eventIncrement(player, eventDatastore, p: string, p2, p3: number)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)

	local v = {
		daily = { data = Events:GetMissions(player), field = "missions" },
		weekly = {
			data = Events:GetWeeklyMissions(player),
			field = "weeklyQuests"
		}
	}

	local _data = v[p].data
	local field = v[p].field

	eventDatastore[field][p2].progress += p3

	if eventDatastore[field][p2].progress >= eventDatastore[field][p2].requirement then
		eventDatastore[field][p2].completed = true
	end
end

return function(p, p2, p3, flag: boolean?)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)

	local player = p.Tags.Player

	if flag ~= false and Events:GetEventDatastore(player, false) then
		local eventDatastore = Events:GetEventDatastore(player, false)
		local missionIndexByKey = Events:GetMissionIndexByKey(player, p2, "Daily")
		local missionIndexByKey2 = Events:GetMissionIndexByKey(player, p2, "Weekly")

		for _, v in missionIndexByKey do
			if not eventDatastore.missions[v].completed then
				eventIncrement(player, eventDatastore, "daily", v, p3)
			end
		end

		for _, v in missionIndexByKey2 do
			if eventDatastore.weeklyQuests then
				if eventDatastore.weeklyQuests[v] and not eventDatastore.weeklyQuests[v].completed then
					eventIncrement(player, eventDatastore, "weekly", v, p3)
				end
			else
				break
			end
		end
	end

	for k, achievement in p.Data.achievements do
		if not Achievements.GetAchievements()[k] or achievement.claimed then
			continue
		end

		for k2, _ in achievement.goals do
			if k2 ~= p2 then
				continue
			end

			achievement.goals[k2] += p3
		end
	end
end