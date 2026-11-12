game:GetService("ReplicatedStorage")
local Lava = {}
Lava.name = "Lava"
Lava.itemType = "Glove"
Lava.instance = script:FindFirstChildWhichIsA("Tool")
function Lava.rarity(_, _): string
	return "Tier7"
end

function Lava.labelTop(_, p)
	return p.name
end

function Lava.labelBottom(_, p)
	return p.itemType
end

function Lava.image(_, _): string
	return "rbxassetid://92546683984494"
end

Lava.animations = { idle = 120250643826676, swing = 13721851561 }

Lava.damage = { min = 2000, max = 2800 }
Lava.criticalChance = 0
Lava.criticalMultiplier = 10
Lava.price = 250000
Lava.rebirth = 1
return Lava