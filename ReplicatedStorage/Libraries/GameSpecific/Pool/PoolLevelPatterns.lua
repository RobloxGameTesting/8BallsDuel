local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

local PoolLevelPatterns = {}
PoolLevelPatterns.WallNumber = 8
PoolLevelPatterns.PostNumber = 9

local function round(p: number) -- 12 equivalent calls inferred from this helper
	return math.round(p * 100) / 100
end

local function anchored(p: number, p2: number, p3: number?, p4: number?)
	local v = {
		N = p4 or PoolLevelPatterns.WallNumber,
		X = round(p), -- inferred equivalent call
		Y = round(p2), -- inferred equivalent call
		S = 0,
		A = true
	}

	if not p3 or p3 == 1 then
		p3 = nil
	end

	v.S = p3
	return v
end

function PoolLevelPatterns.Cues(items)
	local result = {}

	for _, item in items do
		table.insert(result, { N = 0, X = item[1], Y = item[2] })
	end

	return result
end

function PoolLevelPatterns.Golden(items)
	local result = {}

	for _, item in items do
		table.insert(result, { N = 12, X = item[1], Y = item[2] })
	end

	return result
end

function PoolLevelPatterns.Wall(p: number, p2: number, p3: number, p4: number, p5: number, p6: number?, options, p7: number?)
	local set = {}
	local result = {}

	for _, v in options or {} do
		set[v] = true
	end

	for i = 1, p5 do
		if set[i] then
			continue
		end

		local v = p5 == 1 and 0 or (i - 1) / (p5 - 1)

		table.insert(result, anchored(p + (p3 - p) * v, p2 + (p4 - p2) * v, p6, p7))
	end

	return result
end

function PoolLevelPatterns.Ring(p: number, p2: number, p3: number, p4: number, p5: number?, value: number?, value2: number?, p6: number?)
	local v = value2 or 0
	local result = {}

	for i = 0, p4 - 1 do
		local v2 = i / p4 * 360
		local v3 = math.abs((v2 - (value or 0) + 540) % 360 - 180)

		if not (v / 2 < v3) then
			continue
		end

		local v4 = math.rad(v2)
		table.insert(result, anchored(p + math.cos(v4) * p3, p2 + math.sin(v4) * p3, p5, p6))
	end

	return result
end

function PoolLevelPatterns.Cross(p: number, p2: number, p3: number, p4: number, p5: number?, p6: number?)
	local result = { anchored(p, p2, p5, p6 or PoolLevelPatterns.PostNumber) }

	for i = 1, p3 do
		local v = i * p4

		table.insert(result, anchored(p + v, p2, p5, p6 or PoolLevelPatterns.PostNumber))
		table.insert(result, anchored(p - v, p2, p5, p6 or PoolLevelPatterns.PostNumber))
		table.insert(result, anchored(p, p2 + v, p5, p6 or PoolLevelPatterns.PostNumber))
		table.insert(result, anchored(p, p2 - v, p5, p6 or PoolLevelPatterns.PostNumber))
	end

	return result
end

function PoolLevelPatterns.Grid(p: number, p2: number, p3: number, p4: number, p5: number, p6: number?, p7: number?)
	local result = {}

	for i = 0, p3 - 1 do
		for j = 0, p4 - 1 do
			local v = p + (i - (p3 - 1) / 2) * p5
			local v2 = p2 + (j - (p4 - 1) / 2) * p5

			table.insert(result, anchored(v, v2, p6, p7 or PoolLevelPatterns.PostNumber))
		end
	end

	return result
end

function PoolLevelPatterns.Patrol(p: number, p2: number, rx: number, ry: number, rs: number?, p3: number?)
	if not p3 or p3 == 1 then
		p3 = nil
	end

	return {
		N = 5,
		X = p,
		Y = p2,
		RX = rx,
		RY = ry,
		RS = rs,
		S = p3
	}
end

function PoolLevelPatterns.Spinner(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number?)
	local v = {
		N = 4,
		X = round(p), -- inferred equivalent call
		Y = round(p2), -- inferred equivalent call
		A = true,
		G = p6,
		W = math.round(p5),
		L = p3,
		D = p4,
		S = 0
	}

	if not p7 or p7 == 1 then
		p7 = nil
	end

	v.S = p7
	return { v }
end

local BallRadius = PoolConstants.BallRadius

