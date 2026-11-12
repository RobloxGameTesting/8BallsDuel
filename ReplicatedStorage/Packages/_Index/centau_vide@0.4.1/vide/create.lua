local Typeof = game and typeof

if not Typeof then
	local module = require("../test/mock")
	Typeof = module.typeof
end

local instance = game and Instance

if not instance then
	local module = require("../test/mock")
	instance = module.Instance
end

local module = require("./defaults")
local module2 = require("./apply")
local module3 = require("./flags")

local function create_constructor_for_class(p: string)
	local function constructor(p2)
		local success, result = pcall(instance.new, p)

		if not success then
			error(`invalid class name {p}`, 0)
		end

		if module3.defaults then
			local v = module[p]

			if v then
				for k, v2 in v do
					result[k] = v2
				end
			end
		end

		return module2(result, p2)
	end

	return constructor
end

local v = {}

local function create(p, p2)
	if type(p) ~= "string" and Typeof(p) ~= "Instance" then
		error("bad argument #1, expected string or instance, got " .. Typeof(p), 0)
	end

	local constructor

	if type(p) == "string" then
		constructor = v[p]

		if not constructor then
			constructor = function(p3)
				local success, result = pcall(instance.new, p)

				if not success then
					error(`invalid class name {p}`, 0)
				end

				if module3.defaults then
					local v2 = module[p]

					if v2 then
						for k, v3 in v2 do
							result[k] = v3
						end
					end
				end

				return module2(result, p3)
			end

			v[p] = constructor
		end
	else
		constructor = function(p3)
			return module2(assert(p:Clone(), "attempt to clone a non-archivable instance"), p3)
		end
	end

	if p2 then
		return (constructor(p2))
	end

	return constructor
end

return create