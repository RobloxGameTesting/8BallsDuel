local String = {}

function String.trim(value: string, p: string?)
	if p == nil then
		return (string.match(value, "^%s*(.-)%s*$"))
	end

	return string.match(value, "^" .. p .. "*(.-)" .. p .. "*$")
end

function String.toCamelCase(value: string)
	local v = string.lower(value)
	local v2 = string.gsub(v, "[ _](%a)", string.upper)
	local v3 = string.gsub(v2, "^%a", string.upper)
	return (string.gsub(v3, "%p", ""))
end

function String.uppercaseFirstLetter(value: string)
	return (string.gsub(value, "^%a", string.upper))
end

function String.toLowerCamelCase(value: string)
	local v = string.lower(value)
	local v2 = string.gsub(v, "[ _](%a)", string.upper)
	local v3 = string.gsub(v2, "^%a", string.lower)
	return (string.gsub(v3, "%p", ""))
end

function String.toPrivateCase(value: string)
	return "_" .. string.lower((string.sub(value, 1, 1))) .. value:sub(2, #value)
end

function String.trimFront(value: string, value2: string?)
	local v = value2 or "%s"
	return (string.gsub(value, "^" .. v .. "*(.-)" .. v .. "*", "%1"))
end

function String.checkNumOfCharacterInString(value: string, p: string)
	local count = 0

	for _ in string.gmatch(value, p) do
		count += 1
	end

	return count
end

function String.isEmptyOrWhitespaceOrNil(value: string)
	return type(value) ~= "string" or (value == "" or String.isWhitespace(value))
end

function String.isWhitespace(value: string): boolean
	return string.match(value, "[%s]+") == value
end

function String.elipseLimit(value: string, p: number)
	if p < #value then
		value = string.sub(value, 1, p - 3) .. "..."
	end

	return value
end

function String.removePrefix(value: string, list: string)
	if string.sub(value, 1, #list) == list then
		return (string.sub(value, #list + 1))
	end

	return value
end

function String.removePostfix(value: string, list: string)
	if string.sub(value, -#list) == list then
		return (string.sub(value, 1, -#list - 1))
	end

	return value
end

function String.endsWith(value: string, list: string): boolean
	return string.sub(value, -#list) == list
end

function String.startsWith(value: string, list: string): boolean
	return string.sub(value, 1, #list) == list
end

function String.addCommas(value, value2: string)
	if type(value) == "number" then
		value = tostring(value)
	end

	local v = -1
	local v2 = value2 or ","

	while v ~= 0 do
		value, v = string.gsub(value, "^(-?%d+)(%d%d%d)", "%1" .. v2 .. "%2")
	end

	return value
end

return String