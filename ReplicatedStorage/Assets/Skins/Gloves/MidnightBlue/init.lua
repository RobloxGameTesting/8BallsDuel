game:GetService("ReplicatedStorage")
local MidnightBlue = {}
MidnightBlue.name = "Midnight"
MidnightBlue.itemType = "Glove"
MidnightBlue.instance = script:FindFirstChildWhichIsA("Tool")
function MidnightBlue.rarity(_, _): string
	return "Tier7"
end

function MidnightBlue.labelTop(_, p)
	return p.name
end

function MidnightBlue.labelBottom(_, p)
	return p.itemType
end

function MidnightBlue.image(_, _): string
	return "rbxassetid://139921734434398"
end

MidnightBlue.animations = { idle = 120250643826676, swing = 13721851561 }

MidnightBlue.damage = { min = 4000, max = 5500 }
MidnightBlue.criticalChance = 0
MidnightBlue.criticalMultiplier = 10
MidnightBlue.price = 800000
MidnightBlue.rebirth = 1
return MidnightBlue