local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local CurrencyHelper = require(ReplicatedStorage.Libraries.Helpers.CurrencyHelper)
local TableHelper = require(ReplicatedStorage.Libraries.Helpers.TableHelper)

RunService:IsServer()

return function(p, p2)
	if not (p2.mantissa < 0) then
		p.Data.currency2 = CurrencyHelper.Add(p.Data.currency2, p2)

		return
	end

	local copy = TableHelper:DeepCopy(p2)
	copy.mantissa *= -1
	p.Data.currency2 = CurrencyHelper.Subtract(p.Data.currency2, copy)
end