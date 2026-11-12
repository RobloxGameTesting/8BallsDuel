local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Brio")
local v2 = loaded("Maid")
local v3 = loaded("Observable")
local v4 = loaded("Rx")
local named = loaded("Symbol").named("unsetValue")

local RxInstanceUtils = {}

function RxInstanceUtils.observeProperty(instance, propertyName)
	assert(typeof(instance) == "Instance", "'instance' should be of type Instance")
	assert(type(propertyName) == "string", "'propertyName' should be of type string")

	return v3.new(function(object)
		local maid = v2.new()

		maid:GiveTask(instance:GetPropertyChangedSignal(propertyName):Connect(function()
			object:Fire(instance[propertyName], instance)
		end))
		object:Fire(instance[propertyName], instance)

		return maid
	end)
end

function RxInstanceUtils.observeAncestry(instance)
	return v4.start(function()
		return instance, instance.Parent
	end)(v4.fromSignal(instance.AncestryChanged))
end

function RxInstanceUtils.observeFirstAncestorBrio(instance, className)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(className) == "string", "Bad className")

	return v3.new(function(object)
		local maid = v2.new()

		local v5 = nil
		local function handleAncestryChanged() -- 1 equivalent call inferred from this helper
			local firstAncestorWhichIsA = instance:FindFirstAncestorWhichIsA(className)

			if firstAncestorWhichIsA then
				if firstAncestorWhichIsA ~= v5 then
					v5 = firstAncestorWhichIsA
					local current = v.new(firstAncestorWhichIsA)
					maid._current = current
					object:Fire(current)
				end
			elseif v5 then
				maid._current = nil
				v5 = nil
			end
		end

		maid:GiveTask(instance.AncestryChanged:Connect(handleAncestryChanged))
		handleAncestryChanged() -- inferred equivalent call
		return maid
	end)
end

function RxInstanceUtils.observeParentBrio(p)
	return RxInstanceUtils.observePropertyBrio(p, "Parent", function(p2): boolean
		return p2 ~= nil
	end)
end

function RxInstanceUtils.observeFirstAncestor(instance, className)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(className) == "string", "Bad className")

	return v3.new(function(object)
		local maid = v2.new()

		local v5 = named
		local function handleAncestryChanged() -- 1 equivalent call inferred from this helper
			local firstAncestorWhichIsA = instance:FindFirstAncestorWhichIsA(className)

			if firstAncestorWhichIsA ~= v5 then
				v5 = firstAncestorWhichIsA
				object:Fire(firstAncestorWhichIsA)
			end
		end

		maid:GiveTask(instance.AncestryChanged:Connect(handleAncestryChanged))
		handleAncestryChanged() -- inferred equivalent call
		return maid
	end)
end

function RxInstanceUtils.observePropertyBrio(instance, propertyName, callback)
	assert(typeof(instance) == "Instance", "Bad instance")
	assert(type(propertyName) == "string", "Bad propertyName")
	assert(type(callback) == "function" or callback == nil, "Bad predicate")

	return v3.new(function(object)
		local maid = v2.new()
		local v5 = named

		local function handlePropertyChanged() -- 1 equivalent call inferred from this helper
			local v6 = instance[propertyName]

			if v5 ~= v6 then
				v5 = v6

				if callback and not callback(v6) then
					maid._lastBrio = nil
				else
					local lastBrio = v.new(instance[propertyName])

					maid._lastBrio = lastBrio

					if maid._lastBrio == lastBrio then
						object:Fire(lastBrio)
					end
				end
			end
		end

		maid:GiveTask(instance:GetPropertyChangedSignal(propertyName):Connect(handlePropertyChanged))
		handlePropertyChanged() -- inferred equivalent call
		return maid
	end)
end

function RxInstanceUtils.observeLastNamedChildBrio(instance, className, value)
	assert(typeof(instance) == "Instance", "Bad parent")
	assert(type(className) == "string", "Bad className")
	assert(type(value) == "string", "Bad name")

	return v3.new(function(object)
		local maid = v2.new()

		local function handleChild(child)
			if not child:IsA(className) then
				return
			end

			local maid2 = v2.new()

			local function handleNameChanged() -- 1 equivalent call inferred from this helper
				if child.Name ~= value then
					maid2._brio = nil

					return
				end

				local v5 = v.new(child)
				maid2._brio = v5
				maid._lastBrio = v5

				object:Fire(v5)
			end

			maid2:GiveTask(child:GetPropertyChangedSignal("Name"):Connect(handleNameChanged))
			handleNameChanged() -- inferred equivalent call
			maid[child] = maid2
		end

		maid:GiveTask(instance.ChildAdded:Connect(handleChild))
		maid:GiveTask(instance.ChildRemoved:Connect(function(child)
			maid[child] = nil
		end))

		for _, child in pairs(instance:GetChildren()) do
			handleChild(child)
		end

		return maid
	end)
