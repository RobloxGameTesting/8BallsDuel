local ROBLOXAIUtilities = {}

function ROBLOXAIUtilities:WideRayCast(p, p2, p3, p4)
	local parts = {}

	local ray = Ray.new(p, p2 - p)
	local part, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, p4)

	if part then
		table.insert(parts, part)
	end

	local v = p3 * (p2 - p):Cross(Vector3.FromNormalId(Enum.NormalId.Top)).unit
	local ray2 = Ray.new(p + v, p2 - p + v)
	local part2, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray2, p4)

	if part2 then
		table.insert(parts, part2)
	end

	local ray3 = Ray.new(p - v, p2 - p - v)
	local part3, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray3, p4)

	if part3 then
		table.insert(parts, part3)
	end

	return parts
end

function ROBLOXAIUtilities.FindNearestPathPoint(_, object, p, p2, _, _)
	if object:CheckOcclusionAsync(p) > 0 then
		ROBLOXAIUtilities:WideRayCast(p2)
	end
end

function ROBLOXAIUtilities.GetRepulsionVector(_, p, items)
	local total = Vector3.new(0, 0, 0)

	for _, item in pairs(items) do
		local v = p - item

		total += v.unit * 1000 / math.pow(v.magnitude + 1, 2)
	end

	return total * 15
end

function ROBLOXAIUtilities.GetIdleState(_, p)
	local idle = p.NewState()
	idle.Name = "Idle"
	function idle.Action() end
	function idle.Init() end
	return idle
end

function ROBLOXAIUtilities.GetClosestVisibleTarget(_, p, items, p2, p3)
	local v = 1e999
	local closestVisibleTarget = nil

	for _, item in pairs(items) do
		local v2 = item.HumanoidRootPart.Position - p.HumanoidRootPart.Position
		local vector = v2 * Vector3.new(1, 0, 1)

		if not (math.deg((math.acos(vector:Dot(p.HumanoidRootPart.CFrame.lookVector) / vector.magnitude))) < p3) then
			continue
		end

		local ray = Ray.new(p.HumanoidRootPart.Position, v2)
		local part, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, p2)

		if not (part and part.Parent == item and v2.magnitude < v) then
			continue
		end

		v = v2.magnitude
		closestVisibleTarget = item
	end

	return closestVisibleTarget
end

local function isSpaceEmpty(p) -- 2 equivalent calls inferred from this helper
	local region = Region3.new(p - Vector3.new(2, 2, 2), p + Vector3.new(2, 2, 2))
	return game.Workspace:IsRegion3Empty(region)
end

function ROBLOXAIUtilities.FindCloseEmptySpace(_, p)
	math.randomseed(os.time())
	local count = 0

	while true do
		local v = math.random(5, 10)

		if math.random() > 0.5 then
			v *= -1
		end

		local v2 = math.random(5, 10)

		if math.random() > 0.5 then
			v2 *= -1
		end

		local vector3 = Vector3.new(
			p.HumanoidRootPart.Position.X + v,
			p.HumanoidRootPart.Position.Y,
			p.HumanoidRootPart.Position.Z + v2
		)

		if isSpaceEmpty(vector3) then -- inferred equivalent call
			return vector3
		end

		local v3 = vector3 + Vector3.new(0, 4, 0)

		if isSpaceEmpty(v3) then -- inferred equivalent call
			return v3
		end

		count += 1

		if count > 10 then
			return nil
		end
	end
end

return ROBLOXAIUtilities