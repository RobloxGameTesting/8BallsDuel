local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Currency2 = {}
Currency2.name = "Currency2"
Currency2.itemType = "Currency"

function Currency2.image(_, _): string
	return "rbxassetid://91068843812037"
end

function Currency2.labelTop(p, _)
	return NumberHelper:Separate(p.value)
end

function Currency2.labelBottom(): string
	return "Gems"
end
function Currency2.rarity(_, _): string
	return "Tier3"
end

return Currency2