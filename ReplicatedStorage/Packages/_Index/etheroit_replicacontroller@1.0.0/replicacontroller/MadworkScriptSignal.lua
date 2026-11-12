local v = nil

local function AcquireRunnerThreadAndCallEventHandler(callback, ...)
	local v2 = v
	v = nil
	callback(...)

	v = v2
end

local function RunEventHandlerInFreeThread(...)
	AcquireRunnerThreadAndCallEventHandler(...)

	while true do
		AcquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local v2 = {
	Disconnect = function(state)
		local listener = state._listener

		if listener ~= nil then
			local listener_table = state._listener_table
			local index = table.find(listener_table, listener)

			if index ~= nil then
				table.remove(listener_table, index)
			end

			state._listener = nil
		end

		if state._disconnect_listener ~= nil then
			if not v then
				v = coroutine.create(RunEventHandlerInFreeThread)
			end

			task.spawn(v, state._disconnect_listener, state._disconnect_param)
			state._disconnect_listener = nil
		end
	end
}
local MadworkScriptSignal = {}

function MadworkScriptSignal.NewArrayScriptConnection(listener_table, listener, disconnect_listener, disconnect_param)
	return {
		_listener = listener,
		_listener_table = listener_table,
		_disconnect_listener = disconnect_listener,
		_disconnect_param = disconnect_param,
		Disconnect = v2.Disconnect
	}
end

local class = {}

class.__index = class

function class:Disconnect()
	if self._is_connected == false then
		return
	end

	self._is_connected = false
	self._script_signal._listener_count -= 1

	if self._script_signal._head == self then
		self._script_signal._head = self._next
	else
		local v3 = self._script_signal._head

		while v3 ~= nil and v3._next ~= self do
			v3 = v3._next
		end

		if v3 ~= nil then
			v3._next = self._next
		end
	end

	if self._disconnect_listener ~= nil then
		if not v then
			v = coroutine.create(RunEventHandlerInFreeThread)
		end

		task.spawn(v, self._disconnect_listener, self._disconnect_param)
		self._disconnect_listener = nil
	end
end

local v3 = {}

v3.__index = v3

function v3:Connect(listener, disconnect_listener, disconnect_param)
	local head = {
		_listener = listener,
		_script_signal = self,
		_disconnect_listener = disconnect_listener,
		_disconnect_param = disconnect_param,
		_next = self._head,
		_is_connected = true
	}

	setmetatable(head, class)

	self._head = head
	self._listener_count += 1

	return head
end

function v3:GetListenerCount()
	return self._listener_count
end

function v3:Fire(...)
	local v4 = self._head

	while v4 ~= nil do
		if v4._is_connected == true then
			if not v then
				v = coroutine.create(RunEventHandlerInFreeThread)
			end

			task.spawn(v, v4._listener, ...)
		end

		v4 = v4._next
	end
end

function v3:FireUntil(callback, ...)
	local v4 = self._head

	while v4 ~= nil do
		if v4._is_connected == true then
			v4._listener(...)

			if callback() ~= true then
				break
			end
		end

		v4 = v4._next
	end
end

function MadworkScriptSignal.NewScriptSignal()
	return {
		_head = nil,
		_listener_count = 0,
		Connect = v3.Connect,
		GetListenerCount = v3.GetListenerCount,
		Fire = v3.Fire,
		FireUntil = v3.FireUntil
	}
end

return MadworkScriptSignal