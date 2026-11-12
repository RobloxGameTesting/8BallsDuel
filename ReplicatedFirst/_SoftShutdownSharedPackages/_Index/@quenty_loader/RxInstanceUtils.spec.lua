local ServerScriptService = game:GetService("ServerScriptService")
local v = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)("RxInstanceUtils")

return function()
	describe("RxInstanceUtils.observeChildrenBrio", function()
		local part = Instance.new("Part")
		local v2 = v.observeChildrenBrio(part)
		local v3 = nil

		it("should not emit anything", function()
			v2:Subscribe(function(p)
				v3 = p
			end)

			expect(v3).to.equal(nil)
		end)
	end)
end