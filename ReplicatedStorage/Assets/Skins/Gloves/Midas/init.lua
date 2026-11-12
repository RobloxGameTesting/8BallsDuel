game:GetService("ReplicatedStorage")
local Midas = {}
Midas.name = "Midas"
Midas.itemType = "Glove"
Midas.instance = script:FindFirstChildWhichIsA("Tool")
function Midas.rarity(_, _): string
	return "Tier1"
end

function Midas.labelTop(_, p)
	return p.name
end

function Midas.labelBottom(_, p)
	return p.itemType
end

function Midas.image(_, _): string
	return "rbxassetid://98529512670117"
end

Midas.animations = { idle = 120250643826676, swing = 13721851561 }

Midas.damage = { min = 11000, max = 14000 }
Midas.criticalChance = 0
Midas.criticalMultiplier = 10
Midas.price = 4000000
Midas.rebirth = 2
return Midas