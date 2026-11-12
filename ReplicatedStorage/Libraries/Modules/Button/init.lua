game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local HoverFunctions = require(script.HoverFunctions)

local LocalPlayer = Players.LocalPlayer
local Assets = ReplicatedStorage.Assets

local v = {}
local v2 = {}
Maid.new()
Maid.new()

local Button = {}

function Button.Release(p)
	v2[p] = nil
end

function Button.Press(p)
	v2[p] = true
end

function Button.GetPressing(p)
	return v2[p]
end

function Button.MouseEnter(p, p2: string?)
	if p2 then
		HoverFunctions[p2].mouseEnter(p)
	end
end

function Button.MouseLeave(p, p2: string?)
	Button.Release(p, true)

	if p2 then
		HoverFunctions[p2].mouseLeave(p)
	end
end

function Button.Create(instance, callback, p: string?)
	local v3 = v[instance] or Maid.new()
	v[instance] = v3
	local button = instance and instance:FindFirstChild("Button")

	assert(button, "Button not found")
	assert(button:IsA("GuiButton"), "Button is not a GuiButton")

	v3.downConnection = button.MouseButton1Down:Connect(function()
		Button.Press(instance, true)
	end)

	v3.upConnection = button.Activated:Connect(function()
		if Button.GetPressing(instance) then
			Button.Release(instance, true)
			UserInterfaceHelper.Shine()

			callback()
		end
	end)

	v3.enterConnection = button.MouseEnter:Connect(function()
		Button.MouseEnter(instance, p)
	end)

	v3.leaveConnection = button.MouseLeave:Connect(function()
		Button.MouseLeave(instance, p)
	end)
end

local v3 = {
	orange = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(242, 147, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(241, 90, 36))
	}),
	white = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 240, 240)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 190))
	}),
	green = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(136, 255, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 242, 0))
	}),
	yen = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 242, 67)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 204, 0))
	}),
	gift = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(205, 0, 241)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(111, 0, 190))
	}),
	blue = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 110, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 179, 255))
	}),
	red = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 0, 0))
	})
}

function Button.Color(instance, p: string)
	local color = v3[p]

	local content = instance:FindFirstChild("Content")
	local background = content and content:FindFirstChild("Background")
	local uiGradient = content and content:FindFirstChild("UIGradient")

	if uiGradient then
		uiGradient.Color = color
	elseif background and background:IsA("ImageLabel") then
		background.ImageColor3 = color.Keypoints[1].Value
	else
		warn(`UIGradient not found in {instance:GetFullName()}`)
	end
end

function Button.SetColours(items, p, value, value2)
	local v4 = value or "green"
	local v5 = value2 or "white"

	for k, item in items do
		if p == k then
			Button.Color(item, v4)
		else
			Button.Color(item, v5)
		end
	end
end

function Button.Destroy(p)
	v[p] = nil
end

return Button