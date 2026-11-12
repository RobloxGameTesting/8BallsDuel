local ServerScriptService = game:GetService("ServerScriptService")
local v = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)("Rx")

return function()
	describe("Rx.combineLatest({})", function()
		local combineLatest = v.combineLatest({})
		local v2 = nil

		it("should execute immediately", function()
			local v3 = combineLatest:Subscribe(function(p)
				v2 = p
			end)

			expect(v2).to.be.a("table")
			v3:Destroy()
		end)
	end)

	describe("Rx.combineLatest({ value = 5 })", function()
		local combineLatest = v.combineLatest({ value = 5 })
		local v2 = nil

		it("should execute immediately", function()
			local v3 = combineLatest:Subscribe(function(p)
				v2 = p
			end)

			expect(v2).to.be.a("table")
			expect(v2.value).to.equal(5)
			v3:Destroy()
		end)
	end)

	describe("Rx.combineLatest({ value = Rx.of(5) })", function()
		local combineLatest = v.combineLatest({ value = v.of(5) })
		local v2 = nil

		it("should execute immediately", function()
			local v3 = combineLatest:Subscribe(function(p)
				v2 = p
			end)

			expect(v2).to.be.a("table")
			expect(v2.value).to.equal(5)
			v3:Destroy()
		end)
	end)
end