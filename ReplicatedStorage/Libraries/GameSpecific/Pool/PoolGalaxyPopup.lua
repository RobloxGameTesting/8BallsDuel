local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolGalaxyPanel = require(Pool.PoolGalaxyPanel)

local PoolGalaxyPopup = {}

local color = Color3.fromRGB(42, 42, 46)

local v = {
	Back = color,
	Wash = ColorSequence.new(color),
	WashTransparency = 0,
	Outline = Color3.new(0, 0, 0),
	Burst = Color3.fromRGB(255, 236, 170),
	NameGradient = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 226, 150)),
	TextStroke = Color3.fromRGB(16, 6, 22),
	Count = Color3.fromRGB(255, 244, 228)
}

local function need(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolGalaxyPopup: %s.%s is missing (looking for %q)",
					instance:GetFullName(),
					value,
					childName
				),
				2
			)
		end
	end

	return child
end

function PoolGalaxyPopup.new(p)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local v2 = need(p, "GalaxyPopup")
	local v3 = need(v2, "Card")
	local v4 = need(v3, "Body")
	local close = need(v3, "Close")

	v2.Visible = false
	v2.Active = true

	if not v2:FindFirstChild("InputSink") then
		local inputSink = Instance.new("TextButton")
		inputSink.Name = "InputSink"
		inputSink.Size = UDim2.fromScale(1, 1)
		inputSink.Position = UDim2.fromScale(0, 0)
		inputSink.BackgroundTransparency = 1
		inputSink.BorderSizePixel = 0
		inputSink.Text = ""
		inputSink.AutoButtonColor = false
		inputSink.Selectable = false

		inputSink.ZIndex = v2.ZIndex
		inputSink.Parent = v2
	end

	local uiScale = v3:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uiScale.Parent = v3

	local v5 = {
		Root = v2,
		Card = v3,
		Scale = uiScale,
		Panel = PoolGalaxyPanel.new(v4, v4.ZIndex + 1, v),
		Close = close,
		DimTransparency = v2.BackgroundTransparency,
		Closed = bindableEvent.Event,
		CloseBindable = bindableEvent,
		PreviousSelection = nil,
		Maid = maid
	}

	maid:GiveTask(close.Activated:Connect(function()
		if v2.Visible then
			PoolGalaxyPopup.Hide(v5)
			bindableEvent:Fire()
		end
	end))

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonB and v2.Visible then
			PoolGalaxyPopup.Hide(v5)
			bindableEvent:Fire()
		end
	end))

	return v5
end

function PoolGalaxyPopup.SetReplica(p, p2)
	PoolGalaxyPanel.SetReplica(p.Panel, p2)
end

function PoolGalaxyPopup.IsVisible(p)
	return p.Root.Visible
end

function PoolGalaxyPopup:Show()
	if self.Root.Visible then
		return
	end

	self.PreviousSelection = GuiService.SelectedObject
	self.Root.Visible = true
	self.Root.BackgroundTransparency = 1

	TweenService:Create(self.Root, TweenInfo.new(0.25), {
		BackgroundTransparency = self.DimTransparency
	}):Play()

	self.Scale.Scale = 0.8
	TweenService:Create(self.Scale, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()

	PoolGalaxyPanel.Refresh(self.Panel)
	PoolAudio.PlayCue("MenuOpen")

	if UserInputService.GamepadEnabled then
		GuiService.SelectedObject = self.Close
	end
end

function PoolGalaxyPopup.Hide(p)
	if not p.Root.Visible then
		return
	end

	p.Root.Visible = false

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(p.Root) then
		GuiService.SelectedObject = nil
	end

	local previousSelection = p.PreviousSelection

	if previousSelection and previousSelection.Parent and previousSelection.Visible then
		GuiService.SelectedObject = previousSelection
	end
end

function PoolGalaxyPopup.Destroy(p)
	PoolGalaxyPanel.Destroy(p.Panel)
	p.Maid:DoCleaning()
end

return PoolGalaxyPopup