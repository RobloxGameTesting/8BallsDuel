game:GetService("ReplicatedStorage")
local Galaxy = {}
Galaxy.name = "Galaxy"
Galaxy.itemType = "Glove"
Galaxy.instance = script:FindFirstChildWhichIsA("Tool")
function Galaxy.rarity(_, _): string
	return "Tier4"
end

function Galaxy.labelTop(_, p)
	return p.name
end

function Galaxy.labelBottom(_, p)
	return p.itemType
end

function Galaxy.image(_, _): string
	return "rbxassetid://113503851989798"
end

Galaxy.animations = { idle = 120250643826676, swing = 13721851561 }

Galaxy.damage = { min = 20000, max = 21000 }
Galaxy.criticalChance = 0
Galaxy.criticalMultiplier = 10
Galaxy.price = 6000000
Galaxy.rebirth = 3
return Galaxy