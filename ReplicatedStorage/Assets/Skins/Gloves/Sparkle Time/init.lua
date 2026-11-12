game:GetService("ReplicatedStorage")
local SparkleTime = {}
SparkleTime.name = "Sparkle Time"
SparkleTime.itemType = "Glove"
SparkleTime.instance = script:FindFirstChildWhichIsA("Tool")
function SparkleTime.rarity(_, _): string
	return "Tier6"
end

function SparkleTime.labelTop(_, p)
	return p.name
end

function SparkleTime.labelBottom(_, p)
	return p.itemType
end

function SparkleTime.image(_, _): string
	return "rbxassetid://132307617339050"
end

SparkleTime.animations = { idle = 120250643826676, swing = 13721851561 }

SparkleTime.damage = { min = 300, max = 500 }
SparkleTime.criticalChance = 0
SparkleTime.criticalMultiplier = 10
SparkleTime.price = 8000
SparkleTime.rebirth = 0
return SparkleTime