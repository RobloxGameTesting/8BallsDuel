local loader = require(script.Parent.loader)
local v = loader.load(script)("EnumUtils")
local ScrollingDirectionUtils = {}

function ScrollingDirectionUtils.canScrollHorizontal(p): boolean
	assert(v.isOfType(Enum.ScrollingDirection, p))

	return p == Enum.ScrollingDirection.X or p == Enum.ScrollingDirection.XY
end

function ScrollingDirectionUtils.canScrollVertical(p): boolean
	assert(v.isOfType(Enum.ScrollingDirection, p))

	return p == Enum.ScrollingDirection.Y or p == Enum.ScrollingDirection.XY
end

return ScrollingDirectionUtils