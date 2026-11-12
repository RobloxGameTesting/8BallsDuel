local function errorOnIndex(_, p)
	error(("Bad index %q"):format((tostring(p))), 2)
end

local v = { __index = errorOnIndex, __newindex = errorOnIndex }
local Utils = {}

function Utils.readonly(p)
	return (setmetatable(p, v))
end

function Utils.count(items)
	local count = 0

	for _, _ in pairs(items) do
		count += 1
	end

	return count
end

function Utils.getOrCreateValue(parent, className, name, p)
	assert(typeof(parent) == "Instance", "Bad argument 'parent'")
	assert(type(className) == "string", "Bad argument 'instanceType'")
	assert(type(name) == "string", "Bad argument 'name'")

	local child = parent:FindFirstChild(name)

	if child then
		if not child:IsA(className) then
			warn(("[Utils.getOrCreateValue] - Value of type %q of name %q is of type %q in %s instead"):format(
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

function Utils.getValue(instance, className, childName, p)
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

	warn(("[Utils.getValue] - Value of type %q of name %q is of type %q in %s instead"):format(
		className,
		childName,
		child.ClassName,
		child:GetFullName()
	))
	return nil
end

function Utils.setValue(parent, className, name, p)
	assert(typeof(parent) == "Instance", "Bad argument 'parent'")
	assert(type(className) == "string", "Bad argument 'instanceType'")
	assert(type(name) == "string", "Bad argument 'name'")

	local child = parent:FindFirstChild(name)

	if child then
		if not child:IsA(className) then
			warn(("[Utils.setValue] - Value of type %q of name %q is of type %q in %s instead"):format(
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

function Utils.getOrCreateFolder(parent, name)
	local child = parent:FindFirstChild(name)

	if child then
		return child
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

return Utils