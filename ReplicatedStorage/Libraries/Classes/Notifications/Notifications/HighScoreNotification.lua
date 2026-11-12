local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local highScoreNotification = ReplicatedStorage.Assets.Notifications.HighScoreNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local HighScoreNotification = {
	notification = highScoreNotification,
	canOverrideSelf = true,
	parent = "HighScoreNotifications"
}

function HighScoreNotification.new(notificationInstance)
	local clone = highScoreNotification:Clone()
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or HighScoreNotification.parent
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Frame.Label.Text = notificationInstance.values.message
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)
	clone.Frame.Background.ImageColor3 = notificationInstance.values.colour or Color3.fromRGB(255, 255, 255)

	return v
end

function HighScoreNotification.Show(p)
	if p.notificationInstance.values.audio then
		Sounds.Play(Sounds.new(p.notificationInstance.values.audio, nil), nil, true)
	end

	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 1, 0) }):Play()
	task.wait(p.notificationInstance.values.length or 3)
end

function HighScoreNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	task.wait(0.2)
end

function HighScoreNotification:Destroy()
	self.notificationLabel:Destroy()
end

return HighScoreNotification