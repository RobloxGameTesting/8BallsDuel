local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolPlayerData = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolPlayerData)
local PoolButtonSkin = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolButtonSkin)

local PoolMenuWidgets = {}

local Menu = PoolConstants.Menu

PoolMenuWidgets.DisplayFont = Font.new(
	"rbxasset://fonts/families/Teko.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)

PoolMenuWidgets.BodyFont = Enum.Font.GothamBold

function PoolMenuWidgets.Corner(parent, p: number)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(p, 0)
	uiCorner.Parent = parent

	return uiCorner
end

function PoolMenuWidgets.Stroke(parent, thickness: number, color: Color3, value: number?)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = thickness
	uiStroke.Color = color
	uiStroke.Transparency = value or 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = parent

	return uiStroke
end

function PoolMenuWidgets.Gradient(parent, color: Color3, color2: Color3, value: number?)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new(color, color2)
	uiGradient.Rotation = value or 90
	uiGradient.Parent = parent

	return uiGradient
end

local function shade(color: Color3, p: number)
	return color:Lerp(Color3.new(0, 0, 0), p)
end

local function lift(color: Color3, p: number) -- 3 equivalent calls inferred from this helper
	return color:Lerp(Color3.new(1, 1, 1), p)
end

function PoolMenuWidgets.Label(parent, name: string, text: string, textColor: Color3, zIndex: number)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Text = text
	textLabel.FontFace = PoolMenuWidgets.DisplayFont
	textLabel.TextScaled = true
	textLabel.TextColor3 = textColor
	textLabel.ZIndex = zIndex
	textLabel.Parent = parent

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Menu.TextOutline
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uiStroke.Parent = textLabel

	return textLabel
end

local function plainControl(parent, name: string, backgroundColor: Color3, zIndex: number, p: number) -- 2 equivalent calls inferred from this helper
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.BackgroundColor3 = backgroundColor
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = true
	textButton.Text = ""
	textButton.ZIndex = zIndex
	textButton.Parent = parent
	PoolMenuWidgets.Corner(textButton, p)

	return textButton
end

function PoolMenuWidgets.Button(parent, name: string, backgroundColor: Color3, zIndex: number)
	local textButton = plainControl(parent, name, backgroundColor, zIndex, 0.16) -- inferred equivalent call
	PoolButtonSkin.Apply(textButton, { Tint = backgroundColor })

	return textButton
end

PoolMenuWidgets.SetButtonColour = PoolButtonSkin.SetColour

function PoolMenuWidgets.ButtonText(p, p2: string, p3: string?, p4: number)
	local label = PoolMenuWidgets.Label(p, "Top", p2, Menu.TextPrimary, p4 + 2)
	label.AnchorPoint = Vector2.new(0.5, 0.5)

	if p3 and p3 ~= "" then
		label.Position = UDim2.fromScale(0.5, 0.37)
		label.Size = UDim2.fromScale(0.86, 0.33)

		local label2 = PoolMenuWidgets.Label(p, "Bottom", p3, Menu.TextPrimary, p4 + 2)
		label2.AnchorPoint = Vector2.new(0.5, 0.5)
		label2.Position = UDim2.fromScale(0.5, 0.68)
		label2.Size = UDim2.fromScale(0.86, 0.2)
	else
		label.Position = UDim2.fromScale(0.5, 0.46)
		label.Size = UDim2.fromScale(0.84, 0.34)
	end

	PoolButtonSkin.CentreText(p)

	return label
end

function PoolMenuWidgets.Currency(parent, name: string, p: number, zIndex: number)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = Menu.Panel
	frame.BorderSizePixel = 0
	frame.ZIndex = zIndex
	frame.Parent = parent
	PoolMenuWidgets.Corner(frame, 0.35)
	PoolMenuWidgets.Gradient(frame, Menu.Panel, Menu.PanelShade)
	PoolMenuWidgets.Stroke(frame, 2.5, Color3.fromRGB(8, 10, 14), 0.15)

	local coin = Instance.new("ImageLabel")
	coin.Name = "Coin"
	coin.AnchorPoint = Vector2.new(0, 0.5)
	coin.Position = UDim2.fromScale(0.03, 0.5)
	coin.Size = UDim2.fromScale(0.9, 0.66)
	coin.BackgroundTransparency = 1
	coin.Image = Menu.CoinImage
	coin.ZIndex = zIndex + 1
	coin.Parent = frame

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = coin

	local label = PoolMenuWidgets.Label(frame, "Amount", PoolPlayerData.FormatCoins(p), Menu.TextPrimary, zIndex + 1)
	label.AnchorPoint = Vector2.new(1, 0.5)
	label.Position = UDim2.fromScale(0.8, 0.5)
	label.Size = UDim2.fromScale(0.58, 0.42)
	label.TextXAlignment = Enum.TextXAlignment.Right

	local button = PoolMenuWidgets.Button(frame, "Add", Menu.Shop, zIndex + 1)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.fromScale(0.975, 0.5)
	button.Size = UDim2.fromScale(0.9, 0.72)

	local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint2.AspectRatio = 1
	uiAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint2.Parent = button

	local label2 = PoolMenuWidgets.Label(button, "Sign", "+", Menu.TextPrimary, zIndex + 3)
	label2.AnchorPoint = Vector2.new(0.5, 0.5)
	label2.Position = UDim2.fromScale(0.5, 0.46)
	label2.Size = UDim2.fromScale(0.7, 0.7)

	return frame, label, button
end

function PoolMenuWidgets.FeltStrip(parent, zIndex: number)
	local felt = Instance.new("Frame")
	felt.Name = "Felt"
	felt.AnchorPoint = Vector2.new(0.5, 1)
	felt.Position = UDim2.fromScale(0.5, 1)
	felt.Size = UDim2.fromScale(1, 0.26)
	felt.BackgroundColor3 = Menu.Felt
	felt.BorderSizePixel = 0
	felt.ZIndex = zIndex
	felt.Parent = parent
	PoolMenuWidgets.Gradient(felt, Menu.Felt, Menu.FeltShade)

	local rail = Instance.new("Frame")
	rail.Name = "Rail"
	rail.AnchorPoint = Vector2.new(0.5, 0)
	rail.Position = UDim2.fromScale(0.5, 0)
	rail.Size = UDim2.fromScale(1, 0.2)
	rail.BackgroundColor3 = Menu.Rail
	rail.BorderSizePixel = 0
	rail.ZIndex = zIndex
	rail.Parent = felt
	PoolMenuWidgets.Gradient(rail, Menu.Rail, Menu.RailShade)

	return felt
end

function PoolMenuWidgets.IconButton(parent, name: string, p: string, backgroundColor: Color3, zIndex: number)
	local parent2 = plainControl(parent, name, backgroundColor, zIndex, 0.5) -- inferred equivalent call
	PoolButtonSkin.Apply(parent2, { Tint = backgroundColor, Round = true })

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = parent2

	local label = PoolMenuWidgets.Label(parent2, "Glyph", p, Menu.TextPrimary, zIndex + 2)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.46)
	label.Size = UDim2.fromScale(0.62, 0.62)

	return parent2
