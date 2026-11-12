local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local Crawler = {}
Crawler.id = script.Name
Crawler.rarity = "Common"
Crawler.walkSpeed = 30
Crawler.crawlWalkSpeed = 8
Crawler.jumpHeight = 7
Crawler.health = 100
Crawler.canCrouch = true
Crawler.canDash = true
Crawler.description = "Your crawl speed when downed by zombies is much faster and allows you to get to safety."

function Crawler.onDealDamage(_): nil
	print("onDealDamage Crawler. No ability")
	return nil
end

function Crawler.onHealTeammate(_): nil
	print("onHealTeammate Crawler. No ability")
	return nil
end

function Crawler.onReviveTeammate(_): nil
	print("onReviveTeammate Crawler. No ability")
	return nil
end

function Crawler.onDayStart(_)
	print("onDayStart Crawler. No ability")
end

function Crawler.onNightStart(_)
	print("onNightStart Crawler. No ability")
end

function Crawler.onSpawn(_)
	print("onSpawn Crawler. No ability")
end

function Crawler.onHeal(_)
	print("onHeal Crawler. No ability")
end

function Crawler.onTakeDamage(_)
	print("onTakeDamage Crawler. No ability")
end

function Crawler.onDowned(_)
	print("onDowned Crawler. No ability")
end

function Crawler.onRevive(_)
	print("onRevive Crawler. No ability")
end

function Crawler.onJoin(_) end

function Crawler.onLeave(_)
	print("onLeave Crawler. No ability")
end

return Crawler