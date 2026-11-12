local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local FriendConstants = require(ReplicatedStorage.Libraries.Constants.FriendConstants)

local friendNotification = ReplicatedStorage.Assets.Notifications.FriendNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local description = FriendConstants.DESCRIPTION
local INVITE_MESSAGE_ID = FriendConstants.INVITE_MESSAGE_ID

local FriendNotification = {
	notification = friendNotification,
	canOverrideSelf = true,
	parent = "FriendNotificationPrompts"
}

function FriendNotification.new(notificationInstance)
	local clone = friendNotification:Clone()
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or FriendNotification.parent,
		maid = Maid.new()
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.PlayerIcon.Username.Text = notificationInstance.values.DisplayName
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)
	clone.Label.TextColor3 = notificationInstance.values.colour or Color3.fromRGB(255, 255, 255)

	task.spawn(function()
		local _, _ = pcall(function()
			local userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(
				v.notificationInstance.values.VisitorId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)

			if v2 and v.notificationLabel then
				v.notificationLabel.PlayerIcon.Image = userThumbnailAsync
			end
		end)
	end)

	return v
end

function FriendNotification.Show(data)
	data.notificationLabel.Position = UDim2.fromScale(0.5, 1.5)
	TweenService:Create(data.notificationLabel, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, 0)
	}):Play()

	data.maid.yield = Instance.new("BindableEvent")

	Button.Create(data.notificationLabel.Exit, function()
		data.maid.yield:Fire()
	end)

	Button.Create(data.notificationLabel.Invite, function()
		local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
		experienceInviteOptions.InviteUser = data.notificationInstance.values.VisitorId
		experienceInviteOptions.PromptMessage = description
		experienceInviteOptions.InviteMessageId = INVITE_MESSAGE_ID

		FriendHelper.PromptGameInvite(experienceInviteOptions)
		data.maid.yield:Fire()
	end)

	task.spawn(function()
		local v = 20

		while data.maid.yield and v >= 0 do
			v -= 1

			data.notificationLabel.Invite.Content.Timer.Text = NumberHelper.FormatTimerMS(v)
			task.wait(1)
		end

		if data.maid.yield then
			data.maid.yield:Fire()
		end
	end)

	data.maid.yield.Event:Wait()
	data.maid.yield = nil
end

function FriendNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0.5, 1.5)
	}):Play()

	task.wait(0.2)
end

function FriendNotification.Destroy(p)
	Button.Destroy(p.notificationLabel.Exit)
	Button.Destroy(p.notificationLabel.Invite)
	p.maid:Destroy()
	p.notificationLabel:Destroy()
end

return FriendNotification