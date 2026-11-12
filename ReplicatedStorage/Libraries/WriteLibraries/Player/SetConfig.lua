local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.ConfigChecker)

return function(p, data)
	p.Data.configuration[data.configurationType][data.configuration] = data.val
end