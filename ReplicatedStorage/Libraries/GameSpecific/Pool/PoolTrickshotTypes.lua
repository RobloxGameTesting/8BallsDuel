local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolGeometry = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolGeometry)
local PoolModifiers = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolModifiers)

local PoolTrickshotTypes = {}
PoolTrickshotTypes.ObstacleNumber = 16
PoolTrickshotTypes.MaxBalls = 100
PoolTrickshotTypes.MaxSlots = 50
PoolTrickshotTypes.MaxNameLength = 24
PoolTrickshotTypes.MinScale = 0.35
PoolTrickshotTypes.MaxScale = 6
PoolTrickshotTypes.Version = 3
PoolTrickshotTypes.CueId = PoolConstants.CueBallNumber
PoolTrickshotTypes.MaxCueBalls = 8
PoolTrickshotTypes.FirstId = 100

function PoolTrickshotTypes.CleanTableScale(value)
	if typeof(value) ~= "number" or value ~= value then
		return 1
	end

	local scaleStep = PoolGeometry.ScaleStep
	return math.round(math.clamp(
		math.round(value / scaleStep) * scaleStep,
		PoolGeometry.MinScale,
		PoolGeometry.MaxScale
	) * 100) / 100
end

function PoolTrickshotTypes.TableOf(p)
	local tl

	if typeof(p) == "table" then
		tl = p.TL
	end

	local v

	if typeof(p) == "table" then
		v = p.TH
	end

	return PoolGeometry.For(PoolTrickshotTypes.CleanTableScale(tl), PoolTrickshotTypes.CleanTableScale(v), false)
end

function PoolTrickshotTypes.ClampPosition(vector2: Vector2, p: number, p2)
	local v = PoolConstants.BallRadius * p
	local v2 = p2 or PoolTrickshotTypes.TableOf(nil)

	local v3 = math.max(v2.HalfWidth - v, 0)
	local v4 = math.max(v2.HalfHeight - v, 0)

	return Vector2.new(math.clamp(vector2.X, -v3, v3), (math.clamp(vector2.Y, -v4, v4)))
end

function PoolTrickshotTypes.IsPlaceable(p: number): boolean
	return p == math.floor(p) and p >= 0 and p <= 15
end

function PoolTrickshotTypes.IsPottable(p: number): boolean
	return p >= 1 and p <= 15
end

PoolTrickshotTypes.ModifierRegion = 2

function PoolTrickshotTypes.ClampModifierPosition(vector2: Vector2, p)
	local v = p or PoolTrickshotTypes.TableOf(nil)
	local v2 = v.HalfWidth * PoolTrickshotTypes.ModifierRegion
	local v3 = v.HalfHeight * PoolTrickshotTypes.ModifierRegion

	return Vector2.new(math.clamp(vector2.X, -v2, v2), (math.clamp(vector2.Y, -v3, v3)))
end

function PoolTrickshotTypes.CleanName(value)
	if typeof(value) ~= "string" then
		return nil
	end

	local v = value:gsub("[%c]", ""):gsub("^%s+", ""):gsub("%s+$", "")

	if v == "" then
		return nil
	end

	return v:sub(1, PoolTrickshotTypes.MaxNameLength)
end

local function readPatrol(data, clampPosition: Vector2, p: number, tbl)
	if typeof(data.RX) ~= "number" or typeof(data.RY) ~= "number" or (data.RX ~= data.RX or data.RY ~= data.RY) then
		return nil, nil, nil
	end

	local clampPosition2 = PoolTrickshotTypes.ClampPosition(Vector2.new(data.RX, data.RY), p, tbl)

	if (clampPosition2 - clampPosition).Magnitude < PoolModifiers.MinPatrolDistance then
		return nil, nil, nil
	end

	local v = PoolModifiers.DefaultPatrolSpeed

	if typeof(data.RS) == "number" and data.RS == data.RS then
		v = math.clamp(data.RS, PoolModifiers.MinPatrolSpeed, PoolModifiers.MaxPatrolSpeed)
	end

	return math.round(clampPosition2.X * 100) / 100, math.round(clampPosition2.Y * 100) / 100, math.round(v * 10) / 10
end

