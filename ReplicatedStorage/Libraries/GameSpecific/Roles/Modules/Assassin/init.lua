local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
require(ReplicatedStorage.Libraries.GameSpecific.Tools.ToolTypes)
local Assassin = {}
Assassin.id = script.Name
Assassin.rarity = "Legendary"
Assassin.walkSpeed = 33
Assassin.crawlWalkSpeed = 2
Assassin.jumpHeight = 9
Assassin.health = 90
Assassin.canCrouch = true
Assassin.canDash = true
Assassin.description = "Gives you extra jump and walk speed and melee attacks deal double damage. You lose 10 health"

function Assassin.onDealDamage(_, p, p2)
	if p == "Melee" then
		return p2 * 2
	end

	return nil
end

function Assassin.onHealTeammate(_): nil
	return nil
end

function Assassin.onReviveTeammate(_): nil
	return nil
end

function Assassin.onDayStart(_) end

function Assassin.onNightStart(_) end

function Assassin.onSpawn(_) end

function Assassin.onHeal(_) end

function Assassin.onTakeDamage(_) end

function Assassin.onDowned(_) end

function Assassin.onRevive(_) end

function Assassin.onJoin(_) end

function Assassin.onLeave(_) end

return Assassin