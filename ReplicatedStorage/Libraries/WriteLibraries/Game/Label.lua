local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, label)
	p.Data.label = label
end