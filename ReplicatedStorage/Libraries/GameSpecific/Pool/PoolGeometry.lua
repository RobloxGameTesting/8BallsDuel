local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

local PoolGeometry = {}

local halfWidth = PoolConstants.PlayWidth / 2
local halfHeight = PoolConstants.PlayHeight / 2

local v = PoolConstants.CornerPocketMouth / 1.4142135623730951
local halfSidePocketMouth = PoolConstants.SidePocketMouth / 2

PoolGeometry.HalfWidth = halfWidth
PoolGeometry.HalfHeight = halfHeight

PoolGeometry.HeadStringX = -halfWidth / 2
PoolGeometry.HeadSpot = Vector2.new(-halfWidth / 2, 0)

PoolGeometry.BreakSpot = Vector2.new(-halfWidth / 2 - PoolConstants.BallRadius, 0)
PoolGeometry.FootSpot = Vector2.new(halfWidth / 2, 0)

PoolGeometry.RespotSpot = Vector2.zero
PoolGeometry.CentreSpot = Vector2.zero

local CushionDepth = PoolConstants.CushionDepth

local function reachToBowl(vector2: Vector2, vector2_2: Vector2, vector2_3: Vector2, p: number) -- 2 equivalent calls inferred from this helper
	local vector = vector2_3 - vector2
	local dot = vector:Dot(vector2_2)
	local v2 = vector:Dot(vector) - dot * dot
	local v3 = p * p

	if v3 <= v2 then
		return dot
	end

	return dot - math.sqrt(v3 - v2)
end

local function makePocket(id: string, kind: string, mouthA: Vector2, mouthB: Vector2)
	local magnitude = (mouthB - mouthA).Magnitude
	local mouthCentre = (mouthA + mouthB) / 2
	local unit = (mouthB - mouthA).Unit

	local vector2 = Vector2.new(unit.Y, -unit.X)

	if vector2:Dot(mouthCentre) < 0 then
		vector2 = -vector2
	end

	local v2 = kind == "Corner"
	local v3

	if v2 then
		v3 = PoolConstants.CornerFacingFlare
	else
		v3 = PoolConstants.SideFacingFlare
	end

	local v4 = math.rad(v3)

	local unit2 = (mouthA - mouthCentre).Unit
	local unit3 = (mouthB - mouthCentre).Unit
	local v5 = vector2 * math.cos(v4) + unit2 * math.sin(v4)
	local v6 = vector2 * math.cos(v4) + unit3 * math.sin(v4)

	local bowlRadius = magnitude * PoolConstants.BowlDiameterScale / 2
	local v7

	if v2 then
		v7 = PoolConstants.CornerBowlOffsetScale
	else
		v7 = PoolConstants.SideBowlOffsetScale
	end

	local v8 = magnitude * v7
	local bowlCentre = mouthCentre + vector2 * v8

	local v9 = CushionDepth / math.cos(v4)
	local v10 = math.max(reachToBowl(mouthA, v5, bowlCentre, bowlRadius), v9) -- inferred equivalent call
	local v11 = math.max(reachToBowl(mouthB, v6, bowlCentre, bowlRadius), v9) -- inferred equivalent call

	local facingAEnd = mouthA + v5 * v10
	local facingBEnd = mouthB + v6 * v11

	local pocket = {
		Id = id,
		Kind = kind,
		MouthA = mouthA,
		MouthB = mouthB,
		MouthCentre = mouthCentre,
		Mouth = magnitude,
		Normal = vector2,
		FacingAEnd = facingAEnd,
		FacingBEnd = facingBEnd,
		ThroatWidth = (facingBEnd - facingAEnd).Magnitude,
		BowlCentre = bowlCentre,
		BowlRadius = bowlRadius,
		DropDepth = v8 - bowlRadius,
		CommitDepth = 0
	}
	local commitDepth

	if v2 then
		commitDepth = PoolConstants.CornerMouthDepth
	else
		commitDepth = PoolConstants.SideMouthDepth
	end

	pocket.CommitDepth = commitDepth
	return pocket
end

