local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()

return function(p, p2, p3)
	p.Data.selectedWeaponSlot[p2] = p3
end