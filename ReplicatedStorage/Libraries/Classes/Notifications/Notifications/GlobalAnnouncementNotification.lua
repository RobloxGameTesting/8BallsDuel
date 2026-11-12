local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local globalAnnouncementNotification = ReplicatedStorage.Assets.Notifications.GlobalAnnouncementNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local GlobalAnnouncementNotification = {
	notification = globalAnnouncementNotification,
	canOverrideSelf = true,
	parent = "TopNotificationLabel"
}

function GlobalAnnouncementNotification.new(notificationInstance)
	local clone = globalAnnouncementNotification:Clone()
	clone.Name = Random.new():NextInteger(1, 100)
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or GlobalAnnouncementNotification.parent
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Label.Text = notificationInstance.values.message
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)
	clone.Label.TextColor3 = notificationInstance.values.colour or Color3.fromRGB(255, 255, 255)

	return v
end

function GlobalAnnouncementNotification.Show(p)
	if p.notificationInstance.values.audio then
		Sounds.Play(Sounds.new(p.notificationInstance.values.audio, nil), nil, true)
	end

	task.wait(p.notificationInstance.values.length or 3)
end

function GlobalAnnouncementNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	task.wait(0.2)
end

function GlobalAnnouncementNotification:Destroy()
	self.notificationLabel:Destroy()
end

return GlobalAnnouncementNotification