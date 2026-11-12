local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Stretch = {}
Stretch.name = "Stretch"
Stretch.itemType = "Emote"

function Stretch.rarity(_, _): string
	return "Tier2"
end

Stretch.animationId = 138339983510811

function Stretch.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Stretch.labelBottom(_, _): string
	return "Emote"
end

function Stretch.image(_, _): string
	return "rbxassetid://131373049968391"
end

return Stretch