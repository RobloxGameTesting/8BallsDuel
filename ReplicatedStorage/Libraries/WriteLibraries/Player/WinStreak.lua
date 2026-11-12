return function(p, value)
	if typeof(p.Data.winStreak) ~= "number" then
		p.Data.winStreak = 0
	end

	if typeof(value) ~= "number" then
		return
	end

	p.Data.winStreak = math.max(p.Data.winStreak + value, 0)
end