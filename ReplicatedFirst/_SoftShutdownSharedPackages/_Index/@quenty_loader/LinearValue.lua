local LinearValue = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "LinearValue"
}

LinearValue.__index = LinearValue

function LinearValue.new(constructor, values)
	return (setmetatable({ _constructor = constructor, _values = values }, LinearValue))
end

function LinearValue.isLinear(p): boolean
	return type(p) == "table" and getmetatable(p) == LinearValue
end

function LinearValue:ToBaseValue()
	return self._constructor(unpack(self._values))
end

local function operation(fn) -- 3 equivalent calls inferred from this helper
	return function(value, value2)
		if LinearValue.isLinear(value) and LinearValue.isLinear(value2) then
			assert(value._constructor == value2._constructor, "a is not the same type of linearValue as b")

			local v = {}

			for i = 1, #value._values do
				v[i] = fn(value._values[i], value2._values[i])
			end

			return LinearValue.new(value._constructor, v)
		elseif LinearValue.isLinear(value) then
			if type(value2) ~= "number" then
				error("Bad type (b)")
				return
			end

			local v = {}

			for i = 1, #value._values do
				v[i] = fn(value._values[i], value2)
			end

			return LinearValue.new(value._constructor, v)
		else
			if not LinearValue.isLinear(value2) then
				error("Neither value is a linearValue")

				return
			end

			if type(value) ~= "number" then
				error("Bad type (a)")
				return
			end

			local v = {}

			for i = 1, #value2._values do
				v[i] = fn(value, value2._values[i])
			end

			return LinearValue.new(value2._constructor, v)
		end
	end
end

function LinearValue:GetMagnitude()
	local total = 0

	for i = 1, #self._values do
		local value = self._values[i]
		total += value * value
	end

	return (math.sqrt(total))
end

function LinearValue:__index(p)
	if LinearValue[p] then
		return LinearValue[p]
	end

	if p == "magnitude" then
		return self:GetMagnitude()
	end

	return nil
end

local function fn(p, p2)
	return p + p2
end

function LinearValue:__add(value)
	if LinearValue.isLinear(self) and LinearValue.isLinear(value) then
		assert(self._constructor == value._constructor, "a is not the same type of linearValue as b")

		local v = {}

		for i = 1, #self._values do
			v[i] = fn(self._values[i], value._values[i])
		end

		return LinearValue.new(self._constructor, v)
	elseif LinearValue.isLinear(self) then
		if type(value) ~= "number" then
			error("Bad type (b)")
			return
		end

		local v = {}

		for i = 1, #self._values do
			v[i] = fn(self._values[i], value)
		end

		return LinearValue.new(self._constructor, v)
	else
		if not LinearValue.isLinear(value) then
			error("Neither value is a linearValue")

			return
		end

		if type(self) ~= "number" then
			error("Bad type (a)")
			return
		end

		local v = {}

		for i = 1, #value._values do
			v[i] = fn(self, value._values[i])
		end

		return LinearValue.new(value._constructor, v)
	end
end

local function fn2(p, p2)
	return p - p2
end

LinearValue.__sub = operation(fn2) -- inferred equivalent call

local function fn3(p, p2)
	return p * p2
end

LinearValue.__mul = operation(fn3) -- inferred equivalent call

local function fn4(p, p2)
	return p / p2
end

LinearValue.__div = operation(fn4) -- inferred equivalent call

function LinearValue.__eq(_, p, p2): boolean
	if not (LinearValue.isLinear(p) and LinearValue.isLinear(p2) and #p._values == #p2._values) then
		return false
	end

	for i = 1, #p._values do
		if p._values[i] ~= p2._values[i] then
			return false
		end
	end

	return true
end

return LinearValue