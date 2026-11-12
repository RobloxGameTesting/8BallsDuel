game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local roleNotification = ReplicatedStorage.Assets.Notifications.RoleNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local RoleNotification = {
	notification = roleNotification,
	canOverrideSelf = true,
	parent = "RoleNotifications"
}

function RoleNotification.new(notificationInstance)
	local clone = roleNotification:Clone()
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or RoleNotification.parent
	}

	clone.Label.Text = ""
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)

	return v
end

function RoleNotification.Show(p)
	local label = p.notificationLabel:FindFirstChild("Label")

	for i = 1, 12 do
		if i % 2 == 0 then
			label.Text = "???"
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			label.Text = Random.new():NextInteger(1, 2) == 1 and "Admin" or "Player"

			if label.Text == "Admin" then
				label.TextColor3 = Color3.fromRGB(255, 0, 0)
			else
				label.TextColor3 = Color3.fromRGB(0, 255, 0)
			end
		end

		Sounds.Play(Sounds.new({ "Freebie" }, nil), nil, true)
		task.wait(0.2)
	end

	label.Text = p.notificationInstance.values.role
	label.TextColor3 = Color3.fromRGB(255, 0, 0)

	if p.notificationInstance.values.role == "Player" then
		Sounds.Play(Sounds.new({ "Feel", "BasicReward" }, nil), nil, true)
	elseif p.notificationInstance.values.role == "Admin" then
		Sounds.Play(Sounds.new({ "Feel", "Ding" }, nil), nil, true)
		Sounds.Play(Sounds.new({ "Feel", "BasicReward" }, nil), nil, true)
		Sounds.Play(Sounds.new({ "Feel", "LevelUp2" }, nil), nil, true)
	end

	task.wait(p.notificationInstance.values.length or 3)
end

function RoleNotification.Hide(_) end

function RoleNotification:Destroy()
	self.notificationLabel:Destroy()
end

return RoleNotification