local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Bulldozer = {}
Bulldozer.id = script.Name
Bulldozer.rarity = "Rare"
Bulldozer.walkSpeed = 30
Bulldozer.crawlWalkSpeed = 2
Bulldozer.jumpHeight = 7
Bulldozer.health = 100
Bulldozer.canCrouch = true
Bulldozer.canDash = true
Bulldozer.description = "Grants a 5% damage buff with all weapons against all enemies"

function Bulldozer.onDealDamage(_, _, p)
	return p * 1.05
end

function Bulldozer.onHealTeammate(_, _): nil
	return nil
end

function Bulldozer.onReviveTeammate(_, _): nil
	return nil
end

function Bulldozer.onDayStart(_)
	print("onDayStart Bulldozer. No ability")
end

function Bulldozer.onNightStart(_)
	print("onNightStart Bulldozer. No ability")
end

function Bulldozer.onSpawn(_)
	print("onSpawn Bulldozer. No ability")
end

function Bulldozer.onHeal(_)
	print("onHeal Bulldozer. No ability")
end

function Bulldozer.onTakeDamage(_)
	print("onTakeDamage Bulldozer. No ability")
end

function Bulldozer.onDowned(_)
	print("onDowned Bulldozer. No ability")
end

function Bulldozer.onRevive(_)
	print("onRevive Bulldozer. No ability")
end

function Bulldozer.onJoin(_) end

function Bulldozer.onLeave(_)
	print("onLeave Bulldozer. No ability")
end

return Bulldozer