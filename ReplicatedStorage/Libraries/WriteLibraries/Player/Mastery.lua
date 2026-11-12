local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Players")
local MasteryConstants = require(ReplicatedStorage.Libraries.Constants.MasteryConstants)

RunService:IsServer()

return function(p, items)
	for k, item in items do
		if not p.Data.mastery[k] then
			p.Data.mastery[k] = 0
		end

		p.Data.mastery[k] += math.min(item, MasteryConstants.MAX_MASTERY_EXP)
	end
end