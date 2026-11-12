local Loader = { ["ClassName"] = nil, ["ClassName"] = nil, ClassName = "Loader" }

Loader.__index = Loader

function Loader.new(Script)
	return (setmetatable({ _script = Script, _cache = {} }, Loader))
end

local function waitForValue(objectValue)
	local value = objectValue.Value

	if value then
		return value
	end

	return objectValue.Changed:Wait()
end

function Loader:__call(moduleScript)
	if type(moduleScript) ~= "string" then
		return require(moduleScript)
	end

	local modulesByModuleScript = rawget(self, "_cache")

	if modulesByModuleScript[moduleScript] ~= nil then
		return modulesByModuleScript[moduleScript]
	end

	local objectValue = self._script.Parent[moduleScript]

	if objectValue:IsA("ObjectValue") then
		local module = require(waitForValue(objectValue))
		modulesByModuleScript[moduleScript] = module
		return module
	else
		local module = require(objectValue)
		modulesByModuleScript[moduleScript] = module
		return module
	end
end

Loader.__index = Loader.__call

return Loader