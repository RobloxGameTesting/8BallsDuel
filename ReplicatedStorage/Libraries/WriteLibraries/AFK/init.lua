local RunService = game:GetService("RunService")

RunService:IsServer()

local AFK = {}

for _, moduleScript in script:GetChildren(), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	AFK[name] = module
end

return AFK