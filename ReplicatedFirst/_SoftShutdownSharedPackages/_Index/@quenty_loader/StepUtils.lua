local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local StepUtils = {}

function StepUtils.bindToRenderStep(callback)
	return StepUtils.bindToSignal(RunService.RenderStepped, callback)
end

function StepUtils.deferWait()
	local thread = coroutine.running()
	task.defer(task.spawn, thread)
	coroutine.yield()
end

function StepUtils.bindToStepped(callback)
	return StepUtils.bindToSignal(RunService.Stepped, callback)
end

function StepUtils.bindToSignal(object, callback)
	if typeof(object) ~= "RBXScriptSignal" then
		error("signal must be of type RBXScriptSignal")
	end

	if type(callback) ~= "function" then
		error(string.format("update must be of type function, got %q", (type(callback))))
	end

	local connection = nil
	local function disconnect() -- 1 equivalent call inferred from this helper
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	local function connect(...)
		if connection and connection.Connected or not callback(...) or connection and connection.Connected then
			return
		end

		local v = { ... }

		connection = object:Connect(function()
			if not callback(unpack(v)) then
				disconnect() -- inferred equivalent call
			end
		end)
	end

	return connect, disconnect
end

function StepUtils.onceAtRenderPriority(value: number, callback)
	assert(type(value) == "number", "Bad priority")
	assert(type(callback) == "function", "Bad func")

	local v = string.format("StepUtils.onceAtPriority_%s", HttpService:GenerateGUID(false))

	local function cleanup() -- 1 equivalent call inferred from this helper
		RunService:UnbindFromRenderStep(v)
	end

	RunService:BindToRenderStep(v, value, function()
		cleanup() -- inferred equivalent call
		callback()
	end)

	return cleanup
end

function StepUtils.onceAtStepped(onStepped)
	local steppedConnection = RunService.Stepped:Once(onStepped)
	return function()
		steppedConnection:Disconnect()
	end
end

function StepUtils.onceAtRenderStepped(onRenderStepped)
	local renderSteppedConnection = RunService.RenderStepped:Once(onRenderStepped)
	return function()
		renderSteppedConnection:Disconnect()
	end
end

function StepUtils.onceAtEvent(object, callback)
	assert(type(callback) == "function", "Bad func")

	local connection = nil
	local function cleanup() -- 1 equivalent call inferred from this helper
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	connection = object:Connect(function(...)
		cleanup() -- inferred equivalent call
		callback(...)
	end)

	return cleanup
end

return StepUtils