local module = require("./graph")

local create_node = module.create_node
local create_source_node = module.create_source_node
local assert_stable_scope = module.assert_stable_scope
local evaluate_node = module.evaluate_node
local update_descendants = module.update_descendants
local push_scope_as_child_of = module.push_scope_as_child_of

local v = {
	number = function(p)
		return vector.create(p, 0, 0), Vector3.new(0, 0, 0)
	end,
	CFrame = function(cframe)
		return cframe.Position, (vector.create(cframe:ToEulerAnglesXYZ()))
	end,
	Color3 = function(data)
		return vector.create(data.R, data.G, data.B), Vector3.new(0, 0, 0)
	end,
	UDim = function(p)
		return vector.create(p.Scale, p.Offset, 0), Vector3.new(0, 0, 0)
	end,
	UDim2 = function(p)
		return vector.create(p.X.Scale, p.X.Offset, p.Y.Scale), (vector.create(p.Y.Offset, 0, 0))
	end,
	Vector2 = function(p)
		return vector.create(p.X, p.Y, 0), Vector3.new(0, 0, 0)
	end,
	Vector3 = function(p)
		return p, Vector3.new(0, 0, 0)
	end,
	Rect = function(p)
		return vector.create(p.Min.X, p.Min.Y, p.Max.X), (vector.create(p.Max.Y, 0, 0))
	end,
	table = function(list)
		return vector.create(list[1] or 0, list[2] or 0, list[3] or 0), (vector.create(list[4] or 0, 0, 0))
	end
}

local v2 = {
	number = function(p, _)
		return p.X
	end,
	CFrame = function(position, data)
		return CFrame.new(position) * CFrame.fromEulerAnglesXYZ(data.X, data.Y, data.Z)
	end,
	Color3 = function(data)
		return Color3.new(math.clamp(data.X, 0, 1), math.clamp(data.Y, 0, 1), (math.clamp(data.Z, 0, 1)))
	end,
	UDim = function(p)
		return UDim.new(p.X, (math.round(p.Y)))
	end,
	UDim2 = function(data, p)
		return UDim2.new(data.X, math.round(data.Y), data.Z, (math.round(p.X)))
	end,
	Vector2 = function(p)
		return Vector2.new(p.X, p.Y)
	end,
	Vector3 = function(p)
		return p
	end,
	Rect = function(data, p)
		return Rect.new(data.X, data.Y, data.Z, p.X)
	end,
	table = function(data, p)
		return { data.X, data.Y, data.Z, p.X }
	end
}

local v3 = {
	__index = function(_, p: string)
		error(`cannot spring type {p}`, 0)
	end
}

setmetatable(v, v3)
setmetatable(v2, v3)

local v4 = {}
setmetatable(v4, { __mode = "v" })

