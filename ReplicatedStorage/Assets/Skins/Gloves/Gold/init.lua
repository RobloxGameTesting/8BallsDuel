game:GetService("ReplicatedStorage")
local Gold = {}
Gold.name = "Gold"
Gold.itemType = "Glove"
Gold.instance = script:FindFirstChildWhichIsA("Tool")
function Gold.rarity(_, _): string
	return "Tier7"
end

function Gold.labelTop(_, p)
	return p.name
end

function Gold.labelBottom(_, p)
	return p.itemType
end

function Gold.image(_, _): string
	return "rbxassetid://82929114644614"
end

Gold.animations = { idle = 120250643826676, swing = 13721851561 }

Gold.damage = { min = 1100, max = 1400 }
Gold.criticalChance = 0
Gold.criticalMultiplier = 10
Gold.price = 99000
Gold.rebirth = 1
return Gold