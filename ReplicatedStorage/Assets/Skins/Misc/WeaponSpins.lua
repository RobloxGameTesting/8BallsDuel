local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local WeaponSpins = {}
WeaponSpins.name = "Weapon Spins"
WeaponSpins.itemType = "Spins"

function WeaponSpins.image(p, _): string
	if p.value <= 1000 or p.value > 1000 and p.value <= 3000 or p.value > 3000 and p.value <= 8000 then
		return "rbxassetid://108082625519897"
	end

	if p.value > 8000 and p.value <= 15000 then
	end

	return "rbxassetid://108082625519897"
end

function WeaponSpins.labelTop(p, _)
	return NumberHelper:Separate(p.value)
end

function WeaponSpins.labelBottom(): string
	return "Weapon Spins"
end
function WeaponSpins.rarity(_, _): string
	return "Tier3"
end

return WeaponSpins