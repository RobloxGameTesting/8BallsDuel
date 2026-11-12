local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.RoundTypes)

return function(p, p2, p3)
	local v = p.Data.playerData[p2]

	if v then
		v.purchases[p3] = v.purchases[p3] and v.purchases[p3] + 1 or 1
	end
end