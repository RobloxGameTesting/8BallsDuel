local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)

local PoolStreakBadge = require(script.Parent.PoolStreakBadge)
local PoolVip = require(script.Parent.PoolVip)

local PoolFoulPopup = require(script.Parent.PoolFoulPopup)

local PoolEmotes = require(script.Parent.PoolEmotes)
local TweenService = game:GetService("TweenService")

local PoolTableRenderer3D = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTableRenderer3D)

local PoolHudRenderer = {}

local Hud = PoolConstants.Hud
Color3.fromRGB(22, 25, 28)
Color3.fromRGB(255, 255, 255)

local function corner(parent, p: number) -- 6 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(p, 0)
	uiCorner.Parent = parent
end

local function square(parent) -- 7 equivalent calls inferred from this helper
	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = parent
end

local function chatButtonPlacement(icon)
	local levelBadge = icon:FindFirstChild("LevelBadge")

	if levelBadge and levelBadge:IsA("GuiObject") then
		return UDim2.fromScale(1 - levelBadge.Position.X.Scale, levelBadge.Position.Y.Scale), levelBadge.Size
	end

	return UDim2.fromScale(0, 1), UDim2.fromScale(0.5, 0.5)
end

local function attachChat(state, bindableEvent, maid)
	local icon = state.Icon
	local position, size = chatButtonPlacement(icon)

	local chatButton = Instance.new("TextButton")
	chatButton.Name = "ChatButton"
	chatButton.AnchorPoint = Vector2.new(0.5, 0.5)
	chatButton.Position = position
	chatButton.Size = size
	chatButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	chatButton.AutoButtonColor = true
	chatButton.Text = "···"
	chatButton.TextColor3 = Color3.fromRGB(28, 32, 36)
	chatButton.TextScaled = true
	chatButton.FontFace = state.NameLabel.FontFace

	chatButton.ZIndex = icon.ZIndex + 1
	chatButton.Visible = false
	chatButton.Parent = icon
	corner(chatButton, 0.5) -- inferred equivalent call
	square(chatButton) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(30, 30, 30)
	uiStroke.Thickness = 2.5
	uiStroke.Parent = chatButton

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingBottom = UDim.new(0.22, 0)
	uiPadding.PaddingLeft = UDim.new(0.14, 0)
	uiPadding.PaddingRight = UDim.new(0.14, 0)
	uiPadding.Parent = chatButton

	PoolButtonSkin.Apply(chatButton)

	maid:GiveTask(chatButton.Activated:Connect(function()
		bindableEvent:Fire()
	end))

	local chatBubble = Instance.new("Frame")
	chatBubble.Name = "ChatBubble"
	chatBubble.AnchorPoint = Vector2.new(0.5, 0)
	chatBubble.Position = UDim2.fromScale(0.5, 1.18)
	chatBubble.Size = UDim2.fromScale(4.5, 0.55)
	chatBubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	chatBubble.BorderSizePixel = 0

	chatBubble.ZIndex = state.Root.ZIndex + 6
	chatBubble.Visible = false
	chatBubble.Parent = icon
	corner(chatBubble, 0.28) -- inferred equivalent call
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Color = Color3.fromRGB(30, 30, 30)
	uiStroke2.Thickness = 2
	uiStroke2.Parent = chatBubble

	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.BackgroundTransparency = 1
	message.Size = UDim2.fromScale(0.9, 0.78)
	message.Position = UDim2.fromScale(0.5, 0.5)
	message.AnchorPoint = Vector2.new(0.5, 0.5)
	message.FontFace = state.NameLabel.FontFace
	message.TextColor3 = Color3.fromRGB(28, 32, 36)
	message.TextScaled = true
	message.TextWrapped = true
	message.Text = ""
	message.ZIndex = chatBubble.ZIndex + 1
	message.Parent = chatBubble

	local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
	uiTextSizeConstraint.MaxTextSize = 22
	uiTextSizeConstraint.Parent = message

	state.ChatButton = chatButton
	state.Bubble = chatBubble
	state.BubbleLabel = message
end

local tweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function setPickerOpen(state, flag: boolean) -- 1 equivalent call inferred from this helper
	local emotePicker = state.EmotePicker

	if not emotePicker then
		return
	end

	state.EmotePickerToken += 1

	if not flag then
		emotePicker.Visible = false

		return
	end

	emotePicker.Visible = true

	local uiScale = emotePicker:FindFirstChildOfClass("UIScale")

	if uiScale then
		uiScale.Scale = 0.6
		TweenService:Create(uiScale, tweenInfo2, { Scale = 1 }):Play()
	end

	local emotePickerToken = state.EmotePickerToken

	task.delay(4, function()
		if state.EmotePickerToken == emotePickerToken and emotePicker.Parent then
			emotePicker.Visible = false
		end
	end)
end

