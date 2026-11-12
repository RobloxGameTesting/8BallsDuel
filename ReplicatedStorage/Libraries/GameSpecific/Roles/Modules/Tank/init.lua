local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Tank = {}
Tank.id = script.Name
Tank.rarity = "Specialization"
Tank.walkSpeed = 25
Tank.crawlWalkSpeed = 2
Tank.jumpHeight = 7
Tank.health = 150
Tank.canCrouch = true
Tank.canDash = true
Tank.description = "Grants you a bonus +50 max health and -5 walking speed"

function Tank.onDealDamage(_): nil
	print("onDealDamage Citizen. No ability")
	return nil
end

function Tank.onHealTeammate(_): nil
	print("onHealTeammate Citizen. No ability")
	return nil
end

function Tank.onReviveTeammate(_): nil
	print("onReviveTeammate Citizen. No ability")
	return nil
end

function Tank.onDayStart(_)
	print("onDayStart Citizen. No ability")
end

function Tank.onNightStart(_)
	print("onNightStart Citizen. No ability")
end

function Tank.onSpawn(_)
	print("onSpawn Citizen. No ability")
end

function Tank.onHeal(_)
	print("onHeal Citizen. No ability")
end

function Tank.onTakeDamage(_)
	print("onTakeDamage Citizen. No ability")
end

function Tank.onDowned(_)
	print("onDowned Citizen. No ability")
end

function Tank.onRevive(_)
	print("onRevive Citizen. No ability")
end

function Tank.onJoin(_) end

function Tank.onLeave(_)
	print("onLeave Citizen. No ability")
end

return Tank