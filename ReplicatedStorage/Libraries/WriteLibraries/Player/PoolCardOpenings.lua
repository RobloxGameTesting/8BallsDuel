return function(p)
	p.Data.poolCardOpenings = (tonumber(p.Data.poolCardOpenings) or 0) + 1
end