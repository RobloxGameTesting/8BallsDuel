game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BadgeService = game:GetService("BadgeService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

RunService:IsServer()

local Badges = { badges = {} }

function Badges.GetBadges(p)
	return p.badges
end

function Badges.GetBadgeIdData(_, p)
	local success, result = pcall(function()
		return BadgeService:GetBadgeInfoAsync(p)
	end)

	return success, result
end

function Badges.AwardBadgeId(_, p, p2)
	local userId = tostring(p.UserId)
	local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)

	local success, result = pcall(function()
		return BadgeService:AwardBadgeAsync(p.UserId, p2)
	end)

	if not success then
		warn("Error while awarding badge:", result)
	elseif result and v and (not v or v:IsActive()) then
		v:Write("Badges", p2)
	end
end

return Badges