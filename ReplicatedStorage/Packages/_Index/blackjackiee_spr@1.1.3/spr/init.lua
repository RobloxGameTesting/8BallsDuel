local RunService = game:GetService("RunService")

local exp = math.exp
local sin = math.sin
local cos = math.cos
local min = math.min
local sqrt = math.sqrt
local round = math.round

local function magnitudeSq(items) -- 1 equivalent call inferred from this helper
	local total = 0

	for _, item in items do
		total += item ^ 2
	end

	return total
end

local function distanceSq(items, g) -- 1 equivalent call inferred from this helper
	local total = 0

	for k, item in items do
		total += (g[k] - item) ^ 2
	end

	return total
end

local class = {}

class.__index = class

function class.new(p: number, p2: number, p3, rawGoal, typedat)
	local intermediate = typedat.toIntermediate(p3)
	return (setmetatable({
		d = p,
		f = p2,
		g = intermediate,
		p = intermediate,
		v = table.create(#intermediate, 0),
		typedat = typedat,
		rawGoal = rawGoal
	}, class))
end

function class:setGoal(rawGoal)
	self.rawGoal = rawGoal
	self.g = self.typedat.toIntermediate(rawGoal)
end

function class:setDampingRatio(p: number)
	self.d = p
end

function class:setFrequency(p: number)
	self.f = p
end

function class:canSleep(): boolean
	return not (magnitudeSq(self.v) > 0.0001) and not (distanceSq(self.p, self.g) > 6.781684027777778e-8) -- inferred equivalent call
end

function class:step(p: number)
	local d = self.d
	local v = self.f * 2 * 3.141592653589793
	local g = self.g
	local p2 = self.p
	local v2 = self.v

	if d == 1 then
		local v3 = exp(-v * p)
		local v4 = p * v3

		local v5 = v3 + v4 * v
		local v6 = v3 - v4 * v
		local v7 = v4 * v * v

		for i = 1, #p2 do
			local v8 = p2[i] - g[i]
			p2[i] = v8 * v5 + v2[i] * v4 + g[i]
			v2[i] = v2[i] * v6 - v8 * v7
		end
	elseif d < 1 then
		local v3 = exp(-d * v * p)
		local v4 = sqrt(1 - d * d)

		local v5 = cos(p * v * v4)
		local v6 = sin(p * v * v4)
		local v7

		if v4 > 0.00001 then
			v7 = v6 / v4
		else
			local v8 = p * v
			v7 = v8 + (v8 * v8 * (v4 * v4) * (v4 * v4) / 20 - v4 * v4) * (v8 * v8 * v8) / 6
		end

		local v8

		if v * v4 > 0.00001 then
			v8 = v6 / (v * v4)
		else
			local v9 = v * v4
			v8 = p + (p * p * (v9 * v9) * (v9 * v9) / 20 - v9 * v9) * (p * p * p) / 6
		end

		for i = 1, #p2 do
			local v9 = p2[i] - g[i]
			p2[i] = (v9 * (v5 + v7 * d) + v2[i] * v8) * v3 + g[i]
			v2[i] = (v2[i] * (v5 - v7 * d) - v9 * (v7 * v)) * v3
		end
	else
		local v3 = sqrt(d * d - 1)

		local v4 = -v * (d - v3)
		local v5 = -v * (d + v3)

		local v6 = exp(v4 * p)
		local v7 = exp(v5 * p)

		for i = 1, #p2 do
			local v8 = p2[i] - g[i]
			local v9 = (v2[i] - v8 * v4) / (2 * v * v3)
			local v10 = v6 * (v8 - v9)

			p2[i] = v10 + v9 * v7 + g[i]
			v2[i] = v10 * v4 + v9 * v7 * v5
		end
	end

	return self.typedat.fromIntermediate(self.p)
end

local class2 = {}

class2.__index = class2

local function angleBetween(cframe: CFrame, g: CFrame) -- 1 equivalent call inferred from this helper
	local _, v = g:ToObjectSpace(cframe):ToAxisAngle()
	return (math.abs(v))
end

local function matrixToAxis(cframe: CFrame) -- 1 equivalent call inferred from this helper
	local axisAngle, v = cframe:ToAxisAngle()
	return axisAngle * v
end

local function axisToMatrix(vector3: Vector3) -- 3 equivalent calls inferred from this helper
	local magnitude = vector3.Magnitude

	if magnitude > 1e-6 then
		return CFrame.fromAxisAngle(vector3.Unit, magnitude)
	end

	return CFrame.identity
end

function class2.new(p: number, p2: number, cframe: CFrame, cframe2: CFrame)
	return (setmetatable({
		d = p,
		f = p2,
		g = cframe2,
		p = cframe,
		v = Vector3.new(0, 0, 0)
	}, class2))
end

function class2:setGoal(cframe: CFrame)
	self.g = cframe
end

function class2:setDampingRatio(p: number)
	self.d = p
end

function class2:setFrequency(p: number)
	self.f = p
end

function class2:canSleep()
	local v = angleBetween(self.p, self.g) < 0.00017453292519943296 -- inferred equivalent call
	local v2 = self.v.Magnitude < 0.0017453292519943296
	return v and v2
end

function class2:step(p: number)
	local d = self.d
	local v = self.f * 2 * 3.141592653589793
	local g = self.g
	local p2 = self.p
	local v2 = self.v

	local v3 = matrixToAxis(p2 * g:Inverse()) -- inferred equivalent call
	local v4 = exp(-d * v * p)
	local v5, v6

	if d == 1 then
		local _ = p * v4
		v5 = axisToMatrix((v3 * (1 + v * p) + v2 * p) * v4) * g -- inferred equivalent call
		v6 = (v2 * (1 - p * v) - v3 * (p * v * v)) * v4
	elseif d < 1 then
		local v7 = sqrt(1 - d * d)

		local v8 = cos(p * v * v7)
		local v9 = sin(p * v * v7)

		local v10 = v9 / (v * v7)
		local v11 = v9 / v7
		v5 = axisToMatrix((v3 * (v8 + v11 * d) + v2 * v10) * v4) * g -- inferred equivalent call
		v6 = (v2 * (v8 - v11 * d) - v3 * (v11 * v)) * v4
	else
		local v7 = sqrt(d * d - 1)

		local v8 = -v * (d - v7)
		local v9 = -v * (d + v7)

		local v10 = (v2 - v3 * v8) / (2 * v * v7)
		local v11 = (v3 - v10) * exp(v8 * p)
		local v12 = v10 * exp(v9 * p)
		v5 = axisToMatrix(v11 + v12) * g -- inferred equivalent call
		v6 = v11 * v8 + v12 * v9
	end

	self.p = v5
	self.v = v6

	return v5
end

local vector = {
	springType = class.new,
	toIntermediate = function(data)
		return { data.X, data.Y, data.Z }
	end,
	fromIntermediate = function(list)
		return (Vector3.new(list[1], list[2], list[3]))
	end
}

local class3 = {}

class3.__index = class3

function class3.new(p: number, p2: number, cframe: CFrame, rawGoal: CFrame, _)
	return (setmetatable(
		{
			rawGoal = rawGoal,
			_position = class.new(p, p2, cframe.Position, rawGoal.Position, vector),
			_rotation = class2.new(p, p2, cframe.Rotation, rawGoal.Rotation)
		},
		class3
	))
end

function class3:setGoal(rawGoal: CFrame)
	self.rawGoal = rawGoal
	self._position:setGoal(rawGoal.Position)
	self._rotation:setGoal(rawGoal.Rotation)
end

function class3:setDampingRatio(p: number)
	self._position:setDampingRatio(p)
	self._rotation:setDampingRatio(p)
end

function class3:setFrequency(p: number)
	self._position:setFrequency(p)
	self._rotation:setFrequency(p)
end

function class3:canSleep()
	return self._position:canSleep() and self._rotation:canSleep()
end

function class3:step(p)
	local v = self._position:step(p)
	return self._rotation:step(p) + v
end

local function inverseGammaCorrectD65(p) -- 3 equivalent calls inferred from this helper
	return p < 0.0404482362771076 and p / 12.92 or 0.87941546140213 * (p + 0.055) ^ 2.4
end

local function gammaCorrectD65(p) -- 3 equivalent calls inferred from this helper
	return p < 0.0031306684425 and 12.92 * p or 1.055 * p ^ (5 / 12) - 0.055
end

local function rgbToLuv(value: Color3)
	local r = value.R
	local g = value.G
	local b = value.B
	local v = inverseGammaCorrectD65(r) -- inferred equivalent call
	local v2 = inverseGammaCorrectD65(g) -- inferred equivalent call
	local v3 = inverseGammaCorrectD65(b) -- inferred equivalent call
	local v4 = 0.9257063972951867 * v - 0.8333736323779866 * v2 - 0.09209820666085898 * v3
	local v5 = 0.2125862307855956 * v + 0.7151703037034108 * v2 + 0.0722004986433362 * v3
	local v6 = 3.6590806972265884 * v + 11.442689580057424 * v2 + 4.114991502426484 * v3

	local v7 = v5 > 0.008856451679035631 and 116 * v5 ^ (1 / 3) - 16 or 903.296296296296 * v5
	local v8, v9

	if v6 > 1e-14 then
		v8 = v7 * v4 / v6
		v9 = v7 * (9 * v5 / v6 - 0.46832)
	else
		v8 = -0.19783 * v7
		v9 = -0.46832 * v7
	end

	return { v7, v8, v9 }
end

local function luvToRgb(list)
	local item = list[1]

	if item < 0.0197955 then
		return Color3.new(0, 0, 0)
	end

	local v = list[2] / item + 0.19783
	local v2 = list[3] / item + 0.46832

	local v3 = (item + 16) / 116
	local v4 = v3 > 6 / 29 and v3 * v3 * v3 or v3 * (108 / 841) - 0.01771290335807126
	local v5 = v4 * v / v2
	local v6 = v4 * ((3 - v * 0.75) / v2 - 5)

	local v7 = v5 * 7.2914074 - v4 * 1.537208 - v6 * 0.4986286
	local v8 = v5 * -2.180094 + v4 * 1.8757561 + v6 * 0.0415175
	local v9 = v5 * 0.1253477 - v4 * 0.2040211 + v6 * 1.0569959

	if v7 < 0 and v7 < v8 and v7 < v9 then
		v8 -= v7
		v9 -= v7
		v7 = 0
	elseif v8 < 0 and v8 < v9 then
		v7 -= v8
		v9 -= v8
		v8 = 0
	elseif v9 < 0 then
		v7 -= v9
		v8 -= v9
		v9 = 0
	end

	return Color3.new(min(gammaCorrectD65(v7), 1), min(gammaCorrectD65(v8), 1), (min(gammaCorrectD65(v9), 1))) -- inferred equivalent call
end

local v = {
	boolean = {
		springType = class.new,
		toIntermediate = function(p)
			return { p and 1 or 0 }
		end,
		fromIntermediate = function(list): boolean
			return list[1] >= 0.5
		end
	},
	number = {
		springType = class.new,
		toIntermediate = function(p)
			return { p }
		end,
		fromIntermediate = function(list)
			return list[1]
		end
	},
	NumberRange = {
		springType = class.new,
		toIntermediate = function(p)
			return { p.Min, p.Max }
		end,
		fromIntermediate = function(list)
			return NumberRange.new(list[1], list[2])
		end
	},
	UDim = {
		springType = class.new,
		toIntermediate = function(p)
			return { p.Scale, p.Offset }
		end,
		fromIntermediate = function(list)
			return UDim.new(list[1], (round(list[2])))
		end
	},
	UDim2 = {
		springType = class.new,
		toIntermediate = function(p)
			local x = p.X
			local y = p.Y
			return { x.Scale, x.Offset, y.Scale, y.Offset }
		end,
		fromIntermediate = function(list)
			return UDim2.new(list[1], round(list[2]), list[3], (round(list[4])))
		end
	},
	Vector2 = {
		springType = class.new,
		toIntermediate = function(p)
			return { p.X, p.Y }
		end,
		fromIntermediate = function(list)
			return Vector2.new(list[1], list[2])
		end
	},
	Vector3 = vector,
	Color3 = { springType = class.new, toIntermediate = rgbToLuv, fromIntermediate = luvToRgb },
	ColorSequence = {
		springType = class.new,
		toIntermediate = function(sequence)
			local keypoints = sequence.Keypoints

			local v = rgbToLuv(keypoints[1].Value)
			local v2 = rgbToLuv(keypoints[#keypoints].Value)

			return { v[1], v[2], v[3], v2[1], v2[2], v2[3] }
		end,
		fromIntermediate = function(list)
			return ColorSequence.new(luvToRgb({ list[1], list[2], list[3] }), luvToRgb({ list[4], list[5], list[6] }))
		end
	},
	CFrame = { springType = class3.new, toIntermediate = error, fromIntermediate = error }
}

local v2 = {}

RunService.Heartbeat:Connect(function(dt)
	for k, v3 in v2 do
		for k2, v4 in v3 do
			if v4:canSleep() then
				v3[k2] = nil
				k[k2] = v4.rawGoal
			else
				k[k2] = v4:step(dt)
			end
		end

		if not next(v3) then
			v2[k] = nil
		end
	end
end)

local function assertType(p: number, p2: string, value: string, p3) -- 6 equivalent calls inferred from this helper
	if not value:find((typeof(p3))) then
		error(("bad argument #%d to %s (%s expected, got %s)"):format(p, p2, value, (typeof(p3))), 3)
	end
end

return table.freeze({
	target = function(self, p: number, p2: number, items)
		assertType(1, "spr.target", "Instance", self) -- inferred equivalent call
		assertType(2, "spr.target", "number", p) -- inferred equivalent call
		assertType(3, "spr.target", "number", p2) -- inferred equivalent call
		assertType(4, "spr.target", "table", items) -- inferred equivalent call

		if p ~= p or p < 0 then
			error(("expected damping ratio >= 0; got %.2f"):format(p), 2)
		end

		if p2 ~= p2 or p2 < 0 then
			error(("expected undamped frequency >= 0; got %.2f"):format(p2), 2)
		end

		local v3 = v2[self]

		if not v3 then
			v3 = {}
			v2[self] = v3
		end

		for k, item in items do
			local v4 = self[k]

			if typeof(item) ~= typeof(v4) then
				error(("bad property %s to spr.target (%s expected, got %s)"):format(k, typeof(v4), (typeof(item))), 2)
			end

			if p2 == 1e999 then
				self[k] = item
				v3[k] = nil
			else
				local v5 = v3[k]

				if not v5 then
					local v6 = v[typeof(item)]

					if not v6 then
						error("unsupported type: " .. typeof(item), 2)
					end

					v5 = v6.springType(p, p2, v4, item, v6)
					v3[k] = v5
				end

				v5:setGoal(item)
				v5:setDampingRatio(p)
				v5:setFrequency(p2)
			end
		end

		if not next(v3) then
			v2[self] = nil
		end
	end,
	stop = function(p, p2: string?)
		assertType(1, "spr.stop", "Instance", p) -- inferred equivalent call
		assertType(2, "spr.stop", "string|nil", p2) -- inferred equivalent call

		if p2 then
			local v3 = v2[p]

			if v3 then
				v3[p2] = nil
			end
		else
			v2[p] = nil
		end
	end
})