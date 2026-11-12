local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolGeometry = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolGeometry)
local PoolModifiers = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolModifiers)

local PoolPhysics = {}

local Physics = PoolConstants.Physics

local BallRadius = PoolConstants.BallRadius
local BallDiameter = PoolConstants.BallDiameter

local Default = PoolGeometry.Default

local function radiusOf(p) -- 18 equivalent calls inferred from this helper
	return p.Radius or BallRadius
end

local function isAirborne(p): boolean -- 9 equivalent calls inferred from this helper
	return p.Height > PoolModifiers.ClearanceHeight
end

local function sweepCircle(vector: Vector2, vector2: Vector2, p: number, p2: number)
	local v = vector:Dot(vector) - p * p
	local v2 = 2 * vector:Dot(vector2)

	if v < 0 then
		return if v2 < 0 then 0 else nil
	else
		if v2 >= 0 then
			return nil
		end

		local dot = vector2:Dot(vector2)

		if dot <= 1e-6 then
			return nil
		end

		local v3 = v2 * v2 - 4 * dot * v

		if v3 < 0 then
			return nil
		end

		local v4 = (-v2 - math.sqrt(v3)) / (2 * dot)

		return if not (v4 < 0 or p2 < v4) then v4 else nil
	end
end

local function ballBallToi(activeBall, activeBall2, p: number) -- 1 equivalent call inferred from this helper
	return sweepCircle(
		activeBall2.Position - activeBall.Position,
		activeBall2.Velocity - activeBall.Velocity,
		radiusOf(activeBall) + radiusOf(activeBall2), -- inferred equivalent call
		p
	)
end

local function pointToi(position: Vector2, vector2: Vector2, position2: Vector2, p: number, p2: number?) -- 3 equivalent calls inferred from this helper
	return sweepCircle(position2 - position, -vector2, p2 or BallRadius, p)
end

local function cushionToi(position: Vector2, vector: Vector2, cushion, p: number, p2: number?)
	local v = p2 or BallRadius
	local normal = cushion.Normal
	local dot = vector:Dot(normal)

	if dot >= -1e-6 then
		return nil
	end

	local dot2 = (position - cushion.A):Dot(normal)

	if dot2 < -v then
		return nil
	end

	local v2

	if dot2 < v then
		v2 = 0
	else
		v2 = (v - dot2) / dot

		if v2 < 0 or p < v2 then
			return nil
		end
	end

	local v3 = cushion.B - cushion.A
	local magnitude = v3.Magnitude
	local dot3 = (position + vector * v2 - cushion.A):Dot(v3 / magnitude)

	return if not (dot3 < 0 or magnitude < dot3) then v2 else nil
end

local function applySpinThroughContact(state, velocity: Vector2)
	local magnitude = velocity.Magnitude

	if math.abs(state.Spin.Y) <= 0.001 or magnitude <= 1e-6 then
		return
	end

	local velocity2 = state.Velocity + velocity.Unit * (state.Spin.Y * Physics.SpinTransferFraction * magnitude)

	if magnitude < velocity2.Magnitude then
		velocity2 = velocity2.Unit * magnitude
	end

	state.Velocity = velocity2
	state.Spin = Vector2.new(state.Spin.X, state.Spin.Y * 0.35)
end

local function pocketToi(position: Vector2, vector: Vector2, pocket, p: number)
	local dot = vector:Dot(pocket.Normal)

	if dot <= 1e-6 then
		return nil
	end

	local v = -((position - pocket.MouthCentre):Dot(pocket.Normal) - pocket.CommitDepth) / dot

	if v < 0 or p < v then
		return nil
	end

	local vector2 = Vector2.new(-pocket.Normal.Y, pocket.Normal.X)

	if math.abs(((position + vector * v - pocket.MouthCentre):Dot(vector2))) > pocket.Mouth / 2 then
		return nil
	end

	return v
end

local function resolveBallBall(state, state2)
	local v = state2.Position - state.Position
	local magnitude = v.Magnitude

	if magnitude <= 1e-6 then
		return 0
	end

	local v2 = v / magnitude
	local velocity = state.Velocity
	local velocity2 = state2.Velocity
	local dot = velocity:Dot(v2)
	local dot2 = velocity2:Dot(v2)
	local v3 = dot - dot2

	if v3 <= 0 or state.Static and state2.Static then
		return 0
	end

	local static = state.Static or state.Driven
	local static2 = state2.Static or state2.Driven

	if static and static2 then
		return 0
	end

	if static or static2 then
		if not static then
			v2 = -v2
		end

		local v4 = if static then state2 else state
		local v5 = if static then state else state2
		local velocity3 = v4.Velocity

		v4.Velocity = velocity3 - v2 * ((velocity3 - v5.Velocity):Dot(v2) * (1 + Physics.BallRestitution))
		applySpinThroughContact(v4, velocity3)
		local v6 = radiusOf(state) + radiusOf(state2) -- inferred equivalent call

		if magnitude < v6 then
			v4.Position += v2 * (v6 - magnitude + 0.0001)
		end

		return v3
	else
		local ballRestitution = Physics.BallRestitution
		local midpoint = ((1 - ballRestitution) * dot + (1 + ballRestitution) * dot2) / 2
		local midpoint2 = ((1 + ballRestitution) * dot + (1 - ballRestitution) * dot2) / 2

		state.Velocity = velocity - v2 * dot + v2 * midpoint
		state2.Velocity = velocity2 - v2 * dot2 + v2 * midpoint2

		applySpinThroughContact(state, velocity)
		applySpinThroughContact(state2, velocity2)

		return v3
	end