end

function PoolMenuWidgets.Badge(parent, text: string, zIndex: number)
	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.AnchorPoint = Vector2.new(0.5, 0.5)
	badge.Position = UDim2.fromScale(0.94, 0.06)
	badge.Size = UDim2.fromScale(0.44, 0.44)
	badge.BackgroundColor3 = Color3.fromRGB(224, 52, 52)
	badge.BorderSizePixel = 0
	badge.Text = text
	badge.FontFace = PoolMenuWidgets.DisplayFont
	badge.TextScaled = true
	badge.TextColor3 = Menu.TextPrimary
	badge.ZIndex = zIndex
	badge.Parent = parent
	PoolMenuWidgets.Corner(badge, 0.5)
	PoolMenuWidgets.Stroke(badge, 2.5, Color3.fromRGB(96, 16, 16))

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = badge

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0.16, 0)
	uiPadding.PaddingBottom = UDim.new(0.16, 0)
	uiPadding.Parent = badge

	return badge
end

function PoolMenuWidgets.Bar(parent, name: string, backgroundColor: Color3, zIndex: number)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = Color3.fromRGB(12, 16, 22)
	frame.BorderSizePixel = 0
	frame.ZIndex = zIndex
	frame.ClipsDescendants = true
	frame.Parent = parent
	PoolMenuWidgets.Corner(frame, 0.5)
	PoolMenuWidgets.Stroke(frame, 2, Color3.fromRGB(6, 8, 12), 0.2)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = backgroundColor
	fill.BorderSizePixel = 0
	fill.ZIndex = zIndex + 1
	fill.Parent = frame
	PoolMenuWidgets.Corner(fill, 0.5)
	PoolMenuWidgets.Gradient(fill, lift(backgroundColor, 0.35), backgroundColor) -- inferred equivalent call

	return frame, fill
