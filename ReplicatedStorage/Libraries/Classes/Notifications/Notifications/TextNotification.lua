local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local textNotification = ReplicatedStorage.Assets.Notifications.TextNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local TextNotification = {
	notification = textNotification,
	canOverrideSelf = true,
	parent = "MiddleNotifications"
}

function TextNotification.new(notificationInstance)
	local clone = textNotification:Clone()
	clone.Name = Random.new():NextInteger(1, 100)
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or TextNotification.parent
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Label.Text = notificationInstance.values.message
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)
	clone.Label.TextColor3 = notificationInstance.values.colour or Color3.fromRGB(255, 255, 255)

	return v
end

function TextNotification.Show(p)
	if p.notificationInstance.values.audio then
		Sounds.Play(Sounds.new(p.notificationInstance.values.audio, nil), nil, true)
	end

	task.wait(p.notificationInstance.values.length or 3)
end

function TextNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	task.wait(0.2)
end

function TextNotification:Destroy()
	self.notificationLabel:Destroy()
end

return TextNotification