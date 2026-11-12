local _ = {
	RequestDataRepeat = 10,
	SetterError = "[ReplicaController]: Replica setters can only be called inside write functions"
}

local RunService = game:GetService("RunService")

local function WaitForDescendant(instance, childName, p)
	local v = instance:FindFirstChild(childName, true)

	if v ~= nil then
		return v
	end

	local lastTime = os.clock()

	local descendantAddedConnection = instance.DescendantAdded:Connect(function(descendant)
		if descendant.Name == childName then
			v = descendant
		end
	end)

	while v == nil do
		if
			lastTime ~= nil
			and os.clock() - lastTime > 1
			and (RunService:IsServer() == true or game:IsLoaded() == true)
		then
			warn("[" .. script.Name .. "]: Missing " .. p .. " \"" .. childName .. "\" in " .. instance:GetFullName() .. "; Please check setup documentation")
			lastTime = nil
		end

		task.wait()
	end

	descendantAddedConnection:Disconnect()
	return v
end

local replicaRemoteEvents

if RunService:IsServer() == true then
	replicaRemoteEvents = Instance.new("Folder")
	replicaRemoteEvents.Name = "ReplicaRemoteEvents"
	replicaRemoteEvents.Parent = game:GetService("ReplicatedStorage")
else
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	replicaRemoteEvents = WaitForDescendant(ReplicatedStorage, "ReplicaRemoteEvents", "folder")
end

local v = {
	SetupRemoteEvent = function(name)
		if RunService:IsServer() ~= true then
			return WaitForDescendant(replicaRemoteEvents, name, "remote event")
		end

		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = name
		remoteEvent.Parent = replicaRemoteEvents
		return remoteEvent
	end,
	Shared = {}
}

local MadworkScriptSignal = require(script:WaitForChild("MadworkScriptSignal"))
v.NewScriptSignal = MadworkScriptSignal.NewScriptSignal
v.NewArrayScriptConnection = MadworkScriptSignal.NewArrayScriptConnection

local Replicacontroller = {
	NewReplicaSignal = v.NewScriptSignal(),
	InitialDataReceivedSignal = v.NewScriptSignal(),
	InitialDataReceived = false,
	_replicas = {},
	_class_listeners = {},
	_child_listeners = {}
}

local MadworkMaid = require(script:WaitForChild("MadworkMaid"))

local class = nil

local replicas = Replicacontroller._replicas
local newReplicaSignal = Replicacontroller.NewReplicaSignal

local class_listeners = Replicacontroller._class_listeners
local child_listeners = Replicacontroller._child_listeners

local v2 = v.SetupRemoteEvent("Replica_ReplicaRequestData")

local v3 = v.SetupRemoteEvent("Replica_ReplicaSetValue")
local v4 = v.SetupRemoteEvent("Replica_ReplicaSetValues")
local v5 = v.SetupRemoteEvent("Replica_ReplicaArrayInsert")
local v6 = v.SetupRemoteEvent("Replica_ReplicaArraySet")
local v7 = v.SetupRemoteEvent("Replica_ReplicaArrayRemove")
local v8 = v.SetupRemoteEvent("Replica_ReplicaWrite")
local v9 = v.SetupRemoteEvent("Replica_ReplicaSignal")
local v10 = v.SetupRemoteEvent("Replica_ReplicaSetParent")
local v11 = v.SetupRemoteEvent("Replica_ReplicaCreate")
local v12 = v.SetupRemoteEvent("Replica_ReplicaDestroy")

local v13 = false

local v14 = {}

local v15 = false
local function GetWriteLibFunctionsRecursive(list, module, p)
	for k, item in pairs(module) do
		if type(item) == "table" then
			GetWriteLibFunctionsRecursive(list, item, p .. k .. ".")
		elseif type(item) == "function" then
			table.insert(list, { p .. k, item })
		else
			error("[ReplicaController]: Invalid write function value \"" .. tostring(item) .. "\" (" .. typeof(item) .. "); name_stack = \"" .. p .. "\"")
		end
	end
end

local function LoadWriteLib(moduleScript)
	local v16 = v14[moduleScript]

	if v16 ~= nil then
		return v16
	end

	local module = require(moduleScript)

	local v17 = {}

	GetWriteLibFunctionsRecursive(v17, module, "")
	table.sort(v17, function(a, b): boolean
		return a[1] < b[1]
	end)

	local v18 = {}
	local v19 = {}

	for i, v20 in ipairs(v17) do
		v18[i] = v20[2]
		v19[v20[1]] = i
	end

	local v20 = { v18, v19 }

	v14[moduleScript] = v20

	return v20
