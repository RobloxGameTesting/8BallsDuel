local module = require("./flags")
local module2 = require("./graph")

local function batch(callback)
	local batch2 = module.batch
	local v

	if not batch2 then
		module.batch = true
		v = module2.get_update_queue_length()
	end

	local success, result = xpcall(callback, debug.traceback)

	if not batch2 then
		module.batch = false
		module2.flush_update_queue(v)
	end

	if not success then
		error(`error occured while batching updates: {result}`, 0)
	end
end

return batch