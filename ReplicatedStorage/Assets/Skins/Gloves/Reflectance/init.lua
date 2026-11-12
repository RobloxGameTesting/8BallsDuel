game:GetService("ReplicatedStorage")
local Reflectance = {}
Reflectance.name = "Reflectance 100"
Reflectance.itemType = "Glove"
Reflectance.instance = script:FindFirstChildWhichIsA("Tool")
function Reflectance.rarity(_, _): string
	return "Tier7"
end

function Reflectance.labelTop(_, p)
	return p.name
end

function Reflectance.labelBottom(_, p)
	return p.itemType
end

function Reflectance.image(_, _): string
	return "rbxassetid://107516973259650"
end

Reflectance.animations = { idle = 120250643826676, swing = 13721851561 }

Reflectance.damage = { min = 3000, max = 3700 }
Reflectance.criticalChance = 0
Reflectance.criticalMultiplier = 10
Reflectance.price = 400000
Reflectance.rebirth = 1
return Reflectance