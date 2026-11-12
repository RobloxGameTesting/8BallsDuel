local UIPaddingUtils = {}

function UIPaddingUtils.fromUDim(p)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingBottom = p
	uiPadding.PaddingTop = p
	uiPadding.PaddingLeft = p
	uiPadding.PaddingRight = p

	return uiPadding
end

function UIPaddingUtils.getTotalPadding(data)
	return UDim2.new(data.PaddingLeft + data.PaddingRight, data.PaddingBottom + data.PaddingTop)
end

function UIPaddingUtils.getTotalAbsolutePadding(p, p2)
	local totalPadding = UIPaddingUtils.getTotalPadding(p)
	return Vector2.new(
		totalPadding.X.Offset + totalPadding.X.Scale * p2.x,
		totalPadding.Y.Offset + totalPadding.Y.Scale * p2.Y
	)
end

function UIPaddingUtils.getHorizontalPadding(p)
	return p.PaddingLeft + p.PaddingRight
end

return UIPaddingUtils