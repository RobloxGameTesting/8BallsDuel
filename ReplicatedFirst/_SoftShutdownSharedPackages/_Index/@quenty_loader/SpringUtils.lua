local loader = require(script.Parent.loader)
local v = loader.load(script)("LinearValue")
local SpringUtils = {}

function SpringUtils.animating(data, value)
	value = value or 1e-6

	local position = data.Position
	local target = data.Target

	local v2 = nil

	if type(target) == "number" then
		v2 = value < math.abs(data.Position - data.Target) or value < math.abs(data.Velocity)
	else
		local typeName = typeof(target)

		if typeName == "Vector3" or typeName == "Vector2" or v.isLinear(target) then
			v2 = value < (data.Position - data.Target).magnitude or value < data.Velocity.magnitude
		else
			error("Unknown type")
		end
	end

	if v2 then
		return true, position
	end

	return false, target
end

function SpringUtils.getVelocityAdjustment(p, p2, p3)
	assert(p, "Bad velocity")
	assert(p2, "Bad dampen")
	assert(p3, "Bad speed")

	return p * (2 * p2 / p3)
end

function SpringUtils.toLinearIfNeeded(data)
	if typeof(data) == "Color3" then
		return v.new(Color3.new, { data.r, data.g, data.b })
	end

	if typeof(data) == "UDim2" then
		return v.new(UDim2.new, { data.X.Scale, data.X.Offset, data.Y.Scale, data.Y.Offset })
	end

	if typeof(data) == "UDim" then
		return v.new(UDim.new, { data.scale, data.offset })
	end

	return data
end

function SpringUtils.fromLinearIfNeeded(object)
	if v.isLinear(object) then
		return object:ToBaseValue()
	end

	return object
end

return SpringUtils