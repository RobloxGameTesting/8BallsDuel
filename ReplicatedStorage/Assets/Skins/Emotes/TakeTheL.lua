local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local TakeTheL = {}
TakeTheL.name = "Take The L"
TakeTheL.itemType = "Emote"

function TakeTheL.rarity(_, _): string
	return "Tier6"
end

TakeTheL.animationId = 102267908108386

function TakeTheL.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function TakeTheL.labelBottom(_, _): string
	return "Emote"
end

function TakeTheL.image(_, _): string
	return "rbxassetid://107755335078238"
end

TakeTheL.looped = true
return TakeTheL