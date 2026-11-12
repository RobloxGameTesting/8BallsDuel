local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("GoodSignal")
local v2 = loaded("Maid")
local v3 = loaded("Observable")
local v4 = loaded("ValueBaseUtils")
local v5 = loaded("RxValueBaseUtils")
local v6 = loaded("Brio")

local function fn() end

local ValueObject = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "ValueObject"
}

function ValueObject.new(p, checkType)
	local v7 = { _value = p, _checkType = checkType, _maid = v2.new() }

	if checkType and typeof(p) ~= checkType then
		error(string.format("Expected value of type %q, got %q instead", checkType, (typeof(p))))
	end

	v7.Changed = v.new()
	v7._maid:GiveTask(v7.Changed)

	return (setmetatable(v7, ValueObject))
end

function ValueObject.GetCheckType(p)
	return (rawget(p, "_checkType"))
end

function ValueObject.fromObservable(p)
	local v7 = ValueObject.new()

	v7:Mount(p)

	return v7
end

function ValueObject.isValueObject(p): boolean
	return type(p) == "table" and getmetatable(p) == ValueObject
end

function ValueObject:_toMountableObservable(value)
	if v3.isObservable(value) then
		return value
	end

	if typeof(value) == "Instance" then
		if v4.isValueBase(value) then
			return v5.observeValue(value)
		end
	elseif type(value) == "table" and ValueObject.isValueObject(value) then
		return value:Observe()
	end

	return nil
end

function ValueObject:Mount(p)
	local mountableObservable = self:_toMountableObservable(p)

	if mountableObservable then
		self._maid._mount = nil

		local maid = v2.new()

		maid:GiveTask(mountableObservable:Subscribe(function(...)
			self:SetValue(...)
		end))

		maid:GiveTask(function()
			if self._maid._mount == maid then
				self._maid._mount = nil
			end
		end)

		self._maid._mount = maid

		return function()
			if self._maid._mount == maid then
				self._maid._mount = nil
			end
		end
	end

	self._maid._mount = nil

	self:SetValue(p)

	return fn
end

function ValueObject:Observe()
	return v3.new(function(object)
		if self.Destroy then
			local maid = v2.new()

			maid:GiveTask(self.Changed:Connect(function(p, _, _, ...)
				object:Fire(p, ...)
			end))

			local v7 = rawget(self, "_lastEventContext")

			if v7 then
				object:Fire(self.Value, table.unpack(v7, 1, v7.n))
				return maid
			end

			object:Fire(self.Value)

			return maid
		end

		warn("[ValueObject.observeValue] - Connecting to dead ValueObject")

		object:Complete()
	end)
end

function ValueObject.ObserveBrio(data, callback)
	assert(type(callback) == "function" or callback == nil, "Bad condition")

	return v3.new(function(object)
		if data.Destroy then
			local maid = v2.new()

			local function handleNewValue(p, ...)
				if callback and not callback(p) then
					maid._current = nil

					return
				end

				local current = v6.new(p, ...)
				maid._current = current
				object:Fire(current)
			end

			maid:GiveTask(data.Changed:Connect(function(p, _, _, ...)
				handleNewValue(p, ...)
			end))

			local v7 = rawget(data, "_lastEventContext")

			if v7 then
				handleNewValue(data.Value, table.unpack(v7, 1, v7.n))
				return maid
			end

			handleNewValue(data.Value)

			return maid
		end

		warn("[ValueObject.observeValue] - Connecting to dead ValueObject")

		object:Complete()
	end)
end

function ValueObject:SetValue(p, ...)
	local v7 = rawget(self, "_value")
	local v8 = rawget(self, "_checkType")

	if v8 and typeof(p) ~= v8 then
		error(string.format("Expected value of type %q, got %q instead", v8, (typeof(p))))
	end

	if v7 ~= p then
		if select("#", ...) > 0 then
			rawset(self, "_lastEventContext", table.pack(...))
		else
			rawset(self, "_lastEventContext", nil)
		end

		rawset(self, "_value", p)

		local valueMaid = v2.new()

		self.Changed:Fire(p, v7, valueMaid, ...)

		self._maid._valueMaid = valueMaid
	end
end

function ValueObject:__index(p)
	if p == "Value" then
		return self._value
	end

	if ValueObject[p] then
		return ValueObject[p]
	end

	if p == "LastEventContext" then
		local v7 = rawget(self, "_lastEventContext")

		if v7 then
			return table.unpack(v7, 1, v7.n)
		end
	else
		if p == "_value" then
			return nil
		end

		error(("%q is not a member of ValueObject"):format((tostring(p))))
	end
end

function ValueObject.__newindex(p, p2, p3)
	if p2 == "Value" then
		ValueObject.SetValue(p, p3)
	elseif p2 == "LastEventContext" or ValueObject[p2] then
		error(("%q cannot be set in ValueObject"):format((tostring(p2))))
	else
		error(("%q is not a member of ValueObject"):format((tostring(p2))))
	end
end

function ValueObject:Destroy()
	rawset(self, "_value", nil)
	self._maid:DoCleaning()
	setmetatable(self, nil)
end

return ValueObject