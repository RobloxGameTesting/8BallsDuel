local HttpService = game:GetService("HttpService")

local v = nil
local v2 = nil

local Promise = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "Promise"
}

Promise.__index = Promise

function Promise.isPromise(instance): boolean
	return type(instance) == "table" and instance.ClassName == "Promise"
end

function Promise.new(callback)
	local self = setmetatable({
		_pendingExecuteList = {},
		_unconsumedException = true,
		_source = ""
	}, Promise)

	if type(callback) == "function" then
		callback(self:_getResolveReject())
	end

	return self
end

function Promise.spawn(callback)
	local v3 = Promise.new()

	task.spawn(callback, v3:_getResolveReject())

	return v3
end

function Promise.delay(duration, callback)
	assert(type(duration) == "number", "Bad seconds")
	assert(type(callback) == "function", "Bad func")

	local v3 = Promise.new()

	task.delay(duration, callback, v3:_getResolveReject())

	return v3
end

function Promise.defer(callback)
	local v3 = Promise.new()

	task.defer(callback, v3:_getResolveReject())

	return v3
end

function Promise.resolved(...)
	local v3 = select("#", ...)

	if v3 == 0 then
		return v2
	end

	if v3 == 1 and Promise.isPromise(...) then
		local v4 = ...

		if not v4._pendingExecuteList then
			return v4
		end
	end

	local v4 = Promise.new()
	v4:Resolve(...)
	return v4
end

function Promise.rejected(...)
	local v3 = select("#", ...)

	if v3 == 0 then
		return v
	end

	local v4 = Promise.new()
	v4:_reject({ ... }, v3)
	return v4
end

function Promise:IsPending(): boolean
	return self._pendingExecuteList ~= nil
end

function Promise:IsFulfilled(): boolean
	return self._fulfilled ~= nil
end

function Promise:IsRejected(): boolean
	return self._rejected ~= nil
end

function Promise:Wait()
	if self._fulfilled then
		return unpack(self._fulfilled, 1, self._valuesLength)
	end

	if self._rejected then
		return error(tostring(self._rejected[1]), 2)
	end

	local bindableEvent = Instance.new("BindableEvent")

	self:Then(function()
		bindableEvent:Fire()
	end, function()
		bindableEvent:Fire()
	end)

	bindableEvent.Event:Wait()
	bindableEvent:Destroy()

	if self._rejected then
		return error(tostring(self._rejected[1]), 2)
	end

	return unpack(self._fulfilled, 1, self._valuesLength)
end

function Promise:Yield()
	if self._fulfilled then
		return true, unpack(self._fulfilled, 1, self._valuesLength)
	end

	if self._rejected then
		return false, unpack(self._rejected, 1, self._valuesLength)
	end

	local bindableEvent = Instance.new("BindableEvent")

	self:Then(function()
		bindableEvent:Fire()
	end, function()
		bindableEvent:Fire()
	end)

	bindableEvent.Event:Wait()
	bindableEvent:Destroy()

	if self._fulfilled then
		return true, unpack(self._fulfilled, 1, self._valuesLength)
	end

	if self._rejected then
		return false, unpack(self._rejected, 1, self._valuesLength)
	end
end

function Promise:Resolve(...)
	if not self._pendingExecuteList then
		return
	end

	local v3 = select("#", ...)

	if v3 == 0 then
		self:_fulfill({}, 0)
	elseif self == ... then
		self:Reject("TypeError: Resolved to self")
	elseif Promise.isPromise(...) then
		if v3 > 1 then
			local formatted = ("When resolving a promise, extra arguments are discarded! See:\n\n%s"):format(self._source)
			warn(formatted)
		end

		local v4 = ...

		if v4._pendingExecuteList then
			v4._unconsumedException = false
			v4._pendingExecuteList[#v4._pendingExecuteList + 1] = {
				function(...)
					self:Resolve(...)
				end,
				function(...)
					if self._pendingExecuteList then
						self:_reject({ ... }, (select)("#", ...))
					end
				end,
				nil
			}
		elseif v4._rejected then
			v4._unconsumedException = false
			self:_reject(v4._rejected, v4._valuesLength)
		elseif v4._fulfilled then
			self:_fulfill(v4._fulfilled, v4._valuesLength)
		else
			error("[Promise.Resolve] - Bad promise2 state")
		end
	else
		if type(...) ~= "function" then
			self:_fulfill({ ... }, v3)

			return
		end

		if v3 > 1 then
			local formatted = ("When resolving a function, extra arguments are discarded! See:\n\n%s"):format(self._source)
			warn(formatted)
		end

		(...)(self:_getResolveReject())
	end
