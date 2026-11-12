local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("TweenService")
require(ReplicatedStorage.Types.NotificationTypes)

local LocalPlayer = Players.LocalPlayer
local notifications = script.Notifications
local bindableEvent = Instance.new("BindableEvent")

local Notifications = {
	notificationCount = 0,
	Added = bindableEvent.Event,
	activeNotifications = {}
}

function Notifications.new(childName, values)
	Notifications.notificationCount += 1
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local child = notifications:FindFirstChild(childName)

	local v = {
		notificationType = childName,
		moduleObject = child,
		visualInstance = nil,
		overrided = false,
		showedEvent = bindableEvent2,
		Showed = bindableEvent2.Event,
		hideEvent = bindableEvent3,
		Hidden = bindableEvent3.Event,
		values = values,
		layoutOrder = Notifications.notificationCount
	}

	local module = require(child)
	v.visualInstance = module.new(v)
	Notifications.Init(v)

	return v
end

function Notifications.Init(p)
	local _playerGui = LocalPlayer.PlayerGui
	local moduleObject = require(p.moduleObject)
	local activeNotification = Notifications.activeNotifications[p.notificationType]

	if activeNotification and not moduleObject.canOverrideSelf then
		Notifications.Override(activeNotification)
	end

	Notifications.activeNotifications[p.notificationType] = p
	bindableEvent:Fire(p.notificationType)

	task.spawn(function()
		Notifications.Show(p)
		Notifications.Hide(p)
	end)
end

function Notifications.Show(data)
	local moduleObject = require(data.moduleObject)
	moduleObject.Show(data.visualInstance)
	data.showedEvent:Fire()
end

function Notifications.Hide(data)
	local moduleObject = require(data.moduleObject)
	moduleObject.Hide(data.visualInstance)
	data.hideEvent:Fire()
	Notifications.Destroy(data)
end

function Notifications:Override()
	self.visualInstance.notificationLabel.Visible = false
	self.overrided = true
	Notifications.activeNotifications[self.notificationType] = nil
end

function Notifications.Destroy(data)
	if not data.overrided then
		Notifications.activeNotifications[data.notificationType] = nil
	end

	local moduleObject = require(data.moduleObject)
	moduleObject.Destroy(data.visualInstance)
	data.showedEvent:Destroy()
	data.hideEvent:Destroy()
end

return Notifications