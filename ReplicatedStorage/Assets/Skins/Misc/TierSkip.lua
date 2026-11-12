local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local TierSkip = {}
TierSkip.name = "TierSkip"
TierSkip.itemType = "TierSkip"

function TierSkip.image(_, _): string
	return "rbxassetid://89059994883006"
end
function TierSkip.labelTop(_, _): string
	return "+1 Skip"
end

function TierSkip.labelBottom(): string
	return "Battlepass"
end
function TierSkip.rarity(_, _): string
	return "TierSkip"
end

return TierSkip