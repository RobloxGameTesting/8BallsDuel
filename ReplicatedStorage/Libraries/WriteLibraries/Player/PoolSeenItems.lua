local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolSkins = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolSkins)

return function(p, value)
	if typeof(value) ~= "string" or not PoolSkins.GetCategory(value) then
		return
	end

	local v

	if typeof(p.Data.inventory) == "table" then
		v = p.Data.inventory[value]
	else
		v = false
	end

	if typeof(v) ~= "table" then
		return
	end

	if typeof(p.Data.poolSeenItems) ~= "table" then
		p.Data.poolSeenItems = {}
	end

	local poolSeenItem = p.Data.poolSeenItems[value]
	local set = {}

	for k, v2 in v do
		if PoolSkins.IsKnownEntry(value, k, v2) then
			set[k] = true
		elseif typeof(poolSeenItem) == "table" and poolSeenItem[k] then
			set[k] = true
		end
	end

	p.Data.poolSeenItems[value] = set
end