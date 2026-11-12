local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local BoostSuperLuck = {}
BoostSuperLuck.name = "BoostSuperLuck"
BoostSuperLuck.itemType = "BoostSuperLuck"

function BoostSuperLuck.image(_, _): string
	return "rbxassetid://136378801450521"
end
function BoostSuperLuck.labelTop(p, _)
	if p.value >= 3600 then
		return NumberHelper.FormatTimerHMS(p.value)
	end

	return NumberHelper.FormatTimerMS(p.value)
end

function BoostSuperLuck.labelBottom(_, _): string
	return "Super Luck Boost"
end
function BoostSuperLuck.rarity(_, _): string
	return "Tier1"
end

return BoostSuperLuck