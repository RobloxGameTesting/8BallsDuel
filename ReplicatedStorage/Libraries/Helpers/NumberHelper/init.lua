game:GetService("RunService")
game:GetService("TweenService")
local Tween = require(script.Tween)
local NumberTween = require(script.NumberTween)

local NumberHelper = {
	decimalPlaces = 2,
	suffixTable = {
		"k",
		"M",
		"B",
		"T",
		"Qa",
		"Qi",
		"Sx",
		"Sp",
		"Oc",
		"No",
		"Vi"
	}
}

function NumberHelper.RoundToStep(p: number, p2: number)
	return math.round(p / p2) * p2
end

function NumberHelper.FloatingPoint(_, p, p2)
	return (string.format("%." .. p2 .. "f", p):gsub("%.?0+$", ""))
end

function NumberHelper:Round(p: number, p2: number, flag: boolean)
	local v = p * 10 ^ p2

	if flag then
		return math.floor(v) / 10 ^ p2
	end

	return math.floor(tonumber((tostring(v))) + 0.5) / 10 ^ p2
end

function NumberHelper.Separate(_, p: number, value: string?)
	local v = value or ","

	repeat
		local v2
		p, v2 = string.gsub(tostring(p), "^(-?%d+)(%d%d%d)", "%1" .. v .. "%2")
	until v2 == 0

	return p
end

function NumberHelper.Abbreviate(p, value: number, p2: number, flag: boolean)
	if type(value) ~= "number" then
		error("numberToString invalid parameter #1, expected number, got \"nil\"", 2)
	end

	local v = flag or true

	if value < 1000 and value > -1000 then
		return (tostring((NumberHelper:Round(value, p2))))
	end

	local v2 = value < 0
	local v3 = math.abs((math.floor(value)))

	for i = #NumberHelper.suffixTable, 1, -1 do
		local v4 = NumberHelper.suffixTable[i]
		local v5 = 10 ^ (i * 3)

		if v5 <= v3 then
			local v6 = NumberHelper:Round(v3 / v5, p2, v)

			if v6 == 1000 and i < #p.suffixTable[i] then
				v4 = NumberHelper.suffixTable[i][i + 1]
				v6 = 1
			end

			v3 = v6 .. v4
			break
		end
	end

	if v2 then
		return "-" .. v3
	end

	return (tostring(v3))
end

local v = {
	{ value = 1000, symbol = "M" },
	{ value = 900, symbol = "CM" },
	{ value = 500, symbol = "D" },
	{ value = 400, symbol = "CD" },
	{ value = 100, symbol = "C" },
	{ value = 90, symbol = "XC" },
	{ value = 50, symbol = "L" },
	{ value = 40, symbol = "XL" },
	{ value = 10, symbol = "X" },
	{ value = 9, symbol = "IX" },
	{ value = 5, symbol = "V" },
	{ value = 4, symbol = "IV" },
	{ value = 1, symbol = "I" }
}

function NumberHelper.ToRoman(_, p)
	local roman = ""

	while p > 0 do
		for _, v2 in v do
			local symbol = v2.symbol
			local value = v2.value

			while value <= p do
				roman ..= symbol
				p -= value
			end
		end
	end

	return roman
end

function NumberHelper.OrdinalSuffix(value)
	local v2 = tonumber((string.sub(value, (string.len(value)))))
	return value .. (v2 == 1 and "st" or v2 == 2 and "nd" or v2 == 3 and "rd" or "th")
end

function NumberHelper.FormatTimerHMS(p: number)
	return (("%02i:%02i:%02i"):format(p / 60 / 60 % 24, p / 60 % 60, p % 60))
end

function NumberHelper.FormatTimerDHSM(p: number)
	return (("%02i:%02i:%02i:%02i"):format(p / 60 / 60 / 24, p / 60 / 60 % 24, p / 60 % 60, p % 60))
end

function NumberHelper.FormatTimerMS(p: number)
	return (("%02i:%02i"):format(p / 60 % 60, p % 60))
end

function NumberHelper.FormatTimerMSM(p: number)
	local v2 = tonumber((string.sub(tostring(p % 1), 2, 4))) * 100
	return (("%02i:%02i.%02i"):format(p / 60 % 60, p % 60, (math.floor(v2))))
end

function NumberHelper.FormatTimerDH(p: number)
	return (("%02id %02iH"):format(p / 60 / 60 / 24, p / 60 / 60 % 24))
end

function NumberHelper.FormatTimerDHM(p: number)
	return (("%02id %02iH %02iM"):format(p / 60 / 60 / 24, p / 60 / 60 % 24, p / 60 % 60))
end

function NumberHelper.FormatTimerCountdown(p: number)
	if p >= 3600 then
		return NumberHelper.FormatTimerDHM(p)
	end

	return ("%02iM %02iS"):format(p / 60 % 60, p % 60)
end

function NumberHelper.Tween(_, p)
	return Tween.new(p)
end

function NumberHelper.NumberTween(_, p)
	return NumberTween.new(p)
end

function NumberHelper.SetVector3(_, p, p2)
	return (Vector3.new(p.X, p2, p.Z))
end

function NumberHelper.ClampVector3(_, vector3: Vector3, p: string, min: number, max: number)
	if p == "X" then
		return (Vector3.new(math.clamp(vector3.X, min, max), vector3.Y, vector3.Z))
	elseif p == "Y" then
		return (Vector3.new(vector3.X, math.clamp(vector3.Y, min, max), vector3.Z))
	elseif p == "Z" then
		return (Vector3.new(vector3.X, vector3.Y, (math.clamp(vector3.Z, min, max))))
	end

	error("Not a valid value")
end

function NumberHelper.ColourSaturation(_, color: Color3, p: number)
	local hsv, v2, v3 = color:ToHSV()
	local v4 = v2 * p

	return (Color3.fromHSV(hsv, v4, v3))
end

function NumberHelper.CFrameOrientation(_, cframe)
	local orientation, v2, v3 = cframe:ToOrientation()
	return (Vector3.new(math.deg(orientation), math.deg(v2), (math.deg(v3))))
end

function NumberHelper.OrientationMagnitude(_, _, _)
	local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
	local cframe2 = CFrame.Angles(0, 1.5707963267948966, 0)

	return (math.acos((cframe.LookVector:Dot(cframe2.LookVector))))
end

function NumberHelper.KilogramToPounds(_, p: number)
	return p * 2.205
end

function NumberHelper:CentimetersToFeet(p: number)
	local v2, v3 = math.modf(p / 30.48)
	return v2, (self:Round(v3 * 12, 0, true))
end

function NumberHelper.KilometerToMiles(_, p: number)
	return p / 1.609
end

function NumberHelper.GetLookUpDownToNumber(_, cframe: CFrame)
	return math.deg((math.asin((math.clamp(cframe.LookVector.Y, -1, 1))))) / 80
end

function NumberHelper.GetSide(_, vector3: Vector3, vector3_2: Vector3): number
	local dot = vector3.Unit:Cross((vector3_2 - vector3).Unit):Dot(Vector3.new(0, 1, 0))

	if dot > 0 then
		return -1
	end

	return if dot < 0 then 1 else 0
end

function NumberHelper.GetDecimal(p: number)
	return p - math.floor(p)
end

return NumberHelper