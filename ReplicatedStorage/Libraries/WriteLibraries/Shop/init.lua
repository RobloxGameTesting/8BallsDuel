local RunService = game:GetService("RunService")

RunService:IsServer()

local Shop = {}

for _, moduleScript in script:GetChildren(), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	Shop[name] = module
end

return Shop