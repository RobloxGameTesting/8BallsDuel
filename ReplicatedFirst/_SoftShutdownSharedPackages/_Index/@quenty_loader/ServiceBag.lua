local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Signal")
local v2 = loaded("BaseObject")

local object = setmetatable({}, v2)
object.ClassName = "ServiceBag"
object.__index = object

function object.new(parentProvider)
	local self = setmetatable(v2.new(), object)

	self._services = {}
	self._parentProvider = parentProvider

	self._serviceTypesToInitializeSet = {}
	self._initializedServiceTypeSet = {}
	self._initializing = false
	self._destructing = false

	self._serviceTypesToStart = {}

	self._destroyingSignal = v.new()

	return self
end

function object.isServiceBag(instance): boolean
	return type(instance) == "table" and instance.ClassName == "ServiceBag"
end

function object:GetService(value)
	if typeof(value) == "Instance" then
		value = loaded(value)
	end

	assert(type(value) == "table", "Bad serviceType definition")

	if self._services[value] then
		self:_ensureInitialization(value)
		return self._services[value]
	end

	if self._parentProvider then
		return self._parentProvider:GetService(value)
	end

	self:_addServiceType(value)
	self:_ensureInitialization(value)
	return self._services[value]
end

function object:HasService(instance): boolean
	if typeof(instance) == "Instance" then
		instance = loaded(instance)
	end

	return if self._services[instance] then true else false
end

function object:Init()
	assert(not self._initializing, "Already initializing")
	assert(self._serviceTypesToInitializeSet, "Already initialized")
	self._initializing = true

	while next(self._serviceTypesToInitializeSet) do
		local v3 = next(self._serviceTypesToInitializeSet)
		self._serviceTypesToInitializeSet[v3] = nil

		self:_ensureInitialization(v3)
	end

	self._serviceTypesToInitializeSet = nil
	self._initializing = false
end

function object:Start()
	assert(self._serviceTypesToStart, "Already started")
	assert(not self._initializing, "Still initializing")

	while next(self._serviceTypesToStart) do
		local v3 = table.remove(self._serviceTypesToStart)
		local v4 = assert(self._services[v3], "No service")
		local serviceName = self:_getServiceName(v3)

		if not v4.Start then
			continue
		end

		local thread = nil
		task.spawn(function()
			debug.setmemorycategory(serviceName)
			thread = coroutine.running()
			v4:Start()
		end)

		if coroutine.status(thread) ~= "dead" then
			error(string.format("Starting service %q yielded", serviceName))
		end
	end

	self._serviceTypesToStart = nil
end

function object:_getServiceName(p)
	local serviceName = nil
	pcall(function()
		serviceName = p.ServiceName
	end)

	if type(serviceName) == "string" then
		return serviceName
	end

	return (tostring(p))
end

function object:IsStarted(): boolean
	return self._serviceTypesToStart == nil
end

function object:CreateScope()
	local scope = object.new(self)

	self:_addServiceType(scope)

	self._maid[scope] = scope._destroyingSignal:Connect(function()
		self._maid[scope] = nil
		self._services[scope] = nil
	end)

	return scope
end

function object:_addServiceType(p)
	if self._destructing then
		local serviceName = self:_getServiceName(p)
		error(string.format("Cannot query service %q after ServiceBag is cleaned up", serviceName))
	else
		if not self._serviceTypesToInitializeSet then
			error(string.format("Already finished initializing, cannot add %q", self:_getServiceName(p)))
			return
		end

		if self._services[p] then
			return
		end

		local object2 = setmetatable({}, { __index = p })
		self._services[p] = object2

		self:_ensureInitialization(p)
	end
end

function object:_ensureInitialization(p)
	if self._initializedServiceTypeSet[p] then
		return
	end

	if self._destructing then
		local serviceName = self:_getServiceName(p)
		error(string.format("Cannot initialize service %q after ServiceBag is cleaned up", serviceName))
	elseif self._initializing then
		self._serviceTypesToInitializeSet[p] = nil
		self._initializedServiceTypeSet[p] = true
		self:_initService(p)
	else
		if self._serviceTypesToInitializeSet then
			self._serviceTypesToInitializeSet[p] = true
			return
		end

		local serviceName = self:_getServiceName(p)
		error(string.format("Cannot initialize service %q past initializing phase", serviceName))
	end
end

function object:_initService(p)
	local v3 = assert(self._services[p], "No service")
	local serviceName = self:_getServiceName(p)

	if v3.Init then
		local thread = nil
		task.spawn(function()
			debug.setmemorycategory(serviceName)
			thread = coroutine.running()
			v3:Init(self)
		end)

		if coroutine.status(thread) ~= "dead" then
			error(string.format("Initializing service %q yielded", serviceName))
		end
	end

	table.insert(self._serviceTypesToStart, p)
end

function object:Destroy()
	if self._destructing then
		return
	end

	local metatable = getmetatable(object)

	self._destructing = true

	self._destroyingSignal:Fire()
	self._destroyingSignal:Destroy()

	local services = self._services
	local v3, v4 = next(services)

	while v4 ~= nil do
		services[v3] = nil

		if not (self._serviceTypesToInitializeSet and self._serviceTypesToInitializeSet[v3]) then
			task.spawn(function()
				if v4.Destroy then
					v4:Destroy()
				end
			end)
		end

		local v5
		v3, v5 = next(services)
		v4 = v5
	end

	metatable.Destroy(self)
end

return object