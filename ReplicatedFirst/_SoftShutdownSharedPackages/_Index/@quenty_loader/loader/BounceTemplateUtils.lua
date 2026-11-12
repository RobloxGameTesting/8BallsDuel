local BounceTemplate = script.Parent.BounceTemplate

local BounceTemplateUtils = {}

function BounceTemplateUtils.isBounceTemplate(instance): boolean
	return instance:GetAttribute("IsBounceTemplate", true) == true
end

function BounceTemplateUtils.getTarget(objectValue)
	if not BounceTemplateUtils.isBounceTemplate(objectValue) then
		return nil
	end

	if objectValue:IsA("ObjectValue") then
		return objectValue.Value
	end

	local bounceTarget = objectValue:FindFirstChild("BounceTarget")

	if bounceTarget then
		return bounceTarget.Value
	end

	warn("[BounceTemplateUtils.getTarget] - Bounce template without BounceTarget")
	return nil
end

function BounceTemplateUtils.create(instance, name)
	assert(typeof(instance) == "Instance", "Bad target")
	assert(type(name) == "string", "Bad linkName")

	local clone = BounceTemplate:Clone()
	clone:SetAttribute("IsBounceTemplate", true)
	clone.Name = name

	local bounceTarget = Instance.new("ObjectValue")
	bounceTarget.Name = "BounceTarget"
	bounceTarget.Value = instance
	bounceTarget.Parent = clone

	return clone
end

function BounceTemplateUtils.createLink(instance, name)
	assert(typeof(instance) == "Instance", "Bad target")
	assert(type(name) == "string", "Bad linkName")

	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = name
	objectValue.Value = instance
	objectValue:SetAttribute("IsBounceTemplate", true)

	return objectValue
end

return BounceTemplateUtils