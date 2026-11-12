local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMatchTypes)

return function(p, poolMatch)
	p.Data.poolMatch = poolMatch
end