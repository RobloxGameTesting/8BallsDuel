local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()

return function(p, selectedSlot)
	p.Data.selectedSlot = selectedSlot
end