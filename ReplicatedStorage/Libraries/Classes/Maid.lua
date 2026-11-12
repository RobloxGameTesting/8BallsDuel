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
		error(("'%s' is reserved"):format((tostring(p))), 2)
	end

	local tasks = self._tasks
	local task = tasks[p]

	if task == p2 then
		return
	end

	tasks[p] = p2

	if task then
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
	end
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
		elseif typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif connection.Destroy then
			connection:Destroy()
		end

		v, connection = next(tasks)
	end
end

Maid.Destroy = Maid.DoCleaning

return Maid