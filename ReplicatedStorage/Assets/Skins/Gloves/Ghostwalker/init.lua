game:GetService("ReplicatedStorage")
local Ghostwalker = {}
Ghostwalker.name = "Ghostwalker"
Ghostwalker.itemType = "Glove"
Ghostwalker.instance = script:FindFirstChildWhichIsA("Tool")
function Ghostwalker.rarity(_, _): string
	return "Tier7"
end

function Ghostwalker.labelTop(_, p)
	return p.name
end

function Ghostwalker.labelBottom(_, p)
	return p.itemType
end

function Ghostwalker.image(_, _): string
	return "rbxassetid://118078531286155"
end

Ghostwalker.animations = { idle = 120250643826676, swing = 13721851561 }

Ghostwalker.damage = { min = 4500, max = 6000 }
Ghostwalker.criticalChance = 0
Ghostwalker.criticalMultiplier = 10
Ghostwalker.price = 1200000
Ghostwalker.rebirth = 2
return Ghostwalker