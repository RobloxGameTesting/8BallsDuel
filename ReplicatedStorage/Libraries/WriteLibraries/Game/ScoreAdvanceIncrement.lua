local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, p2)
	p.Data.scoreAdvanceIncrement += p2
end