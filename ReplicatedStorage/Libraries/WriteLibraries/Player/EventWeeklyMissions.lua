local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, weeklyQuests, flag: boolean?)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local datastoreKey = Events:GetDatastoreKey()

	p.Data.events[datastoreKey].weeklyQuests = weeklyQuests

	if not flag then
		p.Data.events[datastoreKey].lastWeeklyRefresh = os.time()
	end
end