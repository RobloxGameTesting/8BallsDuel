local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, outbreakLevel)
	p.Data.outbreakLevel = outbreakLevel
end