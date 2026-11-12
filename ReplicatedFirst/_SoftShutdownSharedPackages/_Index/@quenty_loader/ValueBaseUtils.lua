local ValueBaseUtils = {}

local v = {
	["nil"] = "ObjectValue",
	boolean = "BoolValue",
	number = "NumberValue",
	string = "StringValue",
	BrickColor = "BrickColorValue",
	CFrame = "CFrameValue",
	Color3 = "Color3Value",
	Instance = "ObjectValue",
	Ray = "RayValue",
	Vector3 = "Vector3Value"
}

local v2 = {
	BoolValue = "boolean",
	NumberValue = "number",
	IntValue = "number",
	StringValue = "string",
	BrickColorValue = "BrickColor",
	CFrameValue = "CFrame",
	Color3Value = "Color3",
	ObjectValue = "Instance",
	RayValue = "Ray",
	Vector3Value = "Vector3"
}

function ValueBaseUtils.isValueBase(valueBase)
	return typeof(valueBase) == "Instance" and valueBase:IsA("ValueBase")
end

function ValueBaseUtils.getValueBaseType(p)
	return v2[p]
end

function ValueBaseUtils.getClassNameFromType(p)
	return v[p]
end

function ValueBaseUtils.getOrCreateValue(parent, className, name, p)
	assert(typeof(parent) == "Instance", "Bad argument 'parent'")
	assert(type(className) == "string", "Bad argument 'instanceType'")
	assert(type(name) == "string", "Bad argument 'name'")

	local child = parent:FindFirstChild(name)

	if child then
		if not child:IsA(className) then
			warn(("[ValueBaseUtils.getOrCreateValue] - Value of type %q of name %q is of type %q in %s instead"):format(
				className,
				name,
				child.ClassName,
				child:GetFullName()
			))
		end

		return child
	else
		local instance = Instance.new(className)
		instance.Name = name
		instance.Value = p
		instance.Parent = parent

		return instance
	end
end

function ValueBaseUtils.setValue(parent, className, name, p)
	assert(typeof(parent) == "Instance", "Bad argument 'parent'")
	assert(type(className) == "string", "Bad argument 'instanceType'")
	assert(type(name) == "string", "Bad argument 'name'")

	local child = parent:FindFirstChild(name)

	if child then
		if not child:IsA(className) then
			warn(("[ValueBaseUtils.setValue] - Value of type %q of name %q is of type %q in %s instead"):format(
				className,
				name,
				child.ClassName,
				child:GetFullName()
			))
		end

		child.Value = p
	else
		local instance = Instance.new(className)
		instance.Name = name
		instance.Value = p
		instance.Parent = parent
	end
end

function ValueBaseUtils.getValue(instance, className, childName, p)
	assert(typeof(instance) == "Instance", "Bad argument 'parent'")
	assert(type(className) == "string", "Bad argument 'instanceType'")
	assert(type(childName) == "string", "Bad argument 'name'")

	local child = instance:FindFirstChild(childName)

	if not child then
		return p
	end

	if child:IsA(className) then
		return child.Value
	end

	warn(("[ValueBaseUtils.getValue] - Value of type %q of name %q is of type %q in %s instead"):format(
		className,
		childName,
		child.ClassName,
		child:GetFullName()
	))
	return nil
end

function ValueBaseUtils.createGetSet(value, value2)
	assert(type(value) == "string", "Bad argument 'instanceType'")
	assert(type(value2) == "string", "Bad argument 'name'")

	return function(instance, p)
		assert(typeof(instance) == "Instance", "Bad argument 'parent'")

		return ValueBaseUtils.getValue(instance, value, value2, p)
	end, function(instance, p)
		assert(typeof(instance) == "Instance", "Bad argument 'parent'")

		return ValueBaseUtils.setValue(instance, value, value2, p)
	end, function(p, p2)
		return ValueBaseUtils.getOrCreateValue(p, value, value2, p2)
	end
end

return ValueBaseUtils