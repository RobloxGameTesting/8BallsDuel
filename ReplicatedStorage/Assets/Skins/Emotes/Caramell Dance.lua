local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local CaramellDance = {}
CaramellDance.name = "Caramell Dance"
CaramellDance.itemType = "Emote"

function CaramellDance.rarity(_, _): string
	return "Tier6"
end

CaramellDance.animationId = 87518843871536

function CaramellDance.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function CaramellDance.labelBottom(_, _): string
	return "Emote"
end

function CaramellDance.image(_, _): string
	return "rbxassetid://131373049968391"
end

return CaramellDance