local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("AccelTween")
local v2 = loaded("BlendDefaultProps")
local v3 = loaded("Brio")
local v4 = loaded("Maid")
local v5 = loaded("MaidTaskUtils")
local v6 = loaded("Observable")
local v7 = loaded("Promise")
local v8 = loaded("Rx")
local v9 = loaded("BrioUtils")
local v10 = loaded("RxInstanceUtils")
local v11 = loaded("RxValueBaseUtils")
local v12 = loaded("Signal")
local v13 = loaded("Spring")
local v14 = loaded("SpringUtils")
local v15 = loaded("StepUtils")
local v16 = loaded("ValueBaseUtils")
local v17 = loaded("ValueObject")
local v18 = loaded("ValueObjectUtils")
local v19 = loaded("RxBrioUtils")

local Blend = {}

function Blend.New(className)
	assert(type(className) == "string", "Bad className")

	local v20 = v2[className]

	return function(p)
		return v6.new(function(object)
			local instance = Instance.new(className)

			if v20 then
				for k, v21 in pairs(v20) do
					instance[k] = v21
				end
			end

			local maid = Blend.mount(instance, p)
			maid:GiveTask(instance)

			object:Fire(instance)

			return maid
		end)
	end
end

function Blend.State(p, p2)
	return v17.new(p, p2)
end

function Blend.Throttled(object)
	return object:Pipe({ v8.throttleDefer() })
end

function Blend.Shared(object)
	return object:Pipe({ v8.cache() })
end

function Blend.Dynamic(...)
	return Blend.Computed(...):Pipe({ v8.switchMap(function(p, ...)
			if v7.isPromise(p) then
				return v8.fromPromise(p)
			end

			if v6.isObservable(p) then
				return p
			end

			return v8.of(p, ...)
		end) })
end

function Blend.Computed(...)
	local v20 = { ... }
	local v21 = select("#", ...)
	local v22 = v20[v21]

	assert(type(v22) == "function", "Bad compute")

	local v23 = {}

	for i = 1, v21 - 1 do
		local propertyObservable = Blend.toPropertyObservable(v20[i])

		if propertyObservable then
			v23[i] = propertyObservable
		else
			v23[i] = v8.of(v20[i])
		end
	end

	if #v23 == 0 then
		return v6.new(function(object)
			object:Fire(v22())
		end)
	end

	if #v23 == 1 then
		return v8.map(v22)(v23[1])
	end

	return v8.combineLatest(v23):Pipe({ v8.map(function(list)
			return v22(unpack(list, 1, v21 - 1))
		end) })
end

function Blend.OnChange(value)
	assert(type(value) == "string", "Bad propertyName")

	return function(p)
		return v10.observeProperty(p, value)
	end
end

function Blend.OnEvent(value)
	assert(type(value) == "string", "Bad eventName")

	return function(p)
		return v8.fromSignal(p[value])
	end
end

function Blend.Attached(callback)
	return function(p)
		return v6.new(function(object)
			local maid = v4.new()

			local v20 = callback(p)

			if v5.isValidTask(v20) then
				maid:GiveTask(v20)
			end

			object:Fire(v20)

			return maid
		end)
	end
end

function Blend.ComputedPairs(p, callback)
	local v20 = Blend.toPropertyObservable(p) or v8.of(p)

	return v6.new(function(object)
		local v21 = {}
		local maid = v4.new()

		local v22 = v4.new()
		maid:GiveTask(v22)

		maid:GiveTask(v20:Subscribe(function(items)
			assert(type(items) == "table", "Bad value emitted from source")

			local v23 = {}

			for k, _ in pairs(v21) do
				v23[k] = true
			end

			for k, item in pairs(items) do
				v23[k] = nil

				if v21[k] == item then
					continue
				end

				local maid2 = v4.new()
				local v24 = callback(k, item, maid2)

				local v25 = v3.new(v24)
				maid2:GiveTask(v25)

				object:Fire(v25)

				v22[k] = maid2
				v21[k] = item
			end

			for k, _ in pairs(v23) do
				v22[k] = nil
				v21[k] = nil
			end
		end), object:GetFailComplete())

		return maid
	end)
