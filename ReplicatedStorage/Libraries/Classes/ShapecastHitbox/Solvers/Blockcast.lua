--!native
require(script.Parent.Parent.Types)
local Blockcast = { Solvers = {} }

function Blockcast.Cast(_, p, p2)
	local direction = Blockcast.Solvers[p.Instance.ClassName]:ToDirection(p)
	local v = p.CastData._LastCFrameBlockCast

	local blockcast = workspace:Blockcast(
		(v or p.Instance.WorldCFrame) * p.CastData.CFrame,
		p.CastData.Size,
		direction,
		p2
	)

	task.defer(function()
		v = p.Instance.WorldCFrame
	end)

	return blockcast, direction
end

return Blockcast