end

local function resolveNormalBounce(state, normal: Vector2, flag: boolean)
	local dot = state.Velocity:Dot(normal)

	if dot >= 0 then
		return
	end

	local v = (state.Velocity - normal * dot) * (1 - Physics.CushionFriction)

	if flag and math.abs(state.Spin.X) > 0.001 then
		v += Vector2.new(-normal.Y, normal.X) * (state.Spin.X * Physics.CushionSpinTransfer)
		state.Spin = Vector2.new(state.Spin.X * 0.4, state.Spin.Y)
	end

	state.Velocity = v - normal * (dot * Physics.CushionRestitution)
end

local function resolveCushion(p, p2)
	resolveNormalBounce(p, p2.Normal, true)
	local v = radiusOf(p) -- inferred equivalent call
	local dot = (p.Position - p2.A):Dot(p2.Normal)

	if dot < v then
		local v2 = math.min(v - dot + 0.0001, v * 2)
		p.Position += p2.Normal * v2
	end
end

local function resolveTip(state, position: Vector2) -- 1 equivalent call inferred from this helper
	local v = state.Position - position
	local magnitude = v.Magnitude

	if magnitude <= 1e-6 then
		return
	end

	local v2 = v / magnitude
	local v3 = radiusOf(state) -- inferred equivalent call
	local dot = state.Velocity:Dot(v2)

	if not (dot >= 0) then
		state.Velocity = (state.Velocity - v2 * dot) * (1 - Physics.CushionFriction) - v2 * (dot * Physics.CushionRestitution)
	end

	if magnitude < v3 then
		state.Position = position + v2 * (v3 + 0.0001)
	end
end

local function tableOf(p) -- 8 equivalent calls inferred from this helper
	return p.Table or Default
end

function PoolPhysics:SetTable(tbl)
	self.Table = tbl
end

function PoolPhysics.GetTable(p)
	return tableOf(p) -- inferred equivalent call
end

function PoolPhysics.newSimulation()
	return {
		Balls = {},
		Order = {},
		Events = {},
		Elapsed = 0,
		Settled = true,
		RestlessFor = 0,
		IsBreakShot = false,
		Modifiers = {},
		Popped = {},
		CueBall = nil,
		Table = nil
	}
end

function PoolPhysics.AddBall(p, number: number, position: Vector2, radius: number?, static: boolean?)
	local v = {
		Number = number,
		Position = position,
		Velocity = Vector2.zero,
		Spin = Vector2.zero,
		Pocketed = false,
		PocketId = nil,
		Sinking = false,
		Radius = radius,
		Static = static,
		Height = 0,
		VerticalSpeed = 0,
		Triggered = {},
		Fires = {},
		TeeterAt = nil,
		TeeterFor = 0
	}

	if p.Balls[number] == nil then
		table.insert(p.Order, number)
	end

	p.Balls[number] = v

	return v
end

function PoolPhysics:Reset(p)
	self.Balls = {}
	self.Order = {}
	self.Events = {}
	self.Elapsed = 0
	self.Settled = true
	self.RestlessFor = 0

	self.Modifiers = {}
	table.clear(self.Popped)

	self.CueBall = nil

	self.Table = nil

	self.IsBreakShot = true

	PoolPhysics.AddBall(self, PoolConstants.CueBallNumber, PoolGeometry.BreakSpot)

	for _, v in p or PoolGeometry.BuildRack() do
		PoolPhysics.AddBall(self, v.Number, v.Position)
	end
end

function PoolPhysics.GetActiveBalls(p)
	local balls = {}

	for _, v in p.Order do
		local ball = p.Balls[v]

		if not ball or (ball.Pocketed or ball.Destroyed) then
			continue
		end

		table.insert(balls, ball)
	end

	return balls
end

function PoolPhysics:SetModifiers(options)
	local modifiers = {}

	for _, v in options or {} do
		local definition = PoolModifiers.Get(v.K)

		if not definition then
			continue
		end

		local r = v.R or 0

		table.insert(modifiers, {
			Kind = definition.Id,
			Definition = definition,
			Position = Vector2.new(v.X, v.Y),
			Radius = PoolModifiers.RadiusOf(definition, v.S),
			Rotation = r,
			Direction = PoolModifiers.FanDirection(r),
			Strength = PoolModifiers.StrengthOf(definition, v.P)
		})
	end

	self.Modifiers = modifiers
	table.clear(self.Popped)

	for _, v in PoolPhysics.GetActiveBalls(self) do
		table.clear(v.Triggered)

		for k, v2 in modifiers do
			if not (v2.Definition.Kind == "Trigger" and PoolModifiers.Overlaps(
				v2.Position,
				v2.Radius,
				v.Position,
				radiusOf(v) -- inferred equivalent call
			)) then
				continue
			end

			v.Triggered[k] = true
		end
	end
end

