return function(p, value, value2)
	if typeof(value) ~= "number" or typeof(value2) ~= "number" or (value % 1 ~= 0 or value < 1) then
		return
	end

	local v = math.clamp(math.floor(value2), 0, 4)

	if v <= 0 then
		return
	end

	local poolLevels = p.Data.poolLevels

	if typeof(poolLevels) ~= "table" then
		poolLevels = {}
		p.Data.poolLevels = poolLevels
	end

	local v2 = tostring(value)
	local v3 = poolLevels[v2]

	if typeof(v3) == "number" and v <= v3 then
		return
	end

	poolLevels[v2] = v
end