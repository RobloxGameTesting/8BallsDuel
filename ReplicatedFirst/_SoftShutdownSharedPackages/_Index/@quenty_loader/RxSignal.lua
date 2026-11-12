local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Rx")
local v2 = loaded("Observable")

local RxSignal = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "RxSignal"
}

RxSignal.__index = RxSignal

function RxSignal.new(observable)
	assert(observable, "No observable")

	local self = setmetatable({}, RxSignal)

	self._observable = observable

	return self
end

function RxSignal:Connect(p)
	return self:_getObservable():Subscribe(p)
end

function RxSignal:_getObservable()
	if v2.isObservable(self._observable) then
		return self._observable
	end

	if type(self._observable) ~= "function" then
		error("Could not convert self._observable to observable")

		return
	end

	local observable = self._observable()

	assert(v2.isObservable(observable), "Result should be observable")

	return observable
end

function RxSignal:Once(p)
	return self:_getObservable():Pipe({ v.take(1) }):Subscribe(p)
end

return RxSignal