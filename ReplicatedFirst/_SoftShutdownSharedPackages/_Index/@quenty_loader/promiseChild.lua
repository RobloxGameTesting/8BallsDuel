local loader = require(script.Parent.loader)
local v = loader.load(script)("Promise")

return function(instance, childName, p)
	local child = instance:FindFirstChild(childName)

	if child then
		return v.resolved(child)
	end

	return v.spawn(function(callback, callback2)
		local child2 = instance:WaitForChild(childName, p)

		if child2 then
			callback(child2)
		else
			callback2("Timed out")
		end
	end)
end