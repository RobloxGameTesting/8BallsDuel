game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")

RunService:IsServer()

return function(p, matchResultsSeen)
	p.Data.matchResultsSeen = matchResultsSeen
end