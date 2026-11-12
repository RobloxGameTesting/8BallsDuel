local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolModifiers = require(Pool.PoolModifiers)
local PoolPhysics = require(Pool.PoolPhysics)
local PoolTrickshotTypes = require(Pool.PoolTrickshotTypes)

local PoolGoals = {}

local v = { "Bullseye", "Bubble", "Pocket" }

local function countModifiers(p, p2: string) -- 5 equivalent calls inferred from this helper
	local count = 0

	for _, v2 in p.Mods or {} do
		if v2.K == p2 then
			count += 1
		end
	end

	return count
end

local function countGoldenBalls(p) -- 1 equivalent call inferred from this helper
	local count = 0

	for _, ball in p.Balls do
		if PoolTrickshotTypes.IsGolden(ball) then
			count += 1
		end
	end

	return count
end

function PoolGoals.Census(p)
	local v2 = PoolTrickshotTypes.TableOf(p).Pocketed

	if not v2 then
		v2 = countModifiers(p, "Pocket") > 0 -- inferred equivalent call
	end

	local v3 = {
		Bullseye = countModifiers(p, "Bullseye"), -- inferred equivalent call
		Bubble = countModifiers(p, "Bubble"), -- inferred equivalent call
		Pocket = 0,
		None = 0
	}
	local count

	if v2 then
		count = 0

		for _, ball in p.Balls do
			if PoolTrickshotTypes.IsGolden(ball) then
				count += 1
			end
		end
	else
		count = 0
	end

	v3.Pocket = count
	return v3
end

function PoolGoals.KindOf(p)
	local census = PoolGoals.Census(p)

	for _, v2 in v do
		if census[v2] > 0 then
			return v2
		end
	end

	return "None"
end

function PoolGoals.Describe(p)
	local census = PoolGoals.Census(p)
	local count = 0

	for _, v2 in v do
		if census[v2] > 0 then
			count += 1
		end
	end

	if count == 0 then
		if countModifiers(p, "Pocket") > 0 then -- inferred equivalent call
			return "This pocket has no golden ball -- place a new pocket to get one"
		end

		return "Add a bullseye, a golden bubble or a pocket to give this scene a goal"
	elseif count > 1 then
		return string.format("This scene has more than one goal -- it will be scored as %s", PoolGoals.KindOf(p))
	else
		return nil
	end
end

local function scoreBullseye(p, p2)
	local maxValue = 0

	for _, v2 in p.Mods or {} do
		if v2.K ~= "Bullseye" then
			continue
		end

		local v3 = PoolModifiers.Get(v2.K)

		if not v3 then
			continue
		end

		local vector2 = Vector2.new(v2.X, v2.Y)
		local radius = PoolModifiers.RadiusOf(v3, v2.S)

		for _, v4 in PoolPhysics.GetActiveBalls(p2) do
			if not (v4.Height and v4.Height > 0) then
				maxValue = math.max(maxValue, PoolModifiers.StarsAt((v4.Position - vector2).Magnitude, radius))
			end
		end
	end

	return maxValue, PoolModifiers.MaxStars, maxValue
end

local function scaleToStars(count: number, p: number) -- 2 equivalent calls inferred from this helper
	if p <= 0 or count <= 0 then
		return 0
	end

	if p <= count then
		return PoolModifiers.MaxStars
	end

	return (math.clamp(math.floor(count / p * PoolModifiers.MaxStars), 1, PoolModifiers.MaxStars - 1))
end

local function scoreBubbles(p, p2)
	local count2 = countModifiers(p, "Bubble") -- inferred equivalent call
	local count = 0

	for k, v2 in p.Mods or {} do
		if v2.K == "Bubble" and p2.Popped[k] then
			count += 1
		end
	end

	return scaleToStars(count, count2), count2, count -- inferred equivalent call
end

local function scorePockets(p, p2)
	local count2 = countGoldenBalls(p) -- inferred equivalent call
	local count = 0

	for _, ball in p.Balls do
		if not PoolTrickshotTypes.IsGolden(ball) then
			continue
		end

		local ball2 = p2.Balls[ball.I]

		if not ball2 or not ball2.Pocketed or ball2.Destroyed then
			continue
		end

		count += 1
	end

	return scaleToStars(count, count2), count2, count -- inferred equivalent call
end

local v2 = { Bullseye = scoreBullseye, Bubble = scoreBubbles, Pocket = scorePockets }

local v3 = {
	Bullseye = "%d of %d stars on the bullseye",
	Bubble = "%d of %d bubbles popped",
	Pocket = "%d of %d golden balls pocketed"
}

function PoolGoals.Evaluate(p, p2)
	local kind = PoolGoals.KindOf(p)
	local v4 = v2[kind]

	if not v4 then
		return {
			Kind = "None",
			Stars = 0,
			Available = 0,
			Achieved = 0,
			Summary = "This scene has no goal"
		}
	end

	local v5, available, achieved = v4(p, p2)

	return {
		Kind = kind,
		Stars = math.clamp(v5, 0, PoolModifiers.MaxStars),
		Available = available,
		Achieved = achieved,
		Summary = string.format(v3[kind], achieved, available)
	}
end

function PoolGoals.MaxStarsFor(p)
	if PoolGoals.KindOf(p) == "None" then
		return 0
	end

	return PoolModifiers.MaxStars
end

function PoolGoals.NothingLeft(p, p2): boolean
	local kind = PoolGoals.KindOf(p)

	if kind == "Bubble" then
		for k, v4 in p.Mods or {} do
			if v4.K == "Bubble" and not p2.Popped[k] then
				return false
			end
		end
	else
		if kind ~= "Pocket" then
			return false
		end

		for _, ball in p.Balls do
			if not PoolTrickshotTypes.IsGolden(ball) then
				continue
			end

			local ball2 = p2.Balls[ball.I]

			if ball2 and not (ball2.Pocketed or ball2.Destroyed) then
				return false
			end
		end
	end

	return true
end

function PoolGoals.IsPassed(p): boolean
	return p.Stars >= 1
end

return PoolGoals