end

function Blend.AccelTween(p, p2)
	local v20 = Blend.toPropertyObservable(p) or v8.of(p)
	local numberObservable = Blend.toNumberObservable(p2)

	local function createAccelTween(maid, p3)
		local accelTween = v.new()

		if p3 then
			accelTween.p = p3
			accelTween.t = p3
			accelTween.v = 0
		end

		if numberObservable then
			maid:GiveTask(numberObservable:Subscribe(function(value)
				assert(type(value) == "number", "Bad value")
				accelTween.a = value
			end))
		end

		return accelTween
	end

	return v6.new(function(object)
		local v21 = nil
		local maid = v4.new()

		local v22, v23 = v15.bindToRenderStep(function(): boolean
			object:Fire(v21.p)
			return v21.rtime > 0
		end)

		maid:GiveTask(v23)
		maid:GiveTask(v20:Subscribe(function(p3)
			local v24 = v21

			if not v24 then
				v24 = v.new()

				if p3 then
					v24.p = p3
					v24.t = p3
					v24.v = 0
				end

				if numberObservable then
					maid:GiveTask(numberObservable:Subscribe(function(value)
						assert(type(value) == "number", "Bad value")
						v24.a = value
					end))
				end
			end

			v21 = v24
			v21.t = p3
			v22()
		end))

		return maid
	end)
end

function Blend.Spring(p, p2, p3)
	local v20 = Blend.toPropertyObservable(p) or v8.of(p)
	local numberObservable = Blend.toNumberObservable(p2)
	local numberObservable2 = Blend.toNumberObservable(p3)

	local function createSpring(maid, linearIfNeeded)
		local spring = v13.new(linearIfNeeded)

		if numberObservable then
			maid:GiveTask(numberObservable:Subscribe(function(speed)
				assert(type(speed) == "number", "Bad value")
				spring.Speed = speed
			end))
		end

		if numberObservable2 then
			maid:GiveTask(numberObservable2:Subscribe(function(damper)
				assert(type(damper) == "number", "Bad value")

				spring.Damper = damper
			end))
		end

		return spring
	end

	return v6.new(function(object)
		local v21 = nil
		local maid = v4.new()

		local v22, v23 = v15.bindToRenderStep(function()
			local animating, v22 = v14.animating(v21)
			object:Fire(v14.fromLinearIfNeeded(v22))
			return animating
		end)

		maid:GiveTask(v23)
		maid:GiveTask(v20:Subscribe(function(p4)
			if not p4 then
				warn("Got nil value from emitted source")

				return
			end

			local linearIfNeeded = v14.toLinearIfNeeded(p4)
			v21 = v21 or createSpring(maid, linearIfNeeded)
			v21.t = v14.toLinearIfNeeded(p4)
			v22()
		end))

		return maid
	end)
end

function Blend.toPropertyObservable(value)
	if v6.isObservable(value) then
		return value
	end

	if typeof(value) == "Instance" then
		if v16.isValueBase(value) then
			return v11.observeValue(value)
		end
	elseif type(value) == "table" then
		if v17.isValueObject(value) then
			return v18.observeValue(value)
		end

		if v7.isPromise(value) then
			return v8.fromPromise(value)
		end

		if value.Observe then
			return value:Observe()
		end
	end

	return nil
end

function Blend.toNumberObservable(value)
	if type(value) == "number" then
		return v8.of(value)
	end

	return Blend.toPropertyObservable(value)
end

function Blend.toEventObservable(p)
	if v6.isObservable(p) then
		return p
	end

	if typeof(p) == "RBXScriptSignal" or v12.isSignal(p) then
		return v8.fromSignal(p)
	end

	return nil
end

function Blend:toEventHandler()
	if type(self) == "function" then
		return self
	end

	if typeof(self) == "Instance" then
		if v16.isValueBase(self) then
			return function(p)
				self.Value = p
			end
		end
	elseif type(self) == "table" then
		if v12.isSignal(self) then
			return function(...)
				self:Fire(...)
			end
		end

		if self.ClassName == "ValueObject" then
			return function(p)
				self.Value = p
			end
		end
	end

	return nil
