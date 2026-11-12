game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")

RunService:IsServer()

return function(p, p2, p3)
	p.Data.matches[p2] = p3
end