local function attachEmotes(state, bindableEvent, maid)
	local icon = state.Icon
	local position, v = chatButtonPlacement(icon)

	local emoteButton = Instance.new("ImageButton")
	emoteButton.Name = "EmoteButton"
	emoteButton.AnchorPoint = Vector2.new(0.5, 0.5)
	emoteButton.Position = position
	emoteButton.Size = UDim2.new(v.X.Scale * 1.15, v.X.Offset, v.Y.Scale * 1.15, v.Y.Offset)
	emoteButton.BackgroundTransparency = 1
	emoteButton.Image = PoolEmotes.BubbleIcon
	emoteButton.ScaleType = Enum.ScaleType.Fit
	emoteButton.ZIndex = icon.ZIndex + 2
	emoteButton.Visible = false
	emoteButton.Parent = icon
	square(emoteButton) -- inferred equivalent call
	maid:GiveTask(emoteButton)

	local emotePicker = Instance.new("Frame")
	emotePicker.Name = "EmotePicker"
	emotePicker.AnchorPoint = Vector2.new(0.5, 0)
	emotePicker.Position = UDim2.fromScale(0.5, 1.28)
	emotePicker.Size = UDim2.fromScale(3.4, 1)
	emotePicker.BackgroundTransparency = 1
	emotePicker.ZIndex = state.Root.ZIndex + 10
	emotePicker.Visible = false
	emotePicker.Parent = icon
	maid:GiveTask(emotePicker)

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = emotePicker

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0.04, 0)
	uiListLayout.Parent = emotePicker

	for k, playerChoice in PoolEmotes.PlayerChoices do
		local textButton = Instance.new("TextButton")
		textButton.Name = playerChoice
		textButton.LayoutOrder = k
		textButton.Size = UDim2.fromScale(0.3, 1)
		textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textButton.Text = PoolEmotes.Glyph(playerChoice)
		textButton.TextScaled = true
		textButton.AutoButtonColor = true
		textButton.ZIndex = emotePicker.ZIndex + 1
		textButton.Parent = emotePicker
		square(textButton) -- inferred equivalent call
		corner(textButton, 0.5) -- inferred equivalent call
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingTop = UDim.new(0.16, 0)
		uiPadding.PaddingBottom = UDim.new(0.2, 0)
		uiPadding.PaddingLeft = UDim.new(0.16, 0)
		uiPadding.PaddingRight = UDim.new(0.16, 0)
		uiPadding.Parent = textButton

		PoolButtonSkin.Apply(textButton, { Round = true, Tint = Color3.fromRGB(255, 255, 255) })

		maid:GiveTask(textButton.Activated:Connect(function()
			setPickerOpen(state, true)
			bindableEvent:Fire(playerChoice)
		end))
	end

	maid:GiveTask(emoteButton.Activated:Connect(function()
		setPickerOpen(state, not emotePicker.Visible)
	end))

	state.EmoteButton = emoteButton
	state.EmotePicker = emotePicker
end

local cframe = CFrame.Angles(0, 3.141592653589793, 0)

local function slotsOf(p) -- 2 equivalent calls inferred from this helper
	return p.Slots or 7
end

local function slotX(side: string, count: number, slots: number?) -- 1 equivalent call inferred from this helper
	local v = 1 / (slots or 7)
	local v2 = (count - 0.5) * v

	if side == "Left" then
		return 1 - v2
	end

	return v2
end

local function layoutChips(panel, flag: boolean?)
	local v = 1 / slotsOf(panel) -- inferred equivalent call

	local count = 0

	local function seat(p)
		count += 1
		local target = slotX(panel.Side, count, panel.Slots) -- inferred equivalent call
		local v2 = panel.Roll[p]

		if not v2 then
			v2 = { X = target, Target = target, Angle = 0 }
			panel.Roll[p] = v2
			p.Position = UDim2.fromScale(target, 0.5)
		end

		v2.Target = target

		if flag then
			v2.X = target
			p.Position = UDim2.fromScale(target, 0.5)
		end
	end

	for _, viewportFrame in panel.ChipHolder:GetChildren() do
		if not viewportFrame:IsA("ViewportFrame") then
			continue
		end

		viewportFrame.Size = UDim2.fromScale(v, 1)
		viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	if panel.OnEight then
		for _, chip in panel.Chips do
			chip.Visible = false
		end

		if panel.Eight then
			panel.Eight.Visible = true
			seat(panel.Eight)
		end
	else
		if panel.Eight then
			panel.Eight.Visible = false
		end

		for _, v2 in panel.Order do
			local chip = panel.Chips[v2]

			if not chip then
				continue
			end

			chip.Visible = not panel.Potted[v2]

			if chip.Visible then
				seat(chip)
			end
		end
	end
end

local function updateRoll(panel, p: number)
	local v = 1 / slotsOf(panel) -- inferred equivalent call

	local v2 = math.clamp(p * 9, 0, 1)

	for k, v3 in panel.Roll do
		if not (k.Parent and k.Visible) then
			continue
		end

		local v4 = (v3.Target - v3.X) * v2

		if not (math.abs(v4) > 0.00001) then
			continue
		end

		v3.X += v4
		k.Position = UDim2.fromScale(v3.X, 0.5)

		v3.Angle -= v4 / v * 2

		local basePart = k:FindFirstChildWhichIsA("BasePart")

		if basePart then
			basePart.CFrame = CFrame.Angles(0, 0, v3.Angle) * cframe
		end
	end
end

