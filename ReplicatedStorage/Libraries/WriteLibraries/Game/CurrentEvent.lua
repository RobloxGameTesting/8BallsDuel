local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, currentEvent)
	p.Data.currentEvent = currentEvent
end