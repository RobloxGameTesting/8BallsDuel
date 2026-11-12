local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local v = loaded("NumberLocalizationUtils")
local v2 = loaded("RoundingBehaviourTypes")

return function()
	local function checkLocale(p, items)
		for k, item in pairs(items) do
			expect(v.localize(k, p)).to.equal(item)
		end
	end

	local function checkValid_en_zh(p) -- 4 equivalent calls inferred from this helper
		checkLocale(p, {
			[0] = "0",
			[1] = "1",
			[25] = "25",
			[364] = "364",
			[4120] = "4,120",
			[57860] = "57,860",
			[624390] = "624,390",
			[7857000] = "7,857,000",
			[-12345678] = "-12,345,678",
			[23987.45678] = "23,987.45678",
			[-12.3456] = "-12.3456",
			[-23987.45678] = "-23,987.45678"
		})
	end

	describe("NumberLocalizationUtils.localize", function()
		it("should localize correctly. (en-us)", function()
			checkValid_en_zh("en-us") -- inferred equivalent call
		end)

		it("should localize correctly. (en-gb)", function()
			checkValid_en_zh("en-gb") -- inferred equivalent call
		end)

		it("should localize correctly. (zh-cn)", function()
			checkValid_en_zh("zh-cn") -- inferred equivalent call
		end)

		it("should localize correctly. (zh-tw)", function()
			checkValid_en_zh("zh-tw") -- inferred equivalent call
		end)
	end)

	describe("NumberLocalizationUtils.abbreviate", function()
		it("should round towards zero when using RoundingBehaviourTypes.Truncate", function()
			for k, v3 in pairs({
				[0] = "0",
				[1] = "1",
				[25] = "25",
				[364] = "364",
				[4120] = "4.1K",
				[57860] = "57.8K",
				[624390] = "624K",
				[999999] = "999K",
				[7857000] = "7.8M",
				[80000000] = "80M",
				[900000000] = "900M",
				[1000000000] = "1B",
				[1000000000000] = "1,000B",
				[-1] = "-1",
				[-25] = "-25",
				[-364] = "-364",
				[-4120] = "-4.1K",
				[-57860] = "-57.8K",
				[-624390] = "-624K",
				[-999999] = "-999K",
				[-7857000] = "-7.8M",
				[-80000000] = "-80M",
				[-900000000] = "-900M",
				[-1000000000] = "-1B",
				[-1000000000000] = "-1,000B",
				[1.1] = "1.1",
				[1499.99] = "1.4K",
				[-1.1] = "-1.1",
				[-1499.99] = "-1.4K"
			}) do
				expect(v.abbreviate(k, "en-us", v2.TRUNCATE)).to.equal(v3)
			end
		end)
	end)
end