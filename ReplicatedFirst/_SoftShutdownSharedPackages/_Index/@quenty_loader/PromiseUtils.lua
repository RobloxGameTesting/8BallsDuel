local loader = require(script.Parent.loader)
local v = loader.load(script)("Promise")
local PromiseUtils = {}

function PromiseUtils.any(items)
	local v2 = v.new()

	local function resolve(...)
		v2:Resolve(...)
	end

	local function reject(...)
		v2:Reject(...)
	end

	for _, item in pairs(items) do
		item:Then(resolve, reject)
	end

	return v2
end

function PromiseUtils.delayed(value)
	assert(type(value) == "number", "Bad seconds")

	return v.delay(value, function(callback, _)
		callback()
	end)
end

function PromiseUtils.all(list)
	if #list == 0 then
		return v.resolved()
	end

	if #list == 1 then
		return list[1]
	end

	local count = #list
	local v2 = v.new()
	local v3 = {}
	local v4 = true

	local function syncronize(k, p) -- 2 equivalent calls inferred from this helper
		return function(p2)
			v4 = v4 and p
			v3[k] = p2
			count -= 1

			if count == 0 then
				v2[v4 and "Resolve" or "Reject"](v2, unpack(v3, 1, #list))
			end
		end
	end

	for k, item in pairs(list) do
		item:Then(syncronize(k, true), syncronize(k, false)) -- inferred equivalent call
	end

	return v2
end

function PromiseUtils.combine(items)
	assert(type(items) == "table", "Bad stateTable")
	local v2 = 0
	local v3 = {}

	for k, item in pairs(items) do
		if v.isPromise(item) then
			v2 += 1
		else
			v3[k] = item
		end
	end

	if v2 == 0 then
		return v.resolved(items)
	end

	local v4 = v.new()
	local v5 = true

	local function syncronize(k, p) -- 2 equivalent calls inferred from this helper
		return function(p2)
			v5 = v5 and p
			v3[k] = p2
			v2 -= 1

			if v2 == 0 then
				v4[v5 and "Resolve" or "Reject"](v4, v3)
			end
		end
	end

	for k, item in pairs(items) do
		if v.isPromise(item) then
			item:Then(syncronize(k, true), syncronize(k, false)) -- inferred equivalent call
		end
	end

	return v4
end

function PromiseUtils.invert(object)
	if object:IsPending() then
		return object:Then(function(...)
			return v.rejected(...)
		end, function(...)
			return v.resolved(...)
		end)
	end

	local v2 = { object:GetResults() }

	if v2[1] then
		return v.rejected(unpack(v2, 2))
	end

	return v.resolved(unpack(v2, 2))
end

function PromiseUtils.fromSignal(object)
	local v2 = v.new()
	local connection = nil

	v2:Finally(function()
		connection:Disconnect()
		connection = nil
	end)

	connection = object:Connect(function(...)
		v2:Resolve(...)
	end)

	return v2
end

function PromiseUtils.timeout(duration, object)
	assert(type(duration) == "number", "Bad timeoutTime")
	assert(object, "Bad fromPromise")

	if not object:IsPending() then
		return object
	end

	local v2 = v.new()

	v2:Resolve(object)

	task.delay(duration, function()
		v2:Reject()
	end)

	return v2
end

return PromiseUtils