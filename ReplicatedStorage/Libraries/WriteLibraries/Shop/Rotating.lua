game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, p2, p3)
	p.Data.rotating[p2] = p3
end