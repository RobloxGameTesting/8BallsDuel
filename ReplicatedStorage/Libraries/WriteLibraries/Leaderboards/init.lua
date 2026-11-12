local RunService = game:GetService("RunService")

RunService:IsServer()

local Leaderboards = {}

for _, moduleScript in script:GetChildren(), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	Leaderboards[name] = module
end

return Leaderboards