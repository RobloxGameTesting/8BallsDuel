local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage.Assets.Skins.Emotes
local CompanyDance = {}
CompanyDance.name = "Company Dance"
CompanyDance.itemType = "Emote"

function CompanyDance.rarity(_, _): string
	return "Tier5"
end

CompanyDance.animationId = 87109453997083

function CompanyDance.labelTop(p, p2)
	local child = p.emoteName and Emotes:FindFirstChild(p.emoteName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function CompanyDance.labelBottom(_, _): string
	return "Emote"
end

function CompanyDance.image(_, _): string
	return "rbxassetid://131373049968391"
end

return CompanyDance