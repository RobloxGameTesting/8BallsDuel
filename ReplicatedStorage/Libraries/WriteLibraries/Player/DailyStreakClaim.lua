local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, streakClaims)
	p.Data.dailyReward.streakClaims = streakClaims
end