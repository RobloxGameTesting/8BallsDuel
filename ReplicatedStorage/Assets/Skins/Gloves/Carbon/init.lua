game:GetService("ReplicatedStorage")
local Carbon = {}
Carbon.name = "Carbon Fiber"
Carbon.itemType = "Glove"
Carbon.instance = script:FindFirstChildWhichIsA("Tool")
function Carbon.rarity(_, _): string
	return "Tier7"
end

function Carbon.labelTop(_, p)
	return p.name
end

function Carbon.labelBottom(_, p)
	return p.itemType
end

function Carbon.image(_, _): string
	return "rbxassetid://86182830749363"
end

Carbon.animations = { idle = 120250643826676, swing = 13721851561 }

Carbon.damage = { min = 1600, max = 1900 }
Carbon.criticalChance = 0
Carbon.criticalMultiplier = 10
Carbon.price = 180000
Carbon.rebirth = 1
return Carbon