local function spring(callback, value: number?, value2: number?)
	local v5 = assert_stable_scope()

	local v6 = 6.283185307179586 / (value or 1)

	local v7 = v6 ^ 2
	local v8 = (value2 or 1) * (2 * v6)

	if v8 > 240 then
		error("spring damping too high, consider reducing damping or increasing period", 0)
	end

	local v9 = {
		k = v7,
		c = v8,
		x0_123 = Vector3.new(0, 0, 0),
		x_123 = Vector3.new(0, 0, 0),
		x1_123 = Vector3.new(0, 0, 0),
		v_123 = Vector3.new(0, 0, 0),
		x0_456 = Vector3.new(0, 0, 0),
		x_456 = Vector3.new(0, 0, 0),
		x1_456 = Vector3.new(0, 0, 0),
		v_456 = Vector3.new(0, 0, 0),
		source_value = false
	}

	local v10 = create_source_node(false)

	local function updater_effect()
		local source_value = callback()
		local v11, v12 = v[typeof(source_value)](source_value)
		v9.x1_123 = v11
		v9.x1_456 = v12
		v9.source_value = source_value
		v4[v9] = v10
		return source_value
	end

	evaluate_node((create_node(v5, updater_effect, false)))

	local x1_123 = v9.x1_123
	local x1_456 = v9.x1_456
	v9.x_123 = x1_123
	v9.x_456 = x1_456

	v10.cache = v9.source_value

	return function(...)
		if select("#", ...) == 0 then
			push_scope_as_child_of(v10)
			return v10.cache
		end

		local cache = ...
		local v11, v12 = v[typeof(cache)](cache)
		v9.x_123 = v11
		v9.x_456 = v12

		v9.v_123 = Vector3.new(0, 0, 0)
		v9.v_456 = Vector3.new(0, 0, 0)

		v4[v9] = v10

		v10.cache = cache

		return cache
	end, function(data)
		local position = data.position
		local velocity = data.velocity
		local impulse = data.impulse

		if position then
			local v11, v12 = v[typeof(position)](position)
			v9.x_123 = v11
			v9.x_456 = v12
			v9.x0_123 = v11
			v9.x0_456 = v12
		end

		if velocity then
			local v11, v12 = v[typeof(velocity)](velocity)
			v9.v_123 = v11
			v9.v_456 = v12
		end

		if impulse then
			local v11, v12 = v[typeof(impulse)](impulse)
			v9.v_123 += v11
			v9.v_456 += v12
		end

		v4[v9] = v10
	end
end

local function get_min_step(p: number) -- 3 equivalent calls inferred from this helper
	return p / 10000
end

local function get_min_vector_step(vector3: Vector3) -- 2 equivalent calls inferred from this helper
	return (vector.create(get_min_step(vector3.x), get_min_step(vector3.y), get_min_step(vector3.z))) -- inferred equivalent call
end

local function step_springs(p: number)
	for k in v4 do
		local k2 = k.k
		local c = k.c
		local x_123 = k.x_123
		local x_456 = k.x_456
		local x1_123 = k.x1_123
		local x1_456 = k.x1_456
		local v_123 = k.v_123
		local v_456 = k.v_456

		local v5 = x_123 - x1_123
		local v6 = x_456 - x1_456

		local v7 = v5 * -k2
		local v8 = v6 * -k2

		local v9 = v_123 * -c
		local v10 = v_456 * -c

		local v11 = v7 + v9
		local v12 = v8 + v10

		local v13 = v_123 + v11 * p
		local v14 = v_456 + v12 * p

		local v15 = x_123 + v13 * p
		local v16 = x_456 + v14 * p

		k.x_123 = v15
		k.x_456 = v16
		k.v_123 = v13
		k.v_456 = v14
	end
end

local function update_spring_sources()
	for k, v5 in v4 do
		local x0_123 = k.x0_123
		local x0_456 = k.x0_456
		local x_123 = k.x_123
		local x_456 = k.x_456
		local x1_123 = k.x1_123
		local x1_456 = k.x1_456
		local v_123 = k.v_123
		local v_456 = k.v_456

		local v6 = vector.abs(get_min_vector_step(x0_123 - x1_123)) -- inferred equivalent call
		local v7 = vector.abs(get_min_vector_step(x0_456 - x1_456)) -- inferred equivalent call

		if
			vector.max(vector.abs(x_123 - x1_123), v6) == v6
			and vector.max(vector.abs(x_456 - x1_456), v7) == v7
			and vector.max(vector.abs(v_123 / 10), v6) == v6
			and vector.max(vector.abs(v_456 / 10), v7) == v7
		then
			v4[k] = nil
			v5.cache = k.source_value
		else
			v5.cache = v2[typeof(k.source_value)](x_123, x_456)
		end

		update_descendants(v5)
	end
end

return function()
	local v5 = 0

	return spring, function(p: number)
		v5 += p

		while v5 > 1 / 120 do
			v5 -= 1 / 120
			step_springs(1 / 120)
		end

		update_spring_sources()
	end
end