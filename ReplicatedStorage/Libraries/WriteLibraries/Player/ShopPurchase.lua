game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, p2, p3, p4, p5)
	local v = tostring(p3)

	if not p.Data.shopPurchases[p2] then
		p.Data.shopPurchases[p2] = {}
	end

	if not p.Data.shopPurchases[p2][v] then
		p.Data.shopPurchases[p2][v] = {}
	end

	p.Data.shopPurchases[p2][v][p4] = (p.Data.shopPurchases[p2][v][p4] or 0) + p5
end