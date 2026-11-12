local v = { TableSkin = true, CueSkin = true }

return function(p, p2: number, p3: string, p4: string?)
	if not v[p3] then
		return
	end

	local poolMatch = p.Data.poolMatch

	if not (poolMatch and poolMatch.Seats) then
		return
	end

	local seat = poolMatch.Seats[p2]

	if not seat then
		return
	end

	seat[p3] = p4
end