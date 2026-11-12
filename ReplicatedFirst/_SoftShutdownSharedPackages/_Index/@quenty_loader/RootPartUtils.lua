local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("Promise")
local v2 = loaded("Maid")

return {
	promiseRootPart = function(instance)
		if instance.RootPart then
			return v.resolved(instance.RootPart)
		end

		local maid = v2.new()
		local v3 = v.new()

		task.spawn(function()
			while not instance.RootPart and v3:IsPending() do
				task.wait(0.05)
			end

			if instance.RootPart then
				v3:Resolve(instance.RootPart)
			else
				v3:Reject()
			end
		end)

		task.delay(60, function()
			if v3:IsPending() then
				warn("[RootPartUtils.promiseRootPart] - TImed out on root part", debug.traceback())
				v3:Reject("Timed out")
			end
		end)

		maid:GiveTask(instance.AncestryChanged:Connect(function()
			if not instance:IsDescendantOf(game) then
				v3:Reject("Humanoid removed from game")
			end
		end))

		maid:GiveTask(instance.Died:Connect(function()
			v3:Reject("Humanoid died")
		end))

		v3:Finally(function()
			maid:DoCleaning()
		end)

		return v3
	end
}