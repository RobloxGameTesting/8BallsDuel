local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Promise")
local v2 = loaded("Maid")

return {
	promiseRemoved = function(instance)
		assert(instance:IsDescendantOf(game))

		local maid = v2.new()
		local v3 = v.new()

		maid:GiveTask(instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				v3:Resolve()
			end
		end))

		v3:Finally(function()
			maid:DoCleaning()
		end)

		return v3
	end
}