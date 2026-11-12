local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local alertNotification = ReplicatedStorage.Assets.Notifications.AlertNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local AlertNotification = {
	notification = alertNotification,
	canOverrideSelf = true,
	parent = "AlertNotifications"
}

function AlertNotification.new(notificationInstance)
	local clone = alertNotification:Clone()
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or AlertNotification.parent
	}

	clone.Background.BackgroundColor3 = notificationInstance.values.colour
	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Label.Text = notificationInstance.values.message
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)

	return v
end

function AlertNotification.Show(p)
	if p.notificationInstance.values.audio then
		Sounds.Play(Sounds.new(p.notificationInstance.values.audio, nil), nil, true)
	end

	task.wait(p.notificationInstance.values.length or 3)
end

function AlertNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	task.wait(0.2)
end

function AlertNotification:Destroy()
	self.notificationLabel:Destroy()
end

return AlertNotification