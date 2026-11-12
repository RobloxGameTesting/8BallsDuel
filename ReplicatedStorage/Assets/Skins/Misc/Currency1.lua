local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Currency1 = {}
Currency1.name = "Currency1"
Currency1.itemType = "Currency"

function Currency1.image(p, _): string
	if p.value <= 3000 then
		return "rbxassetid://93444258728406"
	end

	if p.value <= 50000 then
		return "rbxassetid://102724445677489"
	end

	return "rbxassetid://85153114387673"
end

function Currency1.labelTop(p, _)
	return NumberHelper:Separate(p.value)
end

function Currency1.labelBottom(): string
	return "Money"
end
function Currency1.rarity(_, _): string
	return "Tier5"
end

return Currency1