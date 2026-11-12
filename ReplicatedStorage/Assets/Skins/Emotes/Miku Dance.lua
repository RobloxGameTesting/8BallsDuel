local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local MikuDance = {}
MikuDance.name = "Miku Dance"
MikuDance.itemType = "Emote"

function MikuDance.rarity(_, _): string
	return "Tier4"
end

MikuDance.animationId = 71572941313419

function MikuDance.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function MikuDance.labelBottom(_, _): string
	return "Emote"
end

function MikuDance.image(_, _): string
	return "rbxassetid://137676133952838"
end

return MikuDance