end

local function statTrack(parent, p: string, name: string, zIndex: number)
	local v = PoolConstants.CueStatInfo[p]
	local backgroundColor = if v then v.Colour else Menu.TextMuted

	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundColor3 = Color3.fromRGB(48, 59, 76)
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.ZIndex = zIndex
	frame.Parent = parent
	PoolMenuWidgets.Corner(frame, 0.5)
	PoolMenuWidgets.Stroke(frame, 1.5, Color3.fromRGB(8, 11, 16), 0.15)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = backgroundColor
	fill.BorderSizePixel = 0
	fill.ZIndex = zIndex + 1
	fill.Parent = frame
	PoolMenuWidgets.Corner(fill, 0.5)
	PoolMenuWidgets.Gradient(fill, lift(backgroundColor, 0.3), shade(backgroundColor, 0.18)) -- inferred equivalent call

	return frame, fill
end

function PoolMenuWidgets.CueStatPips(parent, zIndex: number)
	local cueStats = Instance.new("Frame")
	cueStats.Name = "CueStats"
	cueStats.AnchorPoint = Vector2.new(0.5, 1)
	cueStats.Position = UDim2.fromScale(0.5, 0.62)
	cueStats.Size = UDim2.fromScale(0.8, 0.34)
	cueStats.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
	cueStats.BackgroundTransparency = 0.12
	cueStats.BorderSizePixel = 0
	cueStats.ZIndex = zIndex
	cueStats.Parent = parent
	PoolMenuWidgets.Corner(cueStats, 0.22)
	PoolMenuWidgets.Stroke(cueStats, 2, Color3.fromRGB(6, 8, 12), 0.2)

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0.14, 0)
	uiPadding.PaddingBottom = UDim.new(0.14, 0)
	uiPadding.PaddingLeft = UDim.new(0.08, 0)
	uiPadding.PaddingRight = UDim.new(0.08, 0)
	uiPadding.Parent = cueStats

	local result = {}

	for k, v in PoolConstants.CueStatOrder do
		local v2, fill = statTrack(cueStats, v, v, zIndex + 1)
		v2.AnchorPoint = Vector2.new(0, 0.5)
		v2.Position = UDim2.fromScale((k - 1) * 0.27, 0.5)
		v2.Size = UDim2.fromScale(0.19, 1)

		fill.AnchorPoint = Vector2.new(0.5, 1)
		fill.Position = UDim2.fromScale(0.5, 1)
		fill.Size = UDim2.fromScale(1, 0)

		result[v] = { Fill = fill }
	end

	return cueStats, result
end

function PoolMenuWidgets.CueStatPanel(parent, zIndex: number)
	local cueStats = Instance.new("Frame")
	cueStats.Name = "CueStats"
	cueStats.BackgroundTransparency = 1
	cueStats.BorderSizePixel = 0
	cueStats.ZIndex = zIndex
	cueStats.Parent = parent

	local result = {}

	for k, name in PoolConstants.CueStatOrder do
		local v = PoolConstants.CueStatInfo[name]
		local v2 = (k - 1) % 2
		local v3 = math.floor((k - 1) / 2)

		local frame = Instance.new("Frame")
		frame.Name = name
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Position = UDim2.fromScale(v2 * 0.52, v3 * 0.54)
		frame.Size = UDim2.fromScale(0.48, 0.46)
		frame.ZIndex = zIndex
		frame.Parent = cueStats

		local label = PoolMenuWidgets.Label(frame, "Label", v.Label, Menu.TextMuted, zIndex + 1)
		label.Position = UDim2.fromScale(0, 0)
		label.Size = UDim2.fromScale(0.68, 0.54)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local label2 = PoolMenuWidgets.Label(frame, "Value", "0", v.Colour, zIndex + 1)
		label2.AnchorPoint = Vector2.new(1, 0)
		label2.Position = UDim2.fromScale(1, 0)
		label2.Size = UDim2.fromScale(0.3, 0.54)
		label2.TextXAlignment = Enum.TextXAlignment.Right

		for _, v4 in { label, label2 } do
			local uiStroke = v4:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke.Thickness = 1.5
			end
		end

		local v4, fill = statTrack(frame, name, "Track", zIndex + 1)
		v4.AnchorPoint = Vector2.new(0, 1)
		v4.Position = UDim2.fromScale(0, 0.82)
		v4.Size = UDim2.fromScale(1, 0.26)

		fill.AnchorPoint = Vector2.new(0, 0.5)
		fill.Position = UDim2.fromScale(0, 0.5)
		fill.Size = UDim2.fromScale(0, 1)

		local preview, previewFill = statTrack(frame, name, "PreviewTrack", zIndex + 1)
		preview.AnchorPoint = Vector2.new(0, 1)
		preview.Position = UDim2.fromScale(0, 1)
		preview.Size = UDim2.fromScale(1, 0.16)
		preview.Visible = false

		previewFill.Name = "PreviewFill"
		previewFill.AnchorPoint = Vector2.new(0, 0.5)
		previewFill.Position = UDim2.fromScale(0, 0.5)
		previewFill.Size = UDim2.fromScale(0, 1)
		previewFill.BackgroundColor3 = Menu.UpgradePreview

		local uiGradient = previewFill:FindFirstChildOfClass("UIGradient")

		if uiGradient then
			uiGradient:Destroy()
		end

		PoolMenuWidgets.Gradient(previewFill, lift(Menu.UpgradePreview, 0.3), shade(Menu.UpgradePreview, 0.18)) -- inferred equivalent call

		result[name] = { Fill = fill, Value = label2, Preview = preview, PreviewFill = previewFill }
	end

	return cueStats, result
