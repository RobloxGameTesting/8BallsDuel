local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Bow = {}
Bow.name = "Bow"
Bow.itemType = "Emote"

function Bow.rarity(_, _): string
	return "Tier1"
end

Bow.animationId = 112599417909757

function Bow.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Bow.labelBottom(_, _): string
	return "Emote"
end

function Bow.image(_, _): string
	return "rbxassetid://131373049968391"
end

return Bow