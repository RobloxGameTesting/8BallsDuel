local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, serverLuck)
	p.Data.serverLuck = serverLuck
	p.Data.serverLuckStart = os.time()
end