local v = {}

local thread = coroutine.create(function()
	while true do
		local now = os.time()

		for _, v2 in pairs(v) do
			if v2.destroyTime <= now then
				table.remove(v, 1)

				if v2.object then
					v2.object:Destroy()
				end
			elseif v2.destroyTime - 1 <= now then
				if v2.object and v2.object:IsA("Part") then
					local transparency = v2.object.Transparency + 1 / 30
					v2.object.Transparency = transparency
				end
			else
				break
			end
		end

		wait()
	end
end)

coroutine.resume(thread)
return {
	AddItem = function(_, object, p): boolean
		local v2 = {
			object = object,
			destroyTime = p + os.time()
		}

		for k, _ in pairs(v) do
			if v[k].destroyTime > v2.destroyTime then
				table.insert(v, k, v2)
				return true
			end
		end

		table.insert(v, v2)
		return true
	end
}