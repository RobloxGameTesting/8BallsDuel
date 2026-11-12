local ReplicatedStorage = game:GetService("ReplicatedStorage")

local v = { daily = true, shop = true, raffle = true, hypeSeen = true }

return function(p, p2: string, p3)
	if not v[p2] then
		warn("EventState: unknown field " .. tostring(p2))

		return
	end

	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local event = p.Data.events[Events:GetDatastoreKey()]

	if not event then
		return
	end

	event[p2] = p3
end