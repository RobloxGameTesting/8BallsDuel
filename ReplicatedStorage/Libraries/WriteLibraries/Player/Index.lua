local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()

return function(p, p2)
	if not table.find(p.Data.index, p2) then
		table.insert(p.Data.index, p2)
	end
end