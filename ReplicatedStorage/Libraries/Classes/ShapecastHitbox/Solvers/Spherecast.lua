--!native
require(script.Parent.Parent.Types)
local Spherecast = { Solvers = {} }

function Spherecast.Cast(_, p, p2)
	local solver = Spherecast.Solvers[p.Instance.ClassName]
	local direction = solver:ToDirection(p)
	local position = solver:ToPosition(p)
	return workspace:Spherecast(position, p.CastData.Radius, direction, p2), direction
end

return Spherecast