end

function RxInstanceUtils.observeChildrenOfNameBrio(instance, className, value)
	assert(typeof(instance) == "Instance", "Bad parent")
	assert(type(className) == "string", "Bad className")
	assert(type(value) == "string", "Bad name")

	return v3.new(function(object)
		local maid = v2.new()

		local function handleChild(child)
			if not child:IsA(className) then
				return
			end

			local maid2 = v2.new()

			local function handleNameChanged() -- 1 equivalent call inferred from this helper
				if child.Name ~= value then
					maid2._brio = nil

					return
				end

				local brio = v.new(child)
				maid2._brio = brio

				object:Fire(brio)
			end

			maid[child] = maid2

			maid2:GiveTask(child:GetPropertyChangedSignal("Name"):Connect(handleNameChanged))
			handleNameChanged() -- inferred equivalent call
		end

		maid:GiveTask(instance.ChildAdded:Connect(handleChild))
		maid:GiveTask(instance.ChildRemoved:Connect(function(child)
			maid[child] = nil
		end))

		for _, child in pairs(instance:GetChildren()) do
			handleChild(child)
		end

		return maid
	end)
end

function RxInstanceUtils.observeChildrenOfClassBrio(instance, className)
	assert(typeof(instance) == "Instance", "Bad parent")
	assert(type(className) == "string", "Bad className")

	return RxInstanceUtils.observeChildrenBrio(instance, function(instance2)
		return instance2:IsA(className)
	end)
end

function RxInstanceUtils.observeChildrenBrio(instance, callback)
	assert(typeof(instance) == "Instance", "Bad parent")
	assert(type(callback) == "function" or callback == nil, "Bad predicate")

	return v3.new(function(object)
		local maid = v2.new()

		local function handleChild(child) -- 1 equivalent call inferred from this helper
			if not callback or callback(child) then
				local v5 = v.new(child)
				maid[child] = v5
				object:Fire(v5)
			end
		end

		maid:GiveTask(instance.ChildAdded:Connect(handleChild))
		maid:GiveTask(instance.ChildRemoved:Connect(function(child)
			maid[child] = nil
		end))

		for _, child in pairs(instance:GetChildren()) do
			handleChild(child) -- inferred equivalent call
		end

		return maid
	end)
end

function RxInstanceUtils.observeDescendants(folder, callback)
	assert(typeof(folder) == "Instance", "Bad parent")
	assert(type(callback) == "function" or callback == nil, "Bad predicate")

	return v3.new(function(object)
		local maid = v2.new()
		local v5 = {}

		local function handleDescendant(descendant) -- 1 equivalent call inferred from this helper
			if not callback or callback(descendant) then
				v5[descendant] = true
				object:Fire(descendant, true)
			end
		end

		maid:GiveTask(folder.DescendantAdded:Connect(handleDescendant))
		maid:GiveTask(folder.DescendantRemoving:Connect(function(descendant)
			if v5[descendant] then
				v5[descendant] = nil
				object:Fire(descendant, false)
			end
		end))

		for _, descendant in pairs(folder:GetDescendants()) do
			handleDescendant(descendant) -- inferred equivalent call
		end

		return maid
	end)
end

function RxInstanceUtils.observeDescendantsBrio(folder, callback)
	assert(typeof(folder) == "Instance", "Bad parent")
	assert(type(callback) == "function" or callback == nil, "Bad predicate")

	return v3.new(function(object)
		local maid = v2.new()

		local function handleDescendant(descendant) -- 1 equivalent call inferred from this helper
			if not callback or callback(descendant) then
				local v5 = v.new(descendant)
				maid[descendant] = v5
				object:Fire(v5)
			end
		end

		maid:GiveTask(folder.DescendantAdded:Connect(handleDescendant))
		maid:GiveTask(folder.DescendantRemoving:Connect(function(descendant)
			maid[descendant] = nil
		end))

		for _, descendant in pairs(folder:GetDescendants()) do
			handleDescendant(descendant) -- inferred equivalent call
		end

		return maid
	end)
end

function RxInstanceUtils.observeDescendantsOfClassBrio(instance, className)
	assert(typeof(instance) == "Instance", "Bad parent")
	assert(type(className) == "string", "Bad className")

	return RxInstanceUtils.observeDescendantsBrio(instance, function(instance2)
		return instance2:IsA(className)
	end)
end

return RxInstanceUtils