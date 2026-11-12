local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PremiumWeaponSpins = {}
PremiumWeaponSpins.name = "Premium Weapon Spins"
PremiumWeaponSpins.itemType = "Spins"

function PremiumWeaponSpins.image(p, _): string
	if p.value <= 1000 or p.value > 1000 and p.value <= 3000 or p.value > 3000 and p.value <= 8000 then
		return "rbxassetid://138674914338446"
	end

	if p.value > 8000 and p.value <= 15000 then
	end

	return "rbxassetid://138674914338446"
end

function PremiumWeaponSpins.labelTop(p, _)
	return NumberHelper:Separate(p.value)
end

function PremiumWeaponSpins.labelBottom(): string
	return "Premium Weapon Spins"
end
function PremiumWeaponSpins.rarity(_, _): string
	return "Tier6"
end

return PremiumWeaponSpins