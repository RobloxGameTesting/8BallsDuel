local module = require("./graph")

local create_node = module.create_node
local push_scope = module.push_scope
local pop_scope = module.pop_scope
local destroy = module.destroy
local get_scope = module.get_scope

local function branch(callback)
	local v = get_scope()

	if not v then
		error("cannot use branch() outside a stable or reactive scope", 0)
	end

	local owner = v.owner

	if not owner then
		error("current scope is not owned by a scope", 0)
	end

	local v2 = create_node(owner, false, false)

	local function fn() -- 1 equivalent call inferred from this helper
		destroy(v2)
	end

	push_scope(v2)

	local success, result = xpcall(callback, debug.traceback)

	pop_scope()

	if not success then
		fn() -- inferred equivalent call
		error(`error while running branch():\n\n{result}`, 0)
	end

	return fn, result
end

return branch