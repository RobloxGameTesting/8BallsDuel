local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyHelper = require(ReplicatedStorage.Libraries.Helpers.CurrencyHelper)

return function(p, items)
	for k, item in items do
		local v = p.Data.offlineRewards[k] or { mantissa = 0, exponent = 0 }

		local v2 = CurrencyHelper.Add(v, item)
		p.Data.offlineRewards[k] = v2
	end
end