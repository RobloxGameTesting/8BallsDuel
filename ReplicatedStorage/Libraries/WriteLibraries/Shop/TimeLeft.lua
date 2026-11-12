game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, timeLeft)
	p.Data.timeLeft = timeLeft
end