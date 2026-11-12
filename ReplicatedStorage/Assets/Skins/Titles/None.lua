local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Colours = require(ReplicatedStorage.Libraries.Modules.Colours)

local Titles = ReplicatedStorage.Assets.Skins.Titles
local None = {}
None.name = "None"
None.itemType = "Title"
None.text = ""
None.gradient = Colours.deselected
function None.labelTop(p, p2)
	local child = p.titleName and Titles:FindFirstChild(p.titleName)

	if not child then
		return p2.name
	end

	local module = require(child)
	return module.name
end

function None.labelBottom(_, _): string
	return "Title"
end

function None.image(_, _): string
	return ""
end
function None.rarity(_, _): string
	return "Tier1"
end

return None