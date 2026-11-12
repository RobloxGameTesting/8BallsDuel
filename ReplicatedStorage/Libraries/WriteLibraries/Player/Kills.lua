local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local DateHelper = require(ReplicatedStorage.Libraries.Helpers.DateHelper)
require(ReplicatedStorage.Libraries.Helpers.StatsHelper)

RunService:IsServer()

return function(p, p2)
	local dayKey = DateHelper:GetDayKey()
	p.Data.kills[dayKey] = (p.Data.kills[dayKey] or 0) + p2
end