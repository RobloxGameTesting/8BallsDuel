local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events = require(ReplicatedStorage.Libraries.Modules.Events)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local Inventories = require(ReplicatedStorage.Libraries.Classes.Inventories)
local PoolButtonSkin = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolButtonSkin)

local PoolSeasonHype = {}

local rbxassetfontsfamiliesDenkOnejson = Font.new("rbxasset://fonts/families/DenkOne.json", Enum.FontWeight.Bold)
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
local color = Color3.fromRGB(30, 30, 30)

local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 40)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 240, 60)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(70, 230, 110)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(70, 160, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 90, 255))
})

local color2 = Color3.fromRGB(40, 52, 96)
local color3 = Color3.fromRGB(16, 18, 38)
local color4 = Color3.fromRGB(62, 74, 120)
local color5 = Color3.fromRGB(30, 36, 66)
local color6 = Color3.fromRGB(20, 20, 20)

local color7 = Color3.fromRGB(255, 213, 79)
local color8 = Color3.fromRGB(200, 206, 228)
local color9 = Color3.new(1, 1, 1)

local color10 = Color3.fromRGB(114, 220, 78)

local function make(className: string, p) -- 27 equivalent calls inferred from this helper
	local instance = Instance.new(className)

	for k, v in p do
		if k ~= "Parent" then
			instance[k] = v
		end
	end

	if p.Parent then
		instance.Parent = p.Parent
	end

	return instance
end

local function label(parent, text: string, items)
	local result = make("TextLabel", { -- inferred equivalent call
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesDenkOnejson,
		TextColor3 = color9,
		TextScaled = true,
		Text = text,
		Parent = parent
	})

	make("UIStroke", { Thickness = 2, Color = color, Parent = result }) -- inferred equivalent call

	for k, item in items do
		result[k] = item
	end

	return result
end

local function seasonGradient(activeMission) -- 2 equivalent calls inferred from this helper
	local textGradient = activeMission and activeMission.textGradient

	if typeof(textGradient) == "ColorSequence" then
		return textGradient
	end

	return colorSequence
end

local function panel(parent, flag: boolean, items)
	local result = make("Frame", { BackgroundColor3 = color9, BorderSizePixel = 0, Parent = parent }) -- inferred equivalent call
	local v = if flag then color4 else color2
	local v2 = if flag then color5 else color3
	make("UIGradient", { Rotation = 90, Color = ColorSequence.new(v, v2), Parent = result }) -- inferred equivalent call

	make("UICorner", { -- inferred equivalent call
		CornerRadius = UDim.new(flag and 0.1 or 0.2, 0),
		Parent = result
	})
	make("UIStroke", { -- inferred equivalent call
		Name = "Rim",
		Thickness = flag and 2.5 or 3,
		Color = color6,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = result
	})

	for k, item in items do
		result[k] = item
	end

	return result
end

local function evenText(instance, list, scale) -- 2 equivalent calls inferred from this helper
	local function fit()
		local item = list[1]

		if not item or item.AbsoluteSize.Y <= 0 then
			return
		end

		local textSize = math.floor(item.AbsoluteSize.Y / math.max(scale.Scale, 0.01) * 0.9)

		for _, item2 in list do
			item2.TextScaled = false
		end

		while textSize > 8 do
			local flag = true

			for _, item2 in list do
				item2.TextSize = textSize

				if not item2.TextFits then
					flag = false
				end
			end

			if flag then
				break
			end

			textSize -= 1
		end
	end

	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	task.defer(fit)
end

