local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local BoostExtraLuck = {}
BoostExtraLuck.name = "BoostExtraLuck"
BoostExtraLuck.itemType = "BoostExtraLuck"

function BoostExtraLuck.image(_, _): string
	return "rbxassetid://136378801450521"
end
function BoostExtraLuck.labelTop(p, _)
	if p.value >= 3600 then
		return NumberHelper.FormatTimerHMS(p.value)
	end

	return NumberHelper.FormatTimerMS(p.value)
end

function BoostExtraLuck.labelBottom(_, _): string
	return "Extra Luck Boost"
end
function BoostExtraLuck.rarity(_, _): string
	return "Tier1"
end

return BoostExtraLuck