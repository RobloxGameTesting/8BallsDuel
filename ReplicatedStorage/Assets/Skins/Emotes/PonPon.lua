local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local PonPon = {}
PonPon.name = "Pon Pon"
PonPon.itemType = "Emote"

function PonPon.rarity(_, _): string
	return "Tier5"
end

PonPon.animationId = 83330240732185

function PonPon.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function PonPon.labelBottom(_, _): string
	return "Emote"
end

function PonPon.image(_, _): string
	return "rbxassetid://108771901998171"
end

PonPon.looped = true
return PonPon