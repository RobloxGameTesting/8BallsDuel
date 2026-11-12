local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

RunService:IsServer()

return function(p, p2)
	p.Data.spins += NumberHelper:Round(p2, 0)
end