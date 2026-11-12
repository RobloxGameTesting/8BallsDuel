local Signal = {}
Signal.__index = Signal

local class = {}
class.__index = class

local v = nil

local function RunHandlerInFreeThread(callback, ...)
	local v2 = v
	v = nil

	callback(...)

	v = v2
end

local function CreateFreeThread()
	v = coroutine.running()

	while true do
		RunHandlerInFreeThread(coroutine.yield())
	end
end

function Signal.new()
	return (setmetatable({ _active = true, _head = nil }, Signal))
end

function Signal.Is(p): boolean
	return typeof(p) == "table" and getmetatable(p) == Signal
end

function Signal:IsActive(): boolean
	return self._active == true
end

function Signal:Connect(handler)
	assert(typeof(handler) == "function", "Must be function")

	if self._active ~= true then
		return (setmetatable({ Connected = false, _node = nil }, class))
	end

	local head = self._head

	local v2 = {
		_signal = self,
		_connection = nil,
		_handler = handler,
		_next = head,
		_prev = nil
	}

	if head ~= nil then
		head._prev = v2
	end

	self._head = v2

	local object = setmetatable({ Connected = true, _node = v2 }, class)

	v2._connection = object

	return object
end

function Signal:ConnectOnce(callback)
	assert(typeof(callback) == "function", "Must be function")

	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
end

function Signal:Wait()
	local thread = coroutine.running()

	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)

	return coroutine.yield()
end

function Signal:Fire(...)
	local v2 = self._head

	while v2 ~= nil do
		if v2._connection ~= nil then
			if v == nil then
				task.spawn(CreateFreeThread)
			end

			task.spawn(v, v2._handler, ...)
		end

		v2 = v2._next
	end
end

function Signal:DisconnectAll()
	local v2 = self._head

	while v2 ~= nil do
		local connection = v2._connection

		if connection ~= nil then
			connection.Connected = false
			connection._node = nil
			v2._connection = nil
		end

		v2 = v2._next
	end

	self._head = nil
end

function Signal:Destroy()
	if self._active ~= true then
		return
	end

	self:DisconnectAll()
	self._active = false
end

function class:Disconnect()
	if self.Connected ~= true then
		return
	end

	self.Connected = false

	local node = self._node
	local prev = node._prev
	local nextNode = node._next

	if nextNode ~= nil then
		nextNode._prev = prev
	end

	if prev == nil then
		node._signal._head = nextNode
	else
		prev._next = nextNode
	end

	node._connection = nil
	self._node = nil
end

class.destroy = class.Disconnect
class.Destroy = class.Disconnect
class.disconnect = class.Disconnect
Signal.destroy = Signal.Destroy
Signal.Disconnect = Signal.Destroy
Signal.disconnect = Signal.Destroy

Signal.connect = Signal.Connect
Signal.wait = Signal.Wait
Signal.fire = Signal.Fire

return Signal