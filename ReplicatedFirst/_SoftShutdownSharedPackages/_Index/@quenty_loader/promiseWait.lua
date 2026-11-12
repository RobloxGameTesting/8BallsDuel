local loader = require(script.Parent.loader)
local v = loader.load(script)("Promise")

return function(duration)
	return v.new(function(callback, _)
		task.delay(duration, function()
			callback()
		end)
	end)
end