local function createChip(parent, ballNumber: number, zIndex: number)
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "Chip" .. ballNumber
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.BorderSizePixel = 0
	viewportFrame.ZIndex = zIndex
	viewportFrame:SetAttribute("BallNumber", ballNumber)

	viewportFrame.Ambient = Color3.fromRGB(220, 220, 220)
	viewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
	viewportFrame.LightDirection = Vector3.new(-0.3, -1, -0.6)
	square(viewportFrame) -- inferred equivalent call
	viewportFrame.Parent = parent

	local createLooseBall = PoolTableRenderer3D.CreateLooseBall(viewportFrame, ballNumber, "Ball")

	createLooseBall.CFrame = cframe

	local camera = Instance.new("Camera")
	camera.FieldOfView = 20

	local v = PoolConstants.BallDiameter / 2 * 1.25 / 0.17632698070846498

	camera.CFrame = CFrame.new(Vector3.new(0, 0, v), Vector3.new(0, 0, 0))
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	return viewportFrame
end

local TweenService2 = game:GetService("TweenService")

local v = {
	Left = {
		X = 0.29,
		Width = 0.135,
		IconWidth = 0.42,
		NameX = 0.54,
		NameWidth = 0.5
	},
	Right = {
		X = 0.32,
		Width = 0.135,
		IconWidth = 0.42,
		NameX = 0.46,
		NameWidth = 0.5
	}
}

local clone = table.clone(PoolConstants.NineBall.Balls)
table.sort(clone)

local color = Color3.fromRGB(255, 255, 255)

local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function newNineRack(frame)
	if not (frame and frame:IsA("Frame")) then
		return nil
	end

	local balls = frame:FindFirstChild("Balls")

	if not (balls and balls:IsA("Frame")) then
		warn("[PoolHudRenderer] Hud.NineBallRack needs a Balls frame")

		return nil
	end

	frame.Visible = false

	local ring = Instance.new("Frame")
	ring.Name = "Ring"
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.Size = UDim2.fromScale(1.3, 1.3)
	ring.BackgroundTransparency = 1
	ring.ZIndex = balls.ZIndex + 4
	ring.Visible = false
	ring.Parent = balls
	corner(ring, 0.5) -- inferred equivalent call
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = 2.5
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = ring

	local pop = Instance.new("UIScale")
	pop.Name = "Pop"
	pop.Parent = ring

	return {
		Root = frame,
		Holder = balls,
		Slots = {},
		Chips = {},
		Potted = {},
		Ring = ring,
		RingOn = nil,
		Built = false
	}
end

local function placeRing(state)
	local ringOn = nil

	for _, v2 in clone do
		if state.Slots[v2] and not state.Potted[v2] then
			ringOn = v2
			break
		end
	end

	if ringOn == state.RingOn then
		return
	end

	state.RingOn = ringOn

	local ring = state.Ring

	if not ringOn then
		ring.Visible = false

		return
	end

	ring.Parent = state.Slots[ringOn]
	ring.Visible = true

	local pop = ring:FindFirstChild("Pop")

	if pop then
		pop.Scale = 1.35
		TweenService2:Create(pop, tweenInfo3, { Scale = 1 }):Play()
	end
end

local function buildNineRack(nineRack)
	if nineRack.Built then
		return
	end

	nineRack.Built = true

	nineRack.Ring.Parent = nineRack.Holder
	nineRack.Ring.Visible = false
	nineRack.RingOn = nil

	for _, slot in nineRack.Slots do
		slot:Destroy()
	end

	table.clear(nineRack.Slots)
	table.clear(nineRack.Chips)
	table.clear(nineRack.Potted)

	local zIndex = nineRack.Holder.ZIndex

	for _, layoutOrder in clone do
		local frame = Instance.new("Frame")
		frame.Name = "Slot" .. layoutOrder
		frame.LayoutOrder = layoutOrder
		frame.Size = UDim2.fromScale(0.1, 1)
		frame.BackgroundColor3 = Hud.EmptyChip
		frame.BorderSizePixel = 0
		frame.ZIndex = zIndex + 1
		square(frame) -- inferred equivalent call
		corner(frame, 0.5) -- inferred equivalent call
		frame.Parent = nineRack.Holder

		nineRack.Slots[layoutOrder] = frame
		nineRack.Chips[layoutOrder] = createChip(frame, layoutOrder, zIndex + 2)
	end

	placeRing(nineRack)
end

local function applyNineRackVisible(data) -- 2 equivalent calls inferred from this helper
	local nineRack = data.NineRack

	if nineRack then
		nineRack.Root.Visible = data.NineLayout and data.ChromeShown
	end
end

local function applyNineBallLayout(state, nineLayout: boolean)
	if state.NineLayout == nineLayout then
		return
	end

	state.NineLayout = nineLayout

	for k, panel in state.Panels do
		for _, v2 in { panel.Root, panel.Icon, panel.NameLabel, panel.ChipHolder } do
			local authoredPlate = state.AuthoredPlates[v2]

			if not authoredPlate then
				continue
			end

			v2.Position = authoredPlate.Position
			v2.Size = authoredPlate.Size
			v2.AnchorPoint = authoredPlate.AnchorPoint
		end

		panel.ChipHolder.Visible = not nineLayout

		local v2 = v[k]

		if not (nineLayout and v2) then
			continue
		end

		local root = panel.Root

		root.Position = UDim2.new(v2.X, 0, root.Position.Y.Scale, root.Position.Y.Offset)
		root.Size = UDim2.new(v2.Width, 0, root.Size.Y.Scale, root.Size.Y.Offset)
		panel.Icon.Size = UDim2.new(v2.IconWidth, 0, panel.Icon.Size.Y.Scale, panel.Icon.Size.Y.Offset)
		panel.NameLabel.Position = UDim2.fromScale(v2.NameX, 0.43)
		panel.NameLabel.Size = UDim2.fromScale(v2.NameWidth, 0.42)
	end

	applyNineRackVisible(state) -- inferred equivalent call
