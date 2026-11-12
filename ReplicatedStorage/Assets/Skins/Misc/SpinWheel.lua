local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local SpinWheel = {}
SpinWheel.name = "SpinWheel"
SpinWheel.itemType = "SpinWheel"

function SpinWheel.image(_, _): string
	return "rbxassetid://99228639257848"
end
function SpinWheel.labelTop(p, _)
	local value = p.value

	if value > 1 then
		return value .. "x Spin"
	end

	return "Spin"
end

function SpinWheel.labelBottom(): string
	return "Wheel Tickets"
end
function SpinWheel.rarity(_, _): string
	return "TierSkip"
end

return SpinWheel