local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Promise")
local v2 = loaded("Signal")
local v3 = loaded("Maid")

local CancelToken = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "CancelToken"
}

CancelToken.__index = CancelToken

function CancelToken.new(callback)
	local object = setmetatable({}, CancelToken)

	assert(type(callback) == "function", "Bad executor")

	object._maid = v3.new()

	object.PromiseCancelled = v.new()
	object.Cancelled = v2.new()

	object.PromiseCancelled:Then(function()
		object.Cancelled:Fire()
		object.Cancelled:Destroy()
	end)

	callback(function()
		object:_cancel()
	end, object._maid)

	return object
end

function CancelToken.isCancelToken(p): boolean
	return type(p) == "table" and getmetatable(p) == CancelToken
end

local function fn() end

function CancelToken:fromMaid()
	local v4 = CancelToken.new(fn)

	local v5 = self:GiveTask(function()
		v4:_cancel()
	end)

	v4.PromiseCancelled:Then(function()
		self[v5] = nil
	end)

	return v4
end

function CancelToken.fromSeconds(duration)
	assert(type(duration) == "number", "Bad seconds")

	return CancelToken.new(function(callback, maid)
		maid:GiveTask(task.delay(duration, callback))
	end)
end

function CancelToken.ErrorIfCancelled(p)
	if not p.PromiseCancelled:IsPending() then
		error("[CancelToken.ErrorIfCancelled] - Cancelled")
	end
end

function CancelToken.IsCancelled(p)
	return p.PromiseCancelled:IsFulfilled()
end

function CancelToken:_cancel()
	self._maid:DoCleaning()
	self.PromiseCancelled:Resolve()
end

return CancelToken