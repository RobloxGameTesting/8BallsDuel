local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local RunService = game:GetService("RunService")

local v = loaded("Rx")
local v2 = loaded("RxSignal")
local v3 = loaded("RxValueBaseUtils")
local v4 = loaded("ValueBaseUtils")

local ValueBaseValue = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "ValueBaseValue"
}

ValueBaseValue.__index = ValueBaseValue

function ValueBaseValue.new(instance, className, value, defaultValue)
	assert(typeof(instance) == "Instance", "Bad argument 'parent'")
	assert(type(className) == "string", "Bad argument 'className'")
	assert(type(value) == "string", "Bad argument 'name'")

	local v5 = {
		["_parent"] = instance,
		_name = value,
		_className = className,
		_defaultValue = defaultValue
	}

	if RunService:IsServer() then
		v4.getOrCreateValue(instance, v5._className, v5._name, v5._defaultValue)
	end

	return (setmetatable(v5, ValueBaseValue))
end

function ValueBaseValue:ObserveBrio(p)
	return v3.observeBrio(self._parent, self._className, self._name, p)
end

function ValueBaseValue:Observe()
	return v3.observe(self._parent, self._className, self._name, self._defaultValue)
end

function ValueBaseValue:__index(p)
	if p == "Value" then
		return v4.getValue(self._parent, self._className, self._name, self._defaultValue)
	elseif p == "Changed" then
		return v2.new(self:Observe():Pipe({ v.skip(1) }))
	end

	if ValueBaseValue[p] or p == "_defaultValue" then
		return ValueBaseValue[p]
	end

	error(("%q is not a member of ValueBaseValue"):format((tostring(p))))
end

function ValueBaseValue:__newindex(p, p2)
	if p == "Value" then
		v4.setValue(self._parent, self._className, self._name, p2)
	else
		error(("%q is not a member of ValueBaseValue"):format((tostring(p))))
	end
end

return ValueBaseValue