local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()

return function(p)
	p.Data.roleSlots[p.Data.selectedSlot].locked = not p.Data.roleSlots[p.Data.selectedSlot].locked
end