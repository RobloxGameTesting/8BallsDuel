local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local BoostCurrency2 = {}
BoostCurrency2.name = "BoostCurrency2"
BoostCurrency2.itemType = "BoostCurrency2"

function BoostCurrency2.image(_, _): string
	return "rbxassetid://139646339619059"
end
function BoostCurrency2.labelTop(p, _)
	if p.value >= 3600 then
		return NumberHelper.FormatTimerHMS(p.value)
	end

	return NumberHelper.FormatTimerMS(p.value)
end

function BoostCurrency2.labelBottom(): string
	return "Gem Boost"
end
function BoostCurrency2.rarity(_, _): string
	return "Tier3"
end

return BoostCurrency2