end

function Blend.Children(parent, p)
	assert(typeof(parent) == "Instance", "Bad parent")

	local v20 = Blend._observeChildren(p, parent)

	if v20 then
		return v20:Pipe({ v8.tap(function(p2)
				p2.Parent = parent
			end) })
	end

	return v8.EMPTY
end

function Blend.Tags(instance, p)
	assert(typeof(instance) == "Instance", "Bad parent")

	local v20 = Blend._observeTags(p, instance)

	if v20 then
		return v20:Pipe({ v8.tap(function(tag)
				if type(tag) == "string" then
					instance:AddTag(tag)
				else
					error("Bad tag")
				end
			end) })
	end

	return v8.EMPTY
end

function Blend._observeTags(value)
	if type(value) == "string" then
		return v8.of(value)
	end

	if type(value) ~= "table" then
		error("Bad tags")

		return
	end

	if v6.isObservable(value) then
		return value
	end

	error("Bad tags")
end

function Blend.Find(value)
	assert(type(value) == "string", "Bad className")

	return function(instance)
		assert(type(instance) == "table", "Bad props")
		assert(type(instance.Name) == "string", "No props.Name")

		if instance.Parent then
			return (Blend.toPropertyObservable(instance.Parent) or v8.of(instance.Parent)):Pipe({
				v19.toBrio(),
				v19.where(function(p): boolean
					return p ~= nil
				end),
				v19.switchMapBrio(function(instance2)
					assert(typeof(instance2) == "Instance", "Bad parent retrieved during find spec")

					return v10.observeChildrenOfNameBrio(instance2, value, instance.Name)
				end),
				v8.flatMap(function(object)
					if object:IsDead() then
						return
					end

					local maid = object:ToMaid()
					local value2 = object:GetValue()
					maid:GiveTask(Blend.mount(value2, instance))

					if object:IsDead() then
						maid:DoCleaning()
					end

					return v8.of(value2)
				end)
			})
		end

		return function(p)
			return v10.observeChildrenOfNameBrio(p, value, instance.Name):Pipe({ Blend._mountToFinding(instance) })
		end
	end
end

function Blend._mountToFinding(p)
	return v8.flatMap(function(object)
		if object:IsDead() then
			return
		end

		local maid = object:ToMaid()
		local value = object:GetValue()
		maid:GiveTask(Blend.mount(value, p))

		if object:IsDead() then
			maid:DoCleaning()
		end

		return v8.EMPTY
	end)
end

function Blend.Instance(p)
	return v6.new(function(object)
		object:Fire(p)
	end)
end

function Blend.Single(object)
	return v6.new(function(object2)
		local maid = v4.new()

		maid:GiveTask(object:Subscribe(function(p)
			if v3.isBrio(p) then
				local clone = v9.clone(p)
				maid._current = clone
				object2:Fire(clone)
				return clone
			else
				local current = v3.new(p)
				maid._current = current
				object2:Fire(current)

				return current
			end
		end))

		return maid
	end)
end

