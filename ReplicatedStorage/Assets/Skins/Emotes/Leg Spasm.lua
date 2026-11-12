local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local LegSpasm = {}
LegSpasm.name = "Leg Spasm"
LegSpasm.itemType = "Emote"

function LegSpasm.rarity(_, _): string
	return "Tier3"
end

LegSpasm.animationId = 132464149360183

function LegSpasm.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function LegSpasm.labelBottom(_, _): string
	return "Emote"
end

function LegSpasm.image(_, _): string
	return "rbxassetid://131373049968391"
end

return LegSpasm