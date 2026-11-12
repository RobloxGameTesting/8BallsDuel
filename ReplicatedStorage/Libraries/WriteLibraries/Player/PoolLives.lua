local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolLives = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolLives)

return function(p, value, value2)
	if typeof(value) ~= "number" or typeof(value2) ~= "number" then
		return
	end

	p.Data.poolLives = math.clamp(math.floor(value), 0, PoolLives.Max)
	p.Data.poolLivesAt = math.floor(value2)
end