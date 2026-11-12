local UICornerUtils = {}

function UICornerUtils.fromScale(p, parent)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(p, 0)
	uiCorner.Parent = parent
	return uiCorner
end

function UICornerUtils.fromOffset(p, parent)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = parent
	return uiCorner
end

function UICornerUtils.clampPositionToFrame(p, p2, p3, p4)
	assert(p3 >= 0, "Bad radius")
	assert(p4, "Bad point")

	local x = p4.x
	local y = p4.y

	local x2 = p.x
	local y2 = p.y
	local x3 = p2.x
	local y3 = p2.y

	local v = x2 + p3
	local v2 = x2 + x3 - p3

	local v3 = y2 + p3
	local v4 = y2 + y3 - p3

	if v < v2 then
		v = math.clamp(x, v, v2)
	end

	if v3 < v4 then
		v3 = math.clamp(y, v3, v4)
	end

	local vector2 = Vector2.new(v, v3)

	local v5 = p4 - vector2

	if v5.magnitude == 0 then
		return nil, nil
	end

	local unit = v5.unit
	return vector2 + unit * p3, unit
end

return UICornerUtils