end

function PoolMenuWidgets.ReadCueStats(instance)
	local cueStats = {}

	for _, childName in PoolConstants.CueStatOrder do
		local child = instance:FindFirstChild(childName)
		local fill = child and child:FindFirstChild("Fill", true)
		local value = child and child:FindFirstChild("Value", true)

		local previewTrack = child and child:FindFirstChild("PreviewTrack", true)
		local previewFill = child and child:FindFirstChild("PreviewFill", true)

		if not (fill and fill:IsA("Frame")) then
			continue
		end

		if not (value and value:IsA("TextLabel")) then
			value = nil
		end

		if not (previewTrack and previewTrack:IsA("Frame")) then
			previewTrack = nil
		end

		if not (previewFill and previewFill:IsA("Frame")) then
			previewFill = nil
		end

		cueStats[childName] = {
			Fill = fill,
			Value = value,
			Preview = previewTrack,
			PreviewFill = previewFill
		}
	end

	return cueStats
end

function PoolMenuWidgets.WriteCueStats(p, p2: string?, flag: boolean?, p3: number?, p4: number?)
	for _, v in PoolConstants.CueStatOrder do
		local v2 = p[v]

		if not v2 then
			continue
		end

		local cueRating = PoolConstants.CueRating(p2, v, p3)

		local v3 = math.max(cueRating / PoolConstants.CueStatMax, 0.07)

		local fill = v2.Fill
		local size

		if flag then
			size = UDim2.fromScale(1, v3)
		else
			size = UDim2.fromScale(v3, 1)
		end

		fill.Size = size

		if v2.Value then
			v2.Value.Text = tostring((math.round(cueRating)))
		end

		if not (v2.Preview and v2.PreviewFill) then
			continue
		end

		local v4

		if p4 then
			v4 = PoolConstants.CueRating(p2, v, p4)
		else
			v4 = cueRating
		end

		if v4 <= cueRating then
			v2.Preview.Visible = false
		else
			local v5 = math.max(v4 / PoolConstants.CueStatMax, 0.07)

			v2.Preview.Visible = true
			local previewFill = v2.PreviewFill
			local size2

			if flag then
				size2 = UDim2.fromScale(1, v5)
			else
				size2 = UDim2.fromScale(v5, 1)
			end

			previewFill.Size = size2
		end
	end
end

