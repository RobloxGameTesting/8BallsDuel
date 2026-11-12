local RunService = game:GetService("RunService")

RunService:IsServer()

local Game = {}

for _, moduleScript in script:GetChildren(), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	Game[name] = module
end

return Game