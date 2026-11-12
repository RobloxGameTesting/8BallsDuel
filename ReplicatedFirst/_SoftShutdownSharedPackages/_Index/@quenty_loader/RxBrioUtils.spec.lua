local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local v = loaded("RxBrioUtils")
local v2 = loaded("Brio")
local v3 = loaded("Observable")

return function()
	describe("RxBrioUtils.combineLatest({})", function()
		it("should execute immediately", function()
			local v4 = nil
			local v5 = v.combineLatest({}):Subscribe(function(p)
				v4 = p
			end)
			expect(v4).to.be.ok()
			expect(v2.isBrio(v4)).to.equal(true)
			expect(v4:IsDead()).to.equal(true)

			v5:Destroy()
		end)
	end)

	describe("RxBrioUtils.combineLatest({ value = Observable(Brio(5)) })", function()
		it("should execute immediately", function()
			local v4 = nil
			local v5 = v.combineLatest({
				value = v3.new(function(object)
					object:Fire(v2.new(5))
				end),
				otherValue = 25
			}):Subscribe(function(p)
				v4 = p
			end)
			expect(v4).to.be.ok()
			expect(v2.isBrio(v4)).to.equal(true)
			expect(not v4:IsDead()).to.equal(true)
			expect(v4:GetValue()).to.be.a("table")
			expect(v4:GetValue().value).to.equal(5)

			v5:Destroy()
		end)
	end)

	describe("RxBrioUtils.flatCombineLatest", function()
		local fn
		local v4 = v2.new(5)

		local v5 = nil
		local count = 0
		local v6 = v.flatCombineLatest({
			value = v3.new(function(object)
				object:Fire(v4)
				fn = function(...)
					object:Fire(...)
				end
			end),
			otherValue = 25
		}):Subscribe(function(p)
			v5 = p
			count += 1
		end)

		it("should execute immediately", function()
			expect(count).to.equal(1)
			expect(v5).to.be.a("table")
			expect(v2.isBrio(v5)).to.equal(false)
			expect(v5.value).to.equal(5)
			expect(v5.otherValue).to.equal(25)
		end)

		it("should reset when the brio is killed", function()
			expect(count).to.equal(1)

			v4:Kill()

			expect(count).to.equal(2)
			expect(v5).to.be.a("table")
			expect(v2.isBrio(v5)).to.equal(false)
			expect(v5.value).to.equal(nil)
			expect(v5.otherValue).to.equal(25)
		end)

		it("should allow a new value", function()
			expect(count).to.equal(2)

			fn(v2.new(70))

			expect(count).to.equal(3)
			expect(v5).to.be.a("table")
			expect(v2.isBrio(v5)).to.equal(false)
			expect(v5.value).to.equal(70)
			expect(v5.otherValue).to.equal(25)
		end)

		it("should only fire once if we replace the value", function()
			expect(count).to.equal(3)

			fn(v2.new(75))

			expect(count).to.equal(4)
			expect(v5).to.be.a("table")
			expect(v2.isBrio(v5)).to.equal(false)
			expect(v5.value).to.equal(75)
			expect(v5.otherValue).to.equal(25)
		end)

		it("should cleanup the sub", function()
			v6:Destroy()
		end)
	end)
end