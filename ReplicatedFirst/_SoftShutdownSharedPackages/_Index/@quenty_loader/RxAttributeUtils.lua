local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Brio")
local v2 = loaded("Maid")
local v3 = loaded("Observable")
local named = loaded("Symbol").named("unsetValue")
local RxAttributeUtils = {}

function RxAttributeUtils.observeAttribute(instance, attributeName, p)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(attributeName) == "string", "Bad attributeName")

	return v3.new(function(object)
		local maid = v2.new()

		local function handleAttributeChanged() -- 1 equivalent call inferred from this helper
			local attribute = instance:GetAttribute(attributeName)

			if attribute == nil then
				object:Fire(p)
			else
				object:Fire(attribute)
			end
		end

		maid:GiveTask(instance:GetAttributeChangedSignal(attributeName):Connect(handleAttributeChanged))
		handleAttributeChanged() -- inferred equivalent call
		return maid
	end)
end

function RxAttributeUtils.observeAttributeKeysBrio(instance)
	assert(typeof(instance) == "Instance", "Bad instance")

	return v3.new(function(object)
		local maid = v2.new()

		local v4 = {}

		local function handleAttributeChanged(p, p2) -- 2 equivalent calls inferred from this helper
			if p2 == nil then
				local v5 = v4[p]

				if v5 then
					v4[p] = nil
					maid[v5] = nil
				end
			elseif not v4[p] then
				local v5 = v.new(p)
				v4[p] = v5
				maid[v5] = v5
				object:Fire(v5)
			end
		end

		maid:GiveTask(instance.AttributeChanged:Connect(function(attributeName)
			handleAttributeChanged(attributeName, instance:GetAttribute(attributeName)) -- inferred equivalent call
		end))

		for k, v5 in pairs(instance:GetAttributes()) do
			if not object:IsPending() then
				break
			end

			handleAttributeChanged(k, v5) -- inferred equivalent call
		end

		return maid
	end)
end

function RxAttributeUtils.observeAttributeKeys(instance)
	assert(typeof(instance) == "Instance", "Bad instance")

	return v3.new(function(object)
		local maid = v2.new()

		maid:GiveTask(instance.AttributeChanged:Connect(function(p)
			object:Fire(p)
		end))

		for k, _ in pairs(instance:GetAttributes()) do
			if not object:IsPending() then
				break
			end

			object:Fire(k)
		end

		return maid
	end)
end

function RxAttributeUtils.observeAttributeBrio(instance, attributeName, callback)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(attributeName) == "string", "Bad attributeName")

	return v3.new(function(object)
		local maid = v2.new()
		local v4 = named

		local function handleAttributeChanged()
			local attribute = instance:GetAttribute(attributeName)

			if v4 ~= attribute then
				v4 = attribute

				if callback and not callback(attribute) then
					maid._lastBrio = nil
				else
					local lastBrio = v.new(attribute)
					maid._lastBrio = lastBrio

					if maid._lastBrio == lastBrio then
						object:Fire(lastBrio)
					end
				end
			end
		end

		maid:GiveTask(instance:GetAttributeChangedSignal(attributeName):Connect(handleAttributeChanged))
		handleAttributeChanged()

		return maid
	end)
end

return RxAttributeUtils