require("./flags")
local module = require("./branch")
local module2 = require("./source")
local module3 = require("./effect")
local module4 = require("./timeout")
local v = module4()

local function indexes(callback, callback2)
	local count = 0
	local v2 = {}

	local v3 = module2({})
	local function update_output() -- 2 equivalent calls inferred from this helper
		local v4 = table.create(4)

		for _, v5 in v2 do
			table.insert(v4, v5.object)
		end

		v3(v4)
	end

	module3(function()
		local v4 = callback()

		local count2 = count
		count += 1
		local flag = false

		for k, v5 in v4 do
			local v6 = v2[k]

			if v6 == nil then
				local value_source = module2(v5)
				local present = module2(false)

				local v7 = nil
				local destroy, object = module(function()
					local v8, v9 = callback2(value_source, k, present)
					v7 = v9
					return v8
				end)

				present(true)

				v2[k] = {
					destroy = destroy,
					object = object,
					value = v5,
					value_source = value_source,
					count = count2,
					delay = v7 or 0,
					present = present,
					timeout = nil
				}
				flag = true
			else
				v6.count = count2

				if v6.value ~= v5 then
					if v6.timeout then
						v6.timeout.cancel = true
						v6.timeout = nil
						v6.present(true)
					end

					v6.value = v5
					v6.value_source(v5)
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
				v5.value = nil

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

return indexes