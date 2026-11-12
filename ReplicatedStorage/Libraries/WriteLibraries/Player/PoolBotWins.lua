local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

return function(p, value)
	if typeof(value) ~= "string" or value == "" or not PoolConstants.BotLevelIndex(value) then
		return
	end

	if typeof(p.Data.poolBotWins) ~= "table" then
		p.Data.poolBotWins = {}
	end

	local poolBotWins = p.Data.poolBotWins

	poolBotWins[value] = (poolBotWins[value] or 0) + 1
end