local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Roles.RoleTypes)
local PlaceHelper = require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
local ZRay = {}
ZRay.id = script.Name
ZRay.rarity = "Insignia"
ZRay.walkSpeed = 30
ZRay.crawlWalkSpeed = 2
ZRay.jumpHeight = 7
ZRay.health = 100
ZRay.canCrouch = true
ZRay.canDash = true
ZRay.description = "Allows you and also your teammates to see zombies through walls"

function ZRay.onDealDamage(_): nil
	return nil
end

function ZRay.onHealTeammate(_): nil
	return nil
end

function ZRay.onReviveTeammate(_): nil
	return nil
end

function ZRay.onDayStart(_) end

function ZRay.onNightStart(_) end

function ZRay.onSpawn(_) end

function ZRay.onHeal(_) end

function ZRay.onTakeDamage(_) end

function ZRay.onDowned(_) end

function ZRay.onRevive(_) end

function ZRay.onJoin(_)
	if PlaceHelper.GetPlaceType() ~= "Game" then
		return
	end

	local enemies = workspace.Contents.Enemies

	enemies.Highlight.Enabled = true

	enemies.Highlight:GetPropertyChangedSignal("Enabled"):Connect(function()
		enemies.Highlight.Enabled = true
	end)
end

function ZRay.onLeave(_) end

return ZRay