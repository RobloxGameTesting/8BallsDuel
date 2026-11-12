local v = {
	[Enum.HorizontalAlignment.Left] = 0,
	[Enum.HorizontalAlignment.Center] = 0.5,
	[Enum.HorizontalAlignment.Right] = 1
}

local v2 = {
	[Enum.HorizontalAlignment.Left] = -1,
	[Enum.HorizontalAlignment.Center] = 0,
	[Enum.HorizontalAlignment.Right] = 1
}

local v3 = {
	[Enum.VerticalAlignment.Top] = 0,
	[Enum.VerticalAlignment.Center] = 0.5,
	[Enum.VerticalAlignment.Bottom] = 1
}

local v4 = {
	[Enum.VerticalAlignment.Top] = -1,
	[Enum.VerticalAlignment.Center] = 0,
	[Enum.VerticalAlignment.Bottom] = 1
}
local UIAlignmentUtils = {}

function UIAlignmentUtils.toNumber(p)
	assert(p, "Bad alignment")

	if v[p] then
		return v[p]
	end

	if v3[p] then
		return v3[p]
	end

	error(("[UIAlignmentUtils.toNumber] - Bad alignment %q"):format((tostring(p))))
end

function UIAlignmentUtils.toBias(p)
	assert(p, "Bad alignment")

	if v2[p] then
		return v2[p]
	end

	if v4[p] then
		return v4[p]
	end

	error(("[UIAlignmentUtils.toBias] - Bad alignment %q"):format((tostring(p))))
end

function UIAlignmentUtils.horizontalAlignmentToNumber(p)
	assert(p, "Bad horizontalAlignment")

	if v[p] then
		return v[p]
	end

	error(("[UIAlignmentUtils] - Bad horizontalAlignment %q"):format((tostring(p))))
end

function UIAlignmentUtils.horizontalAlignmentToBias(p)
	assert(p, "Bad horizontalAlignment")

	if v2[p] then
		return v2[p]
	end

	error(("[UIAlignmentUtils] - Bad horizontalAlignment %q"):format((tostring(p))))
end

function UIAlignmentUtils.verticalAlignmentToNumber(p)
	assert(p, "Bad verticalAlignment")

	if v3[p] then
		return v3[p]
	end

	error(("[UIAlignmentUtils] - Bad verticalAlignment %q"):format((tostring(p))))
end

function UIAlignmentUtils.verticalAlignmentToBias(p)
	assert(p, "Bad verticalAlignment")

	if v4[p] then
		return v4[p]
	end

	error(("[UIAlignmentUtils] - Bad verticalAlignment %q"):format((tostring(p))))
end

return UIAlignmentUtils