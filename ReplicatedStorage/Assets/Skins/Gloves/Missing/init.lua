game:GetService("ReplicatedStorage")
local Missing = {}
Missing.name = "Missing"
Missing.itemType = "Glove"
Missing.instance = script:FindFirstChildWhichIsA("Tool")
function Missing.rarity(_, _): string
	return "Tier6"
end

function Missing.labelTop(_, p)
	return p.name
end

function Missing.labelBottom(_, p)
	return p.itemType
end

function Missing.image(_, _): string
	return "rbxassetid://138728518809577"
end

Missing.animations = { idle = 120250643826676, swing = 13721851561 }

Missing.damage = { min = 700, max = 1000 }
Missing.criticalChance = 0
Missing.criticalMultiplier = 10
Missing.price = 60000
Missing.rebirth = 0
return Missing