local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Healer = {}
Healer.id = script.Name
Healer.rarity = "Rare"
Healer.walkSpeed = 30
Healer.crawlWalkSpeed = 2
Healer.jumpHeight = 7
Healer.health = 100
Healer.canCrouch = true
Healer.canDash = true
Healer.description = "Your healing items do double the healing. Healing teammates is also doubled."

function Healer.onDealDamage(_): nil
	return nil
end

function Healer.onHealTeammate(_, p)
	return p * 2
end

function Healer.onReviveTeammate(_): nil
	return nil
end

function Healer.onDayStart(_) end

function Healer.onNightStart(_) end

function Healer.onSpawn(_) end

function Healer.onHeal(_) end

function Healer.onTakeDamage(_) end

function Healer.onDowned(_) end

function Healer.onRevive(_) end

function Healer.onJoin(_) end

function Healer.onLeave(_) end

return Healer