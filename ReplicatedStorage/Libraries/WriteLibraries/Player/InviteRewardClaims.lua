local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, p2)
	p.Data.inviteRewardClaims[tostring(p2)] = true
end