function PoolPhysics.SetPatrol(p, p2: number, to: Vector2?, p3: number?)
	local ball = p.Balls[p2]

	if not ball then
		return
	end

	if to and not ((to - ball.Position).Magnitude < PoolModifiers.MinPatrolDistance) then
		ball.Patrol = {
			From = ball.Position,
			To = to,
			Speed = math.clamp(
				p3 or PoolModifiers.DefaultPatrolSpeed,
				PoolModifiers.MinPatrolSpeed,
				PoolModifiers.MaxPatrolSpeed
			),
			Forward = true
		}

		ball.Driven = true
	else
		ball.Patrol = nil
		ball.Driven = nil
		ball.Velocity = Vector2.zero
	end
end

function PoolPhysics.PowerToSpeed(value: number)
	local v = math.clamp(value, 0, 1) ^ Physics.PowerCurve

	return Physics.MinShotSpeed + (Physics.MaxShotSpeed - Physics.MinShotSpeed) * v
end

function PoolPhysics.GetShotSpeed(p, p2: number)
	local shotSpeed = PoolPhysics.PowerToSpeed(p2)

	if p.IsBreakShot then
		shotSpeed *= Physics.BreakSpeedMultiplier
	end

	return shotSpeed
end

function PoolPhysics.CueNumber(p)
	return p.CueBall or PoolConstants.CueBallNumber
end

function PoolPhysics:Shoot(vector2: Vector2, p: number, vector2_2: Vector2?): boolean
	local ball = self.Balls[PoolPhysics.CueNumber(self)]

	if not ball or ball.Pocketed or vector2.Magnitude <= 1e-6 then
		return false
	end

	for _, v in PoolPhysics.GetActiveBalls(self) do
		table.clear(v.Fires)

		v.Trapped = nil
		v.TeeterAt = nil
		v.TeeterFor = 0
	end

	ball.Static = nil

	ball.Velocity = vector2.Unit * PoolPhysics.GetShotSpeed(self, p)
	ball.Spin = vector2_2 or Vector2.zero

	self.IsBreakShot = false

	self.Events = {}
	self.Elapsed = 0
	self.Settled = false

	self.RestlessFor = 0

	return true
end

local function record(p, p2) -- 10 equivalent calls inferred from this helper
	table.insert(p.Events, p2)
end

local function captureImmediate(p, p2, p3)
	p2.Pocketed = true
	p2.PocketId = p3.Id
	p2.Velocity = Vector2.zero
	p2.Spin = Vector2.zero

	record(p, { Kind = "Pocketed", Time = p.Elapsed, Ball = p2.Number, PocketId = p3.Id }) -- inferred equivalent call
end

local function capture(_, state, p) -- 1 equivalent call inferred from this helper
	if state.Sinking or state.Pocketed then
		return
	end

	state.Sinking = true
	state.PocketId = p.Id
	state.Spin = Vector2.zero
end

local function land(p, state, data)
	if state.Pocketed then
		return
	end

	local position = state.Position
	local magnitude = state.Velocity.Magnitude
	local entryDirection

	if magnitude > 1e-6 then
		entryDirection = state.Velocity.Unit
	else
		entryDirection = data.Normal
	end

	state.Pocketed = true
	state.Sinking = false
	state.PocketId = data.Id
	state.Velocity = Vector2.zero
	state.Spin = Vector2.zero
	state.Position = data.BowlCentre

	record(p, { -- inferred equivalent call
		Kind = "Pocketed",
		Time = p.Elapsed,
		Ball = state.Number,
		PocketId = data.Id,
		EntryPosition = position,
		EntryDirection = entryDirection,
		EntrySpeed = magnitude
	})
end

local function updateSinking(state)
	for _, v in PoolPhysics.GetActiveBalls(state) do
		if not v.Sinking then
			continue
		end

		local v2 = nil

		for _, pocket in tableOf(state).Pockets do -- inferred equivalent call
			if pocket.Id == v.PocketId then
				v2 = pocket
			end
		end

		if v2 then
			local v3 = (v.Position - v2.MouthCentre):Dot(v2.Normal) - v2.CommitDepth
			local dot = v.Velocity:Dot(v2.Normal)

			if v3 < 0 then
				v.Position -= v2.Normal * v3

				if dot < 0 then
					v.Velocity -= v2.Normal * dot
				end
			end

			local vector = v2.BowlCentre - v.Position

			if
				vector.Magnitude <= v2.BowlRadius
				or v.Velocity.Magnitude <= 0
				or v.Velocity.Magnitude > 1e-6 and vector:Dot(v.Velocity) <= 0
			then
				land(state, v, v2)
			end
		else
			v.Sinking = false
		end
	end
end

local function checkPockets(state)
	for _, v in PoolPhysics.GetActiveBalls(state) do
		if v.Static or v.Driven or isAirborne(v) then -- inferred equivalent call
			continue
		end

		local v2 = PoolGeometry.GetPocketAt(v.Position, tableOf(state)) -- inferred equivalent call

		if not v2 and v.Velocity.Magnitude <= 0 then
			v2 = PoolGeometry.IsInThroat(v.Position, tableOf(state)) -- inferred equivalent call
		end

		if not v2 or (v.Sinking or v.Pocketed) then
			continue
		end

		v.Sinking = true
		v.PocketId = v2.Id
		v.Spin = Vector2.zero
	end