local function sanitiseModifiers(mods, tbl)
	local result = {}

	if typeof(mods) ~= "table" then
		return result
	end

	for _, item in mods do
		if #result >= PoolModifiers.MaxModifiers then
			break
		end

		if not (typeof(item) == "table" and typeof(item.X) == "number" and typeof(item.Y) == "number") then
			continue
		end

		local v = PoolModifiers.Get(item.K)

		if not (v and item.X == item.X and item.Y == item.Y) then
			continue
		end

		local v2

		if typeof(item.S) == "number" and item.S == item.S then
			local scaleRange, v3 = PoolModifiers.ScaleRange(v)

			v2 = math.clamp(item.S, scaleRange, v3)
		else
			v2 = 1
		end

		local clampModifierPosition = PoolTrickshotTypes.ClampModifierPosition(Vector2.new(item.X, item.Y), tbl)
		local v3

		if v.Rotatable and typeof(item.R) == "number" and item.R == item.R then
			v3 = math.round(item.R % 360)
		end

		local v4 = nil

		if PoolModifiers.HasStrength(v) and typeof(item.P) == "number" and item.P == item.P then
			local strength = PoolModifiers.StrengthOf(v, item.P)

			if strength ~= v.Strength.Default then
				v4 = math.round(strength * 100) / 100
			end
		end

		local v5 = {
			K = v.Id,
			X = math.round(clampModifierPosition.X * 100) / 100,
			Y = math.round(clampModifierPosition.Y * 100) / 100,
			S = 0,
			R = 0,
			P = 0
		}
		local v6

		if v2 ~= 1 then
			v6 = math.round(v2 * 100) / 100
		end

		v5.S = v6
		v5.R = v3
		v5.P = v4
		table.insert(result, v5)
	end

	return result
end

function PoolTrickshotTypes.Sanitise(data, p: string?)
	if typeof(data) ~= "table" then
		return nil
	end

	local v = if typeof(data.Balls) == "table" then data.Balls else data

	if typeof(v) ~= "table" then
		return nil
	end

	local tl = PoolTrickshotTypes.CleanTableScale(data.TL)
	local th = PoolTrickshotTypes.CleanTableScale(data.TH)
	local tbl = PoolTrickshotTypes.TableOf({ TL = tl, TH = th })

	local v2 = PoolTrickshotTypes.FirstId
	local balls = {}
	local count = 0
	local v3 = false

	for _, v4 in v do
		if #balls >= PoolTrickshotTypes.MaxBalls then
			break
		end

		if not (typeof(v4) == "table" and typeof(v4.N) == "number" and typeof(v4.X) == "number") then
			continue
		end

		if typeof(v4.Y) ~= "number" then
			continue
		end

		local n = math.floor(v4.N)
		local v5

		if v4.X == v4.X then
			v5 = v4.Y == v4.Y
		else
			v5 = false
		end

		local v6

		if n == 0 then
			v6 = PoolTrickshotTypes.MaxCueBalls <= count
		else
			v6 = false
		end

		if not v5 or not PoolTrickshotTypes.IsPlaceable(n) or v6 then
			continue
		end

		local v7 = (typeof(v4.S) ~= "number" or v4.S ~= v4.S) and 1
			or math.clamp(v4.S, PoolTrickshotTypes.MinScale, PoolTrickshotTypes.MaxScale)

		local clampPosition = PoolTrickshotTypes.ClampPosition(Vector2.new(v4.X, v4.Y), v7, tbl)

		local o = v4.O == true
		local v8

		if n == 0 and not o then
			v8 = v4.A ~= false
		else
			v8 = v4.A == true
		end

		if n == 0 then
			count += 1
			v3 = true
		end

		local v9, v10

		if n == 0 and count == 1 then
			v9 = PoolTrickshotTypes.CueId
			v10 = v2
		else
			v10 = v2 + 1
			v9 = v2
		end

		local rx = nil
		local ry = nil
		local rs = nil

		local v11 = nil
		local v12 = nil
		local v13 = nil
		local v14 = nil

		if n ~= 0 and not o and typeof(v4.G) == "number" and v4.G == v4.G then
			local g = math.floor(v4.G)

			if g >= 1 and g <= PoolModifiers.MaxSpinners then
				if typeof(v4.W) == "number" and v4.W == v4.W then
					v12 = math.round((math.clamp(v4.W, PoolModifiers.MinSpinSpeed, PoolModifiers.MaxSpinSpeed)))
					v13 = PoolTrickshotTypes.CleanSpinnerArm(v4.L, PoolModifiers.DefaultSpinnerLength)
					v14 = PoolTrickshotTypes.CleanSpinnerArm(v4.D, PoolModifiers.DefaultSpinnerWidth)
				end

				v11 = g
			end
		end

		if not v11 or v12 then
			if not v8 and n ~= 0 and not o then
				rx, ry, rs = readPatrol(v4, clampPosition, v7, tbl)
			end

			local v15 = {
				I = v9,
				N = n,
				X = math.round(clampPosition.X * 100) / 100,
				Y = math.round(clampPosition.Y * 100) / 100,
				S = 0,
				A = 0,
				RX = 0,
				RY = 0,
				RS = 0,
				G = 0,
				W = 0,
				L = 0,
				D = 0,
				O = 0
			}
			local v16

			if v7 ~= 1 then
				v16 = math.round(v7 * 100) / 100
			end

			v15.S = v16
			local v17

			if v8 then
				v17 = true
			elseif n == 0 and not o then
				v17 = false
			end

			v15.A = v17

			v15.RX = rx
			v15.RY = ry
			v15.RS = rs
			v15.G = v11
			v15.W = v12
			v15.L = v13
			v15.D = v14
			v15.O = o and true or nil
			table.insert(balls, v15)
		end

		v2 = v10
	end

	local mods = sanitiseModifiers(data.Mods, tbl)

	local gSet = {}

	for _, v4 in balls do
		if not v4.G then
			continue
		end

		if gSet[v4.G] then
			v4.G = nil
			v4.W = nil
			v4.L = nil
			v4.D = nil
		else
			gSet[v4.G] = true
			v4.A = true
			v4.RX = nil
			v4.RY = nil
			v4.RS = nil
		end
	end

	local v4 = {}

	for _, v5 in balls do
		if v5.G and v5.W then
			table.insert(v4, v5)
		end
	end

	for _, v5 in v4 do
		local spinnerOffsets = PoolTrickshotTypes.SpinnerOffsets(v5.L or 1, v5.D or 1, v5.S)

		for _, spinnerOffset in spinnerOffsets do
			if #balls >= PoolTrickshotTypes.MaxBalls then
				break
			end

			table.insert(balls, {
				I = v2,
				N = PoolTrickshotTypes.MovingBallNumber,
				X = math.round((v5.X + spinnerOffset.X) * 100) / 100,
				Y = math.round((v5.Y + spinnerOffset.Y) * 100) / 100,
				S = v5.S,
				G = v5.G
			})

			v2 += 1
		end
	end

	local v5 = false

	for _, v6 in mods do
		local v7 = PoolModifiers.Get(v6.K)

		if v7 and v7.Kind == "Goal" then
			v5 = true
			break
		end
	end

	if not v3 or #balls < 2 and not v5 then
		return nil
	end

	local name = PoolTrickshotTypes.CleanName(p or data.Name)

	if not name then
		return nil
	end

	local v6 = {
		Name = name,
		Version = PoolTrickshotTypes.Version,
		Balls = balls,
		Mods = mods,
		TL = 0,
		TH = 0
	}

	if tl == 1 then
		tl = nil
	end

	v6.TL = tl

	if th == 1 then
		th = nil
	end

	v6.TH = th
	return v6
