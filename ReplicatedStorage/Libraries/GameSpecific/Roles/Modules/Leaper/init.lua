local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Leaper = {}
Leaper.id = script.Name
Leaper.rarity = "Common"
Leaper.walkSpeed = 30
Leaper.crawlWalkSpeed = 2
Leaper.jumpHeight = 12
Leaper.health = 100
Leaper.canCrouch = true
Leaper.canDash = true
Leaper.description = "Your jump height is heavily increased"

function Leaper.onDealDamage(_): nil
	print("onDealDamage Citizen. No ability")
	return nil
end

function Leaper.onHealTeammate(_): nil
	print("onHealTeammate Citizen. No ability")
	return nil
end

function Leaper.onReviveTeammate(_): nil
	print("onReviveTeammate Citizen. No ability")
	return nil
end

function Leaper.onDayStart(_)
	print("onDayStart Citizen. No ability")
end

function Leaper.onNightStart(_)
	print("onNightStart Citizen. No ability")
end

function Leaper.onSpawn(_)
	print("onSpawn Citizen. No ability")
end

function Leaper.onHeal(_)
	print("onHeal Citizen. No ability")
end

function Leaper.onTakeDamage(_)
	print("onTakeDamage Citizen. No ability")
end

function Leaper.onDowned(_)
	print("onDowned Citizen. No ability")
end

function Leaper.onRevive(_)
	print("onRevive Citizen. No ability")
end

function Leaper.onJoin(_) end

function Leaper.onLeave(_)
	print("onLeave Citizen. No ability")
end

return Leaper