end

local function advanceHeights(state, p: number)
	for _, v in PoolPhysics.GetActiveBalls(state) do
		if v.Height <= 0 and v.VerticalSpeed <= 0 then
			continue
		end

		v.VerticalSpeed -= PoolModifiers.Gravity * p
		v.Height += v.VerticalSpeed * p

		if not (v.Height <= PoolModifiers.GroundHeight) then
			continue
		end

		v.Height = 0
		v.VerticalSpeed = 0
	end
end

local function applyFields(state, p: number)
	if #state.Modifiers == 0 then
		return
	end

	local v = Physics.MaxShotSpeed * Physics.BreakSpeedMultiplier

	for _, v2 in PoolPhysics.GetActiveBalls(state) do
		if v2.Static or v2.Driven or v2.Sinking or v2.Trapped then
			continue
		end

		local airborne = isAirborne(v2) -- inferred equivalent call

		for _, modifier in state.Modifiers do
			local definition = modifier.Definition

			if not (definition.Kind == "Field" and (not airborne or definition.AffectsAirborne)) then
				continue
			end

			local v3 = modifier.Position - v2.Position
			local magnitude = v3.Magnitude
			local v4 = modifier.Radius + radiusOf(v2) -- inferred equivalent call

			if v4 < magnitude then
				continue
			end

			local falloffAt = PoolModifiers.FalloffAt(magnitude, v4)

			if modifier.Kind == "BlackHole" then
				if magnitude > 1e-6 then
					v2.Velocity += v3 / magnitude * (modifier.Strength * falloffAt * p)
				end
			elseif modifier.Kind == "Fan" then
				v2.Velocity += modifier.Direction * (modifier.Strength * falloffAt * p)
			elseif modifier.Kind == "Mud" then
				local magnitude2 = v2.Velocity.Magnitude

				if magnitude2 > 1e-6 then
					local v5 = math.max(magnitude2 - modifier.Strength * falloffAt * p, 0)
					local velocity

					if v5 <= 0 then
						velocity = Vector2.zero
					else
						velocity = v2.Velocity * (v5 / magnitude2)
					end

					v2.Velocity = velocity
				end
			end

			local magnitude2 = v2.Velocity.Magnitude

			if v < magnitude2 then
				v2.Velocity *= v / magnitude2
			end
		end
	end
end

local function applyTriggers(state)
	if #state.Modifiers == 0 then
		return
	end

	local v = Physics.MaxShotSpeed * Physics.BreakSpeedMultiplier

	for _, v2 in PoolPhysics.GetActiveBalls(state) do
		if v2.Static or v2.Driven or v2.Sinking then
			continue
		end

		local airborne = isAirborne(v2) -- inferred equivalent call

		for k, modifier in state.Modifiers do
			local definition = modifier.Definition

			if definition.Kind ~= "Trigger" then
				continue
			end

			if PoolModifiers.Overlaps(modifier.Position, modifier.Radius, v2.Position, radiusOf(v2)) then -- inferred equivalent call
				if not v2.Triggered[k] and (not airborne or definition.AffectsAirborne) then
					v2.Triggered[k] = true

					local v3 = v2.Fires[k] or 0

					if not (definition.MaxFiresPerShot and definition.MaxFiresPerShot <= v3) then
						v2.Fires[k] = v3 + 1

						if modifier.Kind == "Lava" then
							v2.Destroyed = true
							v2.Velocity = Vector2.zero
							v2.VerticalSpeed = 0
							v2.Height = 0
							record(state, { -- inferred equivalent call
								Kind = "Destroyed",
								Time = state.Elapsed,
								Ball = v2.Number
							})
							break
						elseif modifier.Kind == "Boost" then
							local magnitude = v2.Velocity.Magnitude

							if magnitude > 1e-6 then
								local v4 = math.min(magnitude * modifier.Strength, v)
								v2.Velocity *= v4 / magnitude
								record(state, { -- inferred equivalent call
									Kind = "Boosted",
									Time = state.Elapsed,
									Ball = v2.Number
								})
							end
						elseif modifier.Kind == "Trampoline" then
							v2.VerticalSpeed = PoolModifiers.TrampolineLaunch

							v2.Height = math.max(v2.Height, PoolModifiers.GroundHeight * 2)
							record(state, { -- inferred equivalent call
								Kind = "Launched",
								Time = state.Elapsed,
								Ball = v2.Number
							})
						end
					end
				end
			else
				v2.Triggered[k] = nil
			end
		end
	end
end

local function popBubbles(data)
	if #data.Modifiers == 0 then
		return
	end

	for k, modifier in data.Modifiers do
		if modifier.Kind ~= "Bubble" or data.Popped[k] then
			continue
		end

		for _, v in PoolPhysics.GetActiveBalls(data) do
			if
				not v.Sinking
				and PoolModifiers.Overlaps(modifier.Position, modifier.Radius, v.Position, radiusOf(v)) -- inferred equivalent call
			then
				data.Popped[k] = true
				record(data, { Kind = "Popped", Time = data.Elapsed, Ball = v.Number, Modifier = k }) -- inferred equivalent call
				break
			end
		end
	end
end

