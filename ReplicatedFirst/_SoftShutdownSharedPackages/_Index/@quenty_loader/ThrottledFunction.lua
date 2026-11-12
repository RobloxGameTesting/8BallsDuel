local ThrottledFunction = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "ThrottledFunction"
}

ThrottledFunction.__index = ThrottledFunction

function ThrottledFunction.new(p, p2, p3)
	local self = setmetatable({}, ThrottledFunction)

	self._nextCallTimeStamp = 0
	self._timeout = p or error("No timeoutInSeconds")
	self._func = p2 or error("No func")

	self._trailingValue = nil

	self._callLeading = true
	self._callTrailing = true

	self:_configureOrError(p3)

	return self
end

function ThrottledFunction:Call(...)
	if self._trailingValue then
		self._trailingValue = table.pack(...)
	elseif self._nextCallTimeStamp <= tick() then
		if self._callLeading or self._callLeadingFirstTime then
			self._callLeadingFirstTime = false

			self._nextCallTimeStamp = tick() + self._timeout
			self._func(...)
		else
			if not self._callTrailing then
				error("[ThrottledFunction.Cleanup] - Trailing and leading are both disabled")
				return
			end

			self._trailingValue = table.pack(...)
			task.delay(self._timeout, function()
				if self.Destroy then
					self:_dispatch()
				end
			end)
		end
	elseif self._callLeading or self._callTrailing or self._callLeadingFirstTime then
		self._callLeadingFirstTime = false

		local v = self._nextCallTimeStamp - tick()
		self._trailingValue = table.pack(...)

		task.delay(v, function()
			if self.Destroy then
				self:_dispatch()
			end
		end)
	end
end

function ThrottledFunction:_dispatch()
	self._nextCallTimeStamp = tick() + self._timeout

	local trailingValue = self._trailingValue

	if trailingValue then
		self._trailingValue = nil
		self._func(unpack(trailingValue, 1, trailingValue.n))
	end
end

function ThrottledFunction:_configureOrError(items)
	if items == nil then
		return
	end

	assert(type(items) == "table", "Bad throttleConfig")

	for k, item in pairs(items) do
		assert(type(item) == "boolean", "Bad throttleConfig entry")

		if k == "leading" then
			self._callLeading = item
		elseif k == "trailing" then
			self._callTrailing = item
		elseif k == "leadingFirstTimeOnly" then
			self._callLeadingFirstTime = item
		else
			error(("Bad key %q in config"):format((tostring(k))))
		end
	end

	assert(self._callLeading or self._callTrailing, "Cannot configure both leading and trailing disabled")
end

function ThrottledFunction:Destroy()
	self._trailingValue = nil
	self._func = nil
	setmetatable(self, nil)
end

return ThrottledFunction