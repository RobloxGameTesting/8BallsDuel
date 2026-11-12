local RunService = game:GetService("RunService")

RunService:IsServer()

local Player = {}

for _, moduleScript in script:GetChildren(), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	Player[name] = module
end

return Player