local function buildPockets(p: number, p2: number)
	return {
		makePocket("HeadBottom", "Corner", Vector2.new(-p + v, -p2), Vector2.new(-p, -p2 + v)),
		makePocket("HeadTop", "Corner", Vector2.new(-p + v, p2), Vector2.new(-p, p2 - v)),
		makePocket("FootBottom", "Corner", Vector2.new(p - v, -p2), Vector2.new(p, -p2 + v)),
		makePocket("FootTop", "Corner", Vector2.new(p - v, p2), Vector2.new(p, p2 - v)),
		makePocket("SideBottom", "Side", Vector2.new(-halfSidePocketMouth, -p2), Vector2.new(halfSidePocketMouth, -p2)),
		makePocket("SideTop", "Side", Vector2.new(-halfSidePocketMouth, p2), Vector2.new(halfSidePocketMouth, p2))
	}
end

local function buildNoses(p: number, p2: number)
	return {
		{
			Id = "BottomLeft",
			Rail = "BottomLong",
			A = Vector2.new(-p + v, -p2),
			B = Vector2.new(-halfSidePocketMouth, -p2),
			Normal = Vector2.new(0, 1),
			Kind = "Nose"
		},
		{
			Id = "BottomRight",
			Rail = "BottomLong",
			A = Vector2.new(halfSidePocketMouth, -p2),
			B = Vector2.new(p - v, -p2),
			Normal = Vector2.new(0, 1),
			Kind = "Nose"
		},
		{
			Id = "TopLeft",
			Rail = "TopLong",
			A = Vector2.new(-p + v, p2),
			B = Vector2.new(-halfSidePocketMouth, p2),
			Normal = Vector2.new(0, -1),
			Kind = "Nose"
		},
		{
			Id = "TopRight",
			Rail = "TopLong",
			A = Vector2.new(halfSidePocketMouth, p2),
			B = Vector2.new(p - v, p2),
			Normal = Vector2.new(0, -1),
			Kind = "Nose"
		},
		{
			Id = "Head",
			Rail = "Head",
			A = Vector2.new(-p, -p2 + v),
			B = Vector2.new(-p, p2 - v),
			Normal = Vector2.new(1, 0),
			Kind = "Nose"
		},
		{
			Id = "Foot",
			Rail = "Foot",
			A = Vector2.new(p, -p2 + v),
			B = Vector2.new(p, p2 - v),
			Normal = Vector2.new(-1, 0),
			Kind = "Nose"
		}
	}
end

local function addFacing(list, item, rail: string, p: number, vector2: Vector2, vector2_2: Vector2)
	local unit = (vector2_2 - vector2).Unit
	local vector2_3 = Vector2.new(-unit.Y, unit.X)

	if vector2_3:Dot(item.MouthCentre - vector2) < 0 then
		vector2_3 = -vector2_3
	end

	table.insert(list, {
		Id = string.format("%sFacing%d", item.Id, p),
		Rail = rail,
		A = vector2,
		B = vector2_2,
		Normal = vector2_3,
		Kind = "Facing",
		PocketId = item.Id
	})
end

local function addFacings(p, items)
	for _, item in items do
		local v2

		if item.Kind == "Side" then
			v2 = item.MouthCentre.Y > 0 and "TopLong" or "BottomLong"
		else
			v2 = item.MouthCentre.X > 0 and "Foot" or "Head"
		end

		addFacing(p, item, v2, 1, item.MouthA, item.FacingAEnd)
		addFacing(p, item, v2, 2, item.MouthB, item.FacingBEnd)
	end
end

local function buildDiamonds(p: number, p2: number)
	local v2 = p2 + (PoolConstants.CushionDepth + PoolConstants.RailDepth - PoolConstants.BezelDepth) / 2
	local v3 = p + (PoolConstants.CushionDepth + PoolConstants.RailDepth - PoolConstants.BezelDepth) / 2

	local vector2s = {}

	for i = 1, 7 do
		if i == 4 then
			continue
		end

		local v4 = -p + p * 2 * i / 8
		table.insert(vector2s, Vector2.new(v4, v2))
		table.insert(vector2s, Vector2.new(v4, -v2))
	end

	for i = 1, 3 do
		local v4 = -p2 + p2 * 2 * i / 4
		table.insert(vector2s, Vector2.new(v3, v4))
		table.insert(vector2s, Vector2.new(-v3, v4))
	end

	return vector2s
