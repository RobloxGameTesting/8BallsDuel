return function(p, value, value2)
	if typeof(value) ~= "string" or value == "" or typeof(value2) ~= "number" or value2 ~= value2 then
		return
	end

	if typeof(p.Data.poolAchievements) ~= "table" then
		p.Data.poolAchievements = {}
	end

	local poolAchievements = p.Data.poolAchievements
	local v = tonumber(poolAchievements[value]) or 0

	if math.floor(value2) == v + 1 then
		poolAchievements[value] = v + 1
	end
end