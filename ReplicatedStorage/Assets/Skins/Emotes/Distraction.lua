local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Distraction = {}
Distraction.name = "Distraction"
Distraction.itemType = "Emote"

function Distraction.rarity(_, _): string
	return "Tier4"
end

Distraction.animationId = 109166094649518

function Distraction.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Distraction.labelBottom(_, _): string
	return "Emote"
end

function Distraction.image(_, _): string
	return "rbxassetid://131373049968391"
end

return Distraction