function PoolMenuWidgets.Sparkles(parent, backgroundColor: Color3, zIndex: number)
	local TweenService = game:GetService("TweenService")

	local sparkles = Instance.new("Frame")
	sparkles.Name = "Sparkles"
	sparkles.Size = UDim2.fromScale(1, 1)
	sparkles.BackgroundTransparency = 1
	sparkles.BorderSizePixel = 0
	sparkles.ZIndex = zIndex
	sparkles.Active = false
	sparkles.Selectable = false
	sparkles.Parent = parent

	for k, v in {
		{ 0.08, 0.22, 0.3 },
		{ 0.21, 0.74, 0.2 },
		{ 0.37, 0.15, 0.16 },
		{ 0.52, 0.86, 0.26 },
		{ 0.68, 0.24, 0.18 },
		{ 0.81, 0.7, 0.3 },
		{ 0.94, 0.3, 0.22 },
		{ 0.63, 0.55, 0.14 }
	} do
		local frame = Instance.new("Frame")
		frame.Name = string.format("Star%d", k)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(v[1], v[2])

		frame.Size = UDim2.fromScale(v[3], v[3])
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ZIndex = zIndex
		frame.Active = false
		frame.Selectable = false
		frame.Parent = sparkles

		local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uiAspectRatioConstraint.AspectRatio = 1
		uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
		uiAspectRatioConstraint.Parent = frame

		for _, v2 in {
			{ 0.22, 1 },
			{ 1, 0.22 }
		} do
			local frame2 = Instance.new("Frame")
			frame2.AnchorPoint = Vector2.new(0.5, 0.5)
			frame2.Position = UDim2.fromScale(0.5, 0.5)
			frame2.Size = UDim2.fromScale(v2[1], v2[2])
			frame2.BackgroundColor3 = backgroundColor
			frame2.BorderSizePixel = 0
			frame2.ZIndex = zIndex
			frame2.Active = false
			frame2.Selectable = false
			frame2.Parent = frame

			local uiGradient = Instance.new("UIGradient")

			uiGradient.Rotation = v2[2] > v2[1] and 90 or 0
			uiGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1)
			})

			uiGradient.Parent = frame2
		end

		local v2 = 0.9 + k % 5 * 0.37
		local v3 = k % 7 * 0.31

		frame.BackgroundTransparency = 1

		TweenService:Create(frame, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, v3), {
			Size = UDim2.fromScale(v[3] * 0.25, v[3] * 0.25)
		}):Play()
	end

	return sparkles
end

function PoolMenuWidgets.Starburst(parent, backgroundColor: Color3, zIndex: number, value: number?, value2: number?)
	local TweenService = game:GetService("TweenService")

	local starburst = Instance.new("Frame")
	starburst.Name = "Starburst"
	starburst.AnchorPoint = Vector2.new(0.5, 0.5)
	starburst.BackgroundTransparency = 1
	starburst.BorderSizePixel = 0
	starburst.ZIndex = zIndex

	starburst.Active = false
	starburst.Selectable = false
	starburst.Parent = parent

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.Parent = starburst

	local v = math.max(math.floor(value or 8), 2)

	for i = 1, v do
		local frame = Instance.new("Frame")
		frame.Name = string.format("Ray%d", i)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)

		frame.Size = UDim2.fromScale(0.055, 0.92)
		frame.Rotation = (i - 1) * (180 / v)
		frame.BackgroundColor3 = backgroundColor
		frame.BorderSizePixel = 0
		frame.ZIndex = zIndex
		frame.Active = false
		frame.Selectable = false
		frame.Parent = starburst

		local uiGradient = Instance.new("UIGradient")
		uiGradient.Rotation = 90
		uiGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.32, 0.35),
			NumberSequenceKeypoint.new(0.5, 0.15),
			NumberSequenceKeypoint.new(0.68, 0.35),
			NumberSequenceKeypoint.new(1, 1)
		})

		uiGradient.Parent = frame
	end

	local tween = TweenService:Create(
		starburst,
		TweenInfo.new(value2 or 14, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0),
		{ Rotation = 360 }
	)

	tween:Play()

	return starburst, tween
end

function PoolMenuWidgets.LockIcon(parent, color: Color3, zIndex: number)
	local lock = Instance.new("Frame")
	lock.Name = "Lock"
	lock.BackgroundTransparency = 1
	lock.BorderSizePixel = 0
	lock.ZIndex = zIndex
	lock.Parent = parent

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 0.76

	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = lock

	local shackle = Instance.new("Frame")
	shackle.Name = "Shackle"
	shackle.AnchorPoint = Vector2.new(0.5, 0)
	shackle.Position = UDim2.fromScale(0.5, 0.02)
	shackle.Size = UDim2.fromScale(0.58, 0.62)
	shackle.BackgroundTransparency = 1
	shackle.BorderSizePixel = 0
	shackle.ZIndex = zIndex
	shackle.Parent = lock

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = shackle

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = color
	uiStroke.Parent = shackle

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.AnchorPoint = Vector2.new(0.5, 1)
	body.Position = UDim2.fromScale(0.5, 1)
	body.Size = UDim2.fromScale(1, 0.58)
	body.BackgroundColor3 = color
	body.BorderSizePixel = 0
	body.ZIndex = zIndex + 1
	body.Parent = lock
	PoolMenuWidgets.Corner(body, 0.22)

	return lock
end