end

local function StringPathToArray(value)
	local result = {}

	if value ~= "" then
		for k in string.gmatch(value, "[^%.]+") do
			table.insert(result, k)
		end
	end

	return result
end

local function DestroyReplicaAndDescendantsRecursive(replica, p)
	for _, child in ipairs(replica.Children) do
		DestroyReplicaAndDescendantsRecursive(child, true)
	end

	local id = replica.Id

	replicas[id] = nil

	replica._maid:Cleanup()

	if p ~= true and replica.Parent ~= nil then
		local children = replica.Parent.Children
		table.remove(children, table.find(children, replica))
	end

	child_listeners[id] = nil
end

local function CreateTableListenerPathIndex(p, value, p2)
	local tableListenerPathIndexes = p._table_listeners

	for i = 1, #value do
		local v16 = tableListenerPathIndexes[1][value[i]]

		if v16 == nil then
			v16 = { {} }
			tableListenerPathIndexes[1][value[i]] = v16
		end

		tableListenerPathIndexes = v16
	end

	local tableListenerPathIndex = tableListenerPathIndexes[p2]

	if tableListenerPathIndex == nil then
		tableListenerPathIndex = {}
		tableListenerPathIndexes[p2] = tableListenerPathIndex
	end

	return tableListenerPathIndex
end

local function CleanTableListenerTable(list)
	local v16 = list[1]
	local item = list[2]

	local v17 = { v16 }

	for i = 1, #item do
		v16 = v16[1][item[i]]
		table.insert(v17, v16)
	end

	for i = #v17, 2, -1 do
		local v18 = v17[i]

		if next(v18[1]) ~= nil then
			break
		end

		for j = 2, 6 do
			if v18[j] ~= nil and #v18[j] > 0 then
				return
			end
		end

		v17[i - 1][1][item[i - 1]] = nil
	end
end

local function CreateReplicaBranch(items, options)
	local v16 = {}

	for k, item in pairs(items) do
		item[6] = tonumber(k)
		table.insert(v16, item)
	end

	table.sort(v16, function(a, b): boolean
		return a[6] < b[6]
	end)

	local v17 = {}
	local replicaBranch = options or {}

	for _, v18 in ipairs(v16) do
		local id = v18[6]

		local v19 = v18[4]

		local v20 = false
		local parent

		if v19 ~= 0 then
			parent = replicas[v19]

			if parent == nil then
				v20 = true
			end
		end

		local write_lib, write_lib_dictionary

		if v18[5] ~= nil then
			local loadWriteLib = LoadWriteLib(v18[5])
			write_lib = loadWriteLib[1]
			write_lib_dictionary = loadWriteLib[2]
		end

		local parent2 = {
			Data = v18[3],
			Id = id,
			Class = v18[1],
			Tags = v18[2],
			Parent = parent,
			Children = {},
			_write_lib = write_lib,
			_write_lib_dictionary = write_lib_dictionary,
			_table_listeners = { {} },
			_function_listeners = {},
			_raw_listeners = {},
			_signal_listeners = {},
			_maid = MadworkMaid.NewMaid()
		}

		setmetatable(parent2, class)

		if parent == nil then
			if v20 == true then
				local v21 = v17[v19]

				if v21 == nil then
					v21 = {}
					v17[v19] = v21
				end

				table.insert(v21, parent2)
			end
		else
			table.insert(parent.Children, parent2)
		end

		replicas[id] = parent2
		table.insert(replicaBranch, parent2)

		local v21 = v17[id]

		if v21 == nil then
			continue
		end

		v17[id] = nil

		for _, v22 in ipairs(v21) do
			v22.Parent = parent2
			table.insert(parent2.Children, v22)
		end
	end

	if next(v17) == nil then
		return replicaBranch
	end

	local v18 = "[ReplicaService]: BRANCH REPLICATION ERROR - Missing parents: "

	for k, list in pairs(v17) do
		local v19 = v18 .. "[" .. tostring(k) .. "]: {"

		for i, item in ipairs(list) do
			v19 ..= (i == 1 and "" or ", ") .. item:Identify()
		end

		v18 = v19 .. "}; "
	end

	error(v18)

	return replicaBranch
