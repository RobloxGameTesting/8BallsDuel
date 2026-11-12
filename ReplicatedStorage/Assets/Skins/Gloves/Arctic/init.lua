game:GetService("ReplicatedStorage")
local Arctic = {}
Arctic.name = "Arctic"
Arctic.itemType = "Glove"
Arctic.instance = script:FindFirstChildWhichIsA("Tool")
function Arctic.rarity(_, _): string
	return "Tier7"
end

function Arctic.labelTop(_, p)
	return p.name
end

function Arctic.labelBottom(_, p)
	return p.itemType
end

function Arctic.image(_, _): string
	return "rbxassetid://122916564825502"
end

Arctic.animations = { idle = 120250643826676, swing = 13721851561 }

Arctic.damage = { min = 550, max = 850 }
Arctic.criticalChance = 0
Arctic.criticalMultiplier = 10
Arctic.price = 25000
Arctic.rebirth = 0
return Arctic