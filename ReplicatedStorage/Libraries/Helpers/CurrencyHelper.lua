local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Types.GameSpecificTypes)

local CurrencyHelper = {}

local v = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc",
	"Ud",
	"Dd",
	"Td",
	"Qad",
	"Qid",
	"Sxd",
	"Spd",
	"Ocd",
	"Nod",
	"Vg",
	"Uvg",
	"Dvg",
	"Tvg",
	"Qavg",
	"Qivg",
	"Sxvg",
	"Spvg",
	"Ocvg",
	"Novg",
	"Tg"
}

function CurrencyHelper.Normalize(p)
	local mantissa = p.mantissa
	local exponent = p.exponent

	if mantissa <= 0 then
		return { mantissa = 0, exponent = 0 }
	end

	while mantissa >= 1000 do
		mantissa /= 1000
		exponent += 1
	end

	while mantissa < 1 and exponent > 0 do
		mantissa *= 1000
		exponent -= 1
	end

	return { mantissa = mantissa, exponent = exponent }
end

function CurrencyHelper.FromNumber(mantissa: number)
	return CurrencyHelper.Normalize({ mantissa = mantissa, exponent = 0 })
end

function CurrencyHelper.ToNumber(p)
	local normalized = CurrencyHelper.Normalize(p)

	return normalized.mantissa * 1000 ^ normalized.exponent
end

function CurrencyHelper.CanAfford(p, p2): boolean
	local normalized = CurrencyHelper.Normalize(p)
	local normalized2 = CurrencyHelper.Normalize(p2)

	if normalized2.exponent > normalized.exponent then
		return true
	end

	return not (normalized2.exponent < normalized.exponent) and normalized2.mantissa >= normalized.mantissa
end

function CurrencyHelper.FormatMoney(p)
	local normalized = CurrencyHelper.Normalize(p)

	local v2 = v[normalized.exponent + 1] or "e" .. tostring(normalized.exponent * 3)

	if normalized.exponent == 0 then
		return (tostring((math.floor(normalized.mantissa))))
	end

	if not (normalized.mantissa >= 100) and normalized.mantissa >= 10 then
	end

	return string.format("%.3f", normalized.mantissa):gsub("%.?0+$", "") .. v2
end

function CurrencyHelper.AffordPercent(p, p2)
	local normalized = CurrencyHelper.Normalize(p)
	local normalized2 = CurrencyHelper.Normalize(p2)

	if normalized.mantissa <= 0 or normalized2.exponent > normalized.exponent then
		return 1
	end

	if normalized2.exponent < normalized.exponent then
		local v2 = normalized.exponent - normalized2.exponent

		return (math.clamp(normalized2.mantissa / 1000 ^ v2 / normalized.mantissa, 0, 1))
	end

	return (math.clamp(normalized2.mantissa / normalized.mantissa, 0, 1))
end

function CurrencyHelper.Add(p, p2)
	local v2 = CurrencyHelper.Normalize(p)
	local selected = CurrencyHelper.Normalize(p2)

	if v2.exponent == selected.exponent then
		return CurrencyHelper.Normalize({
			mantissa = v2.mantissa + selected.mantissa,
			exponent = v2.exponent
		})
	end

	if not (selected.exponent > v2.exponent) then
		v2, selected = selected, v2
	end

	local v3 = selected.exponent - v2.exponent

	if v3 > 10 then
		return selected
	end

	local v4 = v2.mantissa / 1000 ^ v3

	return CurrencyHelper.Normalize({
		mantissa = selected.mantissa + v4,
		exponent = selected.exponent
	})
end

function CurrencyHelper.Subtract(p, p2)
	local normalized = CurrencyHelper.Normalize(p)
	local normalized2 = CurrencyHelper.Normalize(p2)

	if normalized.exponent == normalized2.exponent then
		return CurrencyHelper.Normalize({
			mantissa = math.max(normalized.mantissa - normalized2.mantissa, 0),
			exponent = normalized.exponent
		})
	end

	if normalized2.exponent > normalized.exponent then
		return { mantissa = 0, exponent = 0 }
	end

	local v2 = normalized.exponent - normalized2.exponent

	if v2 > 10 then
		return normalized
	end

	local v3 = normalized2.mantissa / 1000 ^ v2

	local v4 = {
		mantissa = normalized.mantissa - v3,
		exponent = normalized.exponent
	}

	if v4.mantissa <= 0 then
		return { mantissa = 0, exponent = 0 }
	end

	local normalized3 = CurrencyHelper.Normalize(v4)
	return CurrencyHelper.Normalize(normalized3)
end

return CurrencyHelper