local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolGeometry = require(Pool.PoolGeometry)
local PoolPhysics = require(Pool.PoolPhysics)
local PoolRules = require(Pool.PoolRules)
local PoolStepper = require(Pool.PoolStepper)

local PoolAI = {}

local Bots = PoolConstants.Bots
local Theatre = Bots.Theatre
local CueBallNumber = PoolConstants.CueBallNumber
local BallDiameter = PoolConstants.BallDiameter
local CatchUp = Bots.CatchUp
local DynamicMiss = Bots.DynamicMiss
local Human = Bots.Human
local EightBallNumber = PoolConstants.EightBallNumber
local v = Bots.Break

function PoolAI.SweepAim(vector2: Vector2, vector2_2: Vector2, value: number)
	local v2 = math.atan2(vector2.Y, vector2.X)
	local v3 = v2 + ((math.atan2(vector2_2.Y, vector2_2.X) - v2 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * math.clamp(value, 0, 1)

	return Vector2.new(math.cos(v3), (math.sin(v3)))
end

function PoolAI.Ease(value: number)
	local v2 = math.clamp(value, 0, 1)

	return v2 * v2 * (3 - v2 * 2)
end

function PoolAI.SweepSeconds(vector2: Vector2, vector2_2: Vector2, p: number)
	local maxAimDegreesPerSecond = PoolConstants.Bots.Theatre.MaxAimDegreesPerSecond

	if
		not maxAimDegreesPerSecond
		or maxAimDegreesPerSecond <= 0
		or vector2.Magnitude < 0.0001
		or vector2_2.Magnitude < 0.0001
	then
		return p
	end

	local v2 = math.atan2(vector2.Y, vector2.X)
	return (math.max(
		p,
		math.deg((math.abs((math.atan2(vector2_2.Y, vector2_2.X) - v2 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793))) / maxAimDegreesPerSecond
	))
end

function PoolAI.BuildCarry(object, vector2: Vector2, vector2_2: Vector2, p: number?)
	local carry = Bots.Carry
	local magnitude = (vector2_2 - vector2).Magnitude
	local function band(p2) -- 15 equivalent calls inferred from this helper
		return p2.Min + (p2.Max - p2.Min) * object:NextNumber()
	end

	local function signed(): number -- 3 equivalent calls inferred from this helper
		return if object:NextNumber() < 0.5 then -1 else 1
	end

	local v2 = math.clamp(carry.BaseSeconds + magnitude * carry.SecondsPerStud, carry.Seconds.Min, carry.Seconds.Max) * (1 + (object:NextNumber() * 2 - 1) * carry.Jitter)

	local warp = -0.6931471805599453 / math.log(band(carry.PeakAt)) -- inferred equivalent call
	local parts = {}
	local wiggles = {}

	local v3 = magnitude < PoolConstants.BallDiameter * 1.5

	if v3 or magnitude <= 0.0001 then
		table.insert(parts, {
			Start = 0,
			Finish = 1,
			FromAlong = 0,
			FromSide = 0,
			ToAlong = 1,
			ToSide = 0,
			Bend = 0,
			Warp = 1
		})
	else
		local v4 = carry.MaxLandingError / magnitude
		local v5

		if object:NextNumber() < carry.OvershootChance then
			v5 = math.min(band(carry.Overshoot), v4) -- inferred equivalent call
		else
			v5 = -math.min(band(carry.Undershoot), v4) -- inferred equivalent call
		end

		local toSide = math.clamp((object:NextNumber() * 2 - 1) * carry.LandingSideError, -v4, v4)
		local finish = band(carry.PrimaryShare) -- inferred equivalent call
		local v6 = {
			Start = 0,
			Finish = finish,
			FromAlong = 0,
			FromSide = 0,
			ToAlong = v5 + 1,
			ToSide = toSide,
			Bend = signed() * band(carry.Bend), -- inferred equivalent call
			Warp = warp
		}
		table.insert(parts, v6)

		local v7 = object:NextNumber() < carry.SecondCorrectionChance and 2 or 1
		local v8 = {}
		local total = 0

		for i = 1, v7 do
			v8[i] = band(carry.CorrectionPause) -- inferred equivalent call
			total += v8[i]
		end

		local v9 = math.max(1 - finish - total, 0.05)

		local fromAlong = v5 + 1
		local fromSide = toSide

		for i = 1, v7 do
			local v10 = i == v7
			local v11

			if not v10 then
				v11 = v9 * band({ Min = 0.5, Max = 0.62 }) -- inferred equivalent call
			end

			local v12 = finish + v8[i]
			finish = v10 and 1 or v12 + v11
			local toAlong

			if v10 then
				toAlong = 1
			else
				toAlong = v5 * band({ Min = -0.35, Max = 0.35 }) + 1 -- inferred equivalent call
			end

			local toSide2

			if v10 then
				toSide2 = 0
			else
				toSide2 = toSide * band({ Min = -0.4, Max = 0.4 }) -- inferred equivalent call
			end

			table.insert(parts, {
				Start = math.min(v12, finish - 0.02),
				Finish = finish,
				FromAlong = fromAlong,
				FromSide = fromSide,
				ToAlong = toAlong,
				ToSide = toSide2,
				Bend = signed() * math.abs(v5) * 0.15, -- inferred equivalent call
				Warp = 1
			})
			fromSide = toSide2
			fromAlong = toAlong
		end

		local v10 = carry.MaxWobble / magnitude

		for _ = 1, carry.WobbleParts do
			local v11 = {
				Amplitude = signed() * math.min(band(carry.Wobble), v10), -- inferred equivalent call
				Frequency = band(carry.WobbleFrequency), -- inferred equivalent call
				Phase = object:NextNumber() * 3.141592653589793 * 2
			}
			table.insert(wiggles, v11)
		end
	end

	return {
		Seconds = p or v2,
		Parts = parts,
		Wiggles = wiggles,
		Tremor = band(carry.Tremor) * (v3 and 0.5 or 1), -- inferred equivalent call
		TremorFrequency = band(carry.TremorFrequency), -- inferred equivalent call
		TremorPhase = object:NextNumber() * 3.141592653589793 * 2,
		Pace = band(carry.PaceWobble), -- inferred equivalent call
		PaceFrequency = band(carry.PaceFrequency), -- inferred equivalent call
		PacePhase = object:NextNumber() * 3.141592653589793 * 2
	}
end

function PoolAI.CarryPosition(data, vector2: Vector2, vector2_2: Vector2, value: number)
	local v2 = math.clamp(value, 0, 1)

	if v2 >= 1 then
		return vector2_2
	end

	local v3 = vector2_2 - vector2
	local magnitude = v3.Magnitude

	if magnitude <= 0.0001 then
		return vector2_2
	end

	local v4 = v3 / magnitude
	local vector2_3 = Vector2.new(-v4.Y, v4.X)

	local v5 = math.clamp(
		v2 + data.Pace * math.sin(6.283185307179586 * data.PaceFrequency * v2 + data.PacePhase) * v2 * (1 - v2),
		0,
		1
	)

	local parts = data.Parts
	local v6 = 0
	local v7 = 0

	for k, part in parts do
		if v5 < part.Start then
			local part2 = parts[k - 1]

			if part2 then
				v6 = part2.ToAlong
				v7 = part2.ToSide
			end

			break
		elseif v5 <= part.Finish or k == #parts then
			local v8 = math.max(part.Finish - part.Start, 0.0001)
			local v9 = math.clamp((v5 - part.Start) / v8, 0, 1) ^ part.Warp
			local v10 = v9 * v9 * v9 * (v9 * (v9 * 6 - 15) + 10)

			v6 = part.FromAlong + (part.ToAlong - part.FromAlong) * v10
			v7 = part.FromSide + (part.ToSide - part.FromSide) * v10 + part.Bend * 4 * v10 * (1 - v10)

			if k == 1 then
				local v11 = math.sin(3.141592653589793 * v10)

				for _, wiggle in data.Wiggles do
					v7 += wiggle.Amplitude * math.sin(6.283185307179586 * wiggle.Frequency * v10 + wiggle.Phase) * v11
				end
			end

			break
		end
	end

	local v8 = vector2 + v4 * (v6 * magnitude) + vector2_3 * (v7 * magnitude)

	local v9 = math.min(1, v5 * 8, (1 - v5) * 8)
	local v10 = 6.283185307179586 * data.TremorFrequency * v5 + data.TremorPhase

	local v11 = v8 + (vector2_3 * math.sin(v10) + v4 * 0.6 * math.sin(v10 * 1.37 + 1.1)) * data.Tremor * v9

	return PoolGeometry.ClampToPlayArea(v11)
end

function PoolAI.GetLevels()
	return Bots.Levels
end

function PoolAI.GetLevel(p: string)
	for _, level in Bots.Levels do
		if level.Id == p then
			return level
		end
	end

	return nil
end

function PoolAI.LevelForRating(p: number)
	local v2 = p + Bots.MatchRatingOffset
	local v3 = Bots.Levels[1]
	local v4 = 1e999

	for _, level in Bots.Levels do
		local v5 = math.abs(level.Rating - v2)

		if not (v5 < v4) then
			continue
		end

		v3 = level
		v4 = v5
	end

	return v3
end

local v2 = {
	TurnSeconds = Theatre.TurnSeconds,
	SpinUse = 0,
	PositionDepth = false,
	PlaysSafeties = false,
	PressureError = 1.2
}

local v3 = {
	Id = "Steady",
	Weight = 1,
	Tempo = 1,
	PowerBias = 0,
	Risk = 1,
	BankLove = 0,
	Fidget = 1,
	Nerves = 1
}

local function rollStyle(random)
	local styles = Bots.Styles

	if not styles or #styles == 0 then
		return v3
	end

	local total = 0

	for _, style in styles do
		total += style.Weight
	end

	local v4 = random:NextNumber() * total

	for _, style in styles do
		v4 -= style.Weight

		if v4 <= 0 then
			return style
		end
	end

	return styles[#styles]
end

function PoolAI.new(level, p: number?)
	local random = Random.new(p or os.clock() * 1000000)
	local traits = Bots.LevelTraits and Bots.LevelTraits[level.Id] or v2

	return {
		Level = level,
		Random = random,
		CatchUp = { Armed = false, Remaining = 0, Deficit = 0 },
		Style = rollStyle(random),
		Traits = traits,
		Form = 1 + (random:NextNumber() + random:NextNumber() - 1) * Human.FormSpread,
		Streak = 0,
		LastOwnLeft = nil,
		BreakSign = random:NextNumber() < 0.5 and -1 or 1
	}
end

local function ghostBall(vector2: Vector2, mouthCentre: Vector2) -- 3 equivalent calls inferred from this helper
	local v4 = mouthCentre - vector2

	if v4.Magnitude <= 0.0001 then
		return vector2
	end

	return vector2 - v4.Unit * BallDiameter
end

local function cutQuality(vector2: Vector2, vector2_2: Vector2) -- 3 equivalent calls inferred from this helper
	if vector2.Magnitude <= 0.0001 or vector2_2.Magnitude <= 0.0001 then
		return 0
	end

	return vector2.Unit:Dot(vector2_2.Unit)
end

local v4 = BallDiameter * 0.9

local function pathBlocked(p, vector2: Vector2, vector2_2: Vector2, cueBallNumber: number, p2: number): boolean
	local v5 = vector2_2 - vector2
	local magnitude = v5.Magnitude

	if magnitude <= 0.0001 then
		return false
	end

	local v6 = v5 / magnitude

	for _, v7 in p.Order do
		local ball = p.Balls[v7]

		if not ball or ball.Pocketed or v7 == cueBallNumber or v7 == p2 then
			continue
		end

		local vector = ball.Position - vector2
		local dot = vector:Dot(v6)

		if dot > 0 and dot < magnitude and math.abs(vector.X * v6.Y - vector.Y * v6.X) < v4 then
			return true
		end
	end

	return false
end

local wall2 = PoolGeometry.HalfWidth - PoolConstants.BallRadius
local wall3 = PoolGeometry.HalfHeight - PoolConstants.BallRadius

local v5 = {
	{ Vertical = true, Wall = wall2 },
	{
		Vertical = true,
		Wall = -wall2
	},
	{ Vertical = false, Wall = wall3 },
	{
		Vertical = false,
		Wall = -wall3
	}
}

local function bankProposal(p, position: Vector2, target: number, position2: Vector2, pocket, p2)
	local v6 = ghostBall(position2, pocket.MouthCentre) -- inferred equivalent call
	local wall = p2.Wall
	local v7 = if p2.Vertical then position.X else position.Y
	local v8 = if p2.Vertical then v6.X else v6.Y
	local v9

	if wall > 0 then
		if v7 < wall - 0.05 then
			v9 = v8 < wall - 0.05
		else
			v9 = false
		end
	elseif wall + 0.05 < v7 then
		v9 = wall + 0.05 < v8
	else
		v9 = false
	end

	if not v9 then
		return nil
	end

	local v10

	if p2.Vertical then
		v10 = Vector2.new(wall * 2 - v6.X, v6.Y)
	else
		v10 = Vector2.new(v6.X, wall * 2 - v6.Y)
	end

	local v11 = v10 - position

	if v11.Magnitude <= BallDiameter then
		return nil
	end

	local v12 = if p2.Vertical then v11.X else v11.Y

	if math.abs(v12) <= 0.0001 then
		return nil
	end

	local v13 = (wall - v7) / v12

	if v13 <= 0.05 or v13 >= 0.95 then
		return nil
	end

	local aimPoint = position + v11 * v13

	if PoolGeometry.GetNearbyJawPocket(aimPoint, BallDiameter * 1.5) then
		return nil
	end

	if
		pathBlocked(p, position, aimPoint, CueBallNumber, target)
		or pathBlocked(p, aimPoint, v6, CueBallNumber, target)
		or pathBlocked(p, position2, pocket.MouthCentre, CueBallNumber, target)
	then
		return nil
	end

	local quality = cutQuality(v6 - aimPoint, pocket.MouthCentre - position2) -- inferred equivalent call

	if quality <= 0.15 then
		return nil
	end

	return {
		Target = target,
		Pocket = pocket.Id,
		Direction = v11.Unit,
		AimPoint = aimPoint,
		Object = position2,
		Quality = quality,
		Clear = true,
		Bank = true,
		Distance = (aimPoint - position).Magnitude + (v6 - aimPoint).Magnitude + (pocket.MouthCentre - position2).Magnitude
	}
end

local function legalTargets(p, p2)
	local result = {}

	for _, v6 in p2.Order do
		local ball = p2.Balls[v6]

		if not ball or ball.Pocketed or v6 == CueBallNumber or not PoolRules.IsLegalFirstContact(p, p2, v6) then
			continue
		end

		table.insert(result, v6)
	end

	return result
end

local function evaluate(p, p2, p3: number, vector2: Vector2, p4: number, vector2_2: Vector2?)
	local clone = PoolPhysics.Clone(p)

	PoolPhysics.Shoot(clone, vector2, p4, vector2_2 or Vector2.zero)
	PoolStepper.RunToSettle(clone)
	local firstContact = nil

	for _, event in clone.Events do
		if event.Kind ~= "BallHit" then
			continue
		end

		if event.Ball == CueBallNumber then
			firstContact = event.Other
			break
		elseif event.Other == CueBallNumber then
			firstContact = event.Ball
			break
		end
	end

	local group = PoolRules.GetGroup(p2, p3)

	local moneyBall = PoolRules.MoneyBall(p2)
	local count = 0
	local count2 = 0
	local scratched = false
	local pottedEight = false

	for _, v6 in clone.Order do
		local ball = p.Balls[v6]
		local ball2 = clone.Balls[v6]

		if not ball or not ball2 or not ball2.Pocketed or ball.Pocketed then
			continue
		end

		if v6 == CueBallNumber then
			scratched = true
		elseif v6 == moneyBall then
			pottedEight = true
		else
			local v7 = v6 < PoolConstants.EightBallNumber and "Solid" or "Stripe"

			if group == nil or v7 == group then
				count += 1
			else
				count2 += 1
			end
		end
	end

	local v6 = 1e999

	for _, event in clone.Events do
		if event.Kind == "BallHit" and event.Ball == CueBallNumber and event.Other and event.Time < v6 then
			v6 = event.Time
		end
	end

	local count3 = 0

	for _, event in clone.Events do
		if (event.Kind == "CushionHit" or event.Kind == "TipHit") and v6 <= event.Time then
			count3 += 1
		end
	end

	local ball = clone.Balls[CueBallNumber]

	local v7 = {
		RailsAfterContact = count3,
		FirstContact = firstContact,
		Trial = clone,
		Pots = count - count2,
		Scratched = scratched,
		LegalContact = firstContact ~= nil and PoolRules.IsLegalFirstContact(p2, p, firstContact),
		HitAnything = firstContact ~= nil,
		PottedEight = pottedEight,
		CueRest = 0
	}

	local cueRest = if ball then ball.Position else Vector2.zero
	v7.CueRest = cueRest
	return v7
end

local function nearestValue(p, p2, p3: number, vector2: Vector2)
	local group = PoolRules.GetGroup(p2, p3)
	local minMagnitude = 1e999
	local v6

	if PoolRules.IsNineBall(p2) then
		v6 = PoolRules.LowestBall(p)
	end

	for _, v7 in p.Order do
		local ball = p.Balls[v7]

		if not ball or ball.Pocketed or v7 == CueBallNumber then
			continue
		end

		local v8 = v7 < PoolConstants.EightBallNumber and "Solid" or "Stripe"
		local v9

		if v6 == nil then
			v9 = group == nil or v8 == group or v7 == PoolConstants.EightBallNumber
		else
			v9 = v7 == v6
		end

		if v9 then
			minMagnitude = math.min(minMagnitude, (ball.Position - vector2).Magnitude)
		end
	end

	if minMagnitude == 1e999 then
		return 0
	end

	return 1 - math.clamp(minMagnitude / PoolGeometry.HalfWidth, 0, 1)
end

local pockets = PoolGeometry.GetPockets()

local function pottableFrom(p, p2, p3: number, vector2: Vector2)
	local group = PoolRules.GetGroup(p2, p3)
	local v6

	if group == nil then
		v6 = false
	else
		v6 = PoolRules.CountRemaining(p, group) == 0
	end

	local v7 = 0
	local v8

	if PoolRules.IsNineBall(p2) then
		v8 = PoolRules.LowestBall(p)
	end

	for _, v9 in p.Order do
		local ball = p.Balls[v9]

		if not ball or ball.Pocketed or v9 == CueBallNumber then
			continue
		end

		local v10

		if v8 == nil then
			if v9 == EightBallNumber then
				v10 = v6
			else
				v10 = group == nil or (v9 < EightBallNumber and "Solid" or "Stripe") == group
			end
		else
			v10 = v9 == v8
		end

		if not v10 then
			continue
		end

		for _, pocket in pockets do
			local v11 = ghostBall(ball.Position, pocket.MouthCentre) -- inferred equivalent call
			local v12 = v11 - vector2
			local v13 = cutQuality(v12, pocket.MouthCentre - ball.Position) -- inferred equivalent call

			if not (v13 > 0.25) then
				continue
			end

			local magnitude = v12.Magnitude

			if not (BallDiameter * 0.5 < magnitude) then
				continue
			end

			local v14 = v13 * (1 - math.clamp(
				(v12.Magnitude + (pocket.MouthCentre - ball.Position).Magnitude) / 400,
				0,
				0.8
			))

			if
				not (v7 < v14)
				or (pathBlocked(p, vector2, v11, CueBallNumber, v9) or pathBlocked(
					p,
					ball.Position,
					pocket.MouthCentre,
					CueBallNumber,
					v9
				))
			then
				continue
			end

			v7 = v14
		end
	end

	return v7
end

local function positionValue(state, trial, p, p2: number, cueRest: Vector2) -- 1 equivalent call inferred from this helper
	local v6 = nearestValue(trial, p, p2, cueRest)

	if state.Traits.PositionDepth then
		return pottableFrom(trial, p, p2, cueRest) * 0.75 + v6 * 0.25
	end

	return v6
end

local v6 = { "HeadOn", "SecondBall", "Control" }

local v7 = { HeadOn = "Head-On (Power)", SecondBall = "Second-Ball", Control = "IQ / Control" }

function PoolAI.BreakKindName(p: string?)
	if p then
		return v7[p] or p
	end

	return "?"
end

local function rollRange(random, p) -- 2 equivalent calls inferred from this helper
	return p.Min + (p.Max - p.Min) * random:NextNumber()
end

local function ballNear(p, vector2: Vector2, p2: number)
	local v8 = nil

	for _, v9 in p.Order do
		local ball = p.Balls[v9]

		if not ball or ball.Pocketed or v9 == CueBallNumber then
			continue
		end

		local magnitude = (ball.Position - vector2).Magnitude

		if not (magnitude < p2) then
			continue
		end

		v8 = v9
		p2 = magnitude
	end

	return v8
end

local function firstBallOnLine(p, vector2: Vector2, vector2_2: Vector2)
	local v8 = BallDiameter * BallDiameter
	local v9 = 1e999
	local v10 = nil

	for _, v11 in p.Order do
		local ball = p.Balls[v11]

		if not ball or ball.Pocketed or v11 == CueBallNumber then
			continue
		end

		local vector = ball.Position - vector2
		local dot = vector:Dot(vector2_2)

		if not (dot > 0) then
			continue
		end

		local v12 = vector:Dot(vector) - dot * dot

		if not (v12 < v8) then
			continue
		end

		local v13 = dot - math.sqrt(v8 - v12)

		if not (v13 < v9) then
			continue
		end

		v10 = v11
		v9 = v13
	end

	return v10
end

local function secondRowPoint(p: number) -- 2 equivalent calls inferred from this helper
	return PoolGeometry.FootSpot + Vector2.new(BallDiameter * 0.8660254037844387, p * BallDiameter / 2)
end

local function lineBeside(vector2: Vector2, vector2_2: Vector2, p: number)
	local v8 = vector2_2 - vector2
	local magnitude = v8.Magnitude
	local v9 = v8 / magnitude
	local v10 = math.asin((math.clamp(p * BallDiameter / magnitude, -1, 1)))
	local v11 = math.cos(v10)
	local v12 = math.sin(v10)

	return Vector2.new(v9.X * v11 - v9.Y * v12, v9.X * v12 + v9.Y * v11)
end

local function legalBreakSpot(p, p2, vector2: Vector2) -- 2 equivalent calls inferred from this helper
	return (PoolRules.ClampPlacement(p2, vector2) - vector2).Magnitude < 0.001
		and PoolGeometry.IsInsidePlayArea(vector2, PoolConstants.BallRadius)
		and ballNear(p, vector2, BallDiameter * 1.02) == nil
end

local function pickBreakKind(data)
	local breakWeights = data.Style and data.Style.BreakWeights or v.DefaultWeights
	local total = 0

	for _, v8 in v6 do
		total += math.max(breakWeights[v8] or 0, 0)
	end

	if total <= 0 then
		return "HeadOn"
	end

	local v8 = data.Random:NextNumber() * total

	for _, v9 in v6 do
		v8 -= math.max(breakWeights[v9] or 0, 0)

		if v8 <= 0 then
			return v9
		end
	end

	return v6[#v6]
end

local function chooseBreak(data, p, p2)
	local ball = p.Balls[CueBallNumber]
	local breakSign = data.BreakSign
	local x = PoolGeometry.BreakSpot.X

	if data.Level.BreakStrategic then
		local v8 = pickBreakKind(data)

		local v9 = v8 == "SecondBall" and not ballNear(p, secondRowPoint(breakSign), BallDiameter * 0.6) and "HeadOn" -- inferred equivalent call
			or v8

		local v10 = v9 == "SecondBall" and PoolRules.IsNineBall(p2) and "HeadOn" or v9

		if v10 == "SecondBall" then
			local v11 = rollRange(data.Random, v.SecondBallRailGap) -- inferred equivalent call

			return {
				Kind = "SecondBall",
				Spot = Vector2.new(x, breakSign * (PoolGeometry.HalfHeight - PoolConstants.BallRadius - v11)),
				Side = breakSign,
				Spin = Vector2.zero
			}
		end

		if v10 == "Control" then
			return {
				Kind = "Control",
				Spot = PoolGeometry.BreakSpot,
				Side = breakSign,
				Spin = v.ControlSpin
			}
		end

		return {
			Kind = "HeadOn",
			Spot = Vector2.new(x, breakSign * rollRange(data.Random, v.HeadOnOffCentre)), -- inferred equivalent call
			Side = breakSign,
			Spin = Vector2.zero
		}
	else
		local spot

		if ball and not ball.Pocketed then
			spot = ball.Position
		end

		if spot then
			if not legalBreakSpot(p, p2, spot) then -- inferred equivalent call
				spot = PoolGeometry.BreakSpot
			end
		else
			spot = PoolGeometry.BreakSpot
		end

		return { Kind = "HeadOn", Spot = spot, Side = breakSign, Spin = Vector2.zero }
	end
end

function PoolAI.StaysForBreak(p, p2, p3)
	if p3.Phase ~= "Break" or p.Level.BreakStrategic then
		return false
	end

	local ball = p2.Balls[CueBallNumber]
	return ball ~= nil and not ball.Pocketed and legalBreakSpot(p2, p3, ball.Position) -- inferred equivalent call
end

local function breakPlan(state, p, p2, position: Vector2)
	local breakChoice = state.BreakChoice

	if breakChoice then
		local magnitude = (breakChoice.Spot - position).Magnitude

		if BallDiameter * 1.5 < magnitude then
			breakChoice = {
				Kind = "HeadOn",
				Spot = position,
				Side = state.BreakSign,
				Spin = Vector2.zero
			}
			state.BreakChoice = breakChoice
		end
	else
		breakChoice = {
			Kind = "HeadOn",
			Spot = position,
			Side = state.BreakSign,
			Spin = Vector2.zero
		}
		state.BreakChoice = breakChoice
	end

	local target = ballNear(p, PoolGeometry.FootSpot, 1e999)

	if not target then
		return nil
	end

	local kind = breakChoice.Kind

	local v8 = 0

	local breakKind = kind == "SecondBall" and PoolRules.IsNineBall(p2) and "HeadOn" or kind

	if breakKind == "SecondBall" then
		local v9 = ballNear(p, secondRowPoint(breakChoice.Side), BallDiameter * 0.6) -- inferred equivalent call
		local v10 = nil

		if v9 then
			local position2 = p.Balls[v9].Position

			for i = 0, 30 do
				local v11 = i * 0.03

				if firstBallOnLine(p, position, lineBeside(position, position2, breakChoice.Side * v11)) == v9 then
					v10 = v11
					break
				end
			end
		end

		if v9 and v10 then
			v8 = math.min(v10 + v.SecondBallMargin, Bots.MaxContactOffset)
			target = v9
		else
			breakKind = "HeadOn"
		end
	end

	local position2 = p.Balls[target].Position
	local v9 = position2 - position

	if v9.Magnitude < BallDiameter then
		return nil
	end

	local direction

	if v8 > 0 then
		direction = lineBeside(position, position2, breakChoice.Side * v8)
	else
		direction = v9.Unit
	end

	local spin

	if breakKind == "Control" then
		spin = breakChoice.Spin
	else
		spin = Vector2.zero
	end

	local choice = {
		Target = target,
		Pocket = nil,
		Direction = direction,
		Power = v.Power,
		AimPoint = position2,
		Score = 0,
		Pots = 0,
		Scratches = false,
		Legal = true,
		Quality = 1 - v8,
		Distance = v9.Magnitude,
		Object = position2,
		Bank = false,
		Clean = false,
		Clear = true,
		Spin = 0
	}

	if not (spin.Magnitude > 0.001) then
		spin = nil
	end

	choice.Spin = spin

	return {
		Candidates = { choice },
		Choice = choice,
		Break = true,
		BreakKind = breakKind
	}
end

local function findSafety(p, p2, p3: number, position: Vector2)
	local v8 = p3 == 1 and 2 or 1
	local requireRailAfterContact = PoolRules.GetRules(p2).RequireRailAfterContact == true
	local v9 = legalTargets(p2, p)

	table.sort(v9, function(a, b): boolean
		return (p.Balls[a].Position - position).Magnitude < (p.Balls[b].Position - position).Magnitude
	end)

	local lastTime = os.clock()
	local v10 = 1e999
	local v11 = nil

	for i = 1, math.min(#v9, Human.SafetyTargets) do
		local target = v9[i]
		local position2 = p.Balls[target].Position
		local v12 = position2 - position
		local magnitude = v12.Magnitude

		if not (BallDiameter < magnitude) then
			continue
		end

		local v13 = v12 / magnitude
		local vector2 = Vector2.new(-v13.Y, v13.X)

		for _, safetyContact in Human.SafetyContacts do
			local aimPoint = position2 + vector2 * (safetyContact * BallDiameter)
			local unit = (aimPoint - position).Unit

			for _, safetyPower in Human.SafetyPowers do
				if os.clock() - lastTime > 0.004 then
					task.wait()
					lastTime = os.clock()
				end

				local v14 = evaluate(p, p2, p3, unit, safetyPower)
				local v15

				if v14.FirstContact == target then
					v15 = v14.LegalContact and not (v14.Scratched or v14.PottedEight)

					if v15 then
						if v14.Pots >= 0 then
							v15 = not requireRailAfterContact or v14.RailsAfterContact > 0 or v14.Pots > 0
						else
							v15 = false
						end
					end
				else
					v15 = false
				end

				if not v15 then
					continue
				end

				local v16 = pottableFrom(v14.Trial, p2, v8, v14.CueRest)

				if not (v16 < v10) then
					continue
				end

				v11 = {
					Target = target,
					Pocket = nil,
					Direction = unit,
					Power = safetyPower,
					AimPoint = aimPoint,
					Score = -1,
					Pots = v14.Pots,
					Scratches = false,
					Legal = true,
					Quality = math.max(1 - math.abs(safetyContact), 0.2),
					Distance = magnitude,
					Object = position2,
					Bank = false,
					Clean = false,
					Clear = true,
					Safety = true
				}
				v10 = v16
			end
		end
	end

	return v11, v10
end

local function shapeChance(value: number, value2: number?) -- 2 equivalent calls inferred from this helper
	if value2 then
		value *= 1 + (DynamicMiss.ShotDifficultyWeight or 0) * (1 - math.clamp(value2, 0, 1) * 2)
	end

	return (math.clamp(value, 0, DynamicMiss.MaxChance or 98))
end

function PoolAI.DynamicMissChance(p: string, p2: number, value: number?)
	if not (DynamicMiss and DynamicMiss.Enabled) then
		return nil
	end

	local chance = DynamicMiss.Chances[p]
	local leads = DynamicMiss.Leads

	if not chance or not leads or #leads == 0 then
		return nil
	end

	local v8 = math.clamp(math.round(p2), leads[1], leads[#leads])
	local v9 = table.find(leads, v8)

	if not v9 then
		for i = #leads, 1, -1 do
			if leads[i] <= v8 then
				v9 = i
				break
			end
		end
	end

	local v10 = chance[v9 or 1]

	if not v10 then
		return nil
	end

	return shapeChance(v10, value) -- inferred equivalent call
end

function PoolAI.WinningShotMissChance(p: string, value: number?)
	if not (DynamicMiss and DynamicMiss.Enabled and DynamicMiss.WinningShot) then
		return nil
	end

	local v8 = DynamicMiss.WinningShot[p]

	if not v8 then
		return nil
	end

	return shapeChance(v8, value) -- inferred equivalent call
end

local function rubberBand(data, p, p2, p3: number)
	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail(): (boolean, boolean)
		if PoolAI.WinningShotMissChance(data.Level.Id) ~= nil then
			return false, false
		end

		local finalBallSuccessChance = data.Level.FinalBallSuccessChance

		if finalBallSuccessChance == nil then
			return false, false
		end

		return false, data.Random:NextNumber() * 100 >= math.clamp(finalBallSuccessChance, 0, 100)
	end

	if PoolRules.IsNineBall(p2) then
		if PoolRules.LowestBall(p) ~= PoolConstants.NineBall.BallNumber then
			return false, false
		end

		return deduplicatedTail()
	else
		local group = PoolRules.GetGroup(p2, p3)
		local group2 = PoolRules.GetGroup(p2, p3 == 1 and 2 or 1)

		if group == nil or group2 == nil then
			return false, false
		end

		local countRemaining = PoolRules.CountRemaining(p, group)

		if countRemaining == 0 then
			return deduplicatedTail()
		elseif DynamicMiss and DynamicMiss.Enabled then
			data.CatchUp.Armed = false
			data.CatchUp.Remaining = 0

			return false, false
		else
			local deficit = countRemaining - PoolRules.CountRemaining(p, group2)
			local catchUp = data.CatchUp

			if deficit < CatchUp.Deficit then
				catchUp.Armed = false
				catchUp.Remaining = 0

				return false, false
			end

			if not catchUp.Armed or catchUp.Deficit < deficit then
				catchUp.Armed = true
				catchUp.Deficit = deficit
				catchUp.Remaining = data.Random:NextInteger(CatchUp.Pots.Min, CatchUp.Pots.Max)
			end

			return catchUp.Remaining > 0, false
		end
	end
end

function PoolAI:Plan(p, p2, p3: number)
	local level = self.Level

	local v8 = math.clamp(level.AimError / Bots.MaxContactOffset, 0, 1)
	local style = self.Style
	local traits = self.Traits
	local ball = p.Balls[CueBallNumber]

	if not ball or ball.Pocketed then
		return { Candidates = {}, Choice = nil }
	end

	local position = ball.Position

	local v9 = p2.Phase == "Break" and breakPlan(self, p, p2, position)

	if v9 then
		return v9
	end

	local pockets2 = PoolGeometry.GetPockets()
	local v10 = {}
	local v11, forceMiss = rubberBand(self, p, p2, p3)

	local group = PoolRules.GetGroup(p2, p3)
	local group2 = PoolRules.GetGroup(p2, p3 == 1 and 2 or 1)
	local ownLeft

	if group then
		ownLeft = PoolRules.CountRemaining(p, group)
	end

	if ownLeft and self.LastOwnLeft then
		if ownLeft < self.LastOwnLeft then
			self.Streak = math.max(self.Streak, 0) + 1
		else
			self.Streak = math.min(self.Streak, 0) - 1
		end
	end

	self.LastOwnLeft = nil
	local pressure

	if group and group2 and ownLeft then
		if PoolRules.CountRemaining(p, group2) == 0 or ownLeft == 1 then
			pressure = true
		elseif ownLeft == 0 then
			pressure = level.FinalBallSuccessChance == nil
		else
			pressure = false
		end
	else
		pressure = false
	end

	for _, target in legalTargets(p2, p) do
		local position2 = p.Balls[target].Position

		for _, pocket in pockets2 do
			local aimPoint = ghostBall(position2, pocket.MouthCentre) -- inferred equivalent call
			local v12 = aimPoint - position
			local quality = cutQuality(v12, pocket.MouthCentre - position2) -- inferred equivalent call

			if not (quality > 0.08) then
				continue
			end

			local magnitude = v12.Magnitude

			if not (BallDiameter * 0.5 < magnitude) then
				continue
			end

			local clear = not (pathBlocked(p, position, aimPoint, CueBallNumber, target) or pathBlocked(
				p,
				position2,
				pocket.MouthCentre,
				CueBallNumber,
				target
			))

			table.insert(v10, {
				Target = target,
				Pocket = pocket.Id,
				Direction = v12.Unit,
				AimPoint = aimPoint,
				Object = position2,
				Quality = quality,
				Clear = clear,
				Bank = false,
				Distance = v12.Magnitude + (pocket.MouthCentre - position2).Magnitude
			})
		end
	end

	local flag = false

	for _, v12 in v10 do
		if v12.Clear then
			flag = true
			break
		end
	end

	local v12

	if flag then
		if style.BankLove > 0 then
			v12 = self.Random:NextNumber() < style.BankLove * 0.4
		else
			v12 = false
		end
	else
		v12 = flag
	end

	local v13 = nil

	if not flag or v12 then
		local v14 = {}

		for _, v15 in legalTargets(p2, p) do
			local position2 = p.Balls[v15].Position

			for _, pocket in pockets2 do
				for _, v16 in v5 do
					local v17 = bankProposal(p, position, v15, position2, pocket, v16)

					if v17 then
						table.insert(v14, v17)
					end
				end
			end
		end

		table.sort(v14, function(a, b): boolean
			return a.Quality - a.Distance / 400 > b.Quality - b.Distance / 400
		end)

		if flag then
			v13 = v14[1]
		else
			for i = 1, math.min(#v14, Bots.MaxBankProposals) do
				table.insert(v10, v14[i])
			end
		end
	end

	table.sort(v10, function(a, b)
		if a.Clear == b.Clear then
			return a.Quality - a.Distance / 400 > b.Quality - b.Distance / 400
		end

		return a.Clear
	end)

	if v13 then
		table.insert(v10, math.min(2, #v10 + 1), v13)
	end

	local v14 = {}

	local v15 = math.min(#v10, level.Candidates + 2)

	if v11 then
		v15 = math.max(v15, (math.min(#v10, CatchUp.SearchLines)))
	end

	local lastTime = os.clock()
	local fullPower, v16

	if level.FullPower then
		fullPower = math.clamp(level.FullPowerChance or 100, 0, 100) > self.Random:NextNumber() * 100
		v16 = not fullPower
	else
		fullPower = false
		v16 = false
	end

	local v17

	if fullPower then
		v17 = { 1 }
	elseif v16 then
		v17 = { 0.55, 0.85 }
	elseif level.Candidates >= 5 then
		v17 = { 0.5, 0.7, 0.92 }
	elseif level.Candidates >= 3 then
		v17 = { 0.55, 0.85 }
	else
		v17 = { 0.7 }
	end

	if style.PowerBias ~= 0 and not fullPower then
		local v18 = {}

		for _, v19 in v17 do
			table.insert(v18, (math.clamp(v19 * (style.PowerBias + 1), 0.2, 1)))
		end

		v17 = v18
	end

	if v11 and not fullPower then
		v17 = CatchUp.Powers
	end

	local softPowers

	if not v11 then
		softPowers = level.SoftPowers
	end

	local isOnEight = PoolRules.IsOnEight(p, PoolRules.GetGroup(p2, p3))

	local isNineBall = PoolRules.IsNineBall(p2)

	local function softPotted(data) -- 2 equivalent calls inferred from this helper
		if not data.LegalContact or data.Scratched then
			return false
		end

		if isNineBall then
			return data.Pots > 0 or data.PottedEight
		end

		if isOnEight then
			return data.PottedEight
		end

		return data.Pots > 0 and not data.PottedEight
	end

	local function isClean(data) -- 2 equivalent calls inferred from this helper
		if not data.LegalContact or data.Scratched then
			return false
		end

		if isNineBall then
			return data.Pots > 0 or data.PottedEight
		end

		return data.Pots > 0 and not data.PottedEight
	end

	local v18

	if softPowers then
		v18 = table.clone(softPowers)

		for _, v19 in v17 do
			table.insert(v18, v19)
		end
	else
		v18 = v17
	end

	local v19 = math.max(style.Risk, 0.1)

	local function scoreOutcome(data, data2, p4: number)
		if not data.HitAnything then
			return -100
		end

		if not data.LegalContact then
			return -60
		end

		local v20 = data.Pots * 12

		if data.Scratched then
			v20 -= 16
		end

		if data.PottedEight and isNineBall then
			v20 += data.Scratched and -10 or 60
		elseif data.PottedEight then
			local group3 = PoolRules.GetGroup(p2, p3)
			v20 += group3 ~= nil and PoolRules.CountRemaining(p, group3) == 0 and not data.Scratched and 60 or -120
		end

		if level.PositionWeight > 0 then
			v20 += positionValue(self, data.Trial, p2, p3, data.CueRest) * 6 * level.PositionWeight -- inferred equivalent call
		end

		local v21 = v20 + data2.Quality * (2 + v8 * Bots.JudgementQualityWeight / v19) - data2.Distance / 200 * v8 * Bots.JudgementDistanceWeight / v19

		if not data2.Clear then
			v21 -= 8
		end

		if data2.Bank then
			v21 -= 3

			if data.Pots > 0 then
				v21 += style.BankLove * 4
			end
		end

		return v21 - p4 * 0.6
	end

	for i = 1, v15 do
		local v20 = v10[i]
		local v21 = nil
		local v22

		if softPowers and i <= Bots.SoftPotLines and not v20.Bank and v20.Distance <= Bots.SoftPotMaxDistance then
			v22 = v18
		else
			v22 = v17
		end

		for _, power in v22 do
			if os.clock() - lastTime > 0.004 then
				task.wait()
				lastTime = os.clock()
			end

			local v23 = evaluate(p, p2, p3, v20.Direction, power)

			if softPowers and table.find(softPowers, power) then
				if not softPotted(v23) then -- inferred equivalent call
					continue
				end

				local v24 = power * (1 - level.PowerError - Bots.SoftPotMargin)
				local v25 = evaluate(p, p2, p3, v20.Direction, v24)

				if not softPotted(v25) or v25.Pots < v23.Pots then -- inferred equivalent call
					continue
				end
			end

			local score = scoreOutcome(v23, v20, power)

			if not (not v21 or v21.Score < score) then
				continue
			end

			v21 = {
				Target = v20.Target,
				Pocket = v20.Pocket,
				Direction = v20.Direction,
				Power = power,
				AimPoint = v20.AimPoint,
				Score = score,
				Pots = v23.Pots,
				Scratches = v23.Scratched,
				Legal = v23.LegalContact,
				Quality = v20.Quality,
				Distance = v20.Distance,
				Object = v20.Object,
				Bank = v20.Bank == true,
				Clear = v20.Clear ~= false,
				Clean = 0
			}
			v21.Clean = isClean(v23) -- inferred equivalent call
		end

		if v21 then
			table.insert(v14, v21)
		end
	end

	table.sort(v14, function(a, b): boolean
		return a.Score > b.Score
	end)

	local spinUse = traits.SpinUse or 0

	if spinUse > 0 and not (v11 or forceMiss) then
		local clone = table.clone(Human.SpinBasic)

		if spinUse >= 2 then
			for _, v20 in Human.SpinSide do
				table.insert(clone, v20)
			end
		end

		for i = 1, math.min(Human.SpinTopCandidates, #v14) do
			local v20 = v14[i]

			if v20.Bank then
				continue
			end

			local v21 = {
				Quality = v20.Quality,
				Distance = v20.Distance,
				Clear = v20.Clear ~= false,
				Bank = false
			}

			for _, spin in clone do
				if os.clock() - lastTime > 0.004 then
					task.wait()
					lastTime = os.clock()
				end

				local v22 = evaluate(p, p2, p3, v20.Direction, v20.Power, spin)
				local score = scoreOutcome(v22, v21, v20.Power) - 0.4

				if not (v20.Score < score) then
					continue
				end

				v20.Score = score
				v20.Spin = spin
				v20.Pots = v22.Pots
				v20.Scratches = v22.Scratched
				v20.Legal = v22.LegalContact
				v20.Clean = isClean(v22) -- inferred equivalent call
			end
		end

		table.sort(v14, function(a, b): boolean
			return a.Score > b.Score
		end)
	end

	if traits.PlaysSafeties and not v11 and not forceMiss and group and group2 then
		local v20 = false

		for _, v21 in v14 do
			if isOnEight and v21.Score >= 30 or not isOnEight and v21.Clean then
				v20 = true
				break
			end
		end

		if not v20 then
			local safety, v21 = findSafety(p, p2, p3, position)
			local v22 = v14[1]
			local v23 = v22 == nil or (not v22.Legal or v22.Scratches)

			if safety and (v21 <= Human.SafetyMaxOpponentChance or v23) then
				table.insert(v14, 1, safety)
			end
		end
	end

	local assist = false

	if v11 then
		for k, v20 in v14 do
			if v20.Clean then
				table.remove(v14, k)
				table.insert(v14, 1, v20)
				assist = true
				break
			end
		end
	end

	local candidates = {}

	for i = 1, math.min(level.Candidates, #v14) do
		table.insert(candidates, v14[i])
	end

	local dynamicMiss = nil
	local lead = nil
	local winning = false
	local v20 = candidates[1]

	if v20 and not v20.Safety and not assist and not forceMiss and p2.Phase ~= "Break" then
		local v21

		if PoolRules.IsNineBall(p2) then
			v21 = PoolRules.LowestBall(p) == PoolConstants.NineBall.BallNumber
		else
			v21 = ownLeft == 0
		end

		if v21 then
			dynamicMiss = PoolAI.WinningShotMissChance(level.Id, PoolAI.Confidence(v20))
			winning = not (dynamicMiss == nil)
		end

		if dynamicMiss == nil and ownLeft ~= 0 then
			lead = not (group and group2 and ownLeft) and 0 or PoolRules.CountRemaining(p, group2) - ownLeft

			dynamicMiss = PoolAI.DynamicMissChance(level.Id, lead, PoolAI.Confidence(v20))
		end
	end

	return {
		Candidates = candidates,
		Choice = candidates[1],
		Assist = assist,
		ForceMiss = forceMiss,
		Pressure = pressure,
		OwnLeft = ownLeft,
		FullPower = fullPower,
		DynamicMiss = dynamicMiss,
		Lead = lead,
		Winning = winning
	}
end

function PoolAI:PlaceCueBallOptions(p, p2, value: number?)
	if p2.Phase == "Break" then
		local breakChoice = chooseBreak(self, p, p2)

		self.BreakChoice = breakChoice

		return { breakChoice.Spot }
	else
		local pockets2 = PoolGeometry.GetPockets()

		local v8 = BallDiameter * 9

		local function blocked(clampToPlayArea: Vector2): boolean
			for _, v9 in p.Order do
				local ball = p.Balls[v9]

				if
					ball
					and not ball.Pocketed
					and v9 ~= CueBallNumber
					and (ball.Position - clampToPlayArea).Magnitude < BallDiameter * 1.05
				then
					return true
				end
			end

			return false
		end

		local v9 = {}

		for _, v10 in legalTargets(p2, p) do
			local position = p.Balls[v10].Position

			for _, pocket in pockets2 do
				local v11 = pocket.MouthCentre - position

				if not (v11.Magnitude > 0.0001) then
					continue
				end

				local v12 = position - v11.Unit * v8
				local clampToPlayArea = PoolGeometry.ClampToPlayArea(v12)

				local v13 = not (blocked(clampToPlayArea) or pathBlocked(
					p,
					clampToPlayArea,
					position,
					CueBallNumber,
					v10
				) or pathBlocked(p, position, pocket.MouthCentre, CueBallNumber, v10))

				if (clampToPlayArea - v12).Magnitude < 0.1 and v13 then
					table.insert(v9, {
						Spot = clampToPlayArea,
						Quality = 1 / (1 + v11.Magnitude / 100)
					})
				end
			end
		end

		table.sort(v9, function(a, b): boolean
			return a.Quality > b.Quality
		end)

		local v10 = math.max(value or 1, 1)
		local spots = {}

		for _, v11 in v9 do
			if v10 <= #spots then
				break
			end

			local flag = true

			for _, v12 in spots do
				if (v12 - v11.Spot).Magnitude < BallDiameter * 6 then
					flag = false
					break
				end
			end

			if flag then
				table.insert(spots, v11.Spot)
			end
		end

		return spots
	end
end

function PoolAI.PlaceCueBall(p, p2, p3)
	local placeCueBallOptions = PoolAI.PlaceCueBallOptions(p, p2, p3, 1)

	if placeCueBallOptions[1] then
		return placeCueBallOptions[1]
	end

	local ball = p2.Balls[CueBallNumber]

	return if ball then ball.Position else Vector2.zero
end

function PoolAI.Confidence(data)
	if not data then
		return 0.2
	end

	local v8 = math.clamp(data.Quality, 0, 1)
	local v9 = 1 - math.clamp(data.Distance / Theatre.LongShot, 0, 1)
	local v10 = data.Pots > 0 and 1 or 0

	return (math.clamp(v8 * 0.45 + v9 * 0.2 + v10 * 0.35, 0, 1))
end

local function lerp(p: number, p2: number, value: number) -- 6 equivalent calls inferred from this helper
	return p + (p2 - p) * math.clamp(value, 0, 1)
end

local function jitter(random, p: number) -- 8 equivalent calls inferred from this helper
	return p * (1 + (random:NextNumber() * 2 - 1) * Theatre.Jitter)
end

local function spread(object, p) -- 18 equivalent calls inferred from this helper
	return p.Min + (p.Max - p.Min) * object:NextNumber()
end

local function rotate(vector2: Vector2, p: number) -- 6 equivalent calls inferred from this helper
	local v8 = math.cos(p)
	local v9 = math.sin(p)

	return Vector2.new(vector2.X * v8 - vector2.Y * v9, vector2.X * v9 + vector2.Y * v8)
end

local function scaleToBudget(items, p: number)
	local total = 0

	for _, item in items do
		total += item.Sweep + item.Rest
	end

	if total <= 0.0001 then
		return
	end

	local v8 = p / total

	for _, item in items do
		item.Sweep *= v8
		item.Rest *= v8
	end
end

local function appendDrag(list, random, vector2: Vector2, direction: Vector2, sweep: number, rest: number)
	local v8 = math.atan2(vector2.Y, vector2.X)
	local v9 = (math.atan2(direction.Y, direction.X) - v8 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
	local integer = random:NextInteger(Theatre.DragSegments.Min, Theatre.DragSegments.Max)

	local v10 = (math.abs(v9) < 0.06981317007977318 or sweep < 0.18) and 1 or integer

	local v11 = {}
	local total = 0

	for i = 1, v10 - 1 do
		v11[i] = math.min(spread(random, Theatre.DragPauseSeconds), sweep / (v10 * 2)) -- inferred equivalent call

		total += v11[i]
	end

	local v12 = math.max(sweep - total, 0.02 * v10)

	for i = 1, v10 do
		local v13 = i == v10
		local v14 = v8 + v9 * (i / v10)

		if not v13 then
			v14 += math.rad(Theatre.DragWanderDegrees) * (random:NextNumber() * 2 - 1)
		end

		local v15 = {
			Direction = Vector2.new(math.cos(v14), (math.sin(v14))),
			Sweep = v12 / v10,
			Rest = 0
		}
		local rest2

		if v13 then
			rest2 = rest
		else
			rest2 = v11[i]
		end

		v15.Rest = rest2
		table.insert(list, v15)
	end
end

local function weightedBallCount(random, value: number)
	local ballCountWeights = Theatre.BallCountWeights
	local v8 = math.clamp(value, 1, #ballCountWeights)
	local total = 0

	for i = 1, v8 do
		total += ballCountWeights[i] or 0
	end

	if total <= 0 then
		return 1
	end

	local v9 = random:NextNumber() * total

	for i = 1, v8 do
		v9 -= ballCountWeights[i] or 0

		if v9 <= 0 then
			return i
		end
	end

	return v8
end

local function idleDirection(random, data, vector2: Vector2)
	local v8 = math.cos((math.rad(Theatre.OffBallDegrees.Min)))

	for _ = 1, 8 do
		local v9 = random:NextNumber() < 0.5 and -1 or 1
		local v10 = rotate(vector2, math.rad(spread(random, Theatre.OffBallDegrees) * v9)) -- inferred equivalent call
		local flag = true

		for _, candidate in data.Candidates do
			if v8 < candidate.Direction:Dot(v10) then
				flag = false
				break
			end
		end

		if flag then
			return v10
		end
	end

	return rotate(vector2, math.rad(Theatre.OffBallDegrees.Max))
end

function PoolAI.BuildTurn(data)
	local random = data.Random

	local v8 = not data.Style and 1 or data.Style.Tempo
	local fidget = not data.Style and 1 or data.Style.Fidget
	local v9

	if data.Traits then
		v9 = data.Traits.TurnSeconds
	else
		v9 = Theatre.TurnSeconds
	end

	local seconds = spread(random, v9) * v8 -- inferred equivalent call
	local v10

	if data.Style and data.Style.PullSeconds then
		v10 = data.Style.PullSeconds
	else
		v10 = { Min = Theatre.ChargeFillSeconds, Max = Theatre.ChargeFillSeconds }
	end

	local pull = math.max(spread(random, v10), Theatre.ChargeFillSeconds) -- inferred equivalent call
	local charge = pull + spread(random, Theatre.ChargeHoldSeconds) * v8 -- inferred equivalent call

	local v11 = seconds - charge - Theatre.CommitSweep - Theatre.MinBrowseSeconds
	local settle = math.min(spread(random, Theatre.SettleSeconds), (math.max(v11, Theatre.MinSettleSeconds))) -- inferred equivalent call
	return {
		Seconds = seconds,
		Browse = math.max(seconds - settle - charge - Theatre.CommitSweep, Theatre.MinBrowseSeconds),
		Settle = settle,
		Charge = charge,
		Pull = pull,
		OnBall = spread(random, Theatre.OnBallFraction), -- inferred equivalent call
		OverAim = math.clamp(spread(random, Theatre.OverAimChance) * fidget, 0, 0.8), -- inferred equivalent call
		PlaceHold = spread(random, Theatre.PlaceHoldSeconds) * v8, -- inferred equivalent call
		Reconsider = random:NextNumber() < math.clamp(Theatre.ReconsiderChance * fidget, 0, 0.6),
		ReconsiderHold = spread(random, Theatre.ReconsiderHoldSeconds) * v8, -- inferred equivalent call
		Fidget = fidget
	}
end

local function missSide(vector2: Vector2?, vector2_2: Vector2?)
	if not vector2 or not vector2_2 or vector2.Magnitude < 0.0001 or vector2_2.Magnitude < 0.0001 then
		return 0, 0
	end

	local unit = vector2.Unit
	local unit2 = vector2_2.Unit
	local v8 = math.atan2(unit.X * unit2.Y - unit.Y * unit2.X, (unit:Dot(unit2)))

	if math.abs(v8) < math.rad(Theatre.MissSideDegrees) then
		return 0, v8
	end

	return v8 > 0 and 1 or -1, v8
end

local function keepOffPocket(items, vector2: Vector2?, vector2_2: Vector2?, flag: boolean)
	local v8, v9 = missSide(vector2, vector2_2)

	if v8 == 0 or not vector2 then
		return
	end

	local unit = vector2.Unit
	local v10 = math.abs(v9)

	for _, item in items do
		local unit2 = item.Direction.Unit
		local v11 = math.atan2(unit.X * unit2.Y - unit.Y * unit2.X, (unit:Dot(unit2)))
		local v12 = v11 * v8

		if v12 < v10 and (not flag or math.abs(v11) <= v10) then
			item.Direction = rotate(unit, v8 * (v10 + (v10 - v12))) -- inferred equivalent call
		end
	end
end

local function playedRestLine(random, direction: Vector2, vector2: Vector2?)
	local v8, v9 = missSide(direction, vector2)

	if v8 == 0 then
		if vector2 then
			return direction
		end

		return rotate(
			direction,
			(random:NextNumber() < 0.5 and -1 or 1) * math.rad(spread(random, Theatre.MissApproachDegrees)) -- inferred equivalent call
		)
	end

	return rotate(direction, v9 + v8 * math.rad(spread(random, Theatre.MissApproachDegrees))) -- inferred equivalent call
end

function PoolAI.BuildLookSequence(p, data, data2, vector2: Vector2?, vector2_2: Vector2?)
	local choice = data.Choice

	if not choice or #data.Candidates == 0 then
		return {}
	end

	local random = p.Random
	local v8 = weightedBallCount(
		random,
		math.clamp(math.round(p.Level.Candidates / 2), Theatre.MinBalls, Theatre.MaxBalls)
	)

	local v9 = { choice.Target }

	for _, candidate in data.Candidates do
		if v8 <= #v9 then
			break
		end

		if not table.find(v9, candidate.Target) then
			table.insert(v9, candidate.Target)
		end
	end

	for i = #v9, 2, -1 do
		local integer = random:NextInteger(1, i)
		local v10 = v9[integer]
		local v11 = v9[i]
		v9[i] = v10
		v9[integer] = v11
	end

	if #v9 > 1 and v9[#v9] == choice.Target then
		local v10 = #v9
		local v11 = v9[1]
		local v12 = v9[#v9]
		v9[v10] = v11
		v9[1] = v12
	end

	local v10 = {}

	for _, v11 in v9 do
		local candidates = {}

		for _, candidate in data.Candidates do
			if candidate.Target == v11 then
				table.insert(candidates, candidate)
			end
		end

		for i = 1, math.min(#candidates, random:NextInteger(1, Theatre.MaxSpotsPerBall)) do
			table.insert(v10, candidates[i])
		end
	end

	if #v10 == 0 then
		return {}
	end

	local confidence = PoolAI.Confidence(choice)
	local v11 = math.max(data2.Browse * (1 + Human.HardShotTimeScale * (1 - 2 * confidence)), Theatre.MinBrowseSeconds)

	local v12 = math.clamp(math.floor(v11 / Theatre.MinLookSeconds), 1, Theatre.MaxLooks)
	local v13 = math.min(#v10, v12)
	local v14 = math.clamp(
		math.round(v13 * (1 - data2.OnBall) / math.max(data2.OnBall, 0.2)),
		0,
		Theatre.MaxLooks - v13
	)

	local v15 = {}

	for i = 1, v13 do
		table.insert(v15, { Line = v10[i] })
	end

	for _ = 1, v14 do
		table.insert(v15, random:NextInteger(1, #v15), { Line = nil })
	end

	local direction = vector2 or choice.Direction
	local v16 = math.clamp(data2.OverAim, 0, 1)

	local v17 = data.Break and 0 or missSide(choice.Direction, vector2_2)
	local v18 = {}

	for _, v19 in v15 do
		local line = v19.Line
		local v20

		if line == nil then
			v20 = false
		else
			v20 = not data.Break

			if v20 then
				if line == choice then
					v20 = true
				elseif line.Target == choice.Target then
					v20 = (line.Direction - choice.Direction).Magnitude < 0.001
				else
					v20 = false
				end
			end
		end

		local v21

		if line then
			if v20 then
				direction = playedRestLine(random, line.Direction, vector2_2)
			else
				direction = line.Direction
			end

			v21 = PoolAI.Confidence(line)
		else
			direction = idleDirection(random, data, direction)
			v21 = 0.15
		end

		if line and random:NextNumber() < v16 then
			local v22 = random:NextNumber() < 0.5 and -1 or 1

			if v20 and v17 ~= 0 then
				v22 = v17
			end

			local v23 = {
				Direction = rotate(direction, math.rad(spread(random, Theatre.OverAimDegrees) * v22)), -- inferred equivalent call
				Sweep = jitter(random, lerp(Theatre.SweepSlow, Theatre.SweepFast, v21)), -- inferred equivalent call
				Rest = jitter(random, Theatre.RestFast) -- inferred equivalent call
			}
			table.insert(v18, v23)
		end

		local v22 = {
			Direction = direction,
			Sweep = jitter(random, lerp(Theatre.SweepSlow, Theatre.SweepFast, v21)), -- inferred equivalent call
			Rest = jitter(random, lerp(Theatre.RestSlow, Theatre.RestFast, v21)) -- inferred equivalent call
		}
		table.insert(v18, v22)
	end

	scaleToBudget(v18, v11)

	local v19 = vector2 or v18[1].Direction
	local v20 = {}

	for _, v21 in v18 do
		appendDrag(v20, random, v19, v21.Direction, v21.Sweep, v21.Rest)
		v19 = v21.Direction
	end

	if not data.Break then
		keepOffPocket(v20, choice.Direction, vector2_2, true)
	end

	return v20
end

function PoolAI.BuildSettleSequence(p, vector2: Vector2, value: number, data, vector2_2: Vector2?)
	local random = p.Random
	local v8 = missSide(vector2_2, vector2)
	local v9 = Theatre.MaxAdjustments - Theatre.MinAdjustments

	local v10 = math.clamp(
		Theatre.MinAdjustments + math.round((1 - math.clamp(value, 0, 1)) * v9) + math.round(((data.Fidget or 1) - 1) * 2),
		1,
		Theatre.MaxAdjustments + 2
	)

	local v11 = math.atan2(vector2.Y, vector2.X)
	local v12 = {}

	if random:NextNumber() < math.clamp(data.OverAim, 0, 1) then
		local v13 = random:NextNumber() < 0.5 and -1 or 1

		if v8 ~= 0 then
			v13 = v8
		end

		local v14 = v11 + math.rad(spread(random, Theatre.OverAimDegrees) * v13) -- inferred equivalent call

		table.insert(v12, {
			Direction = Vector2.new(math.cos(v14), (math.sin(v14))),
			Sweep = jitter(random, Theatre.AdjustSweep * 1.6), -- inferred equivalent call
			Rest = jitter(random, Theatre.AdjustRest * 0.6) -- inferred equivalent call
		})
	end

	for i = 1, v10 do
		local v13 = 1 - (i - 1) / v10
		local v14 = math.rad(Theatre.AdjustDegrees) * v13 * (random:NextNumber() * 2 - 1)

		if v8 ~= 0 then
			v14 = math.abs(v14) * v8
		end

		local v15 = v11 + v14

		table.insert(v12, {
			Direction = Vector2.new(math.cos(v15), (math.sin(v15))),
			Sweep = jitter(random, Theatre.AdjustSweep), -- inferred equivalent call
			Rest = jitter(random, Theatre.AdjustRest) -- inferred equivalent call
		})
	end

	scaleToBudget(v12, math.max(data.Settle, 0.2))
	local v13 = vector2
	local settleSequence = {}

	for _, v14 in v12 do
		appendDrag(settleSequence, random, v13, v14.Direction, v14.Sweep, v14.Rest)
		v13 = v14.Direction
	end

	keepOffPocket(settleSequence, vector2_2, vector2, false)

	return settleSequence
end

local function firstContact(p, position: Vector2, vector2: Vector2)
	local v8 = 1e999
	local v9 = nil

	for _, v10 in p.Order do
		local ball = p.Balls[v10]

		if not ball or ball.Pocketed or v10 == CueBallNumber then
			continue
		end

		local vector = ball.Position - position
		local dot = vector:Dot(vector2)

		if not (dot > 0) then
			continue
		end

		local v11 = math.abs(vector2.X * vector.Y - vector2.Y * vector.X)

		if not (v11 < BallDiameter) then
			continue
		end

		local v12 = dot - math.sqrt(BallDiameter * BallDiameter - v11 * v11)

		if not (v12 < v8) then
			continue
		end

		v9 = v10
		v8 = v12
	end

	return v9
end

local function strikeMisses(p, vector2: Vector2, p2: number, target: number, flag: boolean?, vector2_2: Vector2?)
	local clone = PoolPhysics.Clone(p)

	PoolPhysics.Shoot(clone, vector2, p2, vector2_2 or Vector2.zero)

	local v8 = #clone.Events
	local v9 = math.ceil(PoolStepper.MaxSettleSeconds / PoolStepper.FixedDelta)
	local lastTime = os.clock()

	local function scratched() -- 4 equivalent calls inferred from this helper
		local ball = clone.Balls[CueBallNumber]

		return ball ~= nil and (ball.Pocketed or ball.Sinking)
	end

	local v10 = nil

	for _ = 1, v9 do
		if clone.Settled then
			break
		end

		PoolPhysics.Step(clone, PoolStepper.FixedDelta)

		if flag and os.clock() - lastTime > 0.004 then
			task.wait()
			lastTime = os.clock()
		end

		if not v10 then
			for i = v8 + 1, #clone.Events do
				local event = clone.Events[i]

				if event.Kind ~= "BallHit" then
					continue
				end

				if event.Ball == CueBallNumber then
					v10 = event.Other
					break
				end

				if event.Other == CueBallNumber then
					v10 = event.Ball
					break
				end
			end

			v8 = #clone.Events

			if v10 and v10 ~= target then
				return false, scratched() -- inferred equivalent call
			end
		end

		if not v10 then
			continue
		end

		local ball = clone.Balls[target]

		if ball and not (ball.Pocketed or ball.Sinking) then
			if ball.Velocity == Vector2.zero then
				return true, scratched() -- inferred equivalent call
			end
		else
			return false, scratched() -- inferred equivalent call
		end
	end

	local ball = clone.Balls[target]
	return v10 == target and ball ~= nil and not ball.Pocketed, scratched() -- inferred equivalent call
end

local function aimErrorFor(data, p, p2)
	local v8 = data.Level.AimError * (data.Form or 1)
	local v9 = math.clamp(p2.Distance / Theatre.LongShot, 0, 1.5)
	local v10 = 1 - math.clamp(p2.Quality, 0, 1)

	local v11 = v8 * ((Human.DistanceBase + Human.DistanceScale * v9) * (Human.CutBase + Human.CutScale * v10))

	local streak = data.Streak or 0

	if streak > 0 then
		v11 *= 1 - Human.StreakBonus * math.min(streak, Human.StreakCap)
	elseif streak < 0 then
		v11 *= 1 + Human.TiltPenalty * math.min(-streak, Human.TiltCap)
	end

	if p.Pressure and data.Traits then
		local v12 = not data.Style and 1 or data.Style.Nerves

		return v11 * ((data.Traits.PressureError - 1) * v12 + 1)
	end

	return v11
end

local NearMiss = Bots.NearMiss

local pocketsById = {}

for _, pocket in pockets do
	pocketsById[pocket.Id] = pocket
end

local function objectHeading(vector2: Vector2, vector: Vector2, vector2_2: Vector2)
	local v8 = vector2_2 - vector2
	local dot = vector:Dot(v8)
	local v9 = vector.X * v8.Y - vector.Y * v8.X

	if dot <= 0 then
		return nil
	end

	if BallDiameter <= math.abs(v9) then
		return nil
	end

	local v10 = vector2_2 - (vector2 + vector * (dot - math.sqrt(BallDiameter * BallDiameter - v9 * v9)))

	return if not (v10.Magnitude <= 1e-6) then v10.Unit else nil
end

local function passSide(vector: Vector2, vector2: Vector2) -- 2 equivalent calls inferred from this helper
	return vector.X * vector2.Y - vector.Y * vector2.X
end

local function contactForPass(position: Vector2, object: Vector2, vector2: Vector2, callback, p: number)
	local function sideAt(p2: number) -- 5 equivalent calls inferred from this helper
		local vector = objectHeading(position, callback(p2), object)

		if not vector or vector:Dot(vector2) <= 0 then
			return nil
		end

		return passSide(vector, vector2) -- inferred equivalent call
	end

	local v8 = sideAt(0) -- inferred equivalent call

	if not v8 then
		return nil
	end

	local v9 = BallDiameter * 0.01
	local v10 = sideAt(v9) -- inferred equivalent call
	local v11 = sideAt(-v9) -- inferred equivalent call
	local v12

	if v10 and math.abs(v10 - v8) > 1e-9 then
		v12 = v8 < v10
	elseif v11 and math.abs(v8 - v11) > 1e-9 then
		v12 = v11 < v8
	else
		return nil
	end

	local v13 = v12 == (v8 < p) and 1 or -1

	local v14 = BallDiameter * 0.04
	local v15 = 0
	local v16 = nil

	while math.abs(v15) < BallDiameter * 2 do
		local v17 = v15 + v13 * v14
		local v18 = sideAt(v17) -- inferred equivalent call

		if not v18 then
			return nil
		end

		if (v18 - p) * (v8 - p) <= 0 then
			v16 = v17
			break
		end

		if math.abs(v18 - v8) < 1e-6 then
			return nil
		end

		v14 *= 1.6
		v8 = v18
		v15 = v17
	end

	if not v16 then
		return nil
	end

	for _ = 1, 24 do
		local midpoint = (v15 + v16) / 2
		local v17 = sideAt(midpoint) -- inferred equivalent call

		if v17 and (v17 - p) * (v8 - p) > 0 then
			v8 = v17
			v15 = midpoint
		else
			v16 = midpoint
		end
	end

	return (v15 + v16) / 2
end

local function nearMissLine(state, p, choice, data, contactLine, vector2: Vector2, p2: number, flag: boolean, number: number, p3: number, p4: number, vector2_2: Vector2, flag2: boolean?)
	local ball = p.Balls[CueBallNumber]

	if not ball then
		return vector2, false
	end

	local position = ball.Position
	local object = choice.Object
	local v8 = data.MouthCentre - object
	local magnitude = v8.Magnitude

	if magnitude <= 0.001 then
		return vector2, false
	end

	local v9 = data.Mouth * 0.5 * math.abs(((v8 / magnitude):Dot(data.Normal)))
	local v10 = v9 + NearMiss.KeepBeyond * BallDiameter

	local vector = objectHeading(position, vector2, object)
	local v11

	if vector == nil then
		v11 = false
	else
		v11 = vector:Dot(v8) > 0
	end

	local v12 = not vector and 0 or passSide(vector, v8) -- inferred equivalent call
	local v13 = not v11 or v10 < math.abs(v12)

	if not (v13 or flag) then
		return vector2, true
	end

	local v14 = math.clamp(state.Level.MissBadly or NearMiss.DefaultMissBadly or 0, 0, 1)
	local v15

	if v13 then
		v15 = math.clamp((not v11 and 1e999 or math.abs(v12) - v10) / (NearMiss.SeverityWidths * BallDiameter), 0, 1)
	else
		v15 = number ^ lerp(NearMiss.DeliberateBias, 1, v14) -- inferred equivalent call
	end

	local v16 = lerp(NearMiss.MaxSteady, NearMiss.MaxSevere, v14) -- inferred equivalent call
	local v17 = math.min(
		math.max(lerp(NearMiss.Min, v16, v15) + p3 * NearMiss.Jitter, NearMiss.Floor), -- inferred equivalent call
		(math.max(
			(magnitude * math.sin((math.rad(NearMiss.BelievableAngle or NearMiss.MaxAngle))) - v9) / BallDiameter,
			NearMiss.Min
		))
	)

	local v18 = magnitude * math.sin((math.rad(NearMiss.MaxAngle)))
	local v19

	if v11 and math.abs(v12) > 0.001 then
		v19 = math.sign(v12)
	else
		v19 = p2 < 0 and -1 or 1
	end

	local v20 = nil
	local v21 = nil

	for _, v22 in { v19, -v19 } do
		local step = NearMiss.Step
		local v23 = v17
		local count = 0
		local v24 = nil

		for _ = 1, NearMiss.Tries + NearMiss.MaxTrafficSteps do
			if NearMiss.Tries <= count then
				break
			end

			local v25 = v22 * math.min(v9 + v23 * BallDiameter, v18)

			if v24 and math.abs(v25 - v24) < 0.0001 then
				break
			end

			local v26 = contactForPass(position, object, v8, contactLine, v25)

			if not v26 then
				break
			end

			local v27 = contactLine(v26)

			if firstContact(p, position, v27) == choice.Target then
				count += 1

				local v28, v29 = strikeMisses(p, v27, p4, choice.Target, flag2, vector2_2)

				if v28 then
					if v29 then
						v20 = v20 or v27
					else
						v21 = v27
						break
					end
				end

				v23 += step
				step *= NearMiss.StepGrowth
			else
				v23 += NearMiss.TrafficStep
			end

			v24 = v25
		end

		if v21 then
			break
		end
	end

	local v22 = v21 or v20

	if v22 then
		return v22, true
	end

	return vector2, false
end

local function breakScratches(p, vector2: Vector2, p2: number, vector2_2: Vector2, flag: boolean?)
	local clone = PoolPhysics.Clone(p)

	PoolPhysics.Shoot(clone, vector2, p2, vector2_2)

	local v8 = math.ceil(PoolStepper.MaxSettleSeconds / PoolStepper.FixedDelta)
	local lastTime = os.clock()

	for _ = 1, v8 do
		if clone.Settled then
			break
		end

		PoolPhysics.Step(clone, PoolStepper.FixedDelta)

		local ball = clone.Balls[CueBallNumber]

		if ball and (ball.Pocketed or ball.Sinking) then
			return true
		end

		if not (flag and os.clock() - lastTime > v.SimFrameBudget) then
			continue
		end

		task.wait()
		lastTime = os.clock()
	end

	local ball = clone.Balls[CueBallNumber]

	return ball == nil or ball.Pocketed
end

local function guardBreak(state, state2, choice, p, vector2: Vector2, p2: number, vector2_2: Vector2, callback, flag: boolean?)
	local breakScratchChance = state.Level.BreakScratchChance

	if breakScratchChance == nil then
		state2.BreakNote = "no scratch guard at this level"

		return vector2, vector2_2
	end

	local v8

	if p then
		v8 = p.Balls[CueBallNumber]
	end

	if not p or not v8 or v8.Pocketed then
		state2.BreakNote = "scratch guard skipped: no table to check against"

		return vector2, vector2_2
	end

	local v9 = state.Random:NextNumber() * 100 < math.clamp(breakScratchChance, 0, 100)
	local position = v8.Position
	local direction = choice.Direction
	local v10 = firstContact(p, position, direction) == choice.Target
	local v11 = math.clamp(state.Level.AimError / Bots.MaxContactOffset, 0.15, 1)
	local spin = choice.Spin or Vector2.zero

	local function wobbled()
		if spin.Magnitude <= 0.001 then
			return Vector2.zero
		end

		local v12 = spin + Vector2.new(state.Random:NextNumber() * 2 - 1, state.Random:NextNumber() * 2 - 1) * Human.SpinError * v11

		return if v12.Magnitude > 1 then v12.Unit else v12
	end

	if v9 then
		if breakScratches(p, vector2, p2, vector2_2, flag) then
			state2.BreakNote = string.format(
				"scratch roll hit (%.2f%%): white allowed down, as struck",
				breakScratchChance
			)

			return vector2, vector2_2
		end

		for k, looseHit in v.LooseHits do
			local v12 = lineBeside(position, choice.Object, looseHit.Offset)

			if breakScratches(p, v12, p2, looseHit.Spin, flag) then
				state2.BreakNote = string.format(
					"scratch roll hit (%.2f%%): white allowed down, botched hit %d",
					breakScratchChance,
					k
				)

				return v12, looseHit.Spin
			end
		end

		state2.BreakNote = string.format(
			"scratch roll hit (%.2f%%), but nothing tried scratched: played as struck",
			breakScratchChance
		)

		return vector2, vector2_2
	else
		local v12 = vector2_2
		local v13 = vector2

		for i = 1, v.GuardTries do
			if not breakScratches(p, v13, p2, v12, flag) then
				state2.BreakNote = string.format("scratch guard: white stays up, check %d", i)

				return v13, v12
			end

			local v14 = state.Random:NextNumber() + state.Random:NextNumber() - 1

			if callback then
				v13 = callback(v14 * aimErrorFor(state, state2, choice) * BallDiameter)
			else
				v13 = direction
			end

			if v10 and firstContact(p, position, v13) ~= choice.Target then
				v13 = direction
			end

			v12 = wobbled()
		end

		for _, v14 in { Vector2.zero, Vector2.new(0, -0.3), Vector2.new(0, 0.3) } do
			local v15 = spin + v14

			if v15.Magnitude > 1 then
				v15 = v15.Unit
			end

			if not breakScratches(p, direction, p2, v15, flag) then
				state2.BreakNote = "scratch guard: every re-cue went down, the clean line stays up"

				return direction, v15
			end
		end

		state2.BreakNote = "scratch guard: found no line that keeps the white up"

		return vector2, vector2_2
	end
end

function PoolAI:Commit(state, p, flag: boolean?)
	local choice = state.Choice

	if not choice then
		return nil, nil
	end

	local level = self.Level
	local direction = choice.Direction

	local v8 = self.Random:NextNumber() + self.Random:NextNumber() - 1
	local v9 = v8 * aimErrorFor(self, state, choice) * BallDiameter

	local v10 = state.Assist and 0 or v9

	local v11 = self.Random:NextNumber() * 100
	local v12

	if state.DynamicMiss == nil then
		v12 = false
	else
		v12 = not (state.Assist or state.ForceMiss or state.Break or choice.Safety)
	end

	local v13

	if v12 then
		v13 = v11 < state.DynamicMiss
	else
		v13 = v11 < math.clamp(level.MissAimChance or 0, 0, 100) or state.ForceMiss == true
	end

	local v14 = v13 and not state.Assist and not (state.Break or choice.Safety)
	local v15 = v12 and not v14 and 0 or v10
	local number = self.Random:NextNumber()
	local v16 = self.Random:NextNumber() * 2 - 1

	local bankLine = nil

	local contactLine
	local v17

	if p then
		v17 = p.Balls[CueBallNumber]
	end

	local v18

	if p and v17 then
		local position = v17.Position

		if choice.Bank then
			local v19 = math.max((choice.AimPoint - position).Magnitude, BallDiameter)

			bankLine = function(p2: number)
				return rotate(direction, math.asin((math.clamp(p2 * Bots.BankErrorScale / v19, -1, 1))))
			end

			v18 = rotate(direction, math.asin((math.clamp(v15 * Bots.BankErrorScale / v19, -1, 1)))) -- inferred equivalent call
		else
			local v19 = choice.Object - position
			local magnitude = v19.Magnitude
			local dot = direction:Dot(v19)

			if magnitude > 0.001 and dot > 0 then
				local v20 = math.atan2(direction.X * v19.Y - direction.Y * v19.X, dot)
				local v21 = magnitude * math.sin(v20)

				local v22 = math.max(BallDiameter * Bots.MaxContactOffset, (math.abs(v21)))

				contactLine = function(p2: number)
					local v23 = math.clamp(v21 + p2, -v22, v22)

					return rotate(direction, v20 - math.asin((math.clamp(v23 / magnitude, -1, 1))))
				end

				v18 = rotate( -- inferred equivalent call
					direction,
					v20 - math.asin((math.clamp(math.clamp(v21 + v15, -v22, v22) / magnitude, -1, 1)))
				)

				if firstContact(p, position, direction) == choice.Target then
					bankLine = contactLine

					for _ = 1, Bots.ContactRetries do
						if firstContact(p, position, v18) == choice.Target then
							break
						end

						v15 *= Bots.ContactBackoff
						v18 = rotate( -- inferred equivalent call
							direction,
							v20 - math.asin((math.clamp(math.clamp(v21 + v15, -v22, v22) / magnitude, -1, 1)))
						)
					end

					if firstContact(p, position, v18) ~= choice.Target then
						v18 = direction
					end
				else
					bankLine = contactLine
				end
			else
				v18 = direction
			end
		end
	else
		v18 = direction
	end

	local v19 = self.Random:NextNumber() + self.Random:NextNumber() - 1
	local v20 = math.clamp(choice.Power * (1 + v19 * level.PowerError * (self.Form or 1)), 0.12, 1)

	if state.Assist then
		v20 = choice.Power
	end

	local finalPower = state.FullPower and 1 or v20

	if state.Break then
		finalPower = v.Power
	end

	local v21 = choice.Spin or Vector2.zero

	if v21.Magnitude > 0.001 and not state.Assist then
		local v22 = math.clamp(level.AimError / Bots.MaxContactOffset, 0.15, 1)

		v21 += Vector2.new(self.Random:NextNumber() * 2 - 1, self.Random:NextNumber() * 2 - 1) * Human.SpinError * v22

		if v21.Magnitude > 1 then
			v21 = v21.Unit
		end
	end

	if v12 and not v14 and p and v17 and strikeMisses(p, v18, finalPower, choice.Target, flag, v21) then
		finalPower = state.FullPower and 1 or choice.Power
		v21 = choice.Spin or Vector2.zero
	end

	local v22

	if choice.Pocket then
		v22 = pocketsById[choice.Pocket]
	end

	local v23

	if p and v17 and contactLine and v22 and not (choice.Bank or state.Assist or state.Break or choice.Safety) then
		v18, v23 = nearMissLine(self, p, choice, v22, contactLine, v18, v8, v14, number, v16, finalPower, v21, flag)
	else
		v23 = false
	end

	if v14 and not v23 and p and v17 and bankLine then
		local v24 = v8 < 0 and -1 or 1
		local v25 = nil
		local v26 = nil

		for _, v27 in { v24, -v24 } do
			local v28 = Bots.MissAimStart * BallDiameter

			for _ = 1, Bots.MissAimTries do
				local v29 = bankLine(v15 + v27 * v28)
				local v30, v31 = strikeMisses(p, v29, finalPower, choice.Target, flag, v21)

				if v30 then
					if v31 then
						v25 = v25 or v29
					else
						v26 = v29
						break
					end
				end

				v28 *= Bots.MissAimGrowth
			end

			if v26 then
				break
			end
		end

		local v27 = v26 or v25

		if v27 then
			v18 = v27
		end
	end

	if state.Assist then
		self.CatchUp.Remaining = math.max(self.CatchUp.Remaining - 1, 0)
	end

	state.FinalDirection = v18
	state.FinalPower = finalPower

	state.ShowDirection = v18

	if state.Break then
		v18, v21 = guardBreak(self, state, choice, p, v18, finalPower, v21, bankLine, flag)
		state.FinalDirection = v18
		state.ShowDirection = v18

		self.BreakChoice = nil
	end

	self.LastOwnLeft = state.OwnLeft

	if v12 and DynamicMiss.PrintInStudio and RunService:IsStudio() then
		print(string.format(
			"[PoolAI] %s bot, %s: miss chance %.0f%% -> %s",
			level.Id,
			state.Winning and "WINNING SHOT" or string.format("lead %+d", state.Lead or 0),
			state.DynamicMiss,
			v14 and "MISS" or "POT"
		))
	end

	return v18, finalPower, v21
end

function PoolAI.FallbackShot(p, p2)
	local ball = p.Balls[CueBallNumber]
	local v8 = legalTargets(p2, p)
	local v9 = 1e999
	local v10 = nil

	for _, v11 in v8 do
		local ball2 = p.Balls[v11]
		local magnitude = (ball2.Position - ball.Position).Magnitude

		if not (magnitude < v9) then
			continue
		end

		v10 = ball2
		v9 = magnitude
	end

	if v10 then
		return (v10.Position - ball.Position).Unit, 0.45
	end

	return Vector2.new(1, 0), 0.4
end

function PoolAI.BuildCharge(_, p, p2: number?)
	local time = math.max(p.Pull or Theatre.ChargeFillSeconds, Theatre.ChargeFillSeconds)
	local v8 = math.max(p.Charge - time, 0)

	if p2 and p2 < time then
		time = math.max(p2, Theatre.ChargeFillSeconds)
	end

	local keys = {
		{ Time = 0, Power = 0 }
	}
	local total = 0

	local function key(p3: number, power: number) -- 2 equivalent calls inferred from this helper
		total += math.max(p3, 0)
		table.insert(keys, { Time = total, Power = power })
	end

	key(time, 1) -- inferred equivalent call
	key(v8, 1) -- inferred equivalent call

	if p2 and p2 < total then
		local v9 = math.clamp(p2 - time, 0, v8)

		return {
			Keys = {
				{ Time = 0, Power = 0 },
				{ Time = time, Power = 1 },
				{
					Time = time + v9,
					Power = 1
				}
			},
			Total = time + v9
		}
	end

	return { Keys = keys, Total = total }
end

function PoolAI.ChargeFraction(p, p2: number)
	local keys = p.Keys

	if p2 <= 0 then
		return keys[1].Power
	end

	for i = 2, #keys do
		local key = keys[i]

		if p2 <= key.Time then
			local key2 = keys[i - 1]
			local v8 = key.Time - key2.Time

			if v8 <= 1e-6 then
				return key.Power
			end

			local ease = PoolAI.Ease((p2 - key2.Time) / v8)

			return key2.Power + (key.Power - key2.Power) * ease
		end
	end

	return keys[#keys].Power
end

local function spotIsFree(p, vector2: Vector2): boolean
	if not PoolGeometry.IsInsidePlayArea(vector2, PoolConstants.BallRadius) then
		return false
	end

	for _, v8 in p.Order do
		local ball = p.Balls[v8]

		if
			ball
			and not ball.Pocketed
			and v8 ~= CueBallNumber
			and (ball.Position - vector2).Magnitude < BallDiameter * 1.02
		then
			return false
		end
	end

	return true
end

function PoolAI.BuildPlacementLegs(p, p2, p3, to: Vector2, to2: Vector2?, callback)
	local random = p.Random
	local placementLegs = {}

	if to2 then
		table.insert(placementLegs, { To = to2, Held = true, HoldAfter = p3.ReconsiderHold })
	end

	local flag = false

	if random:NextNumber() < math.clamp(Human.PlacementFussChance * (p3.Fidget or 1), 0, 0.9) then
		local integer = random:NextInteger(Human.PlacementFussNudges.Min, Human.PlacementFussNudges.Max)

		for i = 1, integer do
			local v8 = spread(random, Human.PlacementFussDistance) * BallDiameter * (integer - i + 1) / integer -- inferred equivalent call
			local v9 = random:NextNumber() * 3.141592653589793 * 2
			local to3 = callback(to + Vector2.new(math.cos(v9), (math.sin(v9))) * v8)

			local magnitude = (to3 - to).Magnitude

			if not (BallDiameter * 0.1 < magnitude and spotIsFree(p2, to3)) then
				continue
			end

			local v10 = {
				To = to3,
				Held = true,
				HoldAfter = spread(random, Human.PlacementFussHoldSeconds), -- inferred equivalent call
				Seconds = 0
			}
			local seconds

			if flag then
				seconds = spread(random, Human.PlacementFussSeconds) -- inferred equivalent call
			end

			v10.Seconds = seconds
			table.insert(placementLegs, v10)
			flag = true
		end
	end

	local seconds

	if flag then
		seconds = spread(random, Human.PlacementFussSeconds) -- inferred equivalent call
	end

	table.insert(placementLegs, { To = to, Held = false, HoldAfter = 0, Seconds = seconds })

	return placementLegs
end

return PoolAI