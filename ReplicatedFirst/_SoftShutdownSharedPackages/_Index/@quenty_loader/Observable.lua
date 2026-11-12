local loader = require(script.Parent.loader)
local v = loader.load(script)("Subscription")

local Observable = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "Observable"
}

Observable.__index = Observable

function Observable.isObservable(instance): boolean
	return type(instance) == "table" and instance.ClassName == "Observable"
end

function Observable.new(onSubscribe)
	assert(type(onSubscribe) == "function", "Bad onSubscribe")

	return (setmetatable({ _source = "", _onSubscribe = onSubscribe }, Observable))
end

function Observable.Pipe(p, items)
	assert(type(items) == "table", "Bad transformers")

	for _, item in pairs(items) do
		assert(type(item) == "function", "Bad transformer")
		p = item(p)
		assert(Observable.isObservable(p), "Transformer must return an observable")
	end

	return p
end

function Observable:Subscribe(p, p2, p3)
	local v2 = v.new(p, p2, p3)
	local v3 = self._onSubscribe(v2)

	if v3 then
		v2:_giveCleanup(v3)
	end

	return v2
end

return Observable