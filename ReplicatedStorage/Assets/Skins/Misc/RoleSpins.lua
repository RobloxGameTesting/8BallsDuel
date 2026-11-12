local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RoleSpins = {}
RoleSpins.name = "Role Spins"
RoleSpins.itemType = "Spins"

function RoleSpins.image(p, _): string
	if p.value <= 1000 or p.value > 1000 and p.value <= 3000 or p.value > 3000 and p.value <= 8000 then
		return "rbxassetid://115848569939216"
	end

	if p.value > 8000 and p.value <= 15000 then
	end

	return "rbxassetid://115848569939216"
end

function RoleSpins.labelTop(p, _)
	return NumberHelper:Separate(p.value)
end

function RoleSpins.labelBottom(): string
	return "Role Spins"
end
function RoleSpins.rarity(_, _): string
	return "Tier2"
end

return RoleSpins