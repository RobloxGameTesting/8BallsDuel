local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()

return function(p)
	local v = #p.Data.roleSlots
	p.Data.roleSlots[v + 1] = { role = "Citizen", locked = false }
end