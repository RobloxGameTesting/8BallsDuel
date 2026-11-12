local loader = require(script.Parent.loader)
local v = loader.load(script)("MaidTaskUtils")

local Subscription = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "Subscription"
}

Subscription.__index = Subscription

local _ = { PENDING = "pending", FAILED = "failed", COMPLETE = "complete", CANCELLED = "cancelled" }

function Subscription.new(fireCallback, callback, callback2)
	assert(type(fireCallback) == "function" or fireCallback == nil, "Bad fireCallback")
	assert(type(callback) == "function" or callback == nil, "Bad failCallback")
	assert(type(callback2) == "function" or callback2 == nil, "Bad completeCallback")

	return (setmetatable({
		_state = "pending",
		_source = "",
		_fireCallback = fireCallback,
		_failCallback = callback,
		_completeCallback = callback2
	}, Subscription))
end

function Subscription:Fire(...)
	if self._state == "pending" then
		if self._fireCallback then
			self._fireCallback(...)
		end
	elseif self._state == "cancelled" then
		warn("[Subscription.Fire] - We are cancelled, but events are still being pushed")
	end
end

function Subscription:Fail()
	if self._state ~= "pending" then
		return
	end

	self._state = "failed"

	if self._failCallback then
		self._failCallback()
	end

	self:_doCleanup()
end

function Subscription:GetFireFailComplete()
	return function(...)
		self:Fire(...)
	end, function(...)
		self:Fail(...)
	end, function(...)
		self:Complete(...)
	end
end

function Subscription:GetFailComplete()
	return function(...)
		self:Fail(...)
	end, function(...)
		self:Complete(...)
	end
end

function Subscription:Complete()
	if self._state ~= "pending" then
		return
	end

	self._state = "complete"

	if self._completeCallback then
		self._completeCallback()
	end

	self:_doCleanup()
end

function Subscription:IsPending(): boolean
	return self._state == "pending"
end

function Subscription:_giveCleanup(cleanupTask)
	assert(cleanupTask, "Bad task")
	assert(not self._cleanupTask, "Already have _cleanupTask")

	if self._state == "pending" then
		self._cleanupTask = cleanupTask
	else
		v.doTask(cleanupTask)
	end
end

function Subscription:_doCleanup()
	if self._cleanupTask then
		local cleanupTask = self._cleanupTask
		self._cleanupTask = nil
		v.doTask(cleanupTask)
	end
end

function Subscription:Destroy()
	if self._state == "pending" then
		self._state = "cancelled"
	end

	self:_doCleanup()
end

function Subscription:Disconnect()
	self:Destroy()
end

return Subscription