local function sinkIntoHole(p, state, p2: number)
	if state.Pocketed or state.Destroyed then
		return
	end

	local modifier = p.Modifiers[p2]

	if not modifier then
		return
	end

	local position = state.Position
	local magnitude = state.Velocity.Magnitude
	local entryDirection

	if magnitude > 1e-6 then
		entryDirection = state.Velocity.Unit
	else
		entryDirection = Vector2.new(1, 0)
	end

	local holeId = PoolModifiers.HoleId(p2)

	state.Pocketed = true
	state.Sinking = false
	state.PocketId = holeId
	state.Velocity = Vector2.zero
	state.Spin = Vector2.zero
	state.Position = modifier.Position

	record(p, { -- inferred equivalent call
		Kind = "Pocketed",
		Time = p.Elapsed,
		Ball = state.Number,
		PocketId = holeId,
		EntryPosition = position,
		EntryDirection = entryDirection,
		EntrySpeed = magnitude
	})
end

local function sinkIntoHoles(state)
	if #state.Modifiers == 0 then
		return
	end

	for k, modifier in state.Modifiers do
		if modifier.Kind ~= "Pocket" then
			continue
		end

		for _, v in PoolPhysics.GetActiveBalls(state) do
			if v.Static or v.Driven or v.Sinking or isAirborne(v) or v.Velocity.Magnitude <= 1e-6 then -- inferred equivalent call
				continue
			end

			if not PoolModifiers.IsOverHole(modifier.Position, modifier.Radius, v.Position) then
				continue
			end

			sinkIntoHole(state, v, k)
		end
	end
end

function PoolPhysics.SetRotors(p, items)
	for _, ball in p.Balls do
		ball.Rotor = nil
		ball.RotorSpeed = nil
		ball.RotorAngle = nil

		if not ball.Patrol then
			ball.Driven = nil
		end
	end

	if not items then
		return
	end

	local ballsByG = {}

	for _, item in items do
		if not (typeof(item) == "table" and typeof(item.G) == "number" and typeof(item.W) == "number") then
			continue
		end

		local ball = p.Balls[item.I]

		if not ball or ballsByG[item.G] then
			continue
		end

		ballsByG[item.G] = ball
		ball.RotorSpeed = math.rad(item.W)
		ball.RotorAngle = 0
	end

	for _, item in items do
		if not (typeof(item) == "table" and typeof(item.G) == "number") then
			continue
		end

		local v = ballsByG[item.G]
		local ball = p.Balls[item.I]

		if not (v and ball and ball ~= v) then
			continue
		end

		local v2 = ball.Position - v.Position
		local magnitude = v2.Magnitude

		if magnitude <= 1e-6 then
			continue
		end

		ball.Rotor = { Hub = v.Number, Radius = magnitude, Phase = math.atan2(v2.Y, v2.X) }

		ball.Driven = true

		ball.Static = nil
		ball.Patrol = nil
	end
end

local function driveRotors(state)
	for _, v in PoolPhysics.GetActiveBalls(state) do
		local rotor = v.Rotor

		if not rotor then
			continue
		end

		local ball = state.Balls[rotor.Hub]
		local rotorSpeed = ball and ball.RotorSpeed

		if not (ball and rotorSpeed) then
			continue
		end

		local v2 = (ball.RotorAngle or 0) + rotor.Phase

		v.Velocity = Vector2.new(-math.sin(v2), (math.cos(v2))) * (rotorSpeed * rotor.Radius)
	end
end

local function turnRotors(state, p: number)
	for _, ball in state.Balls do
		if ball.RotorSpeed then
			ball.RotorAngle = (ball.RotorAngle or 0) + ball.RotorSpeed * p
		end
	end

	for _, v in PoolPhysics.GetActiveBalls(state) do
		local rotor = v.Rotor

		if not rotor then
			continue
		end

		local ball = state.Balls[rotor.Hub]

		if not ball then
			continue
		end

		local v2 = (ball.RotorAngle or 0) + rotor.Phase

		v.Position = ball.Position + Vector2.new(math.cos(v2), (math.sin(v2))) * rotor.Radius
	end
end

local function hasRotor(p): boolean -- 2 equivalent calls inferred from this helper
	for _, ball in p.Balls do
		if ball.RotorSpeed then
			return true
		end
	end

	return false
end

local function drivePatrols(state)
	for _, v in PoolPhysics.GetActiveBalls(state) do
		local patrol = v.Patrol

		if not patrol then
			continue
		end

		local v2 = if patrol.Forward then patrol.To else patrol.From
		local v3 = v2 - v.Position
		local magnitude = v3.Magnitude

		if magnitude <= 1e-6 then
			patrol.Forward = not patrol.Forward
			local v4 = if patrol.Forward then patrol.To else patrol.From
			v3 = v4 - v.Position
			magnitude = v3.Magnitude
		end

		if magnitude <= 1e-6 then
			v.Velocity = Vector2.zero
		else
			v.Velocity = v3 / magnitude * patrol.Speed
		end
	end
end

local function turnPatrols(state)
	for _, v in PoolPhysics.GetActiveBalls(state) do
		local patrol = v.Patrol

		if not patrol then
			continue
		end

		local position

		if patrol.Forward then
			position = patrol.To
		else
			position = patrol.From
		end

		if not ((position - v.Position):Dot(v.Velocity) <= 0) then
			continue
		end

		v.Position = position
		patrol.Forward = not patrol.Forward
	end