end

local function buildJaws(items)
	local jaws = {}

	for _, item in items do
		table.insert(jaws, { Position = item.MouthA, Pocket = item })
		table.insert(jaws, { Position = item.MouthB, Pocket = item })
	end

	return jaws
end

local v2 = v + halfSidePocketMouth + PoolConstants.BallDiameter
local v3 = v + PoolConstants.BallDiameter

PoolGeometry.MinScale = 0.2
PoolGeometry.MaxScale = 2

PoolGeometry.ScaleStep = 0.05

local v4 = PoolConstants.FrameWidth - PoolConstants.PlayWidth
local v5 = PoolConstants.FrameHeight - PoolConstants.PlayHeight

local function buildUnbrokenRails(p: number, p2: number)
	return {
		{
			Id = "Bottom",
			Rail = "BottomLong",
			A = Vector2.new(-p, -p2),
			B = Vector2.new(p, -p2),
			Normal = Vector2.new(0, 1),
			Kind = "Nose"
		},
		{
			Id = "Top",
			Rail = "TopLong",
			A = Vector2.new(-p, p2),
			B = Vector2.new(p, p2),
			Normal = Vector2.new(0, -1),
			Kind = "Nose"
		},
		{
			Id = "Head",
			Rail = "Head",
			A = Vector2.new(-p, -p2),
			B = Vector2.new(-p, p2),
			Normal = Vector2.new(1, 0),
			Kind = "Nose"
		},
		{
			Id = "Foot",
			Rail = "Foot",
			A = Vector2.new(p, -p2),
			B = Vector2.new(p, p2),
			Normal = Vector2.new(-1, 0),
			Kind = "Nose"
		}
	}
end

local function build(lengthScale: number, heightScale: number, pocketed: boolean)
	local v6 = halfWidth * lengthScale
	local v7 = if pocketed then v2 else PoolConstants.BallDiameter
	local halfWidth2 = math.max(v6, v7)
	local v8 = halfHeight * heightScale
	local v9 = if pocketed then v3 else PoolConstants.BallDiameter
	local halfHeight2 = math.max(v8, v9)

	local pockets = not pocketed and {} or buildPockets(halfWidth2, halfHeight2)
	local cushions

	if pocketed then
		cushions = buildNoses(halfWidth2, halfHeight2)
	else
		cushions = buildUnbrokenRails(halfWidth2, halfHeight2)
	end

	local noseCount = #cushions

	if pocketed then
		addFacings(cushions, pockets)
	end

	return {
		LengthScale = lengthScale,
		HeightScale = heightScale,
		Pocketed = pocketed,
		HalfWidth = halfWidth2,
		HalfHeight = halfHeight2,
		FrameWidth = halfWidth2 * 2 + v4,
		FrameHeight = halfHeight2 * 2 + v5,
		HeadStringX = -halfWidth2 / 2,
		HeadSpot = Vector2.new(-halfWidth2 / 2, 0),
		BreakSpot = Vector2.new(-halfWidth2 / 2 - PoolConstants.BallRadius, 0),
		FootSpot = Vector2.new(halfWidth2 / 2, 0),
		Cushions = cushions,
		NoseCount = noseCount,
		Pockets = pockets,
		Jaws = buildJaws(pockets),
		Diamonds = buildDiamonds(halfWidth2, halfHeight2)
	}
end

local v6 = {}

