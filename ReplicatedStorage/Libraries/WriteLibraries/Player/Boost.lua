game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")

RunService:IsServer()

return function(p, p2, p3)
	if p.Data.boosts[p2] then
		p.Data.boosts[p2] = math.clamp(p.Data.boosts[p2] + p3, 0, 1e999)
	else
		warn(`There is no boost named: {p2}`)
	end
end