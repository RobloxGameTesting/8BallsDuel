local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)

local PoolChatBox = {}

local Hud = PoolConstants.Hud

local function corner(parent, p: number) -- 3 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(p, 0)
	uiCorner.Parent = parent
end

local function stroke(parent, color: Color3, thickness: number) -- 3 equivalent calls inferred from this helper
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = thickness
	uiStroke.Parent = parent
end

local function makeButton(poolChatBox, name: string, text: string, backgroundColor: Color3, position: UDim2, size: UDim2)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.Position = position
	textButton.Size = size
	textButton.BackgroundColor3 = backgroundColor
	textButton.AutoButtonColor = true
	textButton.Text = text
	textButton.TextColor3 = Color3.fromRGB(22, 25, 28)
	textButton.TextScaled = true
	textButton.ZIndex = 51
	textButton.Parent = poolChatBox
	corner(textButton, 0.25) -- inferred equivalent call
	stroke(textButton, Color3.fromRGB(30, 30, 30), 2) -- inferred equivalent call

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0.22, 0)
	uiPadding.PaddingBottom = UDim.new(0.22, 0)
	uiPadding.Parent = textButton

	PoolButtonSkin.Apply(textButton)

	return textButton
end

function PoolChatBox.new(parent, p: number)
	local maid = Maid.new()

	local poolChatBox = Instance.new("Frame")
	poolChatBox.Name = "PoolChatBox"
	poolChatBox.AnchorPoint = Vector2.new(0.5, 1)

	poolChatBox.Position = UDim2.fromScale(0.5, 0.94)
	poolChatBox.Size = UDim2.fromScale(0.5, 0.09)
	poolChatBox.BackgroundColor3 = Color3.fromRGB(24, 28, 32)
	poolChatBox.BackgroundTransparency = 0.05
	poolChatBox.BorderSizePixel = 0
	poolChatBox.ZIndex = 50
	poolChatBox.Visible = false
	poolChatBox.Parent = parent

	maid:GiveTask(poolChatBox)
	corner(poolChatBox, 0.22) -- inferred equivalent call
	stroke(poolChatBox, Color3.fromRGB(30, 30, 30), 2) -- inferred equivalent call

	local entry = Instance.new("TextBox")
	entry.Name = "Entry"
	entry.AnchorPoint = Vector2.new(0, 0.5)
	entry.Position = UDim2.fromScale(0.03, 0.5)
	entry.Size = UDim2.fromScale(0.62, 0.62)
	entry.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	entry.TextColor3 = Color3.fromRGB(22, 25, 28)
	entry.PlaceholderText = "Say something"
	entry.PlaceholderColor3 = Hud.TextMuted
	entry.Text = ""
	entry.TextScaled = true
	entry.TextXAlignment = Enum.TextXAlignment.Left

	entry.ClearTextOnFocus = false
	entry.MultiLine = false
	entry.ZIndex = 51
	entry.Parent = poolChatBox
	corner(entry, 0.25) -- inferred equivalent call
	stroke(entry, Color3.fromRGB(30, 30, 30), 2) -- inferred equivalent call

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 10)
	uiPadding.PaddingRight = UDim.new(0, 10)
	uiPadding.PaddingTop = UDim.new(0.18, 0)
	uiPadding.PaddingBottom = UDim.new(0.18, 0)
	uiPadding.Parent = entry

	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = 24
	uiTextSizeConstraint.Parent = entry

	local button = makeButton(
		poolChatBox,
		"Send",
		"SEND",
		Color3.fromRGB(126, 232, 118),
		UDim2.fromScale(0.755, 0.5),
		UDim2.fromScale(0.2, 0.62)
	)
	local button2 = makeButton(
		poolChatBox,
		"Close",
		"×",
		Color3.fromRGB(238, 108, 108),
		UDim2.fromScale(0.925, 0.5),
		UDim2.fromScale(0.11, 0.62)
	)

	PoolButtonSkin.ApplyExit(button2)

	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local v = {
		Root = poolChatBox,
		Box = entry,
		SendButton = button,
		CloseButton = button2,
		Submitted = bindableEvent.Event,
		SubmitBindable = bindableEvent,
		Maid = maid
	}

	local function submit() -- 1 equivalent call inferred from this helper
		local v2 = string.sub(string.gsub(entry.Text, "^%s*(.-)%s*$", "%1"), 1, p)

		entry.Text = ""
		PoolChatBox.Hide(v)

		if v2 ~= "" then
			bindableEvent:Fire(v2)
		end
	end

	maid:GiveTask(button.Activated:Connect(submit))

	maid:GiveTask(button2.Activated:Connect(function()
		entry.Text = ""
		PoolChatBox.Hide(v)
	end))

	maid:GiveTask(entry.FocusLost:Connect(function(flag: boolean)
		if flag then
			submit() -- inferred equivalent call
		end
	end))

	maid:GiveTask(entry:GetPropertyChangedSignal("Text"):Connect(function()
		if utf8.len(entry.Text) and p < utf8.len(entry.Text) then
			entry.Text = string.sub(entry.Text, 1, utf8.offset(entry.Text, p + 1) - 1)
		end
	end))

	return v
end

function PoolChatBox.Show(p)
	p.Root.Visible = true
	p.Box:CaptureFocus()
end

function PoolChatBox.Hide(p)
	p.Root.Visible = false

	if UserInputService:GetFocusedTextBox() == p.Box then
		p.Box:ReleaseFocus()
	end
end

function PoolChatBox.IsOpen(p)
	return p.Root.Visible
end

function PoolChatBox.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolChatBox