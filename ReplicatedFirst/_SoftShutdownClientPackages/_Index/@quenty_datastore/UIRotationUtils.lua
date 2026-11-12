local loader = require(script.Parent.loader)
loader.load(script)

local UIRotationUtils = {}

function UIRotationUtils.toUnitCircle(value)
	assert(type(value) == "number", "Bad rotationDegrees")

	return -value + 90
end

function UIRotationUtils.toUnitCircleDirection(value)
	assert(type(value) == "number", "Bad rotationDegrees")

	local v = math.rad((UIRotationUtils.toUnitCircle(value)))

	local v2 = math.cos(v)
	local v3 = math.sin(v)

	return Vector2.new(v2, v3)
end

function UIRotationUtils.toGuiDirection(p)
	assert(typeof(p) == "Vector2", "Bad rotationAnchorPoint")

	return p * Vector2.new(1, -1)
end

return UIRotationUtils