end

function Promise:_fulfill(fulfilled, valuesLength)
	if not self._pendingExecuteList then
		return
	end

	self._fulfilled = fulfilled
	self._valuesLength = valuesLength

	local pendingExecuteList = self._pendingExecuteList
	self._pendingExecuteList = nil

	for _, list in pairs(pendingExecuteList) do
		self:_executeThen(unpack(list))
	end
end

function Promise:Reject(...)
	self:_reject({ ... }, (select)("#", ...))
end

function Promise:_reject(rejected, valuesLength)
	if not self._pendingExecuteList then
		return
	end

	self._rejected = rejected
	self._valuesLength = valuesLength

	local pendingExecuteList = self._pendingExecuteList
	self._pendingExecuteList = nil

	for _, list in pairs(pendingExecuteList) do
		self:_executeThen(unpack(list))
	end

	if self._unconsumedException and self._valuesLength > 0 then
		task.defer(function()
			if self._unconsumedException then
				local humanReadable = self:_toHumanReadable(self._rejected[1])

				warn(("[Promise] - Uncaught exception in promise: %q"):format(humanReadable))
			end
		end)
	end
end

function Promise:_toHumanReadable(p)
	if type(p) ~= "table" then
		return (tostring(p))
	end

	local v3 = nil

	if not pcall(function()
		v3 = HttpService:JSONEncode(p)
	end) then
		v3 = tostring(p)
	end

	return v3
end

function Promise:Then(p, callback)
	if type(callback) == "function" then
		self._unconsumedException = false
	end

	if not self._pendingExecuteList then
		return self:_executeThen(p, callback, nil)
	end

	local v3 = Promise.new()
	self._pendingExecuteList[#self._pendingExecuteList + 1] = { p, callback, v3 }
	return v3
end

function Promise:Tap(p, p2)
	local v3 = self:Then(p, p2)

	if v3 == self then
		return v3
	end

	if v3._fulfilled or v3._rejected then
		return self
	end

	if v3._pendingExecuteList then
		local function returnSelf()
			return self
		end

		return v3:Then(returnSelf, returnSelf)
	end

	error("Bad result state")
end

function Promise:Finally(p)
	return self:Then(p, p)
end

function Promise:Catch(p)
	return self:Then(nil, p)
end

function Promise:Destroy()
	self:_reject({}, 0)
end

function Promise:GetResults()
	if self._rejected then
		return false, unpack(self._rejected, 1, self._valuesLength)
	end

	if self._fulfilled then
		return true, unpack(self._fulfilled, 1, self._valuesLength)
	end

	error("Still pending")
end

function Promise:_getResolveReject()
	return function(...)
		self:Resolve(...)
	end, function(...)
		self:_reject({ ... }, (select)("#", ...))
	end
end

function Promise:_executeThen(callback, callback2, object)
	if self._fulfilled then
		if type(callback) == "function" then
			if object then
				object:Resolve(callback(unpack(self._fulfilled, 1, self._valuesLength)))
				return object
			end

			local v3 = table.pack(callback(unpack(self._fulfilled, 1, self._valuesLength)))

			if v3.n == 0 then
				return v2
			end

			if v3.n == 1 and Promise.isPromise(v3[1]) then
				return v3[1]
			end

			local v4 = Promise.new()

			v4:Resolve(table.unpack(v3, 1, v3.n))
			return v4
		end

		if not object then
			return self
		end

		object:_fulfill(self._fulfilled, self._valuesLength)
		return object
	elseif not self._rejected then
		error("Internal error: still pending")
	elseif type(callback2) == "function" then
		if object then
			object:Resolve(callback2(unpack(self._rejected, 1, self._valuesLength)))
			return object
		end

		local v3 = table.pack(callback2(unpack(self._rejected, 1, self._valuesLength)))

		if v3.n == 0 then
			return v2
		end

		if v3.n == 1 and Promise.isPromise(v3[1]) then
			return v3[1]
		end

		local v4 = Promise.new()

		v4:Resolve(table.unpack(v3, 1, v3.n))
		return v4
	else
		if not object then
			return self
		end

		object:_reject(self._rejected, self._valuesLength)

		return object
	end
end

v2 = Promise.new()
v2:_fulfill({}, 0)

v = Promise.new()
v:_reject({}, 0)

return Promise