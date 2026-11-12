local PoolLives = {}
PoolLives.Max = 5
PoolLives.RegenSeconds = 1800

function PoolLives.Resolve(p, p2: number)
	local max = PoolLives.Max
	local regenSeconds = PoolLives.RegenSeconds
	local poolLives

	if typeof(p) == "table" then
		poolLives = p.poolLives
	end

	local selected = (typeof(p) ~= "table" or typeof(p.poolLivesAt) ~= "number") and 0 or p.poolLivesAt

	if typeof(poolLives) ~= "number" then
		return max, p2, nil
	end

	local selected2 = math.clamp(math.floor(poolLives), 0, max)

	if max <= selected2 then
		return max, selected, nil
	end

	if p2 < selected then
		selected = p2
	end

	local v = math.floor((p2 - selected) / regenSeconds)

	if v > 0 then
		selected2 = math.min(max, selected2 + v)
		selected += v * regenSeconds
	end

	if max <= selected2 then
		return max, selected, nil
	end

	return selected2, selected, selected + regenSeconds
end

function PoolLives.Now()
	return workspace:GetServerTimeNow()
end

function PoolLives.Format(p: number)
	local v = math.max(0, (math.ceil(p)))

	return string.format("%d:%02d", v // 60, v % 60)
end

function PoolLives.OutMessage(p)
	local now = PoolLives.Now()
	local _, _, v = PoolLives.Resolve(p, now)

	if v then
		return string.format("Out of lives! Next life in %s", PoolLives.Format(v - now))
	end

	return "Out of lives!"
end

return PoolLives