end

local function applyFriction(state, p: number)
	local magnitude = state.Velocity.Magnitude

	if magnitude <= 0 then
		state.Spin *= math.exp(-Physics.SpinDecay * p)
		return
	end

	local rollingDeceleration = Physics.RollingDeceleration

	if math.abs(state.Spin.Y) > 0.05 then
		rollingDeceleration += Physics.SlidingDeceleration * 0.35
	end

	local v = magnitude - rollingDeceleration * p

	if v <= Physics.StopSpeed then
		state.Velocity = Vector2.zero
	else
		state.Velocity *= v / magnitude
	end

	state.Spin *= math.exp(-Physics.SpinDecay * p)
end

function PoolPhysics.HasPatrol(p): boolean
	if hasRotor(p) then -- inferred equivalent call
		return true
	end

	for _, v in PoolPhysics.GetActiveBalls(p) do
		if v.Patrol then
			return true
		end
	end

	return false
end

local function checkTeeter(state, p: number)
	for _, v in PoolPhysics.GetActiveBalls(state) do
		if v.Static or v.Driven or v.Sinking then
			continue
		end

		if v.Trapped then
			if v.Velocity.Magnitude > Physics.StopSpeed then
				v.Trapped = nil
				v.TeeterAt = nil
				v.TeeterFor = 0
			end
		elseif v.Velocity.Magnitude <= 0 then
			v.TeeterAt = nil
			v.TeeterFor = 0
		else
			local teeterAt = v.TeeterAt

			if teeterAt then
				v.TeeterFor += p

				if not (v.TeeterFor < Physics.TeeterSeconds) then
					if (v.Position - teeterAt).Magnitude > Physics.TeeterRadius then
						v.TeeterAt = v.Position
						v.TeeterFor = 0
					else
						v.Trapped = true
						v.Velocity = Vector2.zero
						v.Spin = Vector2.zero
					end
				end
			else
				v.TeeterAt = v.Position
				v.TeeterFor = 0
			end
		end
	end
end

