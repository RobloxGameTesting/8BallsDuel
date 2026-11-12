local VectorHelper = {
	IsInFront = function(instance, p): boolean
		return instance.CFrame.LookVector:Dot((p.Position - instance.Position).Unit) > 0
	end,
	ZeroVector3 = function(vector3: Vector3)
		return vector3 - Vector3.new(0, vector3.Y, 0)
	end,
	IsPointInsidePart = function(vector3: Vector3, instance): boolean
		local size = instance.Size
		local _position = instance.Position
		local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector3)

		local v = size * 0.5

		return math.abs(pointToObjectSpace.X) <= v.X
			and math.abs(pointToObjectSpace.Y) <= v.Y
			and math.abs(pointToObjectSpace.Z) <= v.Z
	end,
	DistanceFromPointToRay = function(vector3: Vector3, vector3_2: Vector3, vector3_3: Vector3)
		local unit = vector3_3.Unit

		local dot = (vector3 - vector3_2):Dot(unit)

		local selected = dot < 0 and 0 or dot

		local v = vector3_2 + unit * selected

		return (vector3 - v).Magnitude, v, selected
	end,
	Round = function(_, vector3: Vector3, p: number)
		local function roundToIncrement(p2: number, p3: number) -- 3 equivalent calls inferred from this helper
			return math.floor(p2 / p3 + 0.5) * p3
		end

		return (Vector3.new(
			roundToIncrement(vector3.X, p), -- inferred equivalent call
			roundToIncrement(vector3.Y, p), -- inferred equivalent call
			roundToIncrement(vector3.Z, p) -- inferred equivalent call
		))
	end
}

local v = {}

local function add(vector3: Vector3) -- 26 equivalent calls inferred from this helper
	local magnitude = vector3.Magnitude

	if magnitude > 0 then
		table.insert(v, vector3 / magnitude)
	end
end

add(Vector3.new(1, 0, 0)) -- inferred equivalent call
add(Vector3.new(-1, 0, 0)) -- inferred equivalent call
add(Vector3.new(0, 1, 0)) -- inferred equivalent call
add(Vector3.new(0, -1, 0)) -- inferred equivalent call
add(Vector3.new(0, 0, 1)) -- inferred equivalent call
add(Vector3.new(0, 0, -1)) -- inferred equivalent call
add(Vector3.new(1, 1, 0)) -- inferred equivalent call
add(Vector3.new(1, -1, 0)) -- inferred equivalent call
add(Vector3.new(-1, 1, 0)) -- inferred equivalent call
add(Vector3.new(-1, -1, 0)) -- inferred equivalent call
add(Vector3.new(1, 0, 1)) -- inferred equivalent call
add(Vector3.new(1, 0, -1)) -- inferred equivalent call
add(Vector3.new(-1, 0, 1)) -- inferred equivalent call
add(Vector3.new(-1, 0, -1)) -- inferred equivalent call
add(Vector3.new(0, 1, 1)) -- inferred equivalent call
add(Vector3.new(0, 1, -1)) -- inferred equivalent call
add(Vector3.new(0, -1, 1)) -- inferred equivalent call
add(Vector3.new(0, -1, -1)) -- inferred equivalent call
add(Vector3.new(1, 1, 1)) -- inferred equivalent call
add(Vector3.new(1, 1, -1)) -- inferred equivalent call
add(Vector3.new(1, -1, 1)) -- inferred equivalent call
add(Vector3.new(1, -1, -1)) -- inferred equivalent call
add(Vector3.new(-1, 1, 1)) -- inferred equivalent call
add(Vector3.new(-1, 1, -1)) -- inferred equivalent call
add(Vector3.new(-1, -1, 1)) -- inferred equivalent call
add(Vector3.new(-1, -1, -1)) -- inferred equivalent call

local function getClosestPointOnTerrain(origin: Vector3, value: number?)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Terrain }
	raycastParams.IgnoreWater = false
	local v2 = value or 512
	local v3 = 1e999
	local v4 = nil

	for _, v5 in v do
		local raycastResult = workspace:Raycast(origin, v5 * v2, raycastParams)

		if not raycastResult then
			continue
		end

		local position = raycastResult.Position
		local magnitude = (position - origin).Magnitude

		if not (magnitude < v3) then
			continue
		end

		v4 = position
		v3 = magnitude
	end

	return v4 or origin
end

function VectorHelper.GetClosestPointOnPart(instance, vector3: Vector3)
	if instance == workspace.Terrain or instance:IsA("Terrain") then
		return getClosestPointOnTerrain(vector3)
	end

	local cframe = instance.CFrame
	local pointToObjectSpace = cframe:PointToObjectSpace(vector3)

	local v2 = instance.Size.X * 0.5
	local v3 = instance.Size.Y * 0.5
	local v4 = instance.Size.Z * 0.5

	if not instance:IsA("Part") or instance.Shape ~= Enum.PartType.Cylinder then
		return cframe:PointToWorldSpace((Vector3.new(
			math.clamp(pointToObjectSpace.X, -v2, v2),
			math.clamp(pointToObjectSpace.Y, -v3, v3),
			(math.clamp(pointToObjectSpace.Z, -v4, v4))
		)))
	end

	local v5 = math.clamp(pointToObjectSpace.Y, -v3, v3)

	local v6 = math.min(v2, v4)
	local vector2 = Vector2.new(pointToObjectSpace.X, pointToObjectSpace.Z)
	local magnitude = vector2.Magnitude
	local v7, v8

	if v6 < magnitude then
		local v9 = vector2 / magnitude
		v7 = v9.X * v6
		v8 = v9.Y * v6
	else
		v7 = pointToObjectSpace.X
		v8 = pointToObjectSpace.Z
	end

	return cframe:PointToWorldSpace((Vector3.new(v7, v5, v8)))
end

function VectorHelper.DrawBezier(list, p)
	local result = {}

	for i = 1, p do
		local v2 = i / p
		result[i] = list[1] * (1 - v2) ^ 2 + list[2] * 2 * (1 - v2) * v2 + list[3] * v2 ^ 2
	end

	return result
end

function VectorHelper.RandomPointAround(vector3: Vector3, p: number)
	local v2 = math.random() * 3.141592653589793 * 2

	return vector3 + Vector3.new(math.cos(v2) * p, 0, math.sin(v2) * p)
end

return VectorHelper