local function leftNormal(unit: Vector2) -- 5 equivalent calls inferred from this helper
	return Vector2.new(-unit.Y, unit.X)
end

local function meetLine(vector2: Vector2, unit: Vector2, vector2_2: Vector2, unit2: Vector2) -- 2 equivalent calls inferred from this helper
	local dot = unit:Dot(unit2)

	if math.abs(dot) < 1e-6 then
		return vector2
	end

	return vector2 + unit * ((vector2_2 - vector2):Dot(unit2) / dot)
end

local function walk(list, callback, list2, list3)
	for i = 1, #list - 1 do
		local item = list[i]
		local item2 = list[i + 1]
		local magnitude = (item2 - item).Magnitude

		if magnitude < 1e-6 then
			continue
		end

		local v = (item2 - item) / magnitude
		local v2 = callback(i)
		local total = 0

		while total <= magnitude + 1e-6 do
			local v3 = item + v * math.min(total, magnitude)
			local flag = true

			for _, item3 in list2 do
				if (item3 - v3).Magnitude < v2 then
					flag = false
					break
				end
			end

			if flag then
				table.insert(list2, v3)
				table.insert(list3, v3)
			end

			total += 0.1
		end
	end
end

local function endCap(list, p: number)
	local unit = (list[2] - list[1]).Unit
	local v = leftNormal(unit) -- inferred equivalent call
	local result = {}

	for i = 0, 16 do
		local v2 = 1.5707963267948966 + 3.141592653589793 * (i / 16)

		table.insert(result, list[1] + unit * (math.cos(v2) * p) + v * (math.sin(v2) * p))
	end

	return result
end

