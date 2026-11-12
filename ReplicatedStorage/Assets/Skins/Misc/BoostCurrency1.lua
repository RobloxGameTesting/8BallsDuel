local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local BoostCurrency1 = {}
BoostCurrency1.name = "BoostCurrency1"
BoostCurrency1.itemType = "BoostCurrency1"

function BoostCurrency1.image(_, _): string
	return "rbxassetid://124981904510697"
end
function BoostCurrency1.labelTop(p, _)
	if p.value >= 3600 then
		return NumberHelper.FormatTimerHMS(p.value)
	end

	return NumberHelper.FormatTimerMS(p.value)
end

function BoostCurrency1.labelBottom(): string
	return "Coin Boost"
end
function BoostCurrency1.rarity(_, _): string
	return "Tier5"
end

return BoostCurrency1