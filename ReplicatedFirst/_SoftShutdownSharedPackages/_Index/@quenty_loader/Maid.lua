local Maid = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "Maid"
}

function Maid.new()
	return (setmetatable({ _tasks = {} }, Maid))
end

function Maid.isMaid(instance): boolean
	return type(instance) == "table" and instance.ClassName == "Maid"
end

function Maid:__index(p)
	if Maid[p] then
		return Maid[p]
	end

	return self._tasks[p]
end

function Maid:__newindex(p, p2)
	if Maid[p] ~= nil then
		error(("Cannot use '%s' as a Maid key"):format((tostring(p))), 2)
	end

	local tasks = self._tasks
	local task2 = tasks[p]

	if task2 == p2 then
		return
	end

	tasks[p] = p2

	if task2 then
		if type(task2) == "function" then
			task2()
		elseif type(task2) == "thread" then
			local v

			if coroutine.running() ~= task2 then
				v = pcall(function()
					task.cancel(task2)
				end)
			end

			if not v then
				task.defer(function()
					task.cancel(task2)
				end)
			end
		elseif typeof(task2) == "RBXScriptConnection" then
			task2:Disconnect()
		elseif task2.Destroy then
			task2:Destroy()
		end
	end
end

function Maid:Add(p)
	if not p then
		error("Task cannot be false or nil", 2)
	end

	self[#self._tasks + 1] = p

	if type(p) == "table" and not p.Destroy then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return p
end

function Maid:GiveTask(p)
	if not p then
		error("Task cannot be false or nil", 2)
	end

	local v = #self._tasks + 1
	self[v] = p

	if type(p) == "table" and not p.Destroy then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return v
end

function Maid:GivePromise(object)
	if not object:IsPending() then
		return object
	end

	local resolved = object.resolved(object)
	local v = self:GiveTask(resolved)

	resolved:Finally(function()
		self[v] = nil
	end)

	return resolved
end

function Maid:DoCleaning()
	local tasks = self._tasks

	for k, task in pairs(tasks) do
		if typeof(task) ~= "RBXScriptConnection" then
			continue
		end

		tasks[k] = nil
		task:Disconnect()
	end

	local v, connection = next(tasks)

	while connection ~= nil do
		tasks[v] = nil

		if type(connection) == "function" then
			connection()
		elseif type(connection) == "thread" then
			local v2

			if coroutine.running() ~= connection then
				v2 = pcall(function()
					task.cancel(connection)
				end)
			end

			if not v2 then
				local v3 = connection
				task.defer(function()
					task.cancel(v3)
				end)
			end
		elseif typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif connection.Destroy then
			connection:Destroy()
		end

		local v2
		v, v2 = next(tasks)
		connection = v2
	end
end

Maid.Destroy = Maid.DoCleaning

return Maid