function PoolPhysics:Step(p: number)
	if self.Settled and not PoolPhysics.HasPatrol(self) and not hasRotor(self) then -- inferred equivalent call
		return true
	end

	local count = 0
	local v = tableOf(self) -- inferred equivalent call
	local v2 = p

	while v2 > 1e-6 and count < Physics.MaxSubSteps do
		count += 1

		drivePatrols(self)
		driveRotors(self)

		local activeBalls = PoolPhysics.GetActiveBalls(self)
		local v3 = v2
		local v4 = nil
		local v5 = nil
		local v6 = nil
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = nil

		for i = 1, #activeBalls - 1 do
			for j = i + 1, #activeBalls do
				local activeBall = activeBalls[i]
				local activeBall2 = activeBalls[j]

				if
					activeBall.Sinking
					or activeBall2.Sinking
					or (activeBall.Static or activeBall.Driven) and (activeBall2.Static or activeBall2.Driven)
					or isAirborne(activeBall) -- inferred equivalent call
					or isAirborne(activeBall2) -- inferred equivalent call
				then
					continue
				end

				local v11 = ballBallToi(activeBall, activeBall2, v3) -- inferred equivalent call

				if not (v11 and v11 < v3) then
					continue
				end

				v10 = activeBall2
				v5 = activeBall
				v3 = v11
				v4 = "BallHit"
				v7 = nil
				v8 = nil
				v9 = nil
			end
		end

		for _, activeBall in activeBalls do
			if not (activeBall.Velocity.Magnitude > 1e-6) or (activeBall.Static or activeBall.Driven) then
				continue
			end

			for _, cushion in v.Cushions do
				local v11 = cushionToi(activeBall.Position, activeBall.Velocity, cushion, v3, radiusOf(activeBall)) -- inferred equivalent call

				if not (v11 and v11 < v3) then
					continue
				end

				v9 = cushion
				v5 = activeBall
				v3 = v11
				v4 = "CushionHit"
				v7 = nil
				v8 = nil
				v10 = nil
			end

			for _, jaw in v.Jaws do
				local v11 = pointToi(activeBall.Position, activeBall.Velocity, jaw.Position, v3, radiusOf(activeBall)) -- inferred equivalent call

				if not (v11 and v11 < v3) then
					continue
				end

				v8 = jaw
				v5 = activeBall
				v3 = v11
				v4 = "TipHit"
				v7 = nil
				v9 = nil
				v10 = nil
			end

			for _, pocket in v.Pockets do
				if activeBall.Sinking or isAirborne(activeBall) then -- inferred equivalent call
					continue
				end

				local v11 = pocketToi(activeBall.Position, activeBall.Velocity, pocket, v3)

				if not (v11 and v11 < v3) then
					continue
				end

				v7 = pocket
				v5 = activeBall
				v3 = v11
				v4 = "Pocketed"
				v8 = nil
				v9 = nil
				v10 = nil
			end

			if activeBall.Sinking or activeBall.Driven or isAirborne(activeBall) then -- inferred equivalent call
				continue
			end

			for k, modifier in self.Modifiers do
				if modifier.Kind ~= "Pocket" then
					continue
				end

				local v11 = pointToi(activeBall.Position, activeBall.Velocity, modifier.Position, v3, modifier.Radius) -- inferred equivalent call

				if not (v11 and v11 < v3) then
					continue
				end

				v6 = k
				v5 = activeBall
				v3 = v11
				v4 = "Pocketed"
				v7 = nil
				v8 = nil
				v9 = nil
				v10 = nil
			end
		end

		for _, activeBall in activeBalls do
			if not activeBall.Static then
				activeBall.Position += activeBall.Velocity * v3
			end
		end

		self.Elapsed += v3
		v2 -= v3

		advanceHeights(self, v3)
		turnPatrols(self)
		turnRotors(self, v3)
		applyFields(self, v3)
		applyTriggers(self)
		popBubbles(self)

		if v4 == "BallHit" and v5 and v10 then
			local ballBall = resolveBallBall(v5, v10)
			record(self, { -- inferred equivalent call
				Kind = "BallHit",
				Time = self.Elapsed,
				Ball = v5.Number,
				Other = v10.Number,
				Speed = ballBall
			})
		elseif v4 == "CushionHit" and v5 and v9 then
			resolveCushion(v5, v9)
			record(self, { -- inferred equivalent call
				Kind = "CushionHit",
				Time = self.Elapsed,
				Ball = v5.Number,
				CushionId = v9.Id
			})
		elseif v4 == "TipHit" and v5 and v8 then
			resolveTip(v5, v8.Position) -- inferred equivalent call
			record(self, { Kind = "TipHit", Time = self.Elapsed, Ball = v5.Number }) -- inferred equivalent call
		elseif v4 == "Pocketed" and v5 and v7 then
			capture(nil, v5, v7) -- inferred equivalent call
		elseif v4 == "Pocketed" and v5 and v6 then
			sinkIntoHole(self, v5, v6)
		end

		sinkIntoHoles(self)
		checkPockets(self)
		updateSinking(self)
	end

	if v2 > 1e-6 then
		for _, v3 in PoolPhysics.GetActiveBalls(self) do
			if not v3.Static then
				v3.Position += v3.Velocity * v2
			end
		end

		self.Elapsed += v2
		advanceHeights(self, v2)
		turnPatrols(self)
		turnRotors(self, v2)
	end

	for _, v3 in PoolPhysics.GetActiveBalls(self) do
		if v3.Static or v3.Driven then
			continue
		end

		if not isAirborne(v3) then -- inferred equivalent call
			applyFriction(v3, p)
		end

		if
			v3.Sinking
			or PoolGeometry.IsInsidePlayArea(v3.Position, radiusOf(v3) - 0.01, v) -- inferred equivalent call
			or PoolGeometry.IsInPocketChannel(v3.Position, v)
		then
			continue
		end

		v3.Position = PoolGeometry.ClampToPlayArea(v3.Position, radiusOf(v3), v) -- inferred equivalent call
	end

	checkPockets(self)
	updateSinking(self)

	checkTeeter(self, p)
	local flag = true

	for _, v3 in PoolPhysics.GetActiveBalls(self) do
		if not v3.Driven and (v3.Velocity.Magnitude > 0 or v3.Height > 0) then
			flag = false
			break
		end
	end

	if flag then
		self.RestlessFor = 0
	else
		self.RestlessFor = (self.RestlessFor or 0) + p

		if self.RestlessFor >= 25 then
			for _, v3 in PoolPhysics.GetActiveBalls(self) do
				if v3.Driven then
					continue
				end

				v3.Velocity = Vector2.zero
				v3.Spin = Vector2.zero
				v3.Height = 0
				v3.VerticalSpeed = 0
				v3.Trapped = true
				v3.TeeterAt = nil
				v3.TeeterFor = 0
			end

			self.RestlessFor = 0
			flag = true
		end
	end

	self.Settled = flag

	return flag
end

