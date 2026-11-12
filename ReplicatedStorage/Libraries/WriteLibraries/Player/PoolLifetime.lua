local v = { ballsPotted = true, breakPots = true, bestWinStreak = true, trickshotsPublished = true }

return function(p, p2, p3, value)
	if not v[p3] or (typeof(value) ~= "number" or value ~= value) then
		return
	end

	local poolLifetime = p.Data.poolLifetime

	if typeof(poolLifetime) ~= "table" then
		poolLifetime = {}
		p.Data.poolLifetime = poolLifetime
	end

	local v2 = tonumber(poolLifetime[p3]) or 0
	local v3 = math.floor(value)

	if p2 == "Add" then
		if v3 <= 0 then
			return
		end

		poolLifetime[p3] = v2 + v3
	elseif p2 == "Max" and v2 < v3 then
		poolLifetime[p3] = v3
	end
end