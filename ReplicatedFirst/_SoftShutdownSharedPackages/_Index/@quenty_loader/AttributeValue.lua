local loader = require(script.Parent.loader)
local v = loader.load(script)("RxAttributeUtils")

local AttributeValue = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "AttributeValue"
}

AttributeValue.__index = AttributeValue

function AttributeValue.new(instance, attributeName, defaultValue)
	assert(typeof(instance) == "Instance", "Bad object")
	assert(type(attributeName) == "string", "Bad attributeName")

	local v2 = { _object = instance, _attributeName = attributeName, _defaultValue = defaultValue }

	if defaultValue ~= nil and v2._object:GetAttribute(v2._attributeName) == nil then
		v2._object:SetAttribute(rawget(v2, "_attributeName"), defaultValue)
	end

	return (setmetatable(v2, AttributeValue))
end

function AttributeValue:ObserveBrio(p)
	return v.observeAttributeBrio(self._object, self._attributeName, p)
end

function AttributeValue:Observe()
	return v.observeAttribute(self._object, self._attributeName, (rawget(self, "_defaultValue")))
end

function AttributeValue:__index(p)
	if p == "Value" then
		local attribute = self._object:GetAttribute((rawget(self, "_attributeName")))
		local v2 = rawget(self, "_defaultValue")
		return if attribute == nil then v2 else attribute
	end

	if p == "Changed" then
		return self._object:GetAttributeChangedSignal(self._attributeName)
	end

	if AttributeValue[p] then
		return AttributeValue[p]
	end

	error(string.format("%q is not a member of AttributeValue", (tostring(p))))
end

function AttributeValue:__newindex(p, p2)
	if p == "Value" then
		self._object:SetAttribute(rawget(self, "_attributeName"), p2)
	else
		error(string.format("%q is not a member of AttributeValue", (tostring(p))))
	end
end

return AttributeValue