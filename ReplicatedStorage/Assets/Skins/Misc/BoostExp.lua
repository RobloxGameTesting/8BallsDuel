local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local BoostExp = {}
BoostExp.name = "BoostExp"
BoostExp.itemType = "BoostExp"

function BoostExp.image(_, _): string
	return "rbxassetid://97334660911372"
end
function BoostExp.labelTop(p, _)
	if p.value >= 3600 then
		return NumberHelper.FormatTimerHMS(p.value)
	end

	return NumberHelper.FormatTimerMS(p.value)
end

function BoostExp.labelBottom(_, _): string
	return "Exp Boost"
end
function BoostExp.rarity(_, _): string
	return "Tier3"
end

return BoostExp