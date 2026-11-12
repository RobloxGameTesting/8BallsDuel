local loader = require(script.Parent.loader)
local v = loader.load(script)("RoundingBehaviourTypes")

local NumberLocalizationUtils = {}

local v2 = {}

v2["en-us"] = {
	decimalSeparator = ".",
	groupDelimiter = ",",
	{ 1, "" },
	{ 1000, "K" },
	{ 1000000, "M" },
	{ 1000000000, "B" }
}

v2["es-es"] = {
	decimalSeparator = ",",
	groupDelimiter = ".",
	{ 1, "" },
	{ 1000, " mil" },
	{ 1000000, " M" }
}

v2["fr-fr"] = {
	decimalSeparator = ",",
	groupDelimiter = " ",
	{ 1, "" },
	{ 1000, " k" },
	{ 1000000, " M" },
	{ 1000000000, " Md" }
}

v2["de-de"] = {
	decimalSeparator = ",",
	groupDelimiter = " ",
	{ 1, "" },
	{ 1000, " Tsd." },
	{ 1000000, " Mio." },
	{ 1000000000, " Mrd." }
}

v2["pt-br"] = {
	decimalSeparator = ",",
	groupDelimiter = ".",
	{ 1, "" },
	{ 1000, " mil" },
	{ 1000000, " mi" },
	{ 1000000000, " bi" }
}

v2["zh-cn"] = {
	decimalSeparator = ".",
	groupDelimiter = ",",
	{ 1, "" },
	{ 1000, "千" },
	{ 10000, "万" },
	{ 100000000, "亿" }
}

v2["zh-cjv"] = {
	decimalSeparator = ".",
	groupDelimiter = ",",
	{ 1, "" },
	{ 1000, "千" },
	{ 10000, "万" },
	{ 100000000, "亿" }
}

v2["zh-tw"] = {
	decimalSeparator = ".",
	groupDelimiter = ",",
	{ 1, "" },
	{ 1000, "千" },
	{ 10000, "萬" },
	{ 100000000, "億" }
}

v2["ko-kr"] = {
	decimalSeparator = ".",
	groupDelimiter = ",",
	{ 1, "" },
	{ 1000, "천" },
	{ 10000, "만" },
	{ 100000000, "억" }
}

v2["ja-jp"] = {
	decimalSeparator = ".",
	groupDelimiter = ",",
	{ 1, "" },
	{ 1000, "千" },
	{ 10000, "万" },
	{ 100000000, "億" }
}

v2["it-it"] = {
	decimalSeparator = ",",
	groupDelimiter = " ",
	{ 1, "" },
	{ 1000, " mila" },
	{ 1000000, " Mln" },
	{ 1000000000, " Mld" }
}

v2["ru-ru"] = {
	decimalSeparator = ",",
	groupDelimiter = ".",
	{ 1, "" },
	{ 1000, " тыс" },
	{ 1000000, " млн" },
	{ 1000000000, " млрд" }
}

v2["id-id"] = {
	decimalSeparator = ",",
	groupDelimiter = ".",
	{ 1, "" },
	{ 1000, " rb" },
	{ 1000000, " jt" },
	{ 1000000000, " M" }
}

v2["vi-vn"] = {
	decimalSeparator = ".",
	groupDelimiter = " ",
	{ 1, "" },
	{ 1000, " N" },
	{ 1000000, " Tr" },
	{ 1000000000, " T" }
}

v2["th-th"] = {
	decimalSeparator = ".",
	groupDelimiter = ",",
	{ 1, "" },
	{ 1000, " พ" },
	{ 10000, " ม" },
	{ 100000, " ส" },
	{ 1000000, " ล" }
}

v2["tr-tr"] = {
	decimalSeparator = ",",
	groupDelimiter = ".",
	{ 1, "" },
	{ 1000, " B" },
	{ 1000000, " Mn" },
	{ 1000000000, " Mr" }
}

