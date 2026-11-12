local loader = require(script.Parent.loader)
local v = loader.load(script)("Promise")

return function(instance, propertyName)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(propertyName) == "string", "Bad propertyName")

	local v2 = instance[propertyName]

	if v2 then
		return v.resolved(v2)
	end

	local v3 = v.new()

	local connection = nil
	v3:Finally(function()
		if connection then
			connection:Disconnect()
		end
	end)

	connection = instance:GetPropertyChangedSignal(propertyName):Connect(function()
		if instance[propertyName] then
			v3:Resolve(instance[propertyName])
		end
	end)

	return v3
end