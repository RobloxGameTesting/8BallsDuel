local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.GameSpecificTypes)

return function(p, p2)
	p.Data.activePowerUps[p2] = os.time()
end