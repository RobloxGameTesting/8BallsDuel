local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local v = loaded("BrioUtils")
local v2 = loaded("Brio")

return function()
	describe("BrioUtils.flatten({})", function()
		local flattened = v.flatten({})

		describe("should return a brio that", function()
			it("is a brio", function()
				expect(flattened).to.be.a("table")
				expect(v2.isBrio(flattened)).to.equal(true)
			end)

			it("is alive", function()
				expect(not flattened:IsDead()).to.equal(true)
			end)

			it("contains a table", function()
				expect(flattened:GetValue()).to.be.a("table")
			end)

			it("contains a table with nothing in it", function()
				expect(next(flattened:GetValue())).to.equal(nil)
			end)
		end)
	end)

	describe("BrioUtils.flatten with out a brio in it", function()
		local flattened = v.flatten({ value = 5 })

		describe("should return a brio that", function()
			it("is a brio", function()
				expect(flattened).to.be.a("table")
				expect(v2.isBrio(flattened)).to.equal(true)
			end)

			it("is alive", function()
				expect(not flattened:IsDead()).to.equal(true)
			end)

			it("contains a table", function()
				expect(flattened:GetValue()).to.be.a("table")
			end)

			it("contains a table with value", function()
				expect(flattened:GetValue().value).to.equal(5)
			end)
		end)
	end)

	describe("BrioUtils.flatten a dead brio in it", function()
		local flattened = v.flatten({ value = v2.DEAD })

		describe("should return a brio that", function()
			it("is a brio", function()
				expect(flattened).to.be.a("table")
				expect(v2.isBrio(flattened)).to.equal(true)
			end)

			it("is dead", function()
				expect(flattened:IsDead()).to.equal(true)
			end)
		end)
	end)
end