end

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolHudRenderer: %s.%s is missing (looking for %q)",
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

local function setButtonLabel(instance, text: string) -- 2 equivalent calls inferred from this helper
	local top = instance:FindFirstChild("Top")

	if top and top:IsA("TextLabel") then
		top.Text = text
	else
		instance.Text = text
	end
end

local function bindPlayerPanel(hud, side: string)
	local root = bind(hud, side .. "Player")
	local icon = bind(root, "Icon")
	local chipHolder = bind(root, "Chips")

	local uiListLayout = chipHolder:FindFirstChildWhichIsA("UIListLayout")

	if uiListLayout then
		uiListLayout:Destroy()
	end

	local levelBadge = icon:FindFirstChild("LevelBadge")
	local level = levelBadge and levelBadge:FindFirstChild("Level")

	local v2 = {
		Root = root,
		Icon = icon,
		NameLabel = bind(root, "PlayerName"),
		LevelLabel = 0,
		ChipHolder = 0,
		Chips = 0,
		Order = 0,
		Potted = 0,
		Eight = nil,
		OnEight = false,
		Group = nil,
		Built = false,
		Roll = 0,
		Side = 0,
		ChatButton = nil,
		Bubble = nil,
		BubbleLabel = nil,
		BubbleToken = 0,
		BotTag = nil,
		StatsButton = nil,
		EmoteButton = nil,
		EmotePicker = nil,
		EmotePickerToken = 0,
		EmotesLive = 0
	}

	if not (level and level:IsA("TextLabel")) then
		level = nil
	end

	v2.LevelLabel = level
	v2.ChipHolder = chipHolder
	v2.Chips = {}
	v2.Order = {}
	v2.Potted = {}

	v2.Roll = {}
	v2.Side = side
	return v2
end

local function attachPortraitButton(state, bindableEvent, maid)
	local icon = state.Icon

	local statsButton = Instance.new("TextButton")
	statsButton.Name = "StatsButton"
	statsButton.Size = UDim2.fromScale(1, 1)
	statsButton.BackgroundTransparency = 1
	statsButton.BorderSizePixel = 0
	statsButton.Text = ""
	statsButton.AutoButtonColor = false
	statsButton.Selectable = false
	statsButton.ZIndex = icon.ZIndex
	statsButton.Visible = false
	statsButton.Parent = icon
	maid:GiveTask(statsButton)

	if not icon:FindFirstChild("PressScale") then
		local pressScale = Instance.new("UIScale")
		pressScale.Name = "PressScale"
		pressScale.Parent = icon
		maid:GiveTask(pressScale)
	end

	maid:GiveTask(statsButton.Activated:Connect(function()
		bindableEvent:Fire(state.Side)
	end))

	state.StatsButton = statsButton
end