function PoolGeometry.For(value: number?, value2: number?, flag: boolean?)
	local v7 = math.clamp(value or 1, PoolGeometry.MinScale, PoolGeometry.MaxScale)
	local v8 = math.clamp(value2 or 1, PoolGeometry.MinScale, PoolGeometry.MaxScale)
	local pocketed = flag ~= false
	local lengthScale = math.round(v7 * 100) / 100
	local heightScale = math.round(v8 * 100) / 100

	local v9 = string.format("%.2fx%.2f%s", lengthScale, heightScale, pocketed and "P" or "O")
	local v10 = v6[v9]

	if not v10 then
		v10 = build(lengthScale, heightScale, pocketed)
		v6[v9] = v10
	end

	return v10
end

PoolGeometry.Default = PoolGeometry.For(1, 1)

local default = PoolGeometry.Default
local pockets = default.Pockets
local cushions = default.Cushions
local jaws = default.Jaws
local diamonds = default.Diamonds

function PoolGeometry.GetNoseCount(p)
	return (p or default).NoseCount
end

function PoolGeometry.GetJaws(p)
	return (p or default).Jaws
end

function PoolGeometry.GetNearbyJawPocket(vector2: Vector2, p: number, p2)
	for _, jaw in (p2 or default).Jaws do
		if (vector2 - jaw.Position).Magnitude <= p then
			return jaw.Pocket
		end
	end

	return nil
end

function PoolGeometry.GetCushions(p)
	return (p or default).Cushions
end

function PoolGeometry.GetPockets(p)
	return (p or default).Pockets
end

function PoolGeometry.GetDiamonds(p)
	return (p or default).Diamonds
end

function PoolGeometry.ClampToPlayArea(vector2: Vector2, p: number?, p2)
	local v7 = p2 or default
	local v8 = p or PoolConstants.BallRadius
	local v9 = math.clamp(vector2.X, -v7.HalfWidth + v8, v7.HalfWidth - v8)
	local v10 = math.clamp(vector2.Y, -v7.HalfHeight + v8, v7.HalfHeight - v8)

	return Vector2.new(v9, v10)
end

function PoolGeometry.IsInsidePlayArea(vector2: Vector2, p: number?, p2): boolean
	local v7 = p2 or default
	local v8 = p or PoolConstants.BallRadius

	return math.abs(vector2.X) <= v7.HalfWidth - v8 and math.abs(vector2.Y) <= v7.HalfHeight - v8
end

function PoolGeometry.IsBehindHeadString(vector2: Vector2, p): boolean
	return vector2.X < (p or default).HeadStringX
end

function PoolGeometry.GetPocketAt(vector2: Vector2, p)
	for _, pocket in (p or default).Pockets do
		if (vector2 - pocket.BowlCentre).Magnitude <= pocket.BowlRadius then
			return pocket
		end
	end

	return nil
end

function PoolGeometry.IsInThroat(vector2: Vector2, p)
	for _, pocket in (p or default).Pockets do
		local vector = vector2 - pocket.MouthCentre

		if not (vector:Dot(pocket.Normal) >= pocket.CommitDepth) then
			continue
		end

		local vector2_2 = Vector2.new(-pocket.Normal.Y, pocket.Normal.X)

		if math.max(pocket.Mouth, pocket.ThroatWidth) / 2 >= math.abs((vector:Dot(vector2_2))) then
			return pocket
		end
	end

	return nil
end

function PoolGeometry.IsInPocketChannel(vector2: Vector2, p)
	local _cushionDepth = PoolConstants.CushionDepth

	for _, pocket in (p or default).Pockets do
		local v7 = PoolConstants.BallDiameter + math.max(0, -pocket.CommitDepth)

		local vector = vector2 - pocket.MouthCentre
		local dot = vector:Dot(pocket.Normal)
		local v8 = (pocket.BowlCentre - pocket.MouthCentre):Dot(pocket.Normal) + pocket.BowlRadius + PoolConstants.BallDiameter

		if
			-v7 <= dot
			and dot <= v8
			and math.max(pocket.Mouth / 2, pocket.ThroatWidth / 2) >= math.abs((vector:Dot((Vector2.new(-pocket.Normal.Y, pocket.Normal.X)))))
		then
			return pocket
		end
	end

	return nil
end

local v7 = PoolConstants.RackJitter * 2
local v8 = PoolConstants.BallDiameter + v7
local v9 = v8 * 1.7320508075688772 / 2

