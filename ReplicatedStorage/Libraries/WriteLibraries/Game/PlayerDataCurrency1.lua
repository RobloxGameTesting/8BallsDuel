local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.RoundTypes)

return function(p, p2, p3)
	local v = p.Data.playerData[p2]

	if v then
		v.currency1 += p3
	end
end