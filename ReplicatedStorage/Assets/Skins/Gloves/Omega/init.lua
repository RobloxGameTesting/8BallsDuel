game:GetService("ReplicatedStorage")
local Omega = {}
Omega.name = "Omega"
Omega.itemType = "Glove"
Omega.instance = script:FindFirstChildWhichIsA("Tool")
function Omega.rarity(_, _): string
	return "Tier4"
end

function Omega.labelTop(_, p)
	return p.name
end

function Omega.labelBottom(_, p)
	return p.itemType
end

function Omega.image(_, _): string
	return "rbxassetid://90198143774298"
end

Omega.animations = { idle = 120250643826676, swing = 13721851561 }

Omega.damage = { min = 23000, max = 24000 }
Omega.criticalChance = 0
Omega.criticalMultiplier = 10
Omega.price = 7000000
Omega.rebirth = 3
return Omega