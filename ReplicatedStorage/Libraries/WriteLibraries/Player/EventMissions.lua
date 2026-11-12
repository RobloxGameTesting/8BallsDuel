local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, missions, flag: boolean?)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local datastoreKey = Events:GetDatastoreKey()
	p.Data.events[datastoreKey].missions = missions

	if not flag then
		p.Data.events[datastoreKey].lastMissionRefresh = os.time()
	end
end