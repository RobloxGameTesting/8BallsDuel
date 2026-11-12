local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Cough = {}
Cough.name = "Cough"
Cough.itemType = "Emote"

function Cough.rarity(_, _): string
	return "Tier3"
end

Cough.animationId = 114297153965759

function Cough.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Cough.labelBottom(_, _): string
	return "Emote"
end

function Cough.image(_, _): string
	return "rbxassetid://112792856518619"
end

return Cough