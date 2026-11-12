local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Stomp = {}
Stomp.name = "Stomp"
Stomp.itemType = "Emote"

function Stomp.rarity(_, _): string
	return "Tier2"
end

Stomp.animationId = 81374274056358

function Stomp.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Stomp.labelBottom(_, _): string
	return "Emote"
end

function Stomp.image(_, _): string
	return "rbxassetid://132245584268984"
end

return Stomp