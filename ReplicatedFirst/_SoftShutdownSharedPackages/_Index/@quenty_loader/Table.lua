local Table = {}

function Table.append(list, items)
	for _, item in items do
		list[#list + 1] = item
	end

	return list
end

function Table.merge(p, items)
	local clone = table.clone(p)

	for k, item in items do
		clone[k] = item
	end

	return clone
end

function Table.reverse(list)
	local result = {}

	for i = #list, 1, -1 do
		table.insert(result, list[i])
	end

	return result
end

function Table.values(items)
	local result = {}

	for _, item in items do
		table.insert(result, item)
	end

	return result
end

function Table.keys(items)
	local result = {}

	for k, _ in items do
		table.insert(result, k)
	end

	return result
end

function Table.mergeLists(items, items2)
	local result = {}

	for _, item in items do
		table.insert(result, item)
	end

	for _, item in items2 do
		table.insert(result, item)
	end

	return result
end

function Table.swapKeyValue(items)
	local result = {}

	for k, item in items do
		result[item] = k
	end

	return result
end

function Table.toList(items)
	local list = {}

	for _, item in items do
		table.insert(list, item)
	end

	return list
end

function Table.count(items)
	local count = 0

	for _, _ in items do
		count += 1
	end

	return count
end

Table.copy = table.clone

function Table.deepCopy(items, options)
	local v = options or {}

	if v[items] then
		return v[items]
	end

	if type(items) ~= "table" then
		return items
	end

	local copiesByCopy = {}
	v[items] = copiesByCopy

	for k, item in items do
		copiesByCopy[Table.deepCopy(k, v)] = Table.deepCopy(item, v)
	end

	return (setmetatable(copiesByCopy, (Table.deepCopy(getmetatable(items), v))))
end

function Table:deepOverwrite(items)
	for k, item in items do
		if type(self[k]) == "table" and type(item) == "table" then
			self[k] = Table.deepOverwrite(self[k], item)
		else
			self[k] = item
		end
	end

	return self
end

function Table.getIndex(items, p)
	assert(p ~= nil, "Needle cannot be nil")

	for k, item in items do
		if p == item then
			return k
		end
	end

	return nil
end

function Table.stringify(items, count: number?, p: string?)
	local v = p or tostring(items)
	local v2 = count or 0

	for k, item in items do
		local v3 = "\n" .. string.rep("  ", v2) .. tostring(k) .. ": "

		if type(item) == "table" then
			local v4 = v .. v3
			v = Table.stringify(item, v2 + 1, v4)
		else
			v ..= v3 .. tostring(item)
		end
	end

	return v
end

function Table.contains(items, p): boolean
	for _, item in items do
		if item == p then
			return true
		end
	end

	return false
end

function Table:overwrite(items)
	for k, item in items do
		self[k] = item
	end

	return self
end

function Table.deepEquivalent(items, items2): boolean
	if items == items2 then
		return true
	end

	if not (type(items) == type(items2) and type(items) == "table") then
		return false
	end

	for k, item in items do
		if not Table.deepEquivalent(item, items2[k]) then
			return false
		end
	end

	for k, item in items2 do
		if not Table.deepEquivalent(item, items[k]) then
			return false
		end
	end

	return true
end

function Table.take(list, p: number)
	local v = math.min(#list, p)
	local result = table.create(v)

	for i = 1, v do
		result[i] = list[i]
	end

	return result
end

local function errorOnIndex(_, p)
	error(string.format("Bad index %q", (tostring(p))), 2)
end

local v = { __index = errorOnIndex, __newindex = errorOnIndex }

function Table.readonly(p)
	return (table.freeze((setmetatable(p, v))))
end

function Table.errorOnNilIndex(p)
	return (setmetatable(p, v))
end

function Table.deepReadonly(items)
	for _, item in items do
		if type(item) == "table" then
			Table.deepReadonly(item)
		end
	end

	return Table.readonly(items)
end

return Table