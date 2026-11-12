local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()

return function(p, p2)
	p.Data.weaponSlots[p2][p.Data.selectedWeaponSlot[p2]].locked = not p.Data.weaponSlots[p2][p.Data.selectedWeaponSlot[p2]].locked
end