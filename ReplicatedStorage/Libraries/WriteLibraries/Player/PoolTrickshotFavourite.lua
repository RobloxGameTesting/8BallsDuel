local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolCommunity = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolCommunity)
local PoolTrickshotCodes = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTrickshotCodes)

return function(p, p2, value)
	if not PoolTrickshotCodes.Normalise(p2) then
		return
	end

	local poolTrickshotFavourites = p.Data.poolTrickshotFavourites

	if typeof(poolTrickshotFavourites) ~= "table" then
		poolTrickshotFavourites = {}
		p.Data.poolTrickshotFavourites = poolTrickshotFavourites
	end

	if value == nil then
		poolTrickshotFavourites[p2] = nil

		return
	end

	if typeof(value) ~= "number" then
		return
	end

	if poolTrickshotFavourites[p2] == nil then
		local count = 0

		for _ in poolTrickshotFavourites do
			count += 1
		end

		if PoolCommunity.MaxFavourites <= count then
			return
		end
	end

	poolTrickshotFavourites[p2] = math.floor(value)
end