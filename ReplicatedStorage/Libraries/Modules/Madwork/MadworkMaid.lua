local MadworkMaid = {}

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

local function CleanupTask(connection, ...)
	if type(connection) == "function" then
		connection(...)
	elseif typeof(connection) == "RBXScriptConnection" then
		connection:Disconnect()
	elseif typeof(connection) == "Instance" then
		connection:Destroy()
	elseif type(connection) == "table" then
		if type(connection.Destroy) == "function" then
			connection:Destroy()
		elseif type(connection.Disconnect) == "function" then
			connection:Disconnect()
		end
	end
end

local function PerformCleanupTask(...)
	if not v then
		v = coroutine.create(RunEventHandlerInFreeThread)
	end

	task.spawn(v, CleanupTask, ...)
end

local class = {}

class.__index = class

function class:AddCleanupTask(value)
	if self._is_cleaned == true then
		PerformCleanupTask(value)
		return function() end
	end

	if type(value) == "function" then
		table.insert(self._cleanup_tasks, value)
	elseif typeof(value) == "RBXScriptConnection" then
		table.insert(self._cleanup_tasks, value)
	elseif typeof(value) == "Instance" then
		table.insert(self._cleanup_tasks, value)
	elseif type(value) == "table" then
		if type(value.Destroy) == "function" then
			table.insert(self._cleanup_tasks, value)
		elseif type(value.Disconnect) == "function" then
			table.insert(self._cleanup_tasks, value)
		else
			error("[MadworkMaid]: Received object table as cleanup task, but couldn't detect a :Destroy() method")
		end
	else
		error("[MadworkMaid]: Cleanup task of type \"" .. typeof(value) .. "\" not supported")
	end

	return function(...)
		self:RemoveCleanupTask(value)
		PerformCleanupTask(value, ...)
	end
end

function class:RemoveCleanupTask(p)
	local cleanup_tasks = self._cleanup_tasks
	local index = table.find(cleanup_tasks, p)

	if index ~= nil then
		table.remove(cleanup_tasks, index)
	end
end

function class:CleanupOfOne(p, ...)
	self:RemoveCleanupTask(p)
	PerformCleanupTask(p, ...)
end

function class:Cleanup(...)
	for _, cleanup_task in ipairs(self._cleanup_tasks) do
		PerformCleanupTask(cleanup_task, ...)
	end

	self._cleanup_tasks = {}
	self._is_cleaned = true
end

function MadworkMaid.NewMaid()
	local maid = { _cleanup_tasks = {}, _is_cleaned = false }

	setmetatable(maid, class)
	return maid
end

MadworkMaid.Cleanup = PerformCleanupTask

return MadworkMaid