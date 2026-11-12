local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolTrickshotCodes = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTrickshotCodes)

return function(p, value: string?, code)
	if typeof(value) ~= "string" or typeof(code) ~= "string" or not PoolTrickshotCodes.Normalise(code) then
		return
	end

	local poolTrickshots = p.Data.poolTrickshots

	if typeof(poolTrickshots) ~= "table" then
		return
	end

	local poolTrickshot = poolTrickshots[value]

	if typeof(poolTrickshot) ~= "table" or poolTrickshot.Code ~= nil then
		return
	end

	poolTrickshot.Code = code
end