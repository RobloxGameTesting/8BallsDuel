local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.PathTypes)
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)

local Paths = {}

function Paths.new(p, rootPart, humanoid)
	local v = {
		agentPath = PathfindingService:CreatePath(p),
		humanoid = humanoid,
		rootPart = rootPart,
		currentPath = 0
	}

	v.agentPath.Blocked:Connect(function() end)

	v.agentPath.Unblocked:Connect(function() end)

	return v
end

function Paths.CreatePathYield(p, vector3: Vector3, vector3_2: Vector3)
	local success, _ = pcall(function()
		p.agentPath:ComputeAsync(vector3, vector3_2)
	end)

	return success
end

function Paths:StartFollowing()
	self.currentPath += 1
	local currentPath = self.currentPath
	local waypoints = Paths.GetWaypoints(self)

	for k, waypoint in waypoints do
		if currentPath ~= self.currentPath then
			break
		end

		if k == 1 then
			continue
		end

		self.humanoid:MoveTo(waypoint.Position)

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			self.humanoid.Jump = true
		end

		self.humanoid.MoveToFinished:Wait()
	end
end

function Paths:StopFollowing()
	self.currentPath += 1
end

function Paths.GetWaypoints(p)
	return p.agentPath:GetWaypoints()
end

function Paths.GetStatus(p)
	return p.agentPath.Status
end

return Paths