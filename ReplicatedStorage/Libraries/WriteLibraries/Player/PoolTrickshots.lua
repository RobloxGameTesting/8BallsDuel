local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolTrickshotTypes = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTrickshotTypes)

local function nextSlotId(poolTrickshots) -- 1 equivalent call inferred from this helper
	local v = 0

	for k in poolTrickshots do
		local v2 = tonumber(k)

		if v2 and v < v2 then
			v = v2
		end
	end

	return (tostring(v + 1))
end

local function countSlots(poolTrickshots) -- 1 equivalent call inferred from this helper
	local count = 0

	for _ in poolTrickshots do
		count += 1
	end

	return count
end

return function(p, value: string?, p2, p3: string?)
	if typeof(p.Data.poolTrickshots) ~= "table" then
		p.Data.poolTrickshots = {}
	end

	local poolTrickshots = p.Data.poolTrickshots

	if p2 == nil then
		if typeof(value) == "string" then
			poolTrickshots[value] = nil
		end
	else
		local sanitise = PoolTrickshotTypes.Sanitise(p2, p3)

		if not sanitise then
			return
		end

		sanitise.Saved = os.time()

		if typeof(value) == "string" and poolTrickshots[value] ~= nil then
			local poolTrickshot = poolTrickshots[value]

			if typeof(poolTrickshot) == "table" and typeof(poolTrickshot.Code) == "string" then
				sanitise.Code = poolTrickshot.Code
			end

			poolTrickshots[value] = sanitise
		else
			local count = countSlots(poolTrickshots) -- inferred equivalent call

			if PoolTrickshotTypes.MaxSlots <= count then
				return
			end

			poolTrickshots[nextSlotId(poolTrickshots)] = sanitise -- inferred equivalent call
		end
	end
end