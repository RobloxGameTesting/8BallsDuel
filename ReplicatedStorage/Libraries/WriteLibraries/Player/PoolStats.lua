return function(p, data)
	if typeof(data) ~= "table" then
		return
	end

	local poolStats = p.Data.poolStats

	if typeof(poolStats) ~= "table" then
		poolStats = {}
		p.Data.poolStats = poolStats
	end

	poolStats.wins = data.wins
	poolStats.losses = data.losses
	poolStats.streak = data.streak
	poolStats.rating = data.rating
end