function PoolPhysics.CastCueBall(p, vector2: Vector2)
	local cueNumber = PoolPhysics.CueNumber(p)
	local ball = p.Balls[cueNumber]
	local v = { Kind = "None", Distance = 0, Ghost = Vector2.zero }

	if not ball or ball.Pocketed or vector2.Magnitude <= 1e-6 then
		return v
	end

	local position = ball.Position
	local unit = vector2.Unit

	local v2 = {
		Number = -1,
		Position = position,
		Velocity = unit,
		Spin = Vector2.zero,
		Pocketed = false,
		PocketId = nil,
		Sinking = false,
		Radius = ball.Radius
	}
	local distance = 1e999
	local kind = "None"
	local v3 = nil
	local id = nil
	local id2 = nil

	for _, v4 in PoolPhysics.GetActiveBalls(p) do
		if v4.Number == cueNumber then
			continue
		end

		local v5 = sweepCircle(v4.Position - position, -unit, radiusOf(v2) + radiusOf(v4), distance) -- inferred equivalent call

		if not (v5 and v5 < distance) then
			continue
		end

		v3 = v4
		distance = v5
		kind = "Ball"
		id = nil
		id2 = nil
	end

	for _, cushion in tableOf(p).Cushions do -- inferred equivalent call
		local v4 = cushionToi(position, unit, cushion, distance, radiusOf(ball)) -- inferred equivalent call

		if not (v4 and v4 < distance) then
			continue
		end

		id = cushion.Id
		distance = v4
		kind = "Cushion"
		v3 = nil
		id2 = nil
	end

	for _, jaw in tableOf(p).Jaws do -- inferred equivalent call
		local v4 = pointToi(position, unit, jaw.Position, distance, radiusOf(ball)) -- inferred equivalent call

		if not (v4 and v4 < distance) then
			continue
		end

		distance = v4
		kind = "Tip"
		v3 = nil
		id = nil
		id2 = nil
	end

	for _, pocket in tableOf(p).Pockets do -- inferred equivalent call
		local v4 = pocketToi(position, unit, pocket, distance)

		if not (v4 and v4 < distance) then
			continue
		end

		id2 = pocket.Id
		distance = v4
		kind = "Pocket"
		v3 = nil
		id = nil
	end

	if kind == "None" then
		return v
	end

	local ghost = position + unit * distance
	local other

	if v3 then
		other = v3.Number
	end

	local v4 = {
		Kind = kind,
		Distance = distance,
		Ghost = ghost,
		Other = other,
		CushionId = id,
		PocketId = id2
	}

	if kind ~= "Ball" or not v3 then
		return v4
	end

	local v5 = v3.Position - ghost

	if not (v5.Magnitude > 1e-6) then
		return v4
	end

	local unit2 = v5.Unit
	v4.ObjectDirection = unit2

	local dot = unit:Dot(unit2)
	v4.ImpactFraction = math.clamp(dot * (1 + Physics.BallRestitution) / 2, 0, 1)

	local v6 = unit - unit2 * (dot * (1 + Physics.BallRestitution) / 2)

	if v6.Magnitude > 0.0001 then
		v4.CueFraction = math.clamp(v6.Magnitude, 0, 1)
		v4.CueDirection = v6.Unit
	end

	return v4
end

local function cueStateAtContact(p: number, vector2: Vector2, distance: number, p2: number)
	local total = 0
	local count = 0

	while total < distance and p > 0 and count < 4096 do
		count += 1

		local v = p * p2

		if distance <= total + v then
			break
		end

		total += v

		local rollingDeceleration = Physics.RollingDeceleration

		if math.abs(vector2.Y) > 0.05 then
			rollingDeceleration += Physics.SlidingDeceleration * 0.35
		end

		local v2 = p - rollingDeceleration * p2
		p = v2 <= Physics.StopSpeed and 0 or v2
		vector2 *= math.exp(-Physics.SpinDecay * p2)
	end

	return p, vector2
end

function PoolPhysics.RollDistance(p: number)
	if p <= Physics.StopSpeed then
		return 0
	end

	return (p * p - Physics.StopSpeed * Physics.StopSpeed) / (2 * Physics.RollingDeceleration)
end

function PoolPhysics.PredictShot(p, vector2: Vector2, p2: number, vector2_2: Vector2?, value: number?)
	local v = PoolPhysics.CastCueBall(p, vector2)
	local objectDirection = v.ObjectDirection

	if v.Kind ~= "Ball" or not objectDirection then
		return v
	end

	local v2 = vector2_2 or Vector2.zero
	local unit = vector2.Unit

	local v3, v4 = cueStateAtContact(PoolPhysics.GetShotSpeed(p, p2), v2, v.Distance, value or 1 / 60)

	if v3 <= 1e-6 then
		v.ObjectDistance = 0
		v.CueDistance = 0

		return v
	else
		local v5 = v3 * (v.ImpactFraction or 0)
		local v6 = math.sqrt((math.max(v3 * v3 - v5 * v5, 0)))

		v.ObjectDistance = PoolPhysics.RollDistance(v5)
		v.CueDistance = PoolPhysics.RollDistance(v6)

		if math.abs(v2.Y) <= 0.001 then
			return v
		end

		local v7 = unit - objectDirection * (unit:Dot(objectDirection) * (1 + Physics.BallRestitution) / 2) + unit * (v4.Y * Physics.SpinTransferFraction)

		if v7.Magnitude > 1 then
			v7 = v7.Unit
		end

		if v7.Magnitude > 0.0001 then
			v.CueDirection = v7.Unit
		end

		return v
	end
end

function PoolPhysics.Clone(data)
	local simulation = PoolPhysics.newSimulation()

	simulation.Elapsed = data.Elapsed
	simulation.Settled = data.Settled
	simulation.RestlessFor = data.RestlessFor
	simulation.IsBreakShot = data.IsBreakShot

	simulation.Table = data.Table

	simulation.Modifiers = table.clone(data.Modifiers or {})
	simulation.Popped = table.clone(data.Popped or {})
	simulation.CueBall = data.CueBall

	for _, v in data.Order do
		local ball = data.Balls[v]

		if not ball then
			continue
		end

		local clone = table.clone(ball)

		clone.Triggered = table.clone(ball.Triggered or {})
		clone.Fires = table.clone(ball.Fires or {})

		if ball.Patrol then
			clone.Patrol = table.clone(ball.Patrol)
		end

		if ball.Rotor then
			clone.Rotor = table.clone(ball.Rotor)
		end

		table.insert(simulation.Order, v)
		simulation.Balls[v] = clone
	end

	return simulation
end

return PoolPhysics