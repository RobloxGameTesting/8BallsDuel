local module = require("./flags")
local module2 = require("./branch")
local module3 = require("./source")
local module4 = require("./effect")
local module5 = require("./timeout")
local v = module5()

local function values(callback, callback2)
	local count = 0
	local v2 = {}

	local v3 = module3({})
	local function update_output() -- 2 equivalent calls inferred from this helper
		local v4 = table.create(4)

		for _, v5 in v2 do
			table.insert(v4, v5.object)
		end

		v3(v4)
	end

	module4(function()
		local v4 = callback()

		local count2 = count
		count += 1

		local flag = false

		if module.strict then
			local set = {}

			for _, v5 in v4 do
				if set[v5] then
					error("table source passed to `values()` contains duplicate values", 0)
				end

				set[v5] = true
			end
		end

		for k, v5 in v4 do
			local v6 = v2[v5]

			if v6 == nil then
				local index_source = module3(k)
				local present = module3(false)

				local v7 = nil
				local destroy, object = module2(function()
					local v8, v9 = callback2(v5, index_source, present)
					v7 = v9
					return v8
				end)

				present(true)

				v2[v5] = {
					destroy = destroy,
					object = object,
					index = k,
					index_source = index_source,
					count = count2,
					delay = v7 or 0,
					present = present,
					timeout = nil
				}
				flag = true
			else
				v6.count = count2

				if v6.index ~= k then
					if v6.timeout then
						v6.timeout.cancel = true
						v6.timeout = nil
						v6.present(true)
					end

					v6.index = k
					v6.index_source(k)
				end
			end
		end

		for k, v5 in v2 do
			if not (v5.count < count2) then
				continue
			end

			v5.present(false)

			if v5.delay == 0 then
				v5.destroy()
				v2[k] = nil
				flag = true
			else
				v5.index = nil

				if v5.timeout == nil then
					v5.timeout = v(v5.delay, function()
						v5.destroy()
						v2[k] = nil
						update_output() -- inferred equivalent call
					end)
				end
			end
		end

		if flag then
			update_output() -- inferred equivalent call
		end
	end)

	return v3
end

return values