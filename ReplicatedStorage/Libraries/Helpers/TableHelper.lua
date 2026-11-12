local TableHelper = {}

function TableHelper:DeepCopy(items)
	local result = {}

	for k, item in items do
		if type(item) == "table" then
			item = self:DeepCopy(item)
		end

		result[k] = item
	end

	return result
end

function TableHelper:DeepCopyWithStringKeys(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = self:DeepCopyWithStringKeys(item)
		end

		if type(k) == "number" then
			k = tostring(k)
		end

		result[k] = item
	end

	return result
end

function TableHelper:Inverse(p)
	local result = self:DeepCopy(p)

	for i = 1, math.floor(#result / 2) do
		local v = #result - i + 1
		local v2 = result[v]
		local v3 = result[i]
		result[i] = v2
		result[v] = v3
	end

	return result
end

function TableHelper.InverseKeyValue(items)
	local result = {}

	for k, item in items do
		result[item] = k
	end

	return result
end

function TableHelper:SortAlphabetical(p)
	local copy = self:DeepCopy(p)

	table.sort(copy, function(a: string, b: string): boolean
		return a < b
	end)

	return copy
end

function TableHelper.KeysToArray(items)
	local result = {}

	for k, _ in items do
		table.insert(result, k)
	end

	return result
end

function TableHelper.ValuesToArray(items)
	local result = {}

	for _, item in items do
		table.insert(result, item)
	end

	return result
end

function TableHelper.FlipKeyValue(items)
	local result = {}

	for k, item in items do
		result[item] = k
	end

	return result
end

function TableHelper.Concat(...)
	local result = {}

	for _, v in { ... } do
		for _, v2 in pairs(v) do
			table.insert(result, v2)
		end
	end

	return result
end

function TableHelper.ConcatDictionaries(...)
	local result = {}

	for _, v in { ... } do
		for k, v2 in v do
			result[k] = v2
		end
	end

	return result
end

function TableHelper.Sum(_, items)
	local total = 0

	for _, item in pairs(items) do
		total += item
	end

	return total
end

function TableHelper.Count(_, items)
	local count = 0

	for _, _ in items do
		count += 1
	end

	return count
end

function TableHelper:Equals(p, p2)
	local items = {}
	local function recurse(items2, items3): boolean
		if type(items2) ~= type(items3) then
			return false
		end

		if type(items2) ~= "table" then
			return items2 == items3
		end

		if items[items2] then
			return items[items2] == items3
		end

		items[items2] = items3

		local v = {}
		local v2 = {}

		for k, _ in pairs(items3) do
			if type(k) == "table" then
				table.insert(v2, k)
			end

			v[k] = true
		end

		for k, item in pairs(items2) do
			local item2 = items3[k]

			if type(k) == "table" then
				local v3 = false

				for k2, v4 in v2 do
					if TableHelper:Equals(k, v4) and recurse(item, items3[v4]) then
						table.remove(v2, k2)
						v[v4] = nil
						v3 = true
						break
					end
				end

				if not v3 then
					return false
				end
			else
				if item2 == nil then
					return false
				end

				v[k] = nil

				if not recurse(item, item2) then
					return false
				end
			end
		end

		return not next(v)
	end

	return (recurse(p, p2))
end

function TableHelper.FindAndRemove(_, list, p)
	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end

	return index
end

function TableHelper.ConvertStringKeysToNumbers(_, items)
	for k, item in items do
		if tonumber(k) then
			items[k] = nil
			items[tonumber(k)] = item
		else
			items[k] = item
		end
	end
end

function TableHelper.GetBetween(_, items, p)
	local v = 1e999
	local v2 = 0

	for _, item in items do
		if item < v and p <= item then
			v = item
		end
	end

	for _, item in items do
		if v2 < item and item <= p then
			v2 = item
		end
	end

	return v2, v
end

function TableHelper.GetBetweenHighValue(_, items, p)
	local v = 1e999
	local v2 = 0

	for _, item in items do
		if item < v and p < item then
			v = item
		end
	end

	for _, item in items do
		if v2 < item and item <= p then
			v2 = item
		end
	end

	return v2, v
end

function TableHelper.GetBetweenNotEqual(_, items, p)
	local v = 1e999
	local v2 = 0

	for _, item in items do
		if item < v and p < item then
			v = item
		end
	end

	for _, item in items do
		if v2 < item and item < p then
			v2 = item
		end
	end

	return v2, v
end

function TableHelper.Reverse(_, list)
	for i = 1, math.floor(#list / 2) do
		local v = #list - i + 1
		local item = list[v]
		local item2 = list[i]
		list[i] = item
		list[v] = item2
	end
end

function TableHelper.ConvertRaycastToTable(raycastResult: RaycastResult)
	return {
		["normal"] = raycastResult.Normal,
		instance = raycastResult.Instance,
		position = raycastResult.Position,
		material = raycastResult.Material,
		distance = raycastResult.Distance
	}
end

function TableHelper.SumValues(items)
	local total = 0

	for _, item in items do
		total += item
	end

	return total
end

function TableHelper.GetFirstKey(items)
	for firstKey, _ in items do
		return firstKey
	end
end

return TableHelper