end

function PoolTrickshotTypes.CountResized(p)
	if typeof(p) ~= "table" then
		return 0
	end

	local count = 0

	for _, v in p.Mods or {} do
		if not (typeof(v) == "table" and typeof(v.S) == "number" and v.S == v.S) then
			continue
		end

		local v2 = PoolModifiers.Get(v.K)

		if not v2 then
			continue
		end

		local scaleRange, v3 = PoolModifiers.ScaleRange(v2)

		if v.S < scaleRange or v3 < v.S then
			count += 1
		end
	end

	for _, v in typeof(p.Balls) ~= "table" and {} or p.Balls do
		if not (typeof(v) == "table" and typeof(v.S) == "number" and v.S == v.S) then
			continue
		end

		if not (v.S < PoolTrickshotTypes.MinScale or v.S > PoolTrickshotTypes.MaxScale) then
			continue
		end

		count += 1
	end

	return count
end

function PoolTrickshotTypes.PaletteOrder()
	return {
		PoolConstants.CueBallNumber,
		3,
		9,
		8,
		PoolTrickshotTypes.MovingBallNumber,
		PoolTrickshotTypes.SpinnerHubNumber
	}
end

function PoolTrickshotTypes.NormalPaletteOrder()
	local v = { PoolConstants.CueBallNumber }

	table.insert(v, 1)
	table.insert(v, 2)
	table.insert(v, 3)
	table.insert(v, 4)
	table.insert(v, 5)
	table.insert(v, 6)
	table.insert(v, 7)
	table.insert(v, 8)
	table.insert(v, 9)
	table.insert(v, 10)
	table.insert(v, 11)
	table.insert(v, 12)
	table.insert(v, 13)
	table.insert(v, 14)
	table.insert(v, 15)

	return v
