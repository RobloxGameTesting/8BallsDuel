local EnumUtils = {}

function EnumUtils.encodeAsString(p)
	assert(typeof(p) == "EnumItem", "Bad enumItem")

	return string.format("Enum.%s.%s", tostring(p.EnumType), p.Name)
end

function EnumUtils.isOfType(p, p2)
	assert(typeof(p) == "Enum", "Bad enum")

	if typeof(p2) ~= "EnumItem" then
		return
			false,
			string.format(
				"Bad enumItem. Expected enumItem to be %s, got %s '%s'",
				tostring(p),
				typeof(p2),
				(tostring(p2))
			)
	end

	if p2.EnumType == p then
		return true, nil
	end

	return
		false,
		string.format("Bad enumItem. Expected enumItem to be %s, got %s", tostring(p), EnumUtils.encodeAsString(p2))
end

function EnumUtils.toEnum(object, value)
	assert(typeof(object) == "Enum", "Bad enum")

	if typeof(value) == "EnumItem" then
		return if value.EnumType == object then value else nil
	else
		if type(value) == "number" then
			return object:FromValue(value)
		end

		if type(value) ~= "string" then
			return nil
		end

		local v = object:FromName(value)

		if v then
			return v
		end

		local decodeFromString = EnumUtils.decodeFromString(value)

		if decodeFromString and decodeFromString.EnumType == object then
			return decodeFromString
		end

		return nil
	end
end

function EnumUtils.isEncodedEnum(p): boolean
	return EnumUtils.decodeFromString(p) ~= nil
end

function EnumUtils.decodeFromString(value: string?)
	if type(value) ~= "string" then
		return nil
	end

	local v, v2 = string.match(value, "^Enum%.([^%.%s]+)%.([^%.%s]+)$")

	if not (v and v2) then
		return nil
	end

	local v3 = nil
	local success, result = pcall(function()
		v3 = Enum[v]:FromName(v2)
	end)

	if success then
		return v3
	end

	warn(
		result,
		string.format(
			"[EnumUtils.decodeFromString] - Failed to decode %q into an enum value due to %q",
			value,
			(tostring(result))
		)
	)

	return nil
end

return EnumUtils