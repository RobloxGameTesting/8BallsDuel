local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(p, ladderScale: number)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local datastoreKey = Events:GetDatastoreKey()

	p.Data.events[datastoreKey].ladderScale = ladderScale
end