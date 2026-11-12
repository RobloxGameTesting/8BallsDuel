game:GetService("ReplicatedStorage")
local CandyRed = {}
CandyRed.name = "Candy Red"
CandyRed.itemType = "Glove"
CandyRed.instance = script:FindFirstChildWhichIsA("Tool")
function CandyRed.rarity(_, _): string
	return "Tier6"
end

function CandyRed.labelTop(_, p)
	return p.name
end

function CandyRed.labelBottom(_, p)
	return p.itemType
end

function CandyRed.image(_, _): string
	return "rbxassetid://80964851811285"
end

CandyRed.animations = { idle = 120250643826676, swing = 13721851561 }

CandyRed.damage = { min = 150, max = 200 }
CandyRed.criticalChance = 0
CandyRed.criticalMultiplier = 10
CandyRed.price = 2000
CandyRed.rebirth = 0
return CandyRed