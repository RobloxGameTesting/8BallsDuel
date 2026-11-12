return function(p, p2)
	local v = tonumber(p2)

	if not v then
		return
	end

	local poolWinnings = p.Data.poolWinnings

	if typeof(poolWinnings) ~= "table" then
		return
	end

	local v2 = {}

	for k in poolWinnings do
		local v3 = tonumber(k)

		if not v3 or v3 < v then
			table.insert(v2, k)
		end
	end

	for _, v3 in v2 do
		poolWinnings[v3] = nil
	end
end