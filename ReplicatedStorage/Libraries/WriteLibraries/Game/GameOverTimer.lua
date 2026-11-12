local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)

return function(p, gameOverTimer)
	p.Data.gameOverTimer = gameOverTimer
end