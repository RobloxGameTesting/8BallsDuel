local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, p2, p3)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local _player = p.Tags.Player
	local datastoreKey = Events:GetDatastoreKey()
	p.Data.events[datastoreKey].battlepassClaims[p2] = p3
end