local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, lastReward)
	p.Data.dailyReward.lastReward = lastReward
	p.Data.dailyReward.claims += 1
	p.Data.dailyReward.streak += 1
end