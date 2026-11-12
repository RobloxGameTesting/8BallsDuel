local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Barf = {}
Barf.name = "Barf"
Barf.itemType = "Emote"

function Barf.rarity(_, _): string
	return "Tier2"
end

Barf.animationId = 72628330261023

function Barf.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Barf.labelBottom(_, _): string
	return "Emote"
end

function Barf.image(_, _): string
	return "rbxassetid://131373049968391"
end

return Barf