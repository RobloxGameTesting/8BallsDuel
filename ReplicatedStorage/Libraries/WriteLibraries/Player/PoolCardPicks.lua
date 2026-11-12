return function(p, p2: string, ...)
	local data = p.Data

	if typeof(data.poolCardPicks) ~= "table" then
		data.poolCardPicks = { pending = {}, nextId = 1 }
	end

	local poolCardPicks = data.poolCardPicks

	if typeof(poolCardPicks.pending) ~= "table" then
		poolCardPicks.pending = {}
	end

	poolCardPicks.nextId = tonumber(poolCardPicks.nextId) or 1

	if p2 == "Add" then
		local tier, v, prize = ...

		if typeof(tier) ~= "string" or tier == "" then
			return
		end

		local count = 0

		for _ in poolCardPicks.pending do
			count += 1
		end

		if count >= 10 then
			return
		end

		local nextId = tostring(poolCardPicks.nextId)
		poolCardPicks.nextId += 1
		local pending = poolCardPicks.pending
		local v2 = {
			Tier = tier,
			Source = typeof(v) ~= "string" and "Match" or v,
			EarnedAt = os.time(),
			Prize = 0
		}

		if typeof(prize) ~= "number" or not (prize > 0) then
			prize = nil
		end

		v2.Prize = prize
		pending[nextId] = v2
	elseif p2 == "Remove" then
		local v = ...

		if typeof(v) == "string" then
			poolCardPicks.pending[v] = nil
		end
	end
end