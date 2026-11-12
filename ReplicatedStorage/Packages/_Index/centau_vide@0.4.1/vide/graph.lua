local module = require("./flags")

local scopes = { n = 0 }

local function efn(value: string)
	local v = debug.traceback(value, 2)

	if string.find(value, "^effect error stacktrace") then
		v = string.gsub("    " .. v, "\n", function(): string
			return "\n    "
		end)
	end

	return v .. "\nsource update stacktrace:"
end

local function ycall(effect, cache)
	local thread = coroutine.create(xpcall)

	local v, v2, v3 = coroutine.resume(thread, effect, efn, cache)

	assert(v)

	if coroutine.status(thread) == "dead" then
		return v2, v3
	end

	return false, debug.traceback(thread, "attempt to yield in reactive scope")
end

local function flush_cleanups(state)
	if state.cleanups then
		for _, callback in state.cleanups do
			local success, result = xpcall(callback, debug.traceback)

			if not success then
				error(`cleanup error: {result}`, 0)
			end
		end

		table.clear(state.cleanups)
	end
end

local function find_and_swap_pop(list, p)
	local index = table.find(list, p)
	local count = #list
	list[index] = list[count]
	list[count] = nil
end

local function unparent(p)
	local parents = p.parents

	for k, list in parents do
		local index = table.find(list, p)
		local count = #list
		list[index] = list[count]
		list[count] = nil

		parents[k] = nil
	end
end

local function destroy(state)
	if module.strict and table.find(scopes, state) then
		error("attempt to destroy an active scope", 0)
	end

	flush_cleanups(state)
	local parents = state.parents

	for k, list in parents do
		local index = table.find(list, state)
		local count = #list
		list[index] = list[count]
		list[count] = nil

		parents[k] = nil
	end

	if state.owner then
		local owned = state.owner.owned
		local index = table.find(owned, state)
		local count = #owned
		owned[index] = owned[count]
		owned[count] = nil

		state.owner = false
	end

	if state.owned then
		local owned = state.owned

		while owned[1] do
			destroy(owned[1])
		end
	end
end

local function destroy_owned(p)
	if p.owned then
		local owned = p.owned

		while owned[1] do
			destroy(owned[1])
		end
	end
end

local v = { n = 0 }

local function evaluate_node(state): boolean
	if module.strict then
		if table.find(scopes, state) then
			error("a scope, that should rerun due to the update of a source, is already active", 0)
		end

		local cache = state.cache

		for _ = 1, 2 do
			local cache2 = state.cache

			flush_cleanups(state)

			if state.owned then
				local owned = state.owned

				while owned[1] do
					destroy(owned[1])
				end
			end

			local v2 = scopes.n + 1
			scopes.n = v2
			scopes[v2] = state

			local v3, cache3 = ycall(state.effect, cache2)
			local n = scopes.n
			scopes.n = n - 1
			scopes[n] = nil

			if not v3 then
				table.clear(v)
				v.n = 0
				error(`effect error stacktrace\n{cache3}`, 0)
			end

			state.cache = cache3
		end

		return cache ~= state.cache
	else
		local cache = state.cache

		flush_cleanups(state)

		if state.owned then
			local owned = state.owned

			while owned[1] do
				destroy(owned[1])
			end
		end

		local v2 = scopes.n + 1
		scopes.n = v2
		scopes[v2] = state

		local success, result = pcall(state.effect, state.cache)
		local n = scopes.n
		scopes.n = n - 1
		scopes[n] = nil

		if not success then
			table.clear(v)
			v.n = 0
			error(`effect error:\n{result}\n`, 0)
		end

		state.cache = result
		return cache ~= result
	end
end

local function queue_children_for_update(list)
	local n = v.n

	while list[1] do
		n += 1
		v[n] = list[1]
		local item = list[1]
		local parents = item.parents

		for k, list2 in parents do
			local index = table.find(list2, item)
			local count = #list2
			list2[index] = list2[count]
			list2[count] = nil

			parents[k] = nil
		end
	end

	v.n = n
end

return table.freeze({
	push_scope = function(p)
		local v2 = scopes.n + 1
		scopes.n = v2
		scopes[v2] = p
	end,
	pop_scope = function()
		local n = scopes.n
		scopes.n = n - 1
		scopes[n] = nil
	end,
	evaluate_node = evaluate_node,
	get_scope = function()
		return scopes[scopes.n]
	end,
	assert_stable_scope = function()
		local v2 = scopes[scopes.n]

		if not v2 then
			local v3 = debug.info(2, "n")
			return error(`cannot use {v3}() outside a stable or reactive scope`, 0)
		end

		if v2.effect then
			error("cannot create a new reactive scope inside another reactive scope", 0)
		end

		return v2
	end,
	push_cleanup = function(p, callback)
		if p.cleanups then
			table.insert(p.cleanups, callback)
		else
			p.cleanups = { callback }
		end
	end,
	destroy = destroy,
	flush_cleanups = flush_cleanups,
	push_scope_as_child_of = function(list)
		local v2 = scopes[scopes.n]

		if v2 and v2.effect then
			table.insert(list, v2)
			table.insert(v2.parents, list)
		end
	end,
	update_descendants = function(list)
		local n = v.n
		local n2 = v.n

		while list[1] do
			n2 += 1
			v[n2] = list[1]
			local item = list[1]
			local parents = item.parents

			for k, list2 in parents do
				local index = table.find(list2, item)
				local count = #list2
				list2[index] = list2[count]
				list2[count] = nil

				parents[k] = nil
			end
		end

		v.n = n2

		if module.batch then
			return
		end

		local v2 = n + 1

		while v2 <= v.n do
			local v3 = v[v2]

			if v3.owner and evaluate_node(v3) then
				local n3 = v.n

				while v3[1] do
					n3 += 1
					v[n3] = v3[1]
					local v4 = v3[1]
					local parents = v4.parents

					for k, list2 in parents do
						local index = table.find(list2, v4)
						local count = #list2
						list2[index] = list2[count]
						list2[count] = nil

						parents[k] = nil
					end
				end

				v.n = n3
			end

			v[v2] = false
			v2 += 1
		end

		v.n = n
	end,
	push_child = function(list, p)
		table.insert(list, p)
		table.insert(p.parents, list)
	end,
	create_node = function(owner, effect, cache)
		local v2 = {
			cache = cache,
			effect = effect,
			cleanups = false,
			context = false,
			owner = owner,
			owned = false,
			parents = {}
		}

		if not owner then
			return v2
		end

		if owner.owned then
			table.insert(owner.owned, v2)
			return v2
		end

		owner.owned = { v2 }

		return v2
	end,
	create_source_node = function(cache)
		return { cache = cache }
	end,
	get_children = function(list)
		return { unpack(list) }
	end,
	flush_update_queue = function(p: number)
		local v2 = p + 1

		while v2 <= v.n do
			local v3 = v[v2]

			if v3.owner and evaluate_node(v3) then
				local n = v.n

				while v3[1] do
					n += 1
					v[n] = v3[1]
					local v4 = v3[1]
					local parents = v4.parents

					for k, list in parents do
						local index = table.find(list, v4)
						local count = #list
						list[index] = list[count]
						list[count] = nil

						parents[k] = nil
					end
				end

				v.n = n
			end

			v[v2] = false
			v2 += 1
		end

		v.n = p
	end,
	get_update_queue_length = function()
		return v.n
	end,
	set_context = function(p, p2: number, p3)
		if p.context then
			p.context[p2] = p3
		else
			p.context = { [p2] = p3 }
		end
	end,
	scopes = scopes,
	q = v
})