end

PoolTrickshotTypes.GoldenBallNumber = 12

function PoolTrickshotTypes.SkinFor(p: number)
	if p == PoolTrickshotTypes.GoldenBallNumber then
		return PoolConstants.GoldenBallSkin
	end

	return p
end

function PoolTrickshotTypes.IsGolden(p): boolean
	return typeof(p) == "table" and p.N == PoolTrickshotTypes.GoldenBallNumber and p.O ~= true
end

function PoolTrickshotTypes.SkinForBall(p)
	if PoolTrickshotTypes.IsGolden(p) then
		return PoolConstants.GoldenBallSkin
	end

	return p.N
end

PoolTrickshotTypes.SpinnerHubNumber = 4

function PoolTrickshotTypes.SpinnerOffsets(p: number, p2: number, value: number?)
	local v = PoolConstants.BallDiameter * (value or 1)
	local vector2s = {}

	for i = 1, p do
		table.insert(vector2s, Vector2.new(v * i, 0))
		table.insert(vector2s, Vector2.new(-v * i, 0))
	end

	for i = 1, p2 do
		table.insert(vector2s, Vector2.new(0, v * i))
		table.insert(vector2s, Vector2.new(0, -v * i))
	end

	return vector2s
end

function PoolTrickshotTypes.SpinnerReach(p: number, p2: number, value: number?)
	local v = value or 1

	return PoolConstants.BallDiameter * v * math.max(p, p2) + PoolConstants.BallRadius * v
end

function PoolTrickshotTypes.SpinnerBallCount(p: number, p2: number)
	return p * 2 + 1 + p2 * 2
end

function PoolTrickshotTypes.CleanSpinnerArm(value, p: number)
	if typeof(value) == "number" and value == value then
		return (math.clamp(math.floor(value), PoolModifiers.MinSpinnerArm, PoolModifiers.MaxSpinnerArm))
	end

	return p
end

PoolTrickshotTypes.MovingBallNumber = 5

function PoolTrickshotTypes.ModifierPaletteOrder()
	return PoolModifiers.Order
end

function PoolTrickshotTypes.IsPocketId(value): boolean
	if typeof(value) ~= "string" then
		return false
	end

	for _, v in PoolGeometry.GetPockets() do
		if v.Id == value then
			return true
		end
	end

	return false
end

function PoolTrickshotTypes.CueBalls(p)
	local balls = {}

	for _, ball in p.Balls do
		if ball.N == PoolConstants.CueBallNumber then
			table.insert(balls, ball)
		end
	end

	return balls
end

function PoolTrickshotTypes.NextCueBall(p, p2, p3)
	for _, v in PoolTrickshotTypes.CueBalls(p) do
		if p3[v.I] then
			continue
		end

		local v2 = p2 and p2.Balls[v.I]

		if v2 and not (v2.Pocketed or v2.Destroyed) then
			return v
		end
	end

	return nil
end

function PoolTrickshotTypes.SpentCueBalls(p, p2, p3)
	local count = 0

	for _, v in PoolTrickshotTypes.CueBalls(p) do
		local v2 = p2 and p2.Balls[v.I]

		if p3[v.I] or not v2 or v2.Pocketed or v2.Destroyed then
			count += 1
		end
	end

	return count
end

PoolTrickshotTypes.NewSceneTableScale = 1

function PoolTrickshotTypes.NewScene()
	local th = PoolTrickshotTypes.CleanTableScale(PoolTrickshotTypes.NewSceneTableScale)

	local scene = {
		Name = "",
		Version = PoolTrickshotTypes.Version,
		Balls = {},
		TL = 0,
		TH = 0
	}
	local tl

	if th ~= 1 then
		tl = th
	end

	scene.TL = tl

	if th == 1 then
		th = nil
	end

	scene.TH = th
	return scene
end

function PoolTrickshotTypes.CountTargets(p)
	local count = 0

	for _, ball in p.Balls do
		if PoolTrickshotTypes.IsGolden(ball) then
			count += 1
		end
	end

	return count
end

function PoolTrickshotTypes.NextId(p)
	local v = PoolTrickshotTypes.FirstId - 1

	for _, ball in p.Balls do
		if v < ball.I then
			v = ball.I
		end
	end

	return v + 1
end

function PoolTrickshotTypes.FindById(p, p2: number)
	for _, ball in p.Balls do
		if ball.I == p2 then
			return ball
		end
	end

	return nil
end

return PoolTrickshotTypes