function Blend._observeChildren(value, p)
	if typeof(value) == "Instance" then
		return v6.new(function(object)
			object:Fire(value)

			return value
		end)
	end

	if type(value) == "function" then
		value = Blend._observeChildren(value(p), p)
	end

	if v17.isValueObject(value) then
		return v6.new(function(object)
			local maid = v4.new()

			local function update()
				local current = value.Value

				if typeof(current) == "Instance" then
					maid._current = current
					object:Fire(current)
				else
					local v20 = Blend._observeChildren(current, p)

					if not v20 then
						maid._current = nil
						return
					end

					maid._current = nil

					local flag = false
					local current2 = nil
					current2 = v20:Subscribe(function(p2)
						object:Fire(p2)
					end, function(...)
						object:Fail(...)
					end, function()
						flag = true

						if maid._current == current2 then
							maid._current = nil
						end
					end)

					if flag then
						if current2 then
							v5.doCleanup(current2)
						end
					else
						maid._current = current2
					end
				end
			end
			maid:GiveTask(value.Changed:Connect(update))
			update()

			return maid
		end)
	end

	if v3.isBrio(value) then
		return v6.new(function(object)
			if value:IsDead() then
				return nil
			end

			local value2 = value:GetValue()

			if typeof(value2) == "Instance" then
				local maid = value:ToMaid()
				maid:GiveTask(value2)
				object:Fire(value2)

				return maid
			else
				local v20 = Blend._observeChildren(value2, p)

				if not v20 then
					warn(("Unknown type in brio %q"):format((typeof(value2))))
					return nil
				end

				local maid = value:ToMaid()

				maid:GiveTask(v20:Subscribe(function(p2)
					object:Fire(p2)
				end, function(...)
					object:Fail(...)
				end, function()
					maid:DoCleaning()
				end))

				return maid
			end
		end)
	end

	if v7.isPromise(value) then
		value = v8.fromPromise(value)
	end

	local v20

	if v12.isSignal(value) or typeof(value) == "RBXScriptSignal" then
		v20 = v8.fromSignal(value)
	else
		v20 = value
	end

	if v6.isObservable(v20) then
		return v6.new(function(object)
			local maid = v4.new()

			maid:GiveTask(v20:Subscribe(function(instance)
				if typeof(instance) == "Instance" then
					maid:GiveTask(instance)
					object:Fire(instance)
				else
					local v21 = Blend._observeChildren(instance, p)

					if not v21 then
						warn(("Failed to convert %q into children"):format((tostring(instance))))

						return
					end

					local maid2 = v4.new()

					maid2:GiveTask(v21:Subscribe(function(p2)
						object:Fire(p2)
					end, function(...)
						maid2:DoCleaning()
						object:Fail(...)
					end, function()
						maid2:DoCleaning()
					end))

					maid2:GiveTask(function()
						maid[maid2] = nil
					end)
					maid[maid2] = maid2
				end
			end, function(...)
				object:Fire(...)
			end, function() end))

			return maid
		end)
	end

	if type(v20) ~= "table" or getmetatable(v20) then
		return nil
	end

	local v21 = {}

	for k, v22 in pairs(v20) do
		local v23 = Blend._observeChildren(v22, p)

		if v23 then
			table.insert(v21, v23)
		else
			warn(("Failed to convert [%s] %q into children"):format(tostring(k), (tostring(v22))))
		end
	end

	if next(v21) then
		return v8.merge(v21)
	end

	return nil
end

function Blend:mount(items)
	assert(typeof(self) == "Instance", "Bad instance")

	local maid = v4.new()

	local v20 = {}
	local parent2 = nil

	for k, item in pairs(items) do
		if type(k) == "string" then
			if k == "Parent" then
				parent2 = item
			else
				local propertyObservable = Blend.toPropertyObservable(item)

				if propertyObservable then
					maid:GiveTask(propertyObservable:Subscribe(function(p)
						task.spawn(function()
							self[k] = p
						end)
					end))
				else
					task.spawn(function()
						self[k] = item
					end)
				end
			end
		elseif type(k) == "function" then
			local eventObservable = Blend.toEventObservable(k(self, item))

			if v6.isObservable(eventObservable) then
				table.insert(v20, { eventObservable, item })
			else
				warn(("Unable to apply event listener %q"):format((tostring(k))))
			end
		elseif type(k) == "number" then
			table.insert(v20, { Blend.Children(self, item), item })
		else
			warn(("Unable to apply property %q"):format((tostring(k))))
		end
	end

	for _, v21 in pairs(v20) do
		maid:GiveTask(v21[1]:Subscribe(Blend.toEventHandler(v21[2])))
	end

	if not parent2 then
		return maid
	end

	local propertyObservable = Blend.toPropertyObservable(parent2)

	if propertyObservable then
		maid:GiveTask(propertyObservable:Subscribe(function(parent)
			self.Parent = parent
		end))
		return maid
	end

	self.Parent = parent2

	return maid
end

return Blend