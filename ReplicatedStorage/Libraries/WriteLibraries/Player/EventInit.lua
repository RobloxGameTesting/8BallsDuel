local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, p2)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local datastoreKey = Events:GetDatastoreKey()
	p.Data.events[datastoreKey] = p2
end