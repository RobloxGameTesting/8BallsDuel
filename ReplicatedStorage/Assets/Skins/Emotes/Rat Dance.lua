local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local RatDance = {}
RatDance.name = "Rat Dance"
RatDance.itemType = "Emote"

function RatDance.rarity(_, _): string
	return "Tier5"
end

RatDance.animationId = 72336857459442

function RatDance.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function RatDance.labelBottom(_, _): string
	return "Emote"
end

function RatDance.image(_, _): string
	return "rbxassetid://75718401643331"
end

return RatDance