local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
game:GetService("TweenService")
local SocialService = game:GetService("SocialService")
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)

local LocalPlayer = Players.LocalPlayer
LocalPlayer:WaitForChild("PlayerGui")

local buttons = {}
local Invite = {}

function Invite.GetButtons()
	return buttons
end

function Invite.Enter() end

function Invite.Leave() end

function Invite.Toggle()
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(LocalPlayer)
	end)

	if success and result then
		pcall(function()
			SocialService:PromptGameInvite(LocalPlayer)
		end)
	end
end

return Invite