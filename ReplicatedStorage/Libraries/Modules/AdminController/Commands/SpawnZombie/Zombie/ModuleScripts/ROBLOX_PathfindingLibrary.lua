local ROBLOXPathfindingLibrary = {}

local PathfindingService = game:GetService("PathfindingService")
PathfindingService.EmptyCutoff = 0.3

function ROBLOXPathfindingLibrary.new()
	local v = Vector3.new(1e999, 1e999, 1e999)
	local v2 = nil
	local v3 = 1
	return {
		MoveToTarget = function(_, instance, position)
			if (v - position).magnitude > 10 then
				local v4 = instance.HumanoidRootPart.Position
				local state = instance.Humanoid:GetState()

				if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
					local ray = Ray.new(instance.HumanoidRootPart.Position, Vector3.new(0, -100, 0))
					local partOnRay, v5 = game.Workspace:FindPartOnRay(ray, instance)

					if partOnRay then
						v4 = v5
					end
				end

				local ray = Ray.new(position + Vector3.new(0, -3, 0), Vector3.new(0, -100, 0))
				local _, v5 = game.Workspace:FindPartOnRay(ray, instance)
				local v6

				if v5 and (v5 - position).magnitude > 4 then
					v6 = position * Vector3.new(1, 0, 1) + Vector3.new(0, 3, 0)
				else
					v6 = position
				end

				v2 = PathfindingService:ComputeSmoothPathAsync(v4, v6, 500)
				local _ = v2.Status == Enum.PathStatus.Success

				v3 = 1
				v = position
			end

			if v2 then
				local pointCoordinates = v2:GetPointCoordinates()

				if v3 < #pointCoordinates then
					local pointCoordinate = pointCoordinates[v3]

					if (instance.HumanoidRootPart.Position - pointCoordinate).magnitude < 4 then
						v3 += 1
					end

					instance.Humanoid:MoveTo(pointCoordinates[v3])

					if pointCoordinates[v3].Y - instance.HumanoidRootPart.Position.Y > 1.5 then
						instance.Humanoid.Jump = true
					end
				else
					instance.Humanoid:MoveTo(position)
				end
			end
		end
	}
end

return ROBLOXPathfindingLibrary