local function clock(p: number) -- 1 equivalent call inferred from this helper
	local v = math.max(0, (math.floor(p)))

	local v2 = v // 86400
	local v3 = v % 86400 // 3600

	if v2 > 0 then
		return string.format("%dd %dh", v2, v3)
	end

	return string.format("%dh %dm", v3, v % 3600 // 60)
end

local function build(state)
	local activeMission = Events:GetActiveMission()
	local hype = activeMission and activeMission.hype

	for _, uiGradient in state.Root:GetChildren() do
		if not uiGradient:IsA("UIGradient") then
			uiGradient:Destroy()
		end
	end

	state.BuiltFor = activeMission and activeMission.eventName

	if typeof(hype) ~= "table" then
		return
	end

	local root = state.Root

	if typeof(hype.image) == "string" and hype.image ~= "" then
		make("ImageLabel", { -- inferred equivalent call
			Name = "Art",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = hype.image,
			ImageTransparency = 0.25,
			ScaleType = Enum.ScaleType.Crop,
			Parent = root
		})
	end

	for k, v in { 0.28, 0.72 } do
		local parent = make("Frame", { -- inferred equivalent call
			Name = "Band" .. k,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, v),
			Size = UDim2.fromScale(1.6, 0.16),
			Rotation = k == 1 and -8 or 8,
			BackgroundColor3 = color9,
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			Parent = root
		})

		make("UIGradient", { Color = seasonGradient(activeMission), Parent = parent }) -- inferred equivalent call
	end

	local parent = label(root, string.upper(activeMission.eventName or "NEW SEASON"), {
		Name = "Title",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.05),
		Size = UDim2.fromScale(0.86, 0.15)
	})

	make("UIGradient", { Color = seasonGradient(activeMission), Parent = parent }) -- inferred equivalent call
	local uiStroke = parent:FindFirstChildOfClass("UIStroke")
	uiStroke.Thickness = 4

	label(root, tostring(hype.tagline or ""), {
		Name = "Tagline",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.2),
		Size = UDim2.fromScale(0.6, 0.065),
		TextColor3 = color7
	})
	label(root, "ENDS IN " .. clock(Events:TimeLeft()), { -- inferred equivalent call
		Name = "Ends",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.27),
		Size = UDim2.fromScale(0.3, 0.04),
		TextColor3 = color8,
		FontFace = rbxassetfontsfamiliesGothamSSmjson
	})

	local parent2 = make("Frame", { -- inferred equivalent call
		Name = "Showcase",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.34),
		Size = UDim2.fromScale(0.88, 0.34),
		BackgroundTransparency = 1,
		Parent = root
	})

	make("UIListLayout", { -- inferred equivalent call
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.025, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent2
	})

	local v = {}

	for k, v2 in typeof(hype.showcase) ~= "table" and {} or hype.showcase do
		local parent3 = panel(parent2, true, {
			Name = "Card" .. k,
			LayoutOrder = k,
			Size = UDim2.fromScale(0.21, 1)
		})

		local rim = parent3:FindFirstChild("Rim")
		rim.Color = color9
		rim.Thickness = 3
		make("UIGradient", { Color = colorSequence, Rotation = 45, Parent = rim }) -- inferred equivalent call

		local parent4 = make("Frame", { -- inferred equivalent call
			Name = "Tile",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.06),
			Size = UDim2.fromScale(0.86, 0.68),
			BackgroundTransparency = 1,
			Parent = parent3
		})

		make("UIAspectRatioConstraint", { AspectRatio = 1, Parent = parent4 }) -- inferred equivalent call

		if typeof(v2.reward) == "table" then
			local success, result = pcall(function()
				Inventories.fromList({ Key = v2.reward }, parent4, "misc", "v1")
			end)

			if not success then
				warn("[PoolSeasonHype] showcase tile failed: " .. tostring(result))
			end
		end

		table.insert(
			v,
			label(parent3, tostring(v2.label or ""), {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 0.95),
				Size = UDim2.fromScale(0.9, 0.17)
			})
		)
	end

	evenText(parent2, v, state.Scale) -- inferred equivalent call

	local parent3 = panel(root, false, {
		Name = "PointsPanel",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.7),
		Size = UDim2.fromScale(0.88, 0.14)
	})

	local parent4 = make("Frame", { -- inferred equivalent call
		Name = "Points",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.95, 0.74),
		BackgroundTransparency = 1,
		Parent = parent3
	})

	make("UIGridLayout", { -- inferred equivalent call
		CellSize = UDim2.fromScale(0.49, 0.45),
		CellPadding = UDim2.fromScale(0.02, 0.1),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent4
	})

	local currencyInfo = Events:GetCurrencyInfo()
	local icon

	if currencyInfo and currencyInfo.icon ~= "" then
		icon = currencyInfo.icon
	end

	local color11

	if currencyInfo and typeof(currencyInfo.tint) == "ColorSequence" then
		color11 = currencyInfo.tint
	else
		color11 = activeMission and activeMission.textGradient

		if typeof(color11) ~= "ColorSequence" then
			color11 = colorSequence
		end
	end

	local v2 = {}

	for k, v3 in typeof(hype.points) ~= "table" and {} or hype.points do
		local parent5 = make("Frame", { -- inferred equivalent call
			LayoutOrder = k,
			BackgroundTransparency = 1,
			Parent = parent4
		})

		local parent6 = make("ImageLabel", { -- inferred equivalent call
			BackgroundTransparency = 1,
			Image = icon or "rbxassetid://91068843812037",
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.08, 1),
			Parent = parent5
		})

		if not icon then
			make("UIGradient", { Color = color11, Rotation = 45, Parent = parent6 }) -- inferred equivalent call
		end

		table.insert(
			v2,
			label(parent5, tostring(v3), {
				Position = UDim2.fromScale(0.1, 0),
				Size = UDim2.fromScale(0.9, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = rbxassetfontsfamiliesGothamSSmjson
			})
		)
	end

	evenText(parent4, v2, state.Scale) -- inferred equivalent call

	local parent5 = make("TextButton", { -- inferred equivalent call
		Name = "PlaySeason",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.965),
		Size = UDim2.fromScale(0.3, 0.1),
		BackgroundColor3 = color10,
		AutoButtonColor = true,
		Text = "",
		ZIndex = 2,
		Parent = root
	})

	label(parent5, "PLAY SEASON", {
		Name = "Top",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.46),
		Size = UDim2.fromScale(0.86, 0.6),
		ZIndex = 4
	})

	PoolButtonSkin.Apply(parent5, { Tint = color10, Round = false })

	parent5.Activated:Connect(function()
		PoolSeasonHype.Hide(state)
		state.OnPlay()
	end)

	local parent6 = make("TextButton", { -- inferred equivalent call
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(0.975, 0.04),
		Size = UDim2.fromScale(0.07, 0.1),
		BackgroundColor3 = PoolButtonSkin.Exit.Colour,
		AutoButtonColor = true,
		Text = "",
		ZIndex = 2,
		Parent = root
	})

	make("UIAspectRatioConstraint", { AspectRatio = 1, Parent = parent6 }) -- inferred equivalent call
	PoolButtonSkin.ApplyExit(parent6)

	parent6.Activated:Connect(function()
		PoolSeasonHype.Hide(state)
	end)
