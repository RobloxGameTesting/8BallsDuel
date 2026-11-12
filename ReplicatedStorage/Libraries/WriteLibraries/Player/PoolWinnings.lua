local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DateHelper = require(ReplicatedStorage.Libraries.Helpers.DateHelper)

return function(p, p2)
	local v = tonumber(p2) or 0

	if v <= 0 then
		return
	end

	local dayKey = DateHelper:GetDayKey()

	if typeof(p.Data.poolWinnings) ~= "table" then
		p.Data.poolWinnings = {}
	end

	p.Data.poolWinnings[dayKey] = (p.Data.poolWinnings[dayKey] or 0) + v
end