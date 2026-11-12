local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, p2)
	p.Data.specialKills += p2
end