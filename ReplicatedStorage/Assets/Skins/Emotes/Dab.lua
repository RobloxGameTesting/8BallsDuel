local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Dab = {}
Dab.name = "Dab"
Dab.itemType = "Emote"

function Dab.rarity(_, _): string
	return "Tier4"
end

Dab.animationId = 132472641985069

function Dab.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Dab.labelBottom(_, _): string
	return "Emote"
end

function Dab.image(_, _): string
	return "rbxassetid://101758544113199"
end

return Dab