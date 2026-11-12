local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Maid")
local v2 = loaded("Brio")

local BrioUtils = {}

function BrioUtils.clone(object)
	assert(object, "Bad brio")

	if object:IsDead() then
		return v2.DEAD
	end

	local v3 = v2.new(object:GetValue())

	v3:ToMaid():GiveTask(object:GetDiedSignal():Connect(function()
		v3:Kill()
	end))

	return v3
end

function BrioUtils.aliveOnly(items)
	local result = {}

	for _, item in pairs(items) do
		if not item:IsDead() then
			table.insert(result, item)
		end
	end

	return result
end

function BrioUtils.firstAlive(items)
	for _, item in pairs(items) do
		if not item:IsDead() then
			return item
		end
	end

	return nil
end

function BrioUtils.flatten(items)
	local v3 = {}
	local v4 = {}

	for k, item in pairs(items) do
		if v2.isBrio(item) then
			if item:IsDead() then
				return v2.DEAD
			end

			table.insert(v3, item)
			v4[k] = item:GetValue()
		else
			v4[k] = item
		end
	end

	return BrioUtils.first(v3, v4)
end

function BrioUtils.first(items, ...)
	for _, item in pairs(items) do
		if v2.isBrio(item) and item:IsDead() then
			return v2.DEAD
		end
	end

	local maid = v.new()
	local v3 = v2.new(...)

	for _, item in pairs(items) do
		if v2.isBrio(item) then
			maid:GiveTask(item:GetDiedSignal():Connect(function()
				v3:Kill()
			end))
		end
	end

	maid:GiveTask(v3:GetDiedSignal():Connect(function()
		maid:DoCleaning()
	end))

	return v3
end

function BrioUtils.withOtherValues(object, ...)
	assert(object, "Bad brio")

	if object:IsDead() then
		return v2.DEAD
	end

	local v3 = v2.new(...)

	v3:ToMaid():GiveTask(object:GetDiedSignal():Connect(function()
		v3:Kill()
	end))

	return v3
end

function BrioUtils:extend(...)
	if self:IsDead() then
		return v2.DEAD
	end

	local values = self._values
	local v3 = {}

	for i = 1, values.n do
		v3[i] = values[i]
	end

	local v4 = table.pack(...)

	for i = 1, v4.n do
		v3[values.n + i] = v4[i]
	end

	local maid = v.new()
	local v5 = v2.new(unpack(v3, 1, values.n + v4.n))

	maid:GiveTask(self:GetDiedSignal():Connect(function()
		v5:Kill()
	end))

	maid:GiveTask(v5:GetDiedSignal():Connect(function()
		maid:DoCleaning()
	end))

	return v5
end

function BrioUtils:prepend(...)
	if self:IsDead() then
		return v2.DEAD
	end

	local values = self._values

	local v3 = table.pack(...)
	local v4 = {}

	for i = 1, v3.n do
		v4[i] = v3[i]
	end

	for i = 1, values.n do
		v4[v3.n + i] = values[i]
	end

	local maid = v.new()
	local v5 = v2.new(unpack(v4, 1, values.n + v3.n))

	maid:GiveTask(self:GetDiedSignal():Connect(function()
		v5:Kill()
	end))

	maid:GiveTask(v5:GetDiedSignal():Connect(function()
		maid:DoCleaning()
	end))

	return v5
end

function BrioUtils:merge(object)
	assert(v2.isBrio(self), "Not a brio")
	assert(v2.isBrio(object), "Not a brio")

	if self:IsDead() or object:IsDead() then
		return v2.DEAD
	end

	local values = self._values
	local v3 = {}

	for i = 1, values.n do
		v3[i] = values[i]
	end

	local _values = object._values

	for i = 1, _values.n do
		v3[values.n + i] = _values[i]
	end

	local maid = v.new()
	local v4 = v2.new(unpack(v3, 1, values.n + _values.n))

	maid:GiveTask(self:GetDiedSignal():Connect(function()
		v4:Kill()
	end))
	maid:GiveTask(object:GetDiedSignal():Connect(function()
		v4:Kill()
	end))

	maid:GiveTask(v4:GetDiedSignal():Connect(function()
		maid:DoCleaning()
	end))

	return v4
end

return BrioUtils