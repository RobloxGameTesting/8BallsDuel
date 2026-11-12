local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()
local v = { primary = "Scar-L", secondary = "M1911", melee = "Fists", utility = "Potato" }

return function(p, p2)
	local v2 = #p.Data.weaponSlots[p2]
	local v3 = v[p2]
	p.Data.weaponSlots[p2][v2 + 1] = { item = v3, locked = false }
end