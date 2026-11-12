return function(p, items)
	if typeof(items) ~= "table" then
		return
	end

	local poolLeague = p.Data.poolLeague

	if typeof(poolLeague) ~= "table" then
		poolLeague = {}
		p.Data.poolLeague = poolLeague
	end

	for k, item in items do
		poolLeague[k] = item
	end
end