function PoolLevelPatterns.Corridor(items, p: number, p2: number, p3: number, p4: number, options, p5: number?)
	local vector2s = {}

	for _, item in items do
		table.insert(vector2s, Vector2.new(item[1], item[2]))
	end

	local v = BallRadius * p2
	local v2 = p + BallRadius + v
	local v3 = {}
	local v4 = {}

	for _, v5 in options or {} do
		table.insert(v3, Vector2.new(v5[1], v5[2]))
	end

	local v5 = {}
	local v6 = {}

	for _, v7 in { 1, -1 } do
		local line = {}
		local mirror = {}
		local unit = (vector2s[2] - vector2s[1]).Unit
		table.insert(line, vector2s[1] + leftNormal(unit) * v2 * v7) -- inferred equivalent call
		table.insert(mirror, false)

		for i = 2, #vector2s - 1 do
			local v8 = vector2s[i]
			local unit2 = (v8 - vector2s[i - 1]).Unit
			local unit3 = (vector2s[i + 1] - v8).Unit
			local v9 = leftNormal(unit2) * v7 -- inferred equivalent call
			local v10 = leftNormal(unit3) * v7 -- inferred equivalent call

			if (unit2.X * unit3.Y - unit2.Y * unit3.X) * v7 >= 0 then
				local unit4 = (v9 + v10).Unit

				table.insert(line, v8 + unit4 * (v2 / math.max(unit4:Dot(v9), 0.2)))
				table.insert(mirror, false)
			else
				local ballRestitution = PoolConstants.Physics.BallRestitution
				local v11 = unit2:Dot(unit3) * (1 - ballRestitution)
				local unit4 = (unit3 * ((v11 + math.sqrt(v11 * v11 + 4 * ballRestitution)) / 2) - unit2).Unit
				local v12 = v8 - unit4 * (BallRadius + v)

				table.insert(line, meetLine(v8 + v9 * v2, unit2, v12, unit4)) -- inferred equivalent call
				table.insert(mirror, true)
				table.insert(line, meetLine(v8 + v10 * v2, unit3, v12, unit4)) -- inferred equivalent call
				table.insert(mirror, false)
				table.insert(v5, v12)
			end
		end

		local unit2 = (vector2s[#vector2s] - vector2s[#vector2s - 1]).Unit
		table.insert(line, vector2s[#vector2s] + leftNormal(unit2) * v2 * v7) -- inferred equivalent call
		table.insert(mirror, false)
		table.insert(v6, { Line = line, Mirror = mirror })
	end

	local count = 0

	for _, v7 in v6 do
		for i = 1, #v7.Line - 1 do
			if not v7.Mirror[i] then
				continue
			end

			count += 1

			local v8 = v7.Line[i]
			local v9 = v7.Line[i + 1]
			local unit = (v9 - v8).Unit
			local magnitude = (v9 - v8).Magnitude
			local dot = (v5[count] - v8):Dot(unit)

			for _, v10 in { 1, -1 } do
				local v11 = if v10 == 1 then 0 else 1

				while true do
					local v12 = dot + v11 * p4 * v10

					if v12 < -1e-6 or magnitude + 1e-6 < v12 then
						break
					end

					local v13 = v8 + unit * v12

					table.insert(v3, v13)
					table.insert(v4, v13)
					v11 += 1
				end
			end
		end
	end

	for _, v7 in v6 do
		walk(v7.Line, function(p6: number)
			return if v7.Mirror[p6] then p4 else p3
		end, v3, v4)
	end

	local v7 = {}

	for i = #vector2s, 1, -1 do
		table.insert(v7, vector2s[i])
	end

	local function capGap()
		return p3
	end

	walk(endCap(v7, v2), capGap, v3, v4)
	walk(endCap(vector2s, v2), capGap, v3, v4)

	local result = {}

	for _, v8 in v4 do
		table.insert(result, anchored(v8.X, v8.Y, p2, p5))
	end

	return result
end

function PoolLevelPatterns.Join(...)
	local result = {}

	for i = 1, select("#", ...) do
		local v = select(i, ...)

		if v.N == nil then
			for _, v2 in v do
				table.insert(result, v2)
			end
		else
			table.insert(result, v)
		end
	end

	return result
end

local v = PoolConstants.BallRadius * 2 + 0.05

local function loose(p: number, p2: number, p3: number, p4: number?)
	local v2 = { N = p3, X = round(p), Y = round(p2), S = 0 } -- inferred equivalent call

	if not p4 or p4 == 1 then
		p4 = nil
	end

	v2.S = p4
	return v2
end

function PoolLevelPatterns.Dots(items, p: number?, p2: number?)
	local result = {}

	for _, item in items do
		table.insert(result, anchored(item[1], item[2], p, item[3] or p2 or PoolLevelPatterns.PostNumber))
	end

	return result
end

function PoolLevelPatterns.Loose(items, value: number?, p: number?)
	local result = {}

	for _, item in items do
		local v2 = item[1]
		local v3 = item[2]
		local v4 = {
			N = item[3] or value or 1,
			X = round(v2), -- inferred equivalent call
			Y = round(v3), -- inferred equivalent call
			S = 0
		}
		local v5

		if p and p ~= 1 then
			v5 = p
		end

		v4.S = v5

		table.insert(result, v4)
	end

	return result
end

function PoolLevelPatterns.Arc(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number?, p8: number?)
	local result = {}

	for i = 0, p6 - 1 do
		local v2 = p6 == 1 and 0.5 or i / (p6 - 1)
		local v3 = math.rad(p4 + (p5 - p4) * v2)

		table.insert(result, anchored(p + math.cos(v3) * p3, p2 + math.sin(v3) * p3, p7, p8))
	end

	return result
end

function PoolLevelPatterns.Rack(p: number, p2: number, p3: number, list, p4: number?, value: number?, flag: boolean?, p5: number?)
	local v2 = p4 or v
	local v3 = v2 * 1.7320508075688772 / 2
	local v4 = math.rad(value or 0)
	local vector2 = Vector2.new(math.cos(v4), (math.sin(v4)))
	local vector2_2 = Vector2.new(-vector2.Y, vector2.X)
	local count = 0
	local result = {}

	for i = 0, p3 - 1 do
		for j = 0, i do
			count += 1

			local v5 = Vector2.new(p, p2) + vector2 * (i * v3) + vector2_2 * ((j - i / 2) * v2)
			local item = list[(count - 1) % #list + 1]
			local v6

			if flag then
				v6 = anchored(v5.X, v5.Y, p5, item)
			else
				local x = v5.X
				local y = v5.Y
				v6 = { N = item, X = round(x), Y = round(y), S = 0 } -- inferred equivalent call
				local v7

				if p5 and p5 ~= 1 then
					v7 = p5
				end

				v6.S = v7
			end

			table.insert(result, v6)
		end
	end

	return result
end

function PoolLevelPatterns.Hex(p: number, p2: number, p3: number, list, p4: number?)
	local v2 = p4 or v
	local v3 = {}

	for i = -p3, p3 do
		for j = math.max(-p3, -i - p3), math.min(p3, -i + p3) do
			local v4 = i + j / 2
			local v5 = j * 1.7320508075688772 / 2

			table.insert(v3, {
				X = v4,
				Y = v5,
				Ring = math.max(math.abs(i), math.abs(j), (math.abs(-i - j))),
				Angle = math.atan2(v5, v4)
			})
		end
	end

	table.sort(v3, function(a, b): boolean
		if a.Ring == b.Ring then
			return a.Angle < b.Angle
		end

		return a.Ring < b.Ring
	end)

	local result = {}

	for k, v4 in v3 do
		local v5 = p + v4.X * v2
		local v6 = p2 + v4.Y * v2
		table.insert(result, {
			N = list[(k - 1) % #list + 1],
			X = round(v5), -- inferred equivalent call
			Y = round(v6), -- inferred equivalent call
			S = nil
		})
	end

	return result
end

function PoolLevelPatterns.Heart(p: number, p2: number, p3: number, p4: number, p5: number?, p6: number?, options)
	local set = {}

	for _, v2 in options or {} do
		set[v2] = true
	end

	local v2 = p3 / 32
	local result = {}

	for i = 1, p4 do
		if set[i] then
			continue
		end

		local v3 = (i - 1) / p4 * 3.141592653589793 * 2
		local v4 = math.sin(v3) ^ 3 * 16
		local v5 = math.cos(v3) * 13 - math.cos(2 * v3) * 5 - math.cos(3 * v3) * 2 - math.cos(4 * v3)

		table.insert(result, anchored(p + v4 * v2, p2 + (v5 + 2.5) * v2, p5, p6))
	end

	return result
end

function PoolLevelPatterns.Star(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number?, p8: number?, value: number?)
	local vector2s = {}

	for i = 0, p5 * 2 - 1 do
		local v2 = if i % 2 == 0 then p3 else p4
		local v3 = math.rad((value or 90) + i * 180 / p5)

		table.insert(vector2s, Vector2.new(p + math.cos(v3) * v2, p2 + math.sin(v3) * v2))
	end

	local result = {}

	for k, v2 in vector2s do
		local v3 = vector2s[k % #vector2s + 1]

		for i = 0, p6 - 1 do
			local lerped = v2:Lerp(v3, i / p6)

			table.insert(result, anchored(lerped.X, lerped.Y, p7, p8))
		end
	end

	return result
end

function PoolLevelPatterns.Wave(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number?, p8: number?, value: number?)
	local result = {}

	for i = 0, p6 - 1 do
		local v2 = p6 == 1 and 0 or i / (p6 - 1)
		local v3 = p + (p2 - p) * v2
		local v4 = p3 + p4 * math.sin((v3 - p) / p5 * 3.141592653589793 * 2 + math.rad(value or 0))

		table.insert(result, anchored(v3, v4, p7, p8))
	end

	return result
end

function PoolLevelPatterns.Spokes(p: number, p2: number, p3: number, p4: number, p5: number, p6: number?, p7: number?, value: number?)
	local result = { anchored(p, p2, p6, p7) }

	for i = 0, p3 - 1 do
		local v2 = math.rad((value or 0) + i * 360 / p3)

		for j = 1, p4 do
			table.insert(result, anchored(p + math.cos(v2) * p5 * j, p2 + math.sin(v2) * p5 * j, p6, p7))
		end
	end

	return result
end

function PoolLevelPatterns.Pixels(list, p: number, p2: number, p3: number, p4: number?, p5: number?)
	local maxValue = 0

	for _, item in list do
		maxValue = math.max(maxValue, #item)
	end

	local result = {}

	for k, item in list do
		for i = 1, #item do
			local v2 = string.sub(item, i, i)

			if not (v2 ~= "." and v2 ~= " ") then
				continue
			end

			local v3 = tonumber(v2, 16)
			local v4 = p + (i - 1 - (maxValue - 1) / 2) * p3
			local v5 = p2 + ((#list - 1) / 2 - (k - 1)) * p3

			if v3 then
				if not (v3 > 0) then
					v3 = p5
				end
			else
				v3 = p5
			end

			table.insert(result, anchored(v4, v5, p4, v3))
		end
	end

	return result
end

return PoolLevelPatterns