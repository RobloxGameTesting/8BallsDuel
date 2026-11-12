game:GetService("ReplicatedStorage")
local BlackOut = {}
BlackOut.name = "Black Out"
BlackOut.itemType = "Glove"
BlackOut.instance = script:FindFirstChildWhichIsA("Tool")
function BlackOut.rarity(_, _): string
	return "Tier7"
end

function BlackOut.labelTop(_, p)
	return p.name
end

function BlackOut.labelBottom(_, p)
	return p.itemType
end

function BlackOut.image(_, _): string
	return "rbxassetid://98409085439519"
end

BlackOut.animations = { idle = 120250643826676, swing = 13721851561 }

BlackOut.damage = { min = 8000, max = 10000 }
BlackOut.criticalChance = 0
BlackOut.criticalMultiplier = 10
BlackOut.price = 3000000
BlackOut.rebirth = 2
return BlackOut