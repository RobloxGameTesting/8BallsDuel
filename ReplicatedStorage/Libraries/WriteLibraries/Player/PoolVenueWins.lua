return function(p, value)
	if typeof(value) ~= "string" or value == "" then
		return
	end

	if typeof(p.Data.poolVenueWins) ~= "table" then
		p.Data.poolVenueWins = {}
	end

	local poolVenueWins = p.Data.poolVenueWins

	poolVenueWins[value] = (poolVenueWins[value] or 0) + 1
end