function PoolMenuWidgets.FindSkinModel(p)
	if
		typeof(p) ~= "table"
		or typeof(p.modelFolder) ~= "table"
		or (typeof(p.modelName) ~= "string" or p.modelName == "")
	then
		return nil
	end

	local child = ReplicatedStorage

	for _, childName in p.modelFolder do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	local model = child:FindFirstChild(p.modelName)

	return if model and model:IsA("Model") then model else nil
end

local function frameModel(parent, camera, clone)
	local boundingBox, v = clone:GetBoundingBox()
	local v2 = v / 2

	if v2.Magnitude <= 0 then
		return
	end

	local unit = (Vector3.new(0.55, 0.62, 0.55)).Unit
	local cframe = CFrame.lookAt(boundingBox.Position + unit, boundingBox.Position)
	local rightVector = cframe.RightVector
	local upVector = cframe.UpVector
	local maxValue = 0
	local maxValue2 = 0

	for i = -1, 1, 2 do
		for j = -1, 1, 2 do
			for k = -1, 1, 2 do
				local vector3 = Vector3.new(i * v2.X, j * v2.Y, k * v2.Z)
				maxValue = math.max(maxValue, (math.abs((vector3:Dot(rightVector)))))
				maxValue2 = math.max(maxValue2, (math.abs((vector3:Dot(upVector)))))
			end
		end
	end

	local v3 = not (parent.AbsoluteSize.Y > 0) and 1 or math.max(parent.AbsoluteSize.X, 1) / parent.AbsoluteSize.Y

	local fieldOfView = math.rad(camera.FieldOfView)
	local v4 = math.atan(math.tan(fieldOfView / 2) * v3) * 2

	local v5 = math.max(maxValue2 / math.tan(fieldOfView / 2), maxValue / math.tan(v4 / 2)) * 1.15

	camera.CFrame = CFrame.lookAt(boundingBox.Position + unit * v5, boundingBox.Position)
end

function PoolMenuWidgets:ModelPreview(instance, maid)
	self:ClearAllChildren()

	if not instance then
		return
	end

	local clone = instance:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.Anchored = true
	end

	clone.Parent = self

	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.Parent = self
	self.CurrentCamera = camera

	if maid then
		maid:GiveTask(clone)
		maid:GiveTask(camera)
	end

	frameModel(self, camera, clone)

	local absoluteSizeChangedConnection = self:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if clone.Parent == self and camera.Parent == self then
			frameModel(self, camera, clone)
		end
	end)

	if maid then
		maid:GiveTask(absoluteSizeChangedConnection)
	end
end

function PoolMenuWidgets:CuePreview(instance)
	self:ClearAllChildren()

	if not instance then
		return
	end

	local clone = instance:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
	end

	local boundingBox, v = clone:GetBoundingBox()

	local v2 = {
		{ Direction = boundingBox.RightVector, Span = v.X },
		{ Direction = boundingBox.UpVector, Span = v.Y },
		{ Direction = boundingBox.LookVector, Span = v.Z }
	}

	local v3 = 1

	local v4 = v2[2].Span > v2[v3].Span and 2 or v3
	local v5 = v2[3].Span > v2[v4].Span and 3 or v4

	local v6 = v5 == 2 and 3 or 2

	local v7 = 6 - v5 - v6

	local span = v2[v5].Span

	local span2 = v2[v7].Span

	local span3 = v2[v6].Span

	local objectSpace = boundingBox:ToObjectSpace(clone:GetPivot())

	local cframe = CFrame.fromMatrix(Vector3.new(0, 0, 0), v2[v5].Direction, v2[v6].Direction)
	clone:PivotTo(CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0.6156615, 0.7880108, 0), Vector3.new(0, 0, 1)) * cframe:Inverse() * boundingBox.Rotation * objectSpace)
	clone.Parent = self

	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.Parent = self
	self.CurrentCamera = camera

	local function frame()
		local v8 = not (self.AbsoluteSize.Y > 0) and 1 or math.max(self.AbsoluteSize.X, 1) / self.AbsoluteSize.Y
		local v9 = math.tan(math.rad(camera.FieldOfView) / 2)
		local v10 = v9 * v8
		local v11 = span / 2 * 0.6156614753256583 + span2 / 2 * 0.788010753606722
		local v12 = math.max((span / 2 * 0.788010753606722 + span2 / 2 * 0.6156614753256583) / v9, v11 / v10) * 1.08 + span3

		camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, v12), Vector3.new(0, 0, 0))
	end

	frame()
	self:GetPropertyChangedSignal("AbsoluteSize"):Connect(frame)
end

return PoolMenuWidgets