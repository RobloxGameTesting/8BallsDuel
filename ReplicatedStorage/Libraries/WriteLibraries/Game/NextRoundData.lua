local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, nextRoundData)
	p.Data.nextRoundData = nextRoundData
end