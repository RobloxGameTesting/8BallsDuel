local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local LocalizationService = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")

local v = loaded("Promise")

return {
	promiseTranslator = function(p)
		local v2 = v.spawn(function(callback, callback2)
			local translatorForPlayerAsync = nil
			local success, result = pcall(function()
				translatorForPlayerAsync = LocalizationService:GetTranslatorForPlayerAsync(p)
			end)

			if not success then
				callback2(result or "Failed to GetTranslatorForPlayerAsync")
				return
			end

			if not translatorForPlayerAsync then
				callback2("Translator was not returned")
				return
			end

			assert(typeof(translatorForPlayerAsync) == "Instance", "Bad translator")
			callback(translatorForPlayerAsync)
		end)

		local v3 = RunService:IsStudio() and 0.5 or 20

		local v4 = false
		task.delay(v3, function()
			if not v2:IsPending() then
				return
			end

			v4 = true
			v2:Reject(("GetTranslatorForPlayerAsync is still pending after %f, using local table"):format(v3))
		end)

		return v2:Catch(function(p2)
			if p2 ~= "Publishing the game is required to use GetTranslatorForPlayerAsync API." and not v4 then
				warn(("[LocalizationServiceUtils.promiseTranslator] - %s"):format((tostring(p2))))
			end

			return (LocalizationService:GetTranslatorForPlayer(p))
		end)
	end
}