local function cancellableDelay(duration: number, callback, ...)
	assert(type(duration) == "number", "Bad timeoutInSeconds")
	assert(type(callback) == "function", "Bad func")

	local v = table.pack(...)

	local thread = nil
	task.spawn(function()
		thread = coroutine.running()
		task.wait(duration)
		local v2 = v
		thread = nil
		v = nil
		callback(table.unpack(v2, 1, v2.n))
	end)

	return function()
		if thread then
			coroutine.close(thread)
			thread = nil
			v = nil
		end
	end
end

return cancellableDelay