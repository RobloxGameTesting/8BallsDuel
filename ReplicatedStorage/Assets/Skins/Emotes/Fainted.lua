local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Fainted = {}
Fainted.name = "Fainted"
Fainted.itemType = "Emote"

function Fainted.rarity(_, _): string
	return "Tier5"
end

Fainted.animationId = 135808124884501

function Fainted.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Fainted.labelBottom(_, _): string
	return "Emote"
end

function Fainted.image(_, _): string
	return "rbxassetid://131373049968391"
end

return Fainted