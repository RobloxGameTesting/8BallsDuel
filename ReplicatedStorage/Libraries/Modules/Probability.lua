local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local Probability = {}

function Probability.ApplyWeightedLuck(items, value: number)
	local v = math.clamp(value, 1, 10000)

	if v == 1 then
		return items
	end

	local v2 = 0
	local result = {}

	for _, item in pairs(items) do
		if v2 < item then
			v2 = item
		end
	end

	for k, item in pairs(items) do
		local v3 = 1 - item / v2
		local v4 = (v - 1) * v3 * 0.35 + 1

		result[tostring(k)] = item / v4
	end

	return result
end

function Probability.ApplySolLuck(items, value: number)
	local v = math.clamp(value, 1, 10000)

	if v == 1 then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = math.floor((math.max(2, item / v + 0.5)))
	end

	return result
end

function Probability.Convert(items)
	local total = 0
	local result = {}

	for k, item in items do
		if item == 0 then
			continue
		end

		total += item
		result[total] = k
	end

	return result
end

function Probability.ConvertToPercent(items)
	local total = 0
	local result = {}

	for _, item in items do
		total += item
	end

	for k, item in items do
		if item ~= 0 then
			result[k] = item / total
		end
	end

	return result
end

function Probability.GetChosen(p, p2: number?)
	local converted = Probability.Convert(p)
	local v = 0

	for k, _ in converted do
		if v < k then
			v = k
		end
	end

	local number = (p2 and Random.new(p2) or Random.new()):NextNumber(0, v)

	for k, _ in converted do
		if number < k and k < v then
			v = k
		end
	end

	return number, v
end

function Probability.GetItem(p, p2: number?)
	local _, v = Probability.GetChosen(p, p2)
	local converted = Probability.Convert(p)
	local _ = converted[v]

	return converted[v]
end

function Probability.ConvertChanceToProbability(p, p2: number, _)
	local v = Probability.ApplySolLuck(p, p2)
	local v2 = {}

	for k, chance in v do
		table.insert(v2, { key = k, chance = chance })
	end

	table.sort(v2, function(a, b): boolean
		return a.chance > b.chance
	end)

	local result = {}

	for _, v3 in v2 do
		result[v3.key] = 1 / v3.chance * 1000000
	end

	return result
end

return Probability