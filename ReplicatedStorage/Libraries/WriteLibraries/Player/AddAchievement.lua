local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Achievements = require(ReplicatedStorage.Libraries.GameSpecific.Achievements)
require(ReplicatedStorage.Libraries.Helpers.StatsHelper)

RunService:IsServer()

return function(p, p2: string, questNumber: number)
	local v = Achievements.GetAchievements()[p2]

	if not v then
		return
	end

	local achievement = p.Data.achievements[p2]
	local v2 = 0

	if
		achievement and questNumber - achievement.questNumber ~= 1
		or achievement and achievement.questNumber == questNumber
	then
		return
	end

	if achievement then
		v2 = achievement.goals[v.missionId]
	end

	local goals = {}
	goals[v.missionId] = v2

	p.Data.achievements[p2] = { questNumber = questNumber, goals = goals, claimed = false }
end