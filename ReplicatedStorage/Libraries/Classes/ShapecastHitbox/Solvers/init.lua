local Solvers = {}

for _, moduleScript in script:GetChildren() do
	local module = require(moduleScript)
	module.Solvers = Solvers
	Solvers[moduleScript.Name] = module
end

return Solvers