v2.en = v2["en-us"]
v2["en-gb"] = v2["en-us"]
v2["es-mx"] = v2["es-es"]

local function findDecimalPointIndex(value) -- 1 equivalent call inferred from this helper
	return string.find(value, "%.") or #value + 1
end

local function findDecimalOffset(p) -- 1 equivalent call inferred from this helper
	if p == 0 then
		return 0
	end

	return -(math.floor((math.log10((math.abs(p))))) + 1)
end

local function roundToSignificantDigits(p, p2, p3) -- 1 equivalent call inferred from this helper
	local v3 = 10 ^ (p2 + findDecimalOffset(p)) -- inferred equivalent call
	local v4

	if p3 == v.TRUNCATE then
		v4 = math.modf(p * v3)
	else
		v4 = math.floor(p * v3 + 0.5)
	end

	return v4 / v3
end

local function addGroupDelimiters(value, groupDelimiter)
	local v3 = string.format("%%1%s%%2", groupDelimiter)

	repeat
		local v4
		value, v4 = string.gsub(value, "^(-?%d+)(%d%d%d)", v3)
	until v4 == 0

	return value
end

local function findDenominationEntry(list, value, p)
	local item = list[1]
	local v3 = math.abs(value)

	for i = #list, 2, -1 do
		local item2 = list[i]
		local v4

		if p == v.TRUNCATE then
			v4 = item2[1]
		else
			v4 = item2[1] - list[i - 1][1] / 2
		end

		if v4 <= v3 then
			return item2
		end
	end

	return item
end

function NumberLocalizationUtils.localize(p, p2)
	if p == 0 then
		return "0"
	end

	local v3 = v2[p2]

	if not v3 then
		v3 = v2["en-us"]
		warn(string.format(
			"[NumberLocalizationUtils] - Locale not found: '%s', reverting to '%s' instead.",
			tostring(p2),
			"en-us"
		))
	end

	if v3.groupDelimiter then
		return addGroupDelimiters(p, v3.groupDelimiter)
	end

	return p
end

function NumberLocalizationUtils.abbreviate(value, p, p2, p3)
	assert(type(value) == "number", "Bad number")

	if p2 == v.NONE then
		return NumberLocalizationUtils.localize(value, p)
	end

	if value == 0 then
		return "0"
	end

	if p2 == nil then
		p2 = v.ROUND_TO_CLOSEST
	end

	local v3 = p3 == nil and 3 or p3

	local v4 = v2[p]

	if not v4 then
		v4 = v2["en-us"]
		warn(string.format(
			"[NumberLocalizationUtils] - Locale not found: '%s', reverting to '%s' instead.",
			tostring(p),
			"en-us"
		))
	end

	local denominationEntry = findDenominationEntry(v4, value, p2)
	local v5 = denominationEntry[1]
	local v6 = denominationEntry[2]

	local v7 = roundToSignificantDigits(value / v5, v3, p2) -- inferred equivalent call

	local v8 = nil
	local v9 = 10 ^ math.max(1, v3 - math.ceil((math.log10(v7))))

	if p2 == v.TRUNCATE then
		v8 = math.modf(v7 * v9) / v9
	elseif p2 == v.ROUND_TO_CLOSEST then
		v8 = math.floor(v7 * v9 + 0.5) / v9
	else
		error(string.format("[NumberLocalizationUtils.abbreviate] - Unknown roundingBehaviourType %q", (tostring(p2))))
	end

	local v10 = tostring(v8)
	local decimalPointIndex = findDecimalPointIndex(v10) -- inferred equivalent call
	local v11 = string.sub(v10, 1, decimalPointIndex - 1)
	local v12 = string.sub(v10, decimalPointIndex + 1, #v10)

	if v4.groupDelimiter then
		v11 = addGroupDelimiters(v11, v4.groupDelimiter)
	end

	if #v12 > 0 then
		return v11 .. v4.decimalSeparator .. v12 .. v6
	end

	return v11 .. v6
end

return NumberLocalizationUtils