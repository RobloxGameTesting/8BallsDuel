local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Citizen = {}
Citizen.id = script.Name
Citizen.rarity = "Common"
Citizen.walkSpeed = 30
Citizen.crawlWalkSpeed = 2
Citizen.jumpHeight = 7
Citizen.health = 100
Citizen.canCrouch = true
Citizen.canDash = true
Citizen.description = "The default role with no special traits or abilities"

function Citizen.onDealDamage(_): nil
	print("onDealDamage Citizen. No ability")
	return nil
end

function Citizen.onHealTeammate(_): nil
	print("onHealTeammate Citizen. No ability")
	return nil
end

function Citizen.onReviveTeammate(_): nil
	print("onReviveTeammate Citizen. No ability")
	return nil
end

function Citizen.onDayStart(_)
	print("onDayStart Citizen. No ability")
end

function Citizen.onNightStart(_)
	print("onNightStart Citizen. No ability")
end

function Citizen.onSpawn(_)
	print("onSpawn Citizen. No ability")
end

function Citizen.onHeal(_)
	print("onHeal Citizen. No ability")
end

function Citizen.onTakeDamage(_)
	print("onTakeDamage Citizen. No ability")
end

function Citizen.onDowned(_)
	print("onDowned Citizen. No ability")
end

function Citizen.onRevive(_)
	print("onRevive Citizen. No ability")
end

function Citizen.onJoin(_) end

function Citizen.onLeave(_)
	print("onLeave Citizen. No ability")
end

return Citizen