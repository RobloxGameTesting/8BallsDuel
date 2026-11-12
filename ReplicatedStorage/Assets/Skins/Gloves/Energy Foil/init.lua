game:GetService("ReplicatedStorage")
local EnergyFoil = {}
EnergyFoil.name = "Energy Foil"
EnergyFoil.itemType = "Glove"
EnergyFoil.instance = script:FindFirstChildWhichIsA("Tool")
function EnergyFoil.rarity(_, _): string
	return "Tier1"
end

function EnergyFoil.labelTop(_, p)
	return p.name
end

function EnergyFoil.labelBottom(_, p)
	return p.itemType
end

function EnergyFoil.image(_, _): string
	return "rbxassetid://109016591110837"
end

EnergyFoil.animations = { idle = 120250643826676, swing = 13721851561 }

EnergyFoil.damage = { min = 14000, max = 18000 }
EnergyFoil.criticalChance = 0
EnergyFoil.criticalMultiplier = 10
EnergyFoil.price = 5000000
EnergyFoil.rebirth = 2
return EnergyFoil