local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

return function(p, value: string, value2: string)
	if typeof(value) ~= "string" or value == "" or (typeof(value2) ~= "string" or value2 == "") then
		return
	end

	if typeof(p.Data.poolCueUpgrades) ~= "table" then
		p.Data.poolCueUpgrades = {}
	end

	local poolCueUpgrades = p.Data.poolCueUpgrades
	local v = tonumber(poolCueUpgrades[value]) or 0

	if PoolConstants.CueMaxLevel(value2) <= v then
		return
	end

	poolCueUpgrades[value] = v + 1
end