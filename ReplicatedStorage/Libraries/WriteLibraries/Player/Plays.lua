game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")

RunService:IsServer()

return function(p, p2)
	p.Data.plays += p2
end