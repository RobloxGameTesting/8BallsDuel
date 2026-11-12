local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)
local Morning = {}
Morning.id = script.Name
Morning.rarity = "Rare"
Morning.walkSpeed = 30
Morning.crawlWalkSpeed = 2
Morning.jumpHeight = 7
Morning.health = 100
Morning.canCrouch = true
Morning.canDash = true
Morning.description = "Every sunrise you get +50 health regeneration"

function Morning.onDealDamage(_): nil
	return nil
end

function Morning.onHealTeammate(_): nil
	return nil
end

function Morning.onReviveTeammate(_): nil
	return nil
end

function Morning.onDayStart(p)
	HealthHandler.Heal(nil, p, 50)
end

function Morning.onNightStart(_) end

function Morning.onSpawn(_) end

function Morning.onHeal(_) end

function Morning.onTakeDamage(_) end

function Morning.onDowned(_) end

function Morning.onRevive(_) end

function Morning.onJoin(_) end

function Morning.onLeave(_) end

return Morning