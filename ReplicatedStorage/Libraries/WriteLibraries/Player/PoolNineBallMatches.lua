return function(p)
	local poolNineBallMatches = tonumber(p.Data.poolNineBallMatches) or 0

	p.Data.poolNineBallMatches = poolNineBallMatches + 1
end