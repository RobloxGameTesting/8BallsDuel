local Visualizers = {}

for _, moduleScript in script:GetChildren() do
	local module = require(moduleScript)
	Visualizers[moduleScript.Name] = module
end

return Visualizers