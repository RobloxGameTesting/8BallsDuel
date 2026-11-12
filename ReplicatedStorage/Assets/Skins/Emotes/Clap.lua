local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Clap = {}
Clap.name = "Clap"
Clap.itemType = "Emote"

function Clap.rarity(_, _): string
	return "Tier1"
end

Clap.animationId = 79416977879349

function Clap.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Clap.labelBottom(_, _): string
	return "Emote"
end

function Clap.image(_, _): string
	return "rbxassetid://118314870706154"
end

Clap.looped = true
return Clap