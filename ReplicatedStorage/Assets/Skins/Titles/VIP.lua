local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Colours = require(ReplicatedStorage.Libraries.Modules.Colours)

local Titles = ReplicatedStorage.Assets.Skins.Titles
local VIP = {}
VIP.name = "None"
VIP.itemType = "Title"
VIP.text = "[ VIP ]"
VIP.gradient = Colours.goldPass
function VIP.labelTop(p, p2)
	local child = p.titleName and Titles:FindFirstChild(p.titleName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function VIP.labelBottom(_, _): string
	return "Title"
end

function VIP.image(_, _): string
	return ""
end
function VIP.rarity(_, _): string
	return "TierRobux"
end

return VIP