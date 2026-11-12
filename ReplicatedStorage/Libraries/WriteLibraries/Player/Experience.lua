local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Badges)
local Level = require(ReplicatedStorage.Libraries.Modules.Level)
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, experience, _)
	local _player = p.Tags.Player
	p.Data.experience = experience
	local level, _, _ = Level:GetLevel(p.Data.experience, "LEVEL_EQUATION")
	p.Data.level = level
end