local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

local PoolModifiers = {}
PoolModifiers.Gravity = 386.09
PoolModifiers.ScaleReferenceHeight = 60
PoolModifiers.GroundHeight = 0.01
PoolModifiers.ClearanceHeight = 1.6

function PoolModifiers.ScaleForHeight(p: number)
	if p <= 0 then
		return 1
	end

	return 1 + p / PoolModifiers.ScaleReferenceHeight
end

PoolModifiers.Order = {
	"Bullseye",
	"Bubble",
	"Pocket",
	"Lava",
	"Boost",
	"Mud",
	"BlackHole",
	"Fan",
	"Trampoline"
}

PoolModifiers.BullseyeRings = {
	{ Stars = 1, Fraction = 1, Colour = Color3.fromRGB(240, 244, 250) },
	{ Stars = 2, Fraction = 0.74, Colour = Color3.fromRGB(66, 132, 226) },
	{ Stars = 3, Fraction = 0.48, Colour = Color3.fromRGB(214, 62, 62) },
	{ Stars = 4, Fraction = 0.24, Colour = Color3.fromRGB(250, 206, 70) }
}

function PoolModifiers.StarsAt(p: number, p2: number)
	if p2 <= 0 or p2 < p then
		return 0
	end

	local maxStars = 0

	for _, bullseyeRing in PoolModifiers.BullseyeRings do
		if p <= p2 * bullseyeRing.Fraction then
			maxStars = math.max(maxStars, bullseyeRing.Stars)
		end
	end

	return maxStars
end

PoolModifiers.Definitions = {
	Pocket = {
		Id = "Pocket",
		Name = "Pocket",
		Kind = "Goal",
		Colour = Color3.fromRGB(16, 16, 20),
		Radius = 3,
		Rotatable = false,
		AffectsAirborne = false,
		MinScale = 0.5,
		MaxScale = 2,
		Hint = "Sink the golden balls here -- one star each, up to four"
	},
	Bubble = {
		Id = "Bubble",
		Name = "Golden Bubble",
		Kind = "Goal",
		Colour = Color3.fromRGB(255, 216, 102),
		Radius = 5,
		Rotatable = false,
		AffectsAirborne = true,
		MinScale = 0.2,
		MaxScale = 5,
		Hint = "Pop these -- one star each, up to four"
	},
	Bullseye = {
		Id = "Bullseye",
		Name = "Bullseye",
		Kind = "Goal",
		Colour = Color3.fromRGB(240, 244, 250),
		Radius = 22,
		Rotatable = false,
		AffectsAirborne = false,
		MinScale = 0.2,
		MaxScale = 1,
		Hint = "Land balls here -- the tighter the band, the more stars"
	},
	Lava = {
		Id = "Lava",
		Name = "Lava",
		Kind = "Trigger",
		Colour = Color3.fromRGB(236, 94, 48),
		Radius = 6,
		Rotatable = false,
		AffectsAirborne = false,
		Hint = "Destroys any ball that rolls into it"
	},
	Boost = {
		Id = "Boost",
		Name = "Speed Boost",
		Kind = "Trigger",
		Colour = Color3.fromRGB(255, 214, 92),
		Radius = 4,
		Rotatable = false,
		AffectsAirborne = false,
		MaxFiresPerShot = 3,
		Strength = { Min = 1.1, Max = 4, Default = 2 },
		Hint = "Doubles the speed of a ball that touches it"
	},
	Mud = {
		Id = "Mud",
		Name = "Mud",
		Kind = "Field",
		Colour = Color3.fromRGB(126, 94, 62),
		Radius = 8,
		Rotatable = false,
		AffectsAirborne = false,
		Strength = { Min = 5, Max = 60, Default = 20 },
		Hint = "Slows any ball crossing it"
	},
	BlackHole = {
		Id = "BlackHole",
		Name = "Black Hole",
		Kind = "Field",
		Colour = Color3.fromRGB(122, 84, 196),
		Radius = 14,
		Rotatable = false,
		AffectsAirborne = true,
		MinScale = 0.5,
		MaxScale = 1.5,
		Strength = { Min = 60, Max = 600, Default = 240 },
		Hint = "Pulls nearby balls towards it"
	},
	Fan = {
		Id = "Fan",
		Name = "Fan",
		Kind = "Field",
		Colour = Color3.fromRGB(122, 196, 224),
		Radius = 13,
		Rotatable = true,
		AffectsAirborne = true,
		MinScale = 0.5,
		MaxScale = 2,
		Strength = { Min = 10, Max = 1200, Default = 170, Curve = 2 },
		Hint = "Blows balls in the direction it faces"
	},
	Trampoline = {
		Id = "Trampoline",
		Name = "Trampoline",
		Kind = "Trigger",
		Colour = Color3.fromRGB(52, 120, 226),
		Radius = 5,
		Rotatable = false,
		AffectsAirborne = false,
		MinScale = 0.5,
		MaxScale = 4,
		Hint = "Launches a ball into the air, clearing whatever is in the way"
	}
}

