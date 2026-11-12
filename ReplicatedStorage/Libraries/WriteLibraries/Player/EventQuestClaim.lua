local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, p2: string, p3: number)
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local player = p.Tags.Player
	local datastoreKey = Events:GetDatastoreKey()
	local event = p.Data.events[datastoreKey]

	if not event then
		return
	end

	local v = event[p2]
	local v2 = v and v[p3]

	if not v2 then
		warn(("EventQuestClaim: no quest at %s[%s]"):format(tostring(p2), (tostring(p3))))

		return
	end

	if not Events:IsQuestClaimable(player, p2, p3) then
		warn(("EventQuestClaim: %s[%s] is not claimable"):format(tostring(p2), (tostring(p3))))

		return
	end

	v2.claimed = true
	event.progress += v2.reward
end