end

function PoolSeasonHype.new(onPlay)
	local localPlayer = Players.LocalPlayer
	local v = make("ScreenGui", { -- inferred equivalent call
		Name = "SeasonHypeUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 13,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false,
		Parent = localPlayer:WaitForChild("PlayerGui")
	})

	local v2 = make("Frame", { -- inferred equivalent call
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(16, 6, 34),
		BorderSizePixel = 0,
		Active = true,
		Parent = v
	})

	make("UIGradient", { -- inferred equivalent call
		Rotation = 90,
		Color = ColorSequence.new(Color3.fromRGB(70, 30, 130), Color3.fromRGB(10, 10, 40)),
		Parent = v2
	})

	local scale = make("UIScale", { Parent = v2 }) -- inferred equivalent call

	return {
		Gui = v,
		Root = v2,
		Scale = scale,
		OnPlay = onPlay,
		BuiltFor = nil
	}
end

function PoolSeasonHype.IsVisible(p)
	return p.Gui.Enabled
end

function PoolSeasonHype.Show(p)
	build(p)

	p.Scale.Scale = 0.92
	p.Gui.Enabled = true

	TweenService:Create(p.Scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()

	RemoteSignals.FireServer("Events", "EventHypeSeen")
end

function PoolSeasonHype.Hide(p)
	p.Gui.Enabled = false
end

return PoolSeasonHype