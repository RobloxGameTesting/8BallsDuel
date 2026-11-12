game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, iteration)
	p.Data.iteration = iteration
end