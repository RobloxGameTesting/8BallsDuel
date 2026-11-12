local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolMatchTypes = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMatchTypes)

return function(p, shot)
	local poolMatch = p.Data.poolMatch

	if not poolMatch then
		return
	end

	poolMatch.Shot = shot
	poolMatch.ShotIndex = shot.Index

	poolMatch.Aim = PoolMatchTypes.EmptyAim()
end