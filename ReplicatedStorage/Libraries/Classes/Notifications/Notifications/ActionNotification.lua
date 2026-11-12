local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local KeybindHelper = require(ReplicatedStorage.Libraries.Helpers.KeybindHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)

local actionNotification = ReplicatedStorage.Assets.Notifications.ActionNotification
local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ActionNotification = {
	notification = actionNotification,
	canOverrideSelf = true,
	parent = "TutorialNotifications"
}

function ActionNotification.new(notificationInstance)
	local clone = actionNotification:Clone()
	local v2 = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or ActionNotification.parent
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Message.Text = notificationInstance.values.message
	local v3 = nil

	if Device:Get() == "Desktop" then
		v3 = KeybindHelper:ConvertValueToDesktop(v, notificationInstance.values.action).Name
	elseif Device:Get() == "Console" then
		v3 = KeybindHelper:ConvertValueToConsole(v, notificationInstance.values.action).Name
	elseif Device:Get() == "Mobile" then
		v3 = KeybindHelper:ConvertValueToMobile(v, notificationInstance.values.action)
	end

	clone.Action.Keybind:SetAttribute("Keybind", v3)
	clone.Parent = PlayerGui:FindFirstChild(v2.parent, true)
	return v2
end

function ActionNotification.Show(p)
	task.wait(p.notificationInstance.values.length or 3)
end

function ActionNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	task.wait(0.2)
end

function ActionNotification:Destroy()
	self.notificationLabel:Destroy()
end

return ActionNotification