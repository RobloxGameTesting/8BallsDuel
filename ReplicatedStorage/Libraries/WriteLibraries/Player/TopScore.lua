local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local NameTagHelper = require(ReplicatedStorage.Libraries.Helpers.NameTagHelper)

local isServer = RunService:IsServer()

return function(p, topScore)
	p.Data.topScore = topScore

	if isServer then
		local player = p.Tags.Player

		NameTagHelper.DisplayScore(player)
	end
end