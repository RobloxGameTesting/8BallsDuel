local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local RunService = game:GetService("RunService")

local v = loaded("Maid")
local v2 = loaded("Promise")
local v3 = loaded("CancelToken")

local function fn(p): boolean
	return p ~= nil
end

local v4 = {
	["nil"] = true,
	string = true,
	boolean = true,
	number = true,
	UDim = true,
	UDim2 = true,
	BrickColor = true,
	CFrame = true,
	Color3 = true,
	Vector2 = true,
	Vector3 = true,
	NumberSequence = true,
	ColorSequence = true,
	IntValue = true,
	NumberRange = true,
	Rect = true,
	Font = true
}
local AttributeUtils = {}

function AttributeUtils.isValidAttributeType(p): boolean
	return v4[p] == true
end

function AttributeUtils.promiseAttribute(instance, attributeName, p, p2)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(attributeName) == "string", "Bad attributeName")
	assert(v3.isCancelToken(p2) or p2 == nil, "Bad cancelToken")

	local v5 = p or fn

	local attribute = instance:GetAttribute(attributeName)

	if v5(attribute) then
		return v2.resolved(attribute)
	end

	local v6 = v2.new()
	local maid = v.new()
	maid:GiveTask(v6)

	if p2 then
		maid:GiveTask(p2.Cancelled:Connect(function()
			v6:Reject()
		end))
	end

	maid:GiveTask(instance:GetAttributeChangedSignal(attributeName):Connect(function()
		local attribute2 = instance:GetAttribute(attributeName)

		if v5(attribute2) then
			v6:Resolve(attribute2)
		end
	end))

	v6:Finally(function()
		maid:DoCleaning()
	end)

	return v6
end

function AttributeUtils.bindToBinder(instance, attributeName, object)
	assert(object, "Bad binder")
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(attributeName) == "string", "Bad attributeName")

	local maid = v.new()

	local function syncAttribute()
		if instance:GetAttribute(attributeName) then
			if RunService:IsClient() then
				object:BindClient(instance)
			else
				object:Bind(instance)
			end
		elseif RunService:IsClient() then
			object:UnbindClient(instance)
		else
			object:Unbind(instance)
		end
	end
	maid:GiveTask(instance:GetAttributeChangedSignal(attributeName):Connect(syncAttribute))

	local function syncBoundClass()
		if object:Get(instance) then
			instance:SetAttribute(attributeName, true)
		else
			instance:SetAttribute(attributeName, false)
		end
	end
	maid:GiveTask(object:ObserveInstance(instance, syncBoundClass))

	if object:Get(instance) or instance:GetAttribute(attributeName) then
		instance:SetAttribute(attributeName, true)

		if RunService:IsClient() then
			object:BindClient(instance)
		else
			object:Bind(instance)
		end
	else
		instance:SetAttribute(attributeName, false)
	end

	maid:GiveTask(function()
		maid:DoCleaning()

		instance:SetAttribute(attributeName, nil)
	end)

	return maid
end

function AttributeUtils.initAttribute(instance, attributeName, p)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(typeof(attributeName) == "string", "Bad attributeName")

	local v5 = instance:GetAttribute(attributeName)

	if v5 == nil then
		instance:SetAttribute(attributeName, p)
		return p
	end

	return v5
end

function AttributeUtils.getAttribute(instance, attributeName, p)
	local attribute = instance:GetAttribute(attributeName)
	return if attribute == nil then p else attribute
end

function AttributeUtils.removeAllAttributes(instance)
	assert(typeof(instance) == "Instance", "Bad instance")

	for k, _ in pairs(instance:GetAttributes()) do
		instance:SetAttribute(k, nil)
	end
end

return AttributeUtils