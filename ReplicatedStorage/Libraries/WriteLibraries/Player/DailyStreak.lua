local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, streak)
	p.Data.dailyReward.streak = streak
end