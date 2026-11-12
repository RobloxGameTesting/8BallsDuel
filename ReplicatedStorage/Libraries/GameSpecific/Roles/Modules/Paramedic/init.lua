local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Paramedic = {}
Paramedic.id = script.Name
Paramedic.rarity = "Common"
Paramedic.walkSpeed = 30
Paramedic.crawlWalkSpeed = 2
Paramedic.jumpHeight = 7
Paramedic.health = 100
Paramedic.canCrouch = true
Paramedic.canDash = true
Paramedic.description = "You revive teammates double the normal speed"

function Paramedic.onDealDamage(_): nil
	print("onDealDamage Citizen. No ability")
	return nil
end

function Paramedic.onHealTeammate(_): nil
	print("onHealTeammate Citizen. No ability")
	return nil
end

function Paramedic.onReviveTeammate(_, p)
	return p * 2
end

function Paramedic.onDayStart(_)
	print("onDayStart Citizen. No ability")
end

function Paramedic.onNightStart(_)
	print("onNightStart Citizen. No ability")
end

function Paramedic.onSpawn(_)
	print("onSpawn Citizen. No ability")
end

function Paramedic.onHeal(_)
	print("onHeal Citizen. No ability")
end

function Paramedic.onTakeDamage(_)
	print("onTakeDamage Citizen. No ability")
end

function Paramedic.onDowned(_)
	print("onDowned Citizen. No ability")
end

function Paramedic.onRevive(_)
	print("onRevive Citizen. No ability")
end

function Paramedic.onJoin(_) end

function Paramedic.onLeave(_)
	print("onLeave Citizen. No ability")
end

return Paramedic