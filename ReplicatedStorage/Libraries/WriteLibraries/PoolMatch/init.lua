local PoolMatch = {}

for _, moduleScript in script:GetChildren(), nil, nil do
	local name = moduleScript.Name
	local module = require(moduleScript)
	PoolMatch[name] = module
end

return PoolMatch