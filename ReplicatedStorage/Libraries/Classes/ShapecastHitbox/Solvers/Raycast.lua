--!native
require(script.Parent.Parent.Types)
local Raycast = { Solvers = {} }

function Raycast.Cast(_, p, raycastParams)
	local solver = Raycast.Solvers[p.Instance.ClassName]
	local position = solver:ToPosition(p)
	local direction = solver:ToDirection(p)

	return workspace:Raycast(position, direction, raycastParams), direction
end

return Raycast