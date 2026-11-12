local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local ExterminatorX = {}
ExterminatorX.id = script.Name
ExterminatorX.rarity = "Insignia"
ExterminatorX.walkSpeed = 30
ExterminatorX.crawlWalkSpeed = 2
ExterminatorX.jumpHeight = 7
ExterminatorX.health = 100
ExterminatorX.canCrouch = true
ExterminatorX.canDash = true
ExterminatorX.description = "Grants a 20% damage buff with all weapons against all enemies"

function ExterminatorX.onDealDamage(_, _, p)
	return p * 1.2
end

function ExterminatorX.onHealTeammate(_, _): nil
	return nil
end

function ExterminatorX.onReviveTeammate(_, _): nil
	return nil
end

function ExterminatorX.onDayStart(_)
	print("onDayStart Bulldozer. No ability")
end

function ExterminatorX.onNightStart(_)
	print("onNightStart Bulldozer. No ability")
end

function ExterminatorX.onSpawn(_)
	print("onSpawn Bulldozer. No ability")
end

function ExterminatorX.onHeal(_)
	print("onHeal Bulldozer. No ability")
end

function ExterminatorX.onTakeDamage(_)
	print("onTakeDamage Bulldozer. No ability")
end

function ExterminatorX.onDowned(_)
	print("onDowned Bulldozer. No ability")
end

function ExterminatorX.onRevive(_)
	print("onRevive Bulldozer. No ability")
end

function ExterminatorX.onJoin(_) end

function ExterminatorX.onLeave(_)
	print("onLeave Bulldozer. No ability")
end

return ExterminatorX