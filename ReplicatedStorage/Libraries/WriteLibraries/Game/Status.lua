local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, status)
	p.Data.status = status
end