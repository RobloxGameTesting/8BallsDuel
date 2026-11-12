local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMatchTypes)

return function(p, aim)
	local poolMatch = p.Data.poolMatch

	if not poolMatch then
		return
	end

	poolMatch.Aim = aim
end