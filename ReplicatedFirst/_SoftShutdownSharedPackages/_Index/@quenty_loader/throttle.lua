local loader = require(script.Parent.loader)
local v = loader.load(script)("ThrottledFunction")

local function throttle(value, callback, p)
	assert(type(value) == "number", "timeoutInSeconds is not a number")
	assert(type(callback) == "function", "func is not a function")

	local v2 = v.new(value, callback, p)

	return function(...)
		v2:Call(...)
	end
end

return throttle