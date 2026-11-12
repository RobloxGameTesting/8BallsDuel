local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Cry = {}
Cry.name = "Cry"
Cry.itemType = "Emote"

function Cry.rarity(_, _): string
	return "Tier4"
end

Cry.animationId = 74037242294551

function Cry.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Cry.labelBottom(_, _): string
	return "Emote"
end

function Cry.image(_, _): string
	return "rbxassetid://86670541791743"
end

Cry.looped = true
return Cry