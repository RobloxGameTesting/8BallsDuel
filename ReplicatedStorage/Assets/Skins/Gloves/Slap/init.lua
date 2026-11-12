game:GetService("ReplicatedStorage")
local Slap = {}
Slap.name = "Slap"
Slap.itemType = "Glove"
Slap.instance = script:FindFirstChildWhichIsA("Tool")
function Slap.rarity(_, _): string
	return "Tier1"
end

function Slap.labelTop(_, p)
	return p.name
end

function Slap.labelBottom(_, p)
	return p.itemType
end

function Slap.image(_, _): string
	return "rbxassetid://92556831366348"
end

Slap.animations = { idle = 120250643826676, swing = 13721851561 }

Slap.damage = { min = 50, max = 80 }
Slap.criticalChance = 0
Slap.criticalMultiplier = 10
Slap.price = 0
Slap.rebirth = 0
return Slap