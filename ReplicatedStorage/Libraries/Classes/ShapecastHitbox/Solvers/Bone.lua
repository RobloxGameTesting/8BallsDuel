--!native
require(script.Parent.Parent.Types)
local Bone = {}

function Bone:ToPosition(p)
	return p.Instance.TransformedWorldCFrame.Position
end

function Bone.ToDirection(_, p)
	if p.Position then
		return Bone:ToPosition(p) - p.Position
	end

	return Vector3.new(0, 0, 0)
end

function Bone.ToVisual(_, p)
	return CFrame.lookAt(Bone:ToPosition(p), p.Position or Vector3.new(0, 0, 0))
end

return Bone