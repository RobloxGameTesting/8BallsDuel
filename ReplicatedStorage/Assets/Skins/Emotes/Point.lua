local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.Types)

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local Point = {}
Point.name = "Point"
Point.itemType = "Emote"

function Point.rarity(_, _): string
	return "Tier6"
end

Point.animationId = 86528237554191

function Point.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function Point.labelBottom(_, _): string
	return "Emote"
end

function Point.image(_, _): string
	return "rbxassetid://78613407559206"
end

return Point