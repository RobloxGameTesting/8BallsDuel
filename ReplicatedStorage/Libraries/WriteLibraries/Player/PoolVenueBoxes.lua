return function(p, value, p2)
	if typeof(value) ~= "string" or value == "" then
		return
	end

	local v = tonumber(p2)

	if not v or v ~= v or v < 0 or v == 1e999 then
		return
	end

	if typeof(p.Data.poolVenueBoxes) ~= "table" then
		p.Data.poolVenueBoxes = {}
	end

	p.Data.poolVenueBoxes[value] = math.floor(v)
end