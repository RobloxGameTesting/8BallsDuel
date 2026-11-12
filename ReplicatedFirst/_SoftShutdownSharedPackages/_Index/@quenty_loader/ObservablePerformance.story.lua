local ServerScriptService = game:GetService("ServerScriptService")
local v = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)("Observable")

return function(_)
	local lastTime = tick()

	for _ = 1, 1000000 do
		v.new(function(object)
			object:Fire()
		end):Subscribe(function() end):Destroy()
	end

	print((tick() - lastTime) * 1000 .. " ms for 1,000,000")

	return function() end
end