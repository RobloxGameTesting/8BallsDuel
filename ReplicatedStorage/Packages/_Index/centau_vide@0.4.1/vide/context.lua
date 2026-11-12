local module = require("./graph")

local create_node = module.create_node
local get_scope = module.get_scope
local push_scope = module.push_scope
local pop_scope = module.pop_scope
local set_context = module.set_context

local v = newproxy()
local count = 0

local function context(...)
	count += 1
	local v2 = count

	local v3 = select("#", ...) > 0
	local v4 = ...

	return function(...)
		local v5 = get_scope()

		if select("#", ...) == 0 then
			while v5 do
				local context2 = v5.context

				if context2 then
					local v6 = context2[v2]

					if v6 ~= nil then
						return if v6 ~= v then v6 else nil
					end
				end

				v5 = v5.owner
			end

			if v3 ~= nil then
				return v4
			end

			error("attempt to get context when no context is set and no default context is set", 0)

			return nil
		else
			if not v5 then
				return error("attempt to set context outside of a vide scope", 0)
			end

			local v6, v7 = ...

			local v8 = create_node(v5, false, false)

			if v6 == nil then
				v6 = v
			end

			set_context(v8, v2, v6)

			push_scope(v8)

			local function efn(p: string)
				return debug.traceback(p, 3)
			end
			local success, result = xpcall(v7, efn)

			pop_scope()

			if not success then
				error(`error while running context:\n\n{result}`, 0)
			end

			return result
		end
	end
end

return context