local vector2s = {}
local v10 = { 11, 15 }

for i = 0, 4 do
	for j = 0, i do
		local v11 = PoolGeometry.FootSpot.X + i * v9
		local v12 = PoolGeometry.FootSpot.Y + (j - i / 2) * v8
		table.insert(vector2s, Vector2.new(v11, v12))
	end
end

local v11 = PoolConstants.BallDiameter * 1.7320508075688772 / 2
local vector2s2 = {}

for i = 0, 4 do
	for j = 0, i do
		local v12 = PoolGeometry.FootSpot.X + i * v11
		local v13 = PoolGeometry.FootSpot.Y + (j - i / 2) * PoolConstants.BallDiameter
		table.insert(vector2s2, Vector2.new(v12, v13))
	end
end

function PoolGeometry.GetTightSlotPositions()
	return vector2s2
end

function PoolGeometry.GetSlotPositions()
	return vector2s
end

local function shuffle(p, object)
	local clone = table.clone(p)

	for i = #clone, 2, -1 do
		local integer = object:NextInteger(1, i)
		local v12 = clone[integer]
		local v13 = clone[i]
		clone[i] = v12
		clone[integer] = v13
	end

	return clone
end

local function slotJitter(object)
	if PoolConstants.RackJitter <= 0 then
		return Vector2.zero
	end

	local number = object:NextNumber(0, 6.283185307179586)
	local v12 = math.sqrt((object:NextNumber())) * PoolConstants.RackJitter

	return Vector2.new(math.cos(number), (math.sin(number))) * v12
end

function PoolGeometry.BuildRack(p)
	local v12 = p or Random.new()

	local v13 = shuffle(PoolConstants.Solids, v12)
	local v14 = shuffle(PoolConstants.Stripes, v12)

	local v15 = table.create(15)

	v15[5] = PoolConstants.EightBallNumber

	local v16 = table.remove(v13, 1)
	local v17 = table.remove(v14, 1)

	if v12:NextNumber() < 0.5 then
		v15[v10[1]] = v16
		v15[v10[2]] = v17
	else
		v15[v10[1]] = v17
		v15[v10[2]] = v16
	end

	local v18 = {}

	for _, v19 in v13 do
		table.insert(v18, v19)
	end

	for _, v19 in v14 do
		table.insert(v18, v19)
	end

	local v19 = shuffle(v18, v12)
	local v20 = 1

	for i = 1, 15 do
		if v15[i] ~= nil then
			continue
		end

		v15[i] = v19[v20]
		v20 += 1
	end

	local rack = {}

	for i = 1, 15 do
		local number = v15[i]
		assert(number ~= nil, string.format("rack slot %d was never filled", i))
		table.insert(rack, {
			Number = number,
			Position = vector2s[i] + slotJitter(v12),
			DisplayPosition = vector2s2[i]
		})
	end

	return rack
end

function PoolGeometry.GetApexSlot(): number
	return 1
end

local v12 = {
	1,
	2,
	3,
	4,
	5,
	6,
	8,
	9,
	13
}

PoolGeometry.NineBallSpot = vector2s2[5]

function PoolGeometry.BuildNineBallRack(p)
	local v13 = p or Random.new()
	local v14 = shuffle({ 2, 3, 4, 5, 6, 7, 8 }, v13)
	local v15 = 1
	local nineBallRack = {}

	for _, v16 in v12 do
		local number

		if v16 == 1 then
			number = 1
		elseif v16 == 5 then
			number = 9
		else
			number = v14[v15]
			v15 += 1
		end

		table.insert(nineBallRack, {
			Number = number,
			Position = vector2s[v16] + slotJitter(v13),
			DisplayPosition = vector2s2[v16]
		})
	end

	return nineBallRack
end

function PoolGeometry.BuildRackFor(p: string?, p2)
	if p == "NineBall" then
		return PoolGeometry.BuildNineBallRack(p2)
	end

	return PoolGeometry.BuildRack(p2)
end

return PoolGeometry