PoolModifiers.TriggerOnEntry = true

PoolModifiers.TrampolineLaunch = 150

PoolModifiers.MinPatrolSpeed = 4
PoolModifiers.MaxPatrolSpeed = 60
PoolModifiers.DefaultPatrolSpeed = 22

PoolModifiers.MinPatrolDistance = 4

PoolModifiers.MinDial = 0
PoolModifiers.MaxDial = 100

function PoolModifiers.DialToSpeed(p: number)
	local v = PoolModifiers.MaxDial - PoolModifiers.MinDial
	local v2 = math.clamp((p - PoolModifiers.MinDial) / v, 0, 1)
	return math.round((PoolModifiers.MinPatrolSpeed + (PoolModifiers.MaxPatrolSpeed - PoolModifiers.MinPatrolSpeed) * v2) * 10) / 10
end

function PoolModifiers.SpeedToDial(p: number)
	local v = PoolModifiers.MaxPatrolSpeed - PoolModifiers.MinPatrolSpeed

	if v <= 0 then
		return PoolModifiers.MinDial
	end

	local v2 = math.clamp((p - PoolModifiers.MinPatrolSpeed) / v, 0, 1)

	return (math.round(PoolModifiers.MinDial + (PoolModifiers.MaxDial - PoolModifiers.MinDial) * v2))
end

PoolModifiers.MinSpinSpeed = 20

PoolModifiers.MaxSpinSpeed = 360
PoolModifiers.DefaultSpinSpeed = 90

PoolModifiers.MinSpinnerArm = 1
PoolModifiers.MaxSpinnerArm = 10
PoolModifiers.DefaultSpinnerLength = 3
PoolModifiers.DefaultSpinnerWidth = 1

PoolModifiers.MaxSpinners = 8

function PoolModifiers.SpinToDial(p: number)
	local v = PoolModifiers.MaxSpinSpeed - PoolModifiers.MinSpinSpeed

	if v <= 0 then
		return PoolModifiers.MinDial
	end

	local v2 = math.clamp((p - PoolModifiers.MinSpinSpeed) / v, 0, 1)

	return (math.round(PoolModifiers.MinDial + (PoolModifiers.MaxDial - PoolModifiers.MinDial) * v2))
end

function PoolModifiers.DialToSpin(p: number)
	local v = PoolModifiers.MaxDial - PoolModifiers.MinDial
	local v2 = math.clamp((p - PoolModifiers.MinDial) / v, 0, 1)
	return (math.round(PoolModifiers.MinSpinSpeed + (PoolModifiers.MaxSpinSpeed - PoolModifiers.MinSpinSpeed) * v2))
end

function PoolModifiers.HasStrength(p): boolean
	return p ~= nil and p.Strength ~= nil
end

