local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Exterminator = {}
Exterminator.id = script.Name
Exterminator.rarity = "Legendary"
Exterminator.walkSpeed = 30
Exterminator.crawlWalkSpeed = 2
Exterminator.jumpHeight = 7
Exterminator.health = 100
Exterminator.canCrouch = true
Exterminator.canDash = true
Exterminator.description = "Grants a 10% damage buff with all weapons against all enemies"

function Exterminator.onDealDamage(_, _, p)
	return p * 1.1
end

function Exterminator.onHealTeammate(_, _): nil
	return nil
end

function Exterminator.onReviveTeammate(_, _): nil
	return nil
end

function Exterminator.onDayStart(_)
	print("onDayStart Bulldozer. No ability")
end

function Exterminator.onNightStart(_)
	print("onNightStart Bulldozer. No ability")
end

function Exterminator.onSpawn(_)
	print("onSpawn Bulldozer. No ability")
end

function Exterminator.onHeal(_)
	print("onHeal Bulldozer. No ability")
end

function Exterminator.onTakeDamage(_)
	print("onTakeDamage Bulldozer. No ability")
end

function Exterminator.onDowned(_)
	print("onDowned Bulldozer. No ability")
end

function Exterminator.onRevive(_)
	print("onRevive Bulldozer. No ability")
end

function Exterminator.onJoin(_) end

function Exterminator.onLeave(_)
	print("onLeave Bulldozer. No ability")
end

return Exterminator