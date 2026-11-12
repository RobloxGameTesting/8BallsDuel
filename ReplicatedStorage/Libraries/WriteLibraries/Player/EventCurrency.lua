local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(p, p2: number)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local event = p.Data.events[Events:GetDatastoreKey()]

	if not event then
		return
	end

	event.currency = math.max(0, (tonumber(event.currency) or 0) + p2)
end