function PoolModifiers.StrengthOf(p, value: number?)
	local strength = p and p.Strength

	if not strength then
		return 0
	end

	if typeof(value) == "number" and value == value then
		return (math.clamp(value, strength.Min, strength.Max))
	end

	return strength.Default
end

function PoolModifiers.StrengthToDial(p, p2: number)
	local strength = p and p.Strength

	if not strength then
		return PoolModifiers.MinDial
	end

	local v = strength.Max - strength.Min

	if v <= 0 then
		return PoolModifiers.MinDial
	end

	local v2 = math.clamp((p2 - strength.Min) / v, 0, 1) ^ (1 / (strength.Curve or 1))

	return (math.round(PoolModifiers.MinDial + (PoolModifiers.MaxDial - PoolModifiers.MinDial) * v2))
end

function PoolModifiers.DialToStrength(p, p2: number)
	local strength = p and p.Strength

	if not strength then
		return 0
	end

	local v = PoolModifiers.MaxDial - PoolModifiers.MinDial
	local v2 = math.clamp((p2 - PoolModifiers.MinDial) / v, 0, 1) ^ (strength.Curve or 1)

	return math.round((strength.Min + (strength.Max - strength.Min) * v2) * 100) / 100
end

PoolModifiers.MaxModifiers = 20

PoolModifiers.MinScale = 0.5
PoolModifiers.MaxScale = 3

function PoolModifiers.ScaleRange(p)
	if p then
		return p.MinScale or PoolModifiers.MinScale, p.MaxScale or PoolModifiers.MaxScale
	end

	return PoolModifiers.MinScale, PoolModifiers.MaxScale
end

PoolModifiers.MaxStars = 4

function PoolModifiers.IsOverHole(vector2: Vector2, p: number, vector2_2: Vector2): boolean
	return (vector2_2 - vector2).Magnitude <= p + 0.0001
end

function PoolModifiers.HoleAsPocket(id: string, bowlCentre: Vector2, bowlRadius: number, vector2: Vector2?, vector2_2: Vector2?)
	local normal

	if vector2_2 and vector2_2.Magnitude > 1e-6 then
		normal = vector2_2.Unit
	else
		normal = Vector2.new(1, 0)
	end

	return {
		Id = id,
		MouthCentre = vector2 or bowlCentre,
		BowlCentre = bowlCentre,
		BowlRadius = bowlRadius,
		Mouth = bowlRadius * 2,
		Normal = normal
	}
end

function PoolModifiers.HoleId(p: number)
	return "Mod" .. p
end

function PoolModifiers.HoleIndex(value)
	if typeof(value) == "string" then
		return (tonumber(value:match("^Mod(%d+)$")))
	end

	return nil
end

function PoolModifiers.Get(value)
	if typeof(value) == "string" then
		return PoolModifiers.Definitions[value]
	end

	return nil
end

function PoolModifiers.IsPlaceable(p): boolean
	return PoolModifiers.Get(p) ~= nil
end

function PoolModifiers.RadiusOf(p, value: number?)
	return p.Radius * (value or 1)
end

function PoolModifiers.Overlaps(vector2: Vector2, p: number, vector2_2: Vector2, p2: number): boolean
	return p + p2 >= (vector2_2 - vector2).Magnitude
end

function PoolModifiers.FalloffAt(p: number, p2: number)
	if p2 <= 0 then
		return 0
	end

	return (math.clamp(1 - p / p2, 0, 1))
end

function PoolModifiers.FanDirection(p: number)
	local v = math.rad(p)

	return Vector2.new(math.cos(v), (math.sin(v)))
end

function PoolModifiers.MaxReach()
	local maxValue = 0

	for _, definition in PoolModifiers.Definitions do
		local _, v = PoolModifiers.ScaleRange(definition)

		maxValue = math.max(maxValue, definition.Radius * v)
	end

	return maxValue + PoolConstants.BallRadius * 6
end

return PoolModifiers