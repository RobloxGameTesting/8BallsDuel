--!native
local Settings = require(script.Parent.Parent.Settings)
require(script.Parent.Parent.Types)

local Attachment = {}

function Attachment:ToPosition(p)
	return p.Position or p.Instance.WorldPosition
end

function Attachment.ToDirection(_, p)
	local direction = p.Instance.WorldPosition - Attachment:ToPosition(p)

	if direction.Magnitude == 0 then
		direction = p.LastDirection.Unit * Settings.Minimum_Stationary_Length
	end

	return direction
end

function Attachment.ToVisual(_, p)
	return CFrame.lookAt(Attachment:ToPosition(p), p.Instance.WorldPosition)
end

return Attachment