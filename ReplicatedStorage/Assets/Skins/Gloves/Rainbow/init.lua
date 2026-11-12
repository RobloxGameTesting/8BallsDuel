game:GetService("ReplicatedStorage")
local Rainbow = {}
Rainbow.name = "Rainbow"
Rainbow.itemType = "Glove"
Rainbow.instance = script:FindFirstChildWhichIsA("Tool")
function Rainbow.rarity(_, _): string
	return "Tier7"
end

function Rainbow.labelTop(_, p)
	return p.name
end

function Rainbow.labelBottom(_, p)
	return p.itemType
end

function Rainbow.image(_, _): string
	return "rbxassetid://87937080348542"
end

Rainbow.animations = { idle = 120250643826676, swing = 13721851561 }

Rainbow.damage = { min = 6000, max = 8000 }
Rainbow.criticalChance = 0
Rainbow.criticalMultiplier = 10
Rainbow.price = 1800000
Rainbow.rebirth = 2
return Rainbow