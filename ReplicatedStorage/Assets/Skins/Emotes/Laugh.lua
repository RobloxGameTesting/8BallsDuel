local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Laugh = {}
Laugh.name = "Laugh"
Laugh.itemType = "Emote"

function Laugh.rarity(_, _): string
	return "Tier5"
end

Laugh.animationId = 117621143821233

function Laugh.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Laugh.labelBottom(_, _): string
	return "Emote"
end

function Laugh.image(_, _): string
	return "rbxassetid://70982890604848"
end

return Laugh