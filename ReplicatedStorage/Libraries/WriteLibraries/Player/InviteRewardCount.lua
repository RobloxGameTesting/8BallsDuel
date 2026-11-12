local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, inviteRewardCount, inviteRewardTime)
	p.Data.inviteRewardCount = inviteRewardCount
	p.Data.inviteRewardTime = inviteRewardTime
end