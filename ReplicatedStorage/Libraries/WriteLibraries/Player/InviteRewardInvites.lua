local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return function(p, p2, p3)
	p.Data.inviteRewardInvites[tostring(p2)] = p3
end