end

local function ReplicaSetValue(id, value, p)
	local replica = replicas[id]

	local v16 = replica.Data
	local v17 = replica._table_listeners

	for i = 1, #value - 1 do
		v16 = v16[value[i]]

		if v17 ~= nil then
			v17 = v17[1][value[i]]
		end
	end

	local item = value[#value]
	local v18 = v16[item]
	v16[item] = p

	if v18 ~= p and v17 ~= nil then
		if v18 == nil and v17[3] ~= nil then
			for _, v19 in ipairs(v17[3]) do
				v19(p, item)
			end
		end

		local v19 = v17[1][value[#value]]

		if v19 ~= nil and v19[2] ~= nil then
			for _, v20 in ipairs(v19[2]) do
				v20(p, v18)
			end
		end
	end

	for _, raw_listener in ipairs(replica._raw_listeners) do
		raw_listener("SetValue", value, p)
	end
end

local function ReplicaSetValues(id, value, items)
	local replica = replicas[id]

	local v16 = replica.Data
	local v17 = replica._table_listeners

	for i = 1, #value do
		v16 = v16[value[i]]

		if v17 ~= nil then
			v17 = v17[1][value[i]]
		end
	end

	for k, item in pairs(items) do
		local v18 = v16[k]
		v16[k] = item

		if not (v18 ~= item and v17 ~= nil) then
			continue
		end

		if v18 == nil and v17[3] ~= nil then
			for _, v19 in ipairs(v17[3]) do
				v19(item, k)
			end
		end

		local v19 = v17[1][k]

		if not (v19 ~= nil and v19[2] ~= nil) then
			continue
		end

		for _, v20 in ipairs(v19[2]) do
			v20(item, v18)
		end
	end

	for _, raw_listener in ipairs(replica._raw_listeners) do
		raw_listener("SetValues", value, items)
	end
end

local function ReplicaArrayInsert(id, value, p)
	local replica = replicas[id]

	local v16 = replica.Data
	local v17 = replica._table_listeners

	for i = 1, #value do
		v16 = v16[value[i]]

		if v17 ~= nil then
			v17 = v17[1][value[i]]
		end
	end

	table.insert(v16, p)

	local count = #v16

	if v17 ~= nil and v17[4] ~= nil then
		for _, v18 in ipairs(v17[4]) do
			v18(count, p)
		end
	end

	for _, raw_listener in ipairs(replica._raw_listeners) do
		raw_listener("ArrayInsert", value, p, count)
	end

	return count
end

local function ReplicaArraySet(id, value, p, p2)
	local replica = replicas[id]

	local v16 = replica.Data
	local v17 = replica._table_listeners

	for i = 1, #value do
		v16 = v16[value[i]]

		if v17 ~= nil then
			v17 = v17[1][value[i]]
		end
	end

	v16[p] = p2

	if v17 ~= nil and v17[5] ~= nil then
		for _, v18 in ipairs(v17[5]) do
			v18(p, p2)
		end
	end

	for _, raw_listener in ipairs(replica._raw_listeners) do
		raw_listener("ArraySet", value, p, p2)
	end
end

local function ReplicaArrayRemove(id, value, p)
	local replica = replicas[id]

	local v16 = replica.Data
	local v17 = replica._table_listeners

	for i = 1, #value do
		v16 = v16[value[i]]

		if v17 ~= nil then
			v17 = v17[1][value[i]]
		end
	end

	local v18 = table.remove(v16, p)

	if v17 ~= nil and v17[6] ~= nil then
		for _, v19 in ipairs(v17[6]) do
			v19(p, v18)
		end
	end

	for _, raw_listener in ipairs(replica._raw_listeners) do
		raw_listener("ArrayRemove", value, p, v18)
	end

	return v18
end

class = {}
class.__index = class

function class:ListenToChange(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToChange()")
	end

	value = type(value) == "string" and StringPathToArray(value) or value

	if #value < 1 then
		error("[ReplicaController]: Passed empty path - a value key must be specified")
	end

	local callbacks = CreateTableListenerPathIndex(self, value, 2)
	table.insert(callbacks, callback)

	return v.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToNewKey(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToNewKey()")
	end

	value = type(value) == "string" and StringPathToArray(value) or value

	local callbacks = CreateTableListenerPathIndex(self, value, 3)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v.NewArrayScriptConnection(callbacks, callback)
	end

	return v.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToArrayInsert(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToArrayInsert()")
	end

	value = type(value) == "string" and StringPathToArray(value) or value

	local callbacks = CreateTableListenerPathIndex(self, value, 4)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v.NewArrayScriptConnection(callbacks, callback)
	end

	return v.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToArraySet(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToArraySet()")
	end

	value = type(value) == "string" and StringPathToArray(value) or value

	local callbacks = CreateTableListenerPathIndex(self, value, 5)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v.NewArrayScriptConnection(callbacks, callback)
	end

	return v.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToArrayRemove(value, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToArrayRemove()")
	end

	value = type(value) == "string" and StringPathToArray(value) or value

	local callbacks = CreateTableListenerPathIndex(self, value, 6)
	table.insert(callbacks, callback)

	if #value == 0 then
		return v.NewArrayScriptConnection(callbacks, callback)
	end

	return v.NewArrayScriptConnection(callbacks, callback, CleanTableListenerTable, { self._table_listeners, value })
end

function class:ListenToWrite(p, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in Replica:ListenToWrite()")
	end

	if self._write_lib == nil then
		error("[ReplicaController]: _write_lib was not declared for this replica")
	end

	local v16 = self._write_lib_dictionary[p]

	if v16 == nil then
		error("[ReplicaController]: Write function \"" .. p .. "\" not declared inside _write_lib of this replica")
	end

	local callbacks = self._function_listeners[v16]

	if callbacks == nil then
		callbacks = {}
		self._function_listeners[v16] = callbacks
	end

	table.insert(callbacks, callback)

	return v.NewArrayScriptConnection(callbacks, callback)
end

function class:ListenToRaw(p)
	local raw_listeners = self._raw_listeners
	table.insert(raw_listeners, p)
	return v.NewArrayScriptConnection(raw_listeners, p)
end

function class:ConnectOnClientEvent(callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only functions can be passed to Replica:ConnectOnClientEvent()")
	end

	table.insert(self._signal_listeners, callback)
	return v.NewArrayScriptConnection(self._signal_listeners, callback)
end

function class:FireServer(...)
	v9:FireServer(self.Id, ...)
end

function class.ListenToChildAdded(p, callback)
	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener")
	end

	if replicas[p.Id] == nil then
		return
	end

	local callbacks = child_listeners[p.Id]

	if callbacks == nil then
		callbacks = {}
		child_listeners[p.Id] = callbacks
	end

	table.insert(callbacks, callback)

	return v.NewArrayScriptConnection(callbacks, callback)
end

function class.FindFirstChildOfClass(p, p2)
	for _, child in ipairs(p.Children) do
		if child.Class == p2 then
			return child
		end
	end

	return nil
end

function class:Identify()
	local v16 = ""

	for k, tag in pairs(self.Tags) do
		v16 ..= "" .. tostring(k) .. "=" .. tostring(tag)
	end

	return "[Id:" .. tostring(self.Id) .. ";Class:" .. self.Class .. ";Tags:{" .. v16 .. "}]"
end

function class.IsActive(p): boolean
	return replicas[p.Id] ~= nil
end

function class:AddCleanupTask(p)
	return self._maid:AddCleanupTask(p)
end

function class:RemoveCleanupTask(p)
	self._maid:RemoveCleanupTask(p)
end

function class.SetValue(p, value, p2)
	if v15 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	value = type(value) == "string" and StringPathToArray(value) or value
	ReplicaSetValue(p.Id, value, p2)
end

function class.SetValues(p, value, p2)
	if v15 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	value = type(value) == "string" and StringPathToArray(value) or value
	ReplicaSetValues(p.Id, value, p2)
end

function class.ArrayInsert(p, value, p2)
	if v15 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	value = type(value) == "string" and StringPathToArray(value) or value
	return ReplicaArrayInsert(p.Id, value, p2)
end

function class.ArraySet(p, value, p2, p3)
	if v15 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	value = type(value) == "string" and StringPathToArray(value) or value
	ReplicaArraySet(p.Id, value, p2, p3)
end

function class.ArrayRemove(p, value, p2)
	if v15 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	value = type(value) == "string" and StringPathToArray(value) or value
	return ReplicaArrayRemove(p.Id, value, p2)
end

function class:Write(p, ...)
	if v15 == false then
		error("[ReplicaController]: Replica setters can only be called inside write functions")
	end

	local v16 = self._write_lib_dictionary[p]
	local v17 = table.pack(self._write_lib[v16](self, ...))

	local function_listener = self._function_listeners[v16]

	if function_listener ~= nil then
		for _, v18 in ipairs(function_listener) do
			v18(...)
		end
	end

	return table.unpack(v17)
end

function Replicacontroller.RequestData()
	if v13 == true then
		return
	end

	v13 = true
	task.spawn(function()
		while game:IsLoaded() == false do
			task.wait()
		end

		v2:FireServer()

		while task.wait(10) and Replicacontroller.InitialDataReceived ~= true do
			v2:FireServer()
		end
	end)
end

function Replicacontroller.ReplicaOfClassCreated(value, callback)
	if type(value) ~= "string" then
		error("[ReplicaController]: replica_class must be a string")
	end

	if type(callback) ~= "function" then
		error("[ReplicaController]: Only a function can be set as listener in ReplicaController.ReplicaOfClassCreated()")
	end

	local v16 = class_listeners[value]

	if v16 == nil then
		v16 = v.NewScriptSignal()
		class_listeners[value] = v16
	end

	return v16:Connect(callback, function()
		if v16:GetListenerCount() == 0 and class_listeners[value] == v16 then
			class_listeners[value] = nil
		end
	end)
end

function Replicacontroller.GetReplicaById(p)
	return replicas[p]
end

v2.OnClientEvent:Connect(function()
	Replicacontroller.InitialDataReceived = true
	print("[ReplicaController]: Initial data received")
	Replicacontroller.InitialDataReceivedSignal:Fire()
end)

v3.OnClientEvent:Connect(ReplicaSetValue)

v4.OnClientEvent:Connect(ReplicaSetValues)

v5.OnClientEvent:Connect(ReplicaArrayInsert)

v6.OnClientEvent:Connect(ReplicaArraySet)

v7.OnClientEvent:Connect(ReplicaArrayRemove)

v8.OnClientEvent:Connect(function(p, p2, ...)
	local replica = replicas[p]

	v15 = true
	replica._write_lib[p2](replica, ...)
	v15 = false

	local function_listener = replica._function_listeners[p2]

	if function_listener ~= nil then
		for _, v16 in ipairs(function_listener) do
			v16(...)
		end
	end
end)

v9.OnClientEvent:Connect(function(p, ...)
	local signal_listeners = replicas[p]._signal_listeners

	for _, signal_listener in ipairs(signal_listeners) do
		signal_listener(...)
	end
end)

v10.OnClientEvent:Connect(function(p, p2)
	local replica = replicas[p]
	local children = replica.Parent.Children
	local replica2 = replicas[p2]
	table.remove(children, table.find(children, replica))
	table.insert(replica2.Children, replica)
	replica.Parent = replica2

	local child_listener = child_listeners[p2]

	if child_listener ~= nil then
		for i = 1, #child_listener do
			child_listener[i](replica)
		end
	end
end)

v11.OnClientEvent:Connect(function(list, list2)
	local v16 = {}

	if type(list) == "table" then
		table.sort(list, function(a, b): boolean
			return a[1] < b[1]
		end)

		for _, item in ipairs(list) do
			CreateReplicaBranch(item[2], v16)
		end
	elseif list2[1] == nil then
		CreateReplicaBranch(list2, v16)
	else
		CreateReplicaBranch({ [tostring(list)] = list2 }, v16)
	end

	table.sort(v16, function(a, b): boolean
		return a.Id < b.Id
	end)

	for _, v17 in ipairs(v16) do
		local parent = v17.Parent

		if parent == nil then
			continue
		end

		local child_listener = child_listeners[parent.Id]

		if child_listener == nil then
			continue
		end

		for i = 1, #child_listener do
			child_listener[i](v17)
		end
	end

	for _, v17 in ipairs(v16) do
		newReplicaSignal:Fire(v17)
		local class_listener = class_listeners[v17.Class]

		if class_listener ~= nil then
			class_listener:Fire(v17)
		end
	end
end)

v12.OnClientEvent:Connect(function(p)
	DestroyReplicaAndDescendantsRecursive(replicas[p])
end)

return Replicacontroller