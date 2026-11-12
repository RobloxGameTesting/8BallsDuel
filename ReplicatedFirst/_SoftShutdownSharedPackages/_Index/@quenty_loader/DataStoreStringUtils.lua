return {
	isValidUTF8 = function(value)
		if type(value) ~= "string" then
			return false, "Not a string"
		end

		if not utf8.len(value) or string.match(value, "[^\0-\127]") then
			return false, "Invalid string"
		end

		return true
	end
}