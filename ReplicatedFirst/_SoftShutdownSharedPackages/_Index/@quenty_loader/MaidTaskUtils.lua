local MaidTaskUtils = {}

function MaidTaskUtils.isValidTask(value): boolean
	return type(value) == "function"
		or type(value) == "thread"
		or typeof(value) == "RBXScriptConnection"
		or type(value) == "table" and type(value.Destroy) == "function"
		or typeof(value) == "Instance"
end

function MaidTaskUtils.doTask(connection)
	if type(connection) == "function" then
		connection()
	elseif type(connection) == "thread" then
		local v

		if coroutine.running() ~= connection then
			v = pcall(function()
				task.cancel(connection)
			end)
		end

		if not v then
			task.defer(function()
				task.cancel(connection)
			end)
		end
	elseif typeof(connection) == "RBXScriptConnection" then
		connection:Disconnect()
	elseif type(connection) == "table" and type(connection.Destroy) == "function" then
		connection:Destroy()
	elseif typeof(connection) == "Instance" then
		connection:Destroy()
	else
		error("Bad job")
	end
end

function MaidTaskUtils.delayed(duration, p)
	assert(type(duration) == "number", "Bad time")
	assert(MaidTaskUtils.isValidTask(p), "Bad job")

	return function()
		task.delay(duration, function()
			MaidTaskUtils.doTask(p)
		end)
	end
end

return MaidTaskUtils