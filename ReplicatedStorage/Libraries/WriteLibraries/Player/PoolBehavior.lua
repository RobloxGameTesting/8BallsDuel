return function(p, poolBehavior)
	if typeof(poolBehavior) ~= "table" then
		return
	end

	p.Data.poolBehavior = poolBehavior
end