function PoolHudRenderer.new(instance, p: string?)
	local theme = PoolConstants.GetTheme(p)
	local maid = Maid.new()

	local hud = instance:WaitForChild("Hud")

	local panels = { Left = bindPlayerPanel(hud, "Left"), Right = bindPlayerPanel(hud, "Right") }

	local powerTrack = bind(hud, "PowerTrack")
	local banner = bind(hud, "Banner")
	local spinWidget = bind(hud, "SpinWidget")

	local spinPanel = hud:FindFirstChild("SpinPanel")
	local widget = spinPanel and spinPanel:FindFirstChild("Widget")
	local dot = widget and widget:FindFirstChild("Dot")

	if spinPanel then
		spinPanel.Visible = false
	end

	local exitButton = bind(hud, "ExitButton")
	local settingsButton = bind(hud, "SettingsButton")

	banner.Visible = false

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local bindableEvent4 = Instance.new("BindableEvent")
	local bindableEvent5 = Instance.new("BindableEvent")
	local bindableEvent6 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent6)
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)
	maid:GiveTask(bindableEvent3)
	maid:GiveTask(bindableEvent4)
	maid:GiveTask(bindableEvent5)

	for _, v2 in panels do
		attachChat(v2, bindableEvent4, maid)
		attachPortraitButton(v2, bindableEvent5, maid)
		attachEmotes(v2, bindableEvent6, maid)
	end

	maid:GiveTask(exitButton.Activated:Connect(function()
		bindableEvent:Fire()
	end))

	maid:GiveTask(settingsButton.Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	local authoredPlates = {}

	for _, v2 in panels do
		for _, v3 in { v2.Root, v2.Icon, v2.NameLabel, v2.ChipHolder } do
			authoredPlates[v3] = {
				Position = v3.Position,
				Size = v3.Size,
				AnchorPoint = v3.AnchorPoint
			}
		end
	end

	local v2 = {}
	v2.Root = hud
	v2.Panels = panels
	v2.WagerLabel = bind(hud, "Wager.Amount")
	v2.WagerFrame = bind(hud, "Wager")
	v2.PowerTrack = powerTrack
	v2.PowerFill = bind(powerTrack, "Fill")
	v2.PowerCue = bind(powerTrack, "Cue")
	v2.PowerLabel = bind(hud, "PowerLabel")
	v2.ViewToggle = bind(hud, "ViewToggle")
	v2.CameraToggle = bind(hud, "CameraToggle")
	v2.ExitButton = exitButton
	v2.Exit = bindableEvent.Event
	v2.ExitBindable = bindableEvent
	v2.SettingsButton = settingsButton
	v2.Settings = bindableEvent2.Event
	v2.SettingsBindable = bindableEvent2
	v2.Banner = banner
	v2.BannerLabel = bind(banner, "Message")
	v2.BannerToken = 0
	v2.FoulPopup = PoolFoulPopup.new(instance:FindFirstChild("FoulPopup"))
	v2.SpinWidget = spinWidget

	if not (spinPanel and spinPanel:IsA("Frame")) then
		spinPanel = nil
	end

	v2.SpinPanel = spinPanel

	if not (widget and widget:IsA("Frame")) then
		widget = nil
	end

	v2.SpinPanelWidget = widget

	if not (dot and dot:IsA("Frame")) then
		dot = nil
	end

	v2.SpinPanelDot = dot
	v2.SpinOpen = false
	v2.SpinSession = 0
	v2.SpinDot = bind(spinWidget, "Dot")
	v2.Spin = Vector2.zero
	v2.SpinBindable = bindableEvent3
	v2.SpinChanged = bindableEvent3.Event
	v2.ChatBindable = bindableEvent4
	v2.Chat = bindableEvent4.Event
	v2.PortraitBindable = bindableEvent5
	v2.Portrait = bindableEvent5.Event
	v2.EmoteBindable = bindableEvent6
	v2.Emote = bindableEvent6.Event

	v2.ShotControlsShown = false
	v2.FlatRackAllowed = true

	v2.NineRack = newNineRack(hud:FindFirstChild("NineBallRack"))
	v2.NineLayout = false
	v2.ChromeShown = true
	v2.AuthoredPlates = authoredPlates
	v2.Theme = theme
	v2.Maid = maid

	PoolHudRenderer.BindSpinInput(v2)

	return v2
end

function PoolHudRenderer.SetChatSide(p, p2: string?)
	for k, panel in p.Panels do
		local chatButton = panel.ChatButton

		if chatButton then
			chatButton.Visible = k == p2
		end
	end
end

function PoolHudRenderer.SetEmoteSide(p, p2: string?)
	for k, panel in p.Panels do
		if panel.EmoteButton then
			panel.EmoteButton.Visible = k == p2
		end

		setPickerOpen(panel, false) -- inferred equivalent call
	end
end

function PoolHudRenderer.PlayEmote(p, p2: string, p3: string)
	local panel = p.Panels[p2]

	if not panel or not PoolEmotes.IsEmote(p3) or panel.EmotesLive >= 24 then
		return
	end

	panel.EmotesLive += 1

	local icon = panel.Icon
	local v2 = (math.random() * 2 - 1) * 0.45
	local emote = Instance.new("TextLabel")
	emote.Name = "Emote"
	emote.AnchorPoint = Vector2.new(0.5, 0.5)
	emote.Position = UDim2.fromScale(0.5 + v2 * 0.4, 0.55)
	emote.Size = UDim2.fromScale(1.05, 1.05)
	emote.BackgroundTransparency = 1
	emote.Text = PoolEmotes.Glyph(p3)
	emote.TextScaled = true
	emote.Rotation = (math.random() * 2 - 1) * 10

	emote.ZIndex = panel.Root.ZIndex + 30
	square(emote) -- inferred equivalent call
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 0.2
	uiScale.Parent = emote
	emote.Parent = icon

	TweenService2:Create(uiScale, tweenInfo, { Scale = 1.15 }):Play()

	TweenService2:Create(emote, TweenInfo.new(1.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5 + v2, 1.9 + math.random() * 0.4),
		Rotation = emote.Rotation + (math.random() * 2 - 1) * 18
	}):Play()

	TweenService2:Create(
		emote,
		TweenInfo.new(0.6075, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.7425000000000002),
		{ TextTransparency = 1 }
	):Play()

	task.delay(1.4000000000000001, function()
		panel.EmotesLive = math.max(panel.EmotesLive - 1, 0)
		emote:Destroy()
	end)
end

function PoolHudRenderer.SetPortraitsPressable(p, flag: boolean, flag2: boolean)
	for k, panel in p.Panels do
		local statsButton = panel.StatsButton

		if not statsButton then
			continue
		end

		local visible = if k == "Left" then flag else flag2
		statsButton.Visible = visible
	end
end

function PoolHudRenderer.SayChat(p, p2: string, text: string, value: number?)
	local panel = p.Panels[p2]
	local bubble = panel and panel.Bubble
	local bubbleLabel = panel and panel.BubbleLabel

	if not (panel and bubble and bubbleLabel) then
		return
	end

	if text == "" then
		bubble.Visible = false

		return
	end

	bubbleLabel.Text = text
	bubble.Visible = true

	panel.BubbleToken += 1

	local bubbleToken = panel.BubbleToken

	task.delay(value or 5, function()
		if panel.BubbleToken == bubbleToken and bubble.Parent then
			bubble.Visible = false
		end
	end)
end

function PoolHudRenderer.ClearChat(p)
	for _, panel in p.Panels do
		panel.BubbleToken += 1

		if panel.Bubble then
			panel.Bubble.Visible = false
		end
	end
end

