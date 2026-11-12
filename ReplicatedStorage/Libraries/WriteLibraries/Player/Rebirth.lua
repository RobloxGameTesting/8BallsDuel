local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Types.DataTypes)

RunService:IsServer()

return function(p, p2: number)
	p.Data.rebirth += p2
end