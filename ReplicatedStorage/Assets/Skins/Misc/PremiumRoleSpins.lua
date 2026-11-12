local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PremiumRoleSpins = {}
PremiumRoleSpins.name = "Premium Weapon Spins"
PremiumRoleSpins.itemType = "Spins"

function PremiumRoleSpins.image(p, _): string
	if p.value <= 1000 or p.value > 1000 and p.value <= 3000 or p.value > 3000 and p.value <= 8000 then
		return "rbxassetid://107750175624542"
	end

	if p.value > 8000 and p.value <= 15000 then
	end

	return "rbxassetid://107750175624542"
end

function PremiumRoleSpins.labelTop(p, _)
	return NumberHelper:Separate(p.value)
end

function PremiumRoleSpins.labelBottom(): string
	return "Premium Role Spins"
end
function PremiumRoleSpins.rarity(_, _): string
	return "Tier7"
end

return PremiumRoleSpins