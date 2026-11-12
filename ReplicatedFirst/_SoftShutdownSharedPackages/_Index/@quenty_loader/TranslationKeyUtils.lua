local loader = require(script.Parent.loader)
local v = loader.load(script)("String")

return {
	getTranslationKey = function(p, value)
		local v2 = string.sub(string.gsub(value, "%s", ""), 1, 20)
		return p .. "." .. v.toLowerCamelCase(v2)
	end
}