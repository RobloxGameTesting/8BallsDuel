local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, p2)
	p.Data.inviteRewardProgress += Number:Round(p2, 0)
end