local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.RoundTypes)

return function(p, p2)
	p.Data.playerData[p2] = {
		currency1 = 0,
		currency2 = 0,
		damageDelt = 0,
		revives = 0,
		purchases = {}
	}
end