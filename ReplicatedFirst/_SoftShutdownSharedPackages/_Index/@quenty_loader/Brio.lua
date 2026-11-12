local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Maid")
local v2 = loaded("GoodSignal")

local Brio = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "Brio"
}

Brio.__index = Brio

function Brio.isBrio(instance): boolean
	return type(instance) == "table" and instance.ClassName == "Brio"
end

function Brio.new(...)
	return (setmetatable({
		_values = table.pack(...)
	}, Brio))
end

function Brio.delayed(duration, ...)
	local v3 = Brio.new(...)
	task.delay(duration, function()
		v3:Kill()
	end)
	return v3
end

function Brio:GetDiedSignal()
	if self:IsDead() then
		error("Brio is dead")
	end

	if self._diedEvent then
		return self._diedEvent
	end

	self._diedEvent = v2.new()
	return self._diedEvent
end

function Brio:IsDead(): boolean
	return self._values == nil
end

function Brio:ErrorIfDead()
	if not self._values then
		error("[Brio.ErrorIfDead] - Brio is dead")
	end
end

function Brio:ToMaid()
	assert(self._values ~= nil, "Brio is dead")

	local maid = v.new()

	maid:GiveTask(self:GetDiedSignal():Connect(function()
		maid:DoCleaning()
	end))

	return maid
end

function Brio:ToMaidAndValue()
	return self:ToMaid(), self:GetValue()
end

function Brio:GetValue()
	assert(self._values, "Brio is dead")

	return unpack(self._values, 1, self._values.n)
end

function Brio:GetPackedValues()
	assert(self._values, "Brio is dead")

	return self._values
end

function Brio:Destroy()
	if not self._values then
		return
	end

	self._values = nil

	if self._diedEvent then
		self._diedEvent:Fire()
		self._diedEvent:Destroy()
		self._diedEvent = nil
	end
end

Brio.Kill = Brio.Destroy

Brio.DEAD = Brio.new()
Brio.DEAD:Kill()

return Brio