local module = require("./graph")

local get_scope = module.get_scope

local function untrack(callback)
	local v = get_scope()

	if not v then
		return callback()
	end

	local effect = v.effect
	v.effect = false

	local success, result = xpcall(callback, debug.traceback)

	v.effect = effect

	if not success then
		error(result, 0)
	end

	return result
end

return untrack