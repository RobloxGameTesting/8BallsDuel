local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local FloatSit = {}
FloatSit.name = "Hovering Aura"
FloatSit.itemType = "Emote"

function FloatSit.rarity(_, _): string
	return "Tier6"
end

FloatSit.animationId = 107988107415905

function FloatSit.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function FloatSit.labelBottom(_, _): string
	return "Emote"
end

function FloatSit.image(_, _): string
	return "rbxassetid://131373049968391"
end

return FloatSit