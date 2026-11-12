local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.CurrencyHelper)

return function(p)
	p.Data.offlineRewards = {}
end