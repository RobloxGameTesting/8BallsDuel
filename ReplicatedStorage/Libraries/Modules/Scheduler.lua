local RunService = game:GetService("RunService")

local v = {}
local count = 0
local Scheduler = {}

function Scheduler.Init()
	RunService.Heartbeat:Connect(function(dt: number)
		for _, v2 in v do
			v2(dt)
		end
	end)
end

function Scheduler.BindHeartbeat(callback)
	local v2 = tostring(count)

	v[v2] = callback

	count += 1
	return v2
end

function Scheduler.UnbindHeartbeat(p: string)
	v[p] = nil
end

return Scheduler