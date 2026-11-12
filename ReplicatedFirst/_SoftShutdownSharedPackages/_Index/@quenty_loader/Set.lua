local Set = {}

function Set.union(items, items2)
	local result = {}

	for k, _ in items do
		result[k] = true
	end

	for k, _ in items2 do
		result[k] = true
	end

	return result
end

function Set.unionUpdate(p, items)
	for k, _ in items do
		p[k] = true
	end
end

function Set.intersection(items, p)
	local result = {}

	for k, _ in items do
		if p[k] ~= nil then
			result[k] = true
		end
	end

	return result
end

function Set.copy(items)
	local result = {}

	for k, _ in items do
		result[k] = true
	end

	return result
end

function Set.count(items)
	local count = 0

	for _, _ in items do
		count += 1
	end

	return count
end

function Set.fromKeys(items)
	local result = {}

	for k, _ in items do
		result[k] = true
	end

	return result
end

function Set.fromTableValue(items)
	local result = {}

	for _, item in items do
		result[item] = true
	end

	return result
end

Set.fromList = Set.fromTableValue

function Set.toList(items)
	local list = {}

	for k, _ in items do
		table.insert(list, k)
	end

	return list
end

function Set:differenceUpdate(items)
	for k, _ in items do
		self[k] = nil
	end
end

function Set.difference(items, items2)
	local result = {}

	for k, _ in items do
		result[k] = true
	end

	for k, _ in items2 do
		result[k] = nil
	end

	return result
end

return Set