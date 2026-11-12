local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local BoostLuck = {}
BoostLuck.name = "BoostLuck"
BoostLuck.itemType = "BoostLuck"

function BoostLuck.image(_, _): string
	return "rbxassetid://136378801450521"
end
function BoostLuck.labelTop(p, _)
	if p.value >= 3600 then
		return NumberHelper.FormatTimerHMS(p.value)
	end

	return NumberHelper.FormatTimerMS(p.value)
end

function BoostLuck.labelBottom(_, _): string
	return "Luck Boost"
end
function BoostLuck.rarity(_, _): string
	return "Tier1"
end

return BoostLuck