local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Sounds)

local regionNotification = ReplicatedStorage.Assets.Notifications.RegionNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local RegionNotification = {
	notification = regionNotification,
	canOverrideSelf = false,
	parent = "RegionNotifications"
}

function RegionNotification.new(notificationInstance)
	local clone = regionNotification:Clone()
	clone.Name = Random.new():NextInteger(1, 100)
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or RegionNotification.parent
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Label.Text = notificationInstance.values.message
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)
	clone.Label.TextColor3 = notificationInstance.values.colour or Color3.fromRGB(255, 255, 255)

	return v
end

function RegionNotification.Show(p)
	local notificationLabel = p.notificationLabel

	TweenService:Create(notificationLabel.Header, TweenInfo.new(2), { TextTransparency = 0 }):Play()
	TweenService:Create(notificationLabel.Label, TweenInfo.new(2), { TextTransparency = 0 }):Play()

	TweenService:Create(notificationLabel.Highlight1, TweenInfo.new(2), {
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(notificationLabel.Highlight2, TweenInfo.new(2), {
		BackgroundTransparency = 0
	}):Play()

	for _, instance in {
		notificationLabel.Header.UIStroke,
		notificationLabel.Label.UIStroke,
		notificationLabel.Highlight1.UIStroke,
		notificationLabel.Highlight2.UIStroke
	} do
		TweenService:Create(instance, TweenInfo.new(2), { Transparency = 0 }):Play()
	end

	task.wait(p.notificationInstance.values.length or 3)
end

function RegionNotification.Hide(p)
	local notificationLabel = p.notificationLabel
	TweenService:Create(notificationLabel.Header, TweenInfo.new(2), { TextTransparency = 1 }):Play()
	TweenService:Create(notificationLabel.Label, TweenInfo.new(2), { TextTransparency = 1 }):Play()

	TweenService:Create(notificationLabel.Highlight1, TweenInfo.new(2), {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(notificationLabel.Highlight2, TweenInfo.new(2), {
		BackgroundTransparency = 1
	}):Play()

	for _, instance in {
		notificationLabel.Header.UIStroke,
		notificationLabel.Label.UIStroke,
		notificationLabel.Highlight1.UIStroke,
		notificationLabel.Highlight2.UIStroke
	} do
		TweenService:Create(instance, TweenInfo.new(2), { Transparency = 1 }):Play()
	end

	task.wait(2)
end

function RegionNotification:Destroy()
	self.notificationLabel:Destroy()
end

return RegionNotification