function PoolHudRenderer.SetExitVisible(p, visible: boolean)
	p.ExitButton.Visible = visible
end

function PoolHudRenderer:SetSpin(spin: Vector2)
	if spin.Magnitude > 1 then
		spin = spin.Unit
	end

	self.Spin = spin

	local udim = UDim2.fromScale(0.5 + spin.X * 0.37, 0.5 - spin.Y * 0.37)

	self.SpinDot.Position = udim

	if self.SpinPanelDot then
		self.SpinPanelDot.Position = udim
	end

	self.SpinBindable:Fire(spin)
end

function PoolHudRenderer:SetSpinOpen(flag: boolean)
	local spinPanel = self.SpinPanel

	if not spinPanel then
		return
	end

	self.SpinOpen = flag

	self.SpinSession += 1
	spinPanel.Visible = flag
end

function PoolHudRenderer.ToggleSpin(p)
	PoolHudRenderer.SetSpinOpen(p, not p.SpinOpen)
end

function PoolHudRenderer.ResetSpin(p)
	PoolHudRenderer.SetSpin(p, Vector2.zero)

	PoolHudRenderer.SetSpinOpen(p, false)
end

local function inputOffset(instance) -- 2 equivalent calls inferred from this helper
	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui and screenGui.IgnoreGuiInset then
		return Vector2.zero
	end

	return GuiService:GetGuiInset()
end

function PoolHudRenderer.BindSpinInput(data)
	local v2 = false

	local function activeWidget() -- 1 equivalent call inferred from this helper
		if data.SpinOpen and data.SpinPanelWidget then
			return data.SpinPanelWidget
		end

		return data.SpinWidget
	end

	local function applyFrom(vector2: Vector2)
		local v3 = activeWidget() -- inferred equivalent call
		local v4 = v3.AbsoluteSize.X / 2

		if v4 <= 0 then
			return
		end

		local v5 = (vector2 - v3.AbsolutePosition - inputOffset(v3) - v3.AbsoluteSize / 2) / v4 -- inferred equivalent call

		PoolHudRenderer.SetSpin(data, Vector2.new(v5.X, -v5.Y))
	end

	local function beginDrag(_, input) -- 2 equivalent calls inferred from this helper
		v2 = true

		applyFrom(Vector2.new(input.Position.X, input.Position.Y))
	end

	local function isPointer(input): boolean -- 4 equivalent calls inferred from this helper
		return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
	end

	data.Maid:GiveTask(data.SpinWidget.InputBegan:Connect(function(input)
		if not isPointer(input) then -- inferred equivalent call
			return
		end

		if data.SpinPanel then
			PoolHudRenderer.SetSpinOpen(data, true)

			return
		end

		local _spinWidget = data.SpinWidget
		beginDrag(nil, input) -- inferred equivalent call
	end))

	if data.SpinPanelWidget then
		local spinPanelWidget = data.SpinPanelWidget

		data.Maid:GiveTask(spinPanelWidget.InputBegan:Connect(function(input)
			if not isPointer(input) then -- inferred equivalent call
				return
			end

			beginDrag(nil, input) -- inferred equivalent call
		end))
	end

	if data.SpinPanel then
		data.Maid:GiveTask(data.SpinPanel.InputBegan:Connect(function(input)
			if isPointer(input) and not v2 then -- inferred equivalent call
				PoolHudRenderer.SetSpinOpen(data, false)
			end
		end))
	end

	data.Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		if not v2 then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			applyFrom(Vector2.new(input.Position.X, input.Position.Y))
		end
	end))

	data.Maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if not isPointer(input) then -- inferred equivalent call
			return
		end

		local v3 = v2

		v2 = false

		if v3 and data.SpinOpen then
			local spinSession = data.SpinSession

			task.delay(0.12, function()
				if data.SpinSession == spinSession then
					PoolHudRenderer.SetSpinOpen(data, false)
				end
			end)
		end
	end))
end

function PoolHudRenderer.IsUsingSpinWidget(p, vector2: Vector2): boolean
	if p.SpinOpen then
		return true
	end

	local spinWidget = p.SpinWidget
	local v2 = spinWidget.AbsolutePosition + inputOffset(spinWidget) -- inferred equivalent call
	local absoluteSize = spinWidget.AbsoluteSize

	return vector2.X >= v2.X
		and vector2.X <= v2.X + absoluteSize.X
		and vector2.Y >= v2.Y
		and vector2.Y <= v2.Y + absoluteSize.Y
end

function PoolHudRenderer.IsUsingPowerMeter(p, vector2: Vector2): boolean
	local powerTrack = p.PowerTrack
	local v2 = powerTrack.AbsolutePosition + GuiService:GetGuiInset()
	local absoluteSize = powerTrack.AbsoluteSize
	local powerMeterTouchPadding = PoolConstants.Input.PowerMeterTouchPadding

	return vector2.X >= v2.X - powerMeterTouchPadding
		and vector2.X <= v2.X + absoluteSize.X + powerMeterTouchPadding
		and vector2.Y >= v2.Y - powerMeterTouchPadding
		and vector2.Y <= v2.Y + absoluteSize.Y + powerMeterTouchPadding
end

function PoolHudRenderer.PowerFromPosition(p, vector2: Vector2)
	local powerTrack = p.PowerTrack
	local v2 = powerTrack.AbsolutePosition + GuiService:GetGuiInset()
	local y = powerTrack.AbsoluteSize.Y

	if y <= 0 then
		return 0
	end

	return (math.clamp((vector2.Y - v2.Y) / y, 0, 1))
end

function PoolHudRenderer.SetBotTag(p, p2: string, visible: boolean)
	local panel = p.Panels[p2]

	if not panel then
		return
	end

	if not panel.BotTag then
		if not visible then
			return
		end

		local botTag = Instance.new("Frame")
		botTag.Name = "BotTag"
		botTag.AnchorPoint = Vector2.new(0.5, 1)
		botTag.Position = UDim2.fromScale(0.5, 1)
		botTag.Size = UDim2.fromScale(1, 0.26)
		botTag.BackgroundColor3 = Color3.fromRGB(12, 14, 16)
		botTag.BackgroundTransparency = 1
		botTag.BorderSizePixel = 0

		botTag.ZIndex = panel.Icon.ZIndex + 6
		botTag.Parent = panel.Icon

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.TextScaled = true
		label.TextColor3 = Color3.fromRGB(255, 255, 255)

		label.FontFace = panel.NameLabel.FontFace
		label.Text = "BOT"
		label.ZIndex = botTag.ZIndex + 1
		label.Parent = botTag

		local uiSizeConstraint = Instance.new("UISizeConstraint")
		uiSizeConstraint.MinSize = Vector2.new(0, 18)
		uiSizeConstraint.Parent = botTag

		panel.BotTag = botTag
	end

	panel.BotTag.Visible = visible
end

function PoolHudRenderer.SetWinStreak(p, p2: string, p3: number?)
	local panel = p.Panels[p2]

	if not panel then
		return
	end

	PoolStreakBadge.Set(panel.Icon, p3, p2 == "Left" and "BottomLeft" or "BottomRight")
end

function PoolHudRenderer.SetPlayer(p, p2: string, p3: string, value: string?, flag: boolean?)
	local panel = p.Panels[p2]

	if not panel then
		return
	end

	PoolVip.Apply(panel.NameLabel, p3, flag)
	panel.Icon.Image = value or ""
end

function PoolHudRenderer.SetLevel(p, p2: string, p3: number)
	local panel = p.Panels[p2]

	if panel and panel.LevelLabel then
		panel.LevelLabel.Text = tostring((math.max(1, (math.floor(p3)))))
	end
end

function PoolHudRenderer.SetGroup(p, p2: string, group)
	applyNineBallLayout(p, false)

	local panel = p.Panels[p2]

	if not panel or panel.Group == group and panel.Built then
		return
	end

	panel.Group = group
	panel.Built = true

	panel.Slots = nil

	for k, chip in panel.Chips do
		chip:Destroy()
		panel.Chips[k] = nil
	end

	panel.OnEight = false

	for _, guiObject in panel.ChipHolder:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	if group == "Solid" or group == "Stripe" then
		local v2

		if group == "Solid" then
			v2 = PoolConstants.Solids
		else
			v2 = PoolConstants.Stripes
		end

		table.clear(panel.Order)
		table.clear(panel.Potted)
		table.clear(panel.Roll)
		panel.Eight = nil

		for _, v3 in v2 do
			panel.Chips[v3] = createChip(panel.ChipHolder, v3, 21)
			table.insert(panel.Order, v3)
		end

		local chipEight = createChip(panel.ChipHolder, PoolConstants.EightBallNumber, 21)
		chipEight.Name = "ChipEight"
		chipEight.Visible = false
		panel.Eight = chipEight

		layoutChips(panel, true)
	else
		for i = 1, 7 do
			local frame = Instance.new("Frame")
			frame.Name = "Placeholder" .. i
			frame.BackgroundColor3 = Hud.EmptyChip
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, 1)
			frame.LayoutOrder = i

			frame.ZIndex = panel.ChipHolder.ZIndex + 1
			frame.Parent = panel.ChipHolder
			square(frame) -- inferred equivalent call
			corner(frame, 1) -- inferred equivalent call
		end
	end
end

function PoolHudRenderer.SetNineBall(p, p2: string)
	applyNineBallLayout(p, true)

	if p.NineRack then
		buildNineRack(p.NineRack)
	end

	local panel = p.Panels[p2]

	if not panel or panel.Group == "NineBall" and panel.Built then
		return
	end

	panel.Group = "NineBall"
	panel.Built = true
	panel.OnEight = false
	panel.Slots = nil

	for k, chip in panel.Chips do
		chip:Destroy()
		panel.Chips[k] = nil
	end

	for _, guiObject in panel.ChipHolder:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	table.clear(panel.Order)
	table.clear(panel.Potted)
	table.clear(panel.Roll)
	panel.Eight = nil
end

function PoolHudRenderer.SetOnEight(p, p2: string, onEight: boolean)
	local panel = p.Panels[p2]

	if not panel or panel.OnEight == onEight then
		return
	end

	panel.OnEight = onEight

	layoutChips(panel)
end

function PoolHudRenderer.ResetRows(p)
	for _, panel in p.Panels do
		panel.Built = false
	end

	if p.NineRack then
		p.NineRack.Built = false
	end
end

function PoolHudRenderer.UpdateChips(p, p2: number)
	for _, panel in p.Panels do
		updateRoll(panel, p2)
	end
end

function PoolHudRenderer.SetActiveSide(p, p2: string?)
	for k, panel in p.Panels do
		local visible = k == p2
		local root = panel.Root
		local backgroundColor

		if visible then
			backgroundColor = Hud.PanelActive
		else
			backgroundColor = Hud.Panel
		end

		root.BackgroundColor3 = backgroundColor

		local timer = panel.Root:FindFirstChild("Timer")

		if timer then
			timer.Visible = visible
		end
	end
end

function PoolHudRenderer.SetBallPotted(p, p2: number, flag: boolean)
	for _, panel in p.Panels do
		if not panel.Chips[p2] then
			continue
		end

		panel.Potted[p2] = flag or nil

		layoutChips(panel)
	end

	local nineRack = p.NineRack
	local v2 = nineRack and nineRack.Built and nineRack.Chips[p2]

	if nineRack and v2 then
		nineRack.Potted[p2] = flag or nil
		v2.Visible = not flag

		placeRing(nineRack)
	end
end

function PoolHudRenderer.SetPower(data, value: number)
	local v2 = math.clamp(value, 0, 1)
	local powerCue = data.PowerCue
	local scale = powerCue.Size.Y.Scale

	local v3 = scale * powerCue.AnchorPoint.Y

	data.PowerFill.Size = UDim2.fromScale(1, v2)
	data.PowerCue.Position = UDim2.fromScale(0.5, v3 + v2 * (1 - scale))
	data.PowerLabel.Text = string.format("%d%%", (math.round(v2 * 100)))
end

function PoolHudRenderer.SetTimer(p, value: number)
	local v2 = math.clamp(value, 0, 1)

	for _, panel in p.Panels do
		local timer = panel.Root:FindFirstChild("Timer")
		local fill = timer and timer:FindFirstChild("Fill")

		if fill then
			fill.Size = UDim2.fromScale(v2, 1)
		end
	end
end

local v2 = { "LeftPlayer", "RightPlayer", "SettingsButton", "QuestsButton" }

local v3 = { "PowerTrack", "PowerLabel", "SpinWidget" }

local function applyFlatRack(data) -- 2 equivalent calls inferred from this helper
	local rack = data.Root:FindFirstChild("Rack")

	if rack and rack:IsA("GuiObject") then
		rack.Visible = data.ShotControlsShown and data.FlatRackAllowed
	end
end

function PoolHudRenderer:SetPottedRackVisible(flatRackAllowed: boolean)
	self.FlatRackAllowed = flatRackAllowed
	applyFlatRack(self) -- inferred equivalent call
end

local function setNamedVisible(data, items, visible: boolean)
	for _, childName in items do
		local guiObject = data.Root:FindFirstChild(childName)

		if guiObject and guiObject:IsA("GuiObject") then
			guiObject.Visible = visible
		end
	end
end

function PoolHudRenderer:SetMatchChromeVisible(chromeShown: boolean)
	setNamedVisible(self, v2, chromeShown)

	self.ChromeShown = chromeShown
	applyNineRackVisible(self) -- inferred equivalent call
end

function PoolHudRenderer:SetShotControlsVisible(shotControlsShown: boolean)
	self.ShotControlsShown = shotControlsShown

	setNamedVisible(self, v3, shotControlsShown)
	applyFlatRack(self) -- inferred equivalent call

	if not shotControlsShown then
		PoolHudRenderer.SetSpinOpen(self, false)
	end
end

function PoolHudRenderer.SetWagerVisible(p, visible: boolean)
	p.WagerFrame.Visible = visible
end

function PoolHudRenderer.SetWager(p, p2: number)
	p.WagerLabel.Text = NumberHelper:Separate((math.round(p2)))
end

function PoolHudRenderer.SetViewToggleLabel(p, text: string)
	setButtonLabel(p.ViewToggle, text) -- inferred equivalent call
end

function PoolHudRenderer.SetCameraActive(p, flag: boolean)
	p.CameraToggle.Visible = PoolConstants.FreeRoamCamera == true

	setButtonLabel(p.CameraToggle, flag and "DONE" or "VIEW") -- inferred equivalent call
	local color2

	if flag then
		color2 = Color3.fromRGB(250, 206, 70)
	else
		color2 = Color3.fromRGB(38, 52, 68)
	end

	if PoolButtonSkin.IsSkinned(p.CameraToggle) then
		PoolButtonSkin.SetColour(p.CameraToggle, color2)
	else
		p.CameraToggle.BackgroundColor3 = color2
	end
end

function PoolHudRenderer:Notify(text: string, value: number?)
	self.BannerToken += 1

	local bannerToken = self.BannerToken
	self.BannerLabel.Text = text
	self.Banner.Visible = true

	task.delay(value or 2.5, function()
		if self.BannerToken == bannerToken then
			self.Banner.Visible = false
		end
	end)
end

function PoolHudRenderer.ShowFoul(p, p2)
	if p.FoulPopup and p2 then
		PoolFoulPopup.Show(p.FoulPopup, p2)
	end
end

function PoolHudRenderer.HideFoul(p)
	if p.FoulPopup then
		PoolFoulPopup.Hide(p.FoulPopup)
	end
end

function PoolHudRenderer:Destroy()
	PoolHudRenderer.HideFoul(self)

	for _, panel in self.Panels do
		panel.Chips = {}
	end

	self.Maid:DoCleaning()
end

return PoolHudRenderer