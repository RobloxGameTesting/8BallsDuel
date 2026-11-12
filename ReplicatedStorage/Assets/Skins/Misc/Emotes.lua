local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local emotes = ReplicatedStorage.Assets.Skins.Emotes
local Emotes = {}
Emotes.name = "Emotes"
Emotes.itemType = "Emote"

function Emotes.image(p, _)
	local module = require(emotes:FindFirstChild(p.emoteName))

	return module.image()
end

function Emotes.labelTop(p, _)
	local module = require(emotes:FindFirstChild(p.emoteName))
	return module.name
end

function Emotes.labelBottom(_, _): string
	return "Emote"
end

function Emotes.rarity(p, p2)
	local module = require(emotes:FindFirstChild(p.emoteName))

	return module.rarity(p, p2)
end

return Emotes