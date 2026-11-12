local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local killFeedNotification = ReplicatedStorage.Assets.Notifications.KillFeedNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local KillFeedNotification = {
	notification = killFeedNotification,
	canOverrideSelf = true,
	parent = "KillsNotifications"
}

function KillFeedNotification.new(notificationInstance)
	local clone = killFeedNotification:Clone()
	clone.Name = Random.new():NextInteger(1, 100)
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or KillFeedNotification.parent
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Label.Text = notificationInstance.values.message
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)
	clone.Label.TextColor3 = notificationInstance.values.colour or Color3.fromRGB(255, 255, 255)

	return v
end

function KillFeedNotification.Show(p)
	if p.notificationInstance.values.audio then
		Sounds.Play(Sounds.new(p.notificationInstance.values.audio, nil), nil, true)
	end

	task.wait(p.notificationInstance.values.length or 1)
end

function KillFeedNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	task.wait(0.2)
end

function KillFeedNotification:Destroy()
	self.notificationLabel:Destroy()
end

return KillFeedNotification