local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Types.NotificationTypes)
local Players = game:GetService("Players")

local goalNotification = ReplicatedStorage.Assets.Notifications.GoalNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local GoalNotification = {
	notification = goalNotification,
	canOverrideSelf = true,
	parent = "GoalNotifications"
}

local function explodeText(p)
	local goal = p.notificationLabel:FindFirstChild("Main")
		and p.notificationLabel:FindFirstChild("Main"):FindFirstChild("Goal")
	local shadow = p.notificationLabel:FindFirstChild("Shadow")

	if not (goal and goal:IsA("GuiObject") and shadow and shadow:IsA("GuiObject")) then
		return
	end

	goal.Position = UDim2.new(0.5, 0, 0.5, 0)
	goal.Size = UDim2.new(0.5, 0, 0, 0)
	TweenService:Create(goal, TweenInfo.new(1.5, Enum.EasingStyle.Elastic), {
		Size = UDim2.new(1, 0, 0.7, 0)
	}):Play()
	task.wait(1.5)
	TweenService:Create(goal, TweenInfo.new(0.5), { Position = UDim2.new(0.5, 0, 1.5, 0) }):Play()
	task.wait(0.5)
end

local function text(p, text2, duration, p2)
	local label = p.notificationLabel:FindFirstChild("Main")
		and p.notificationLabel:FindFirstChild("Main"):FindFirstChild("Label")

	if not (label and label:IsA("TextLabel")) then
		return
	end

	label.Visible = true
	label.Text = text2
	label.Position = UDim2.new(0.5, 0, -0.4, 0)
	TweenService:Create(label, TweenInfo.new(0.5), { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
	task.wait(duration)

	if p2 then
		TweenService:Create(label, TweenInfo.new(0.5), { Position = UDim2.new(0.5, 0, 1.4, 0) }):Play()
		task.wait(0.5)
	end
end

function GoalNotification.new(notificationInstance)
	local clone = goalNotification:Clone()
	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = notificationInstance.values.parent or GoalNotification.parent
	}

	local color = notificationInstance.values.team == "Blue" and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
	clone.Shadow.ImageColor3 = color
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)

	return v
end

function GoalNotification.Show(p)
	local kicker = p.notificationInstance.values.kicker
	local assister = p.notificationInstance.values.assister
	local magnitude = p.notificationInstance.values.magnitude
	local label = p.notificationLabel:FindFirstChild("Main")
		and p.notificationLabel:FindFirstChild("Main"):FindFirstChild("Label")
	local shadow = p.notificationLabel:FindFirstChild("Shadow")

	if not (label and label:IsA("TextLabel") and shadow and shadow:IsA("GuiObject")) then
		return
	end

	TweenService:Create(
		p.notificationLabel,
		TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
		{
			Rotation = Random.new():NextInteger(-10, 10)
		}
	):Play()

	label.Visible = false
	shadow.Size = UDim2.new(shadow.Size.X.Scale, 0, 0, 0)
	TweenService:Create(shadow, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
		Size = UDim2.new(shadow.Size.X.Scale, 0, 0.99, 0)
	}):Play()

	explodeText(p)

	if kicker then
		text(p, kicker.Name, 2, true)
	end

	if assister then
		text(p, assister.Name, 2, true)
	end

	if magnitude then
		text(p, "Distance: " .. math.floor(magnitude / 2.47) .. "m", 2, false)
	end
end

function GoalNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(1), { Position = UDim2.new(0, 0, 1, 0) }):Play()

	task.wait(1)
end

function GoalNotification:Destroy()
	self.notificationLabel:Destroy()
end

return GoalNotification