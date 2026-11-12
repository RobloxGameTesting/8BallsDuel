local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Device)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
require(ReplicatedStorage.Types.Types)

local userId = tostring(Players.LocalPlayer.UserId)
local bindableFunction = Instance.new("BindableFunction")

if not FriendHelper.CanSendInvite(userId) then
	return
end

local v = nil

function bindableFunction.OnInvoke(p)
	if p == "Invite" then
		local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
		experienceInviteOptions.InviteUser = v.VisitorId
		experienceInviteOptions.PromptMessage = "Get a +10% boost when " .. v.DisplayName .. " joins! Would you like to invite them?"
		experienceInviteOptions.InviteMessageId = "897d0a23-cc3f-1a4d-9d32-659224c9e4d6"

		FriendHelper.PromptGameInvite(experienceInviteOptions)
	end
end
FriendHelper.GetOnlineFriends(userId)

Menu.Opened:Connect(function(p)
	if p == "Results" then
		local onlineFriends = FriendHelper.GetOnlineFriends(userId)

		v = onlineFriends[Random.new():NextInteger(1, #onlineFriends)]

		if not v then
			return
		end

		local userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(
			v.VisitorId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size150x150
		)

		StarterGui:SetCore("SendNotification", {
			Title = "Notification",
			Text = "Invite your friend " .. v.DisplayName .. "?",
			Icon = not v2 and "" or userThumbnailAsync,
			Duration = 3,
			Callback = bindableFunction,
			Button1 = "Invite",
			Button2 = "No"
		})
	end
end)