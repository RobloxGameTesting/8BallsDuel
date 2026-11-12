local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Colours)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local InviteRewardProgress = {}
InviteRewardProgress.name = "InviteRewardProgress"
InviteRewardProgress.itemType = "InviteRewardProgress"

function InviteRewardProgress.image(_, _): string
	return "rbxassetid://104460407358065"
end
function InviteRewardProgress.labelTop(p, _)
	return "+" .. p.value
end

function InviteRewardProgress.labelBottom(_, _): string
	return "Invite Points"
end
function InviteRewardProgress.rarity(_, _): string
	return "Tier1"
end

return InviteRewardProgress