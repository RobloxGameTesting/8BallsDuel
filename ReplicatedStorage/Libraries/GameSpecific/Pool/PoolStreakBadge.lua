local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

local PoolStreakBadge = {}

local WinStreak = PoolConstants.WinStreak

local udim = UDim2.fromScale(0.51, 0.64)
local udim2 = UDim2.fromScale(0.56, 0.42)

local rbxassetfontsfamiliesTekojson = Font.new("rbxasset://fonts/families/Teko.json", Enum.FontWeight.Bold)
local color = Color3.fromRGB(30, 30, 30)

local v = {
	TopRight = UDim2.fromScale(0.88, 0.1),
	TopLeft = UDim2.fromScale(0.12, 0.1),
	BottomRight = UDim2.fromScale(0.88, 0.9),
	BottomLeft = UDim2.fromScale(0.12, 0.9)
}

local function oppositeLevel(instance)
	local levelBadge = instance:FindFirstChild("LevelBadge")

	if not (levelBadge and levelBadge:IsA("GuiObject")) then
		return nil
	end

	local position = levelBadge.Position
	local size = levelBadge.Size
	local anchorPoint = levelBadge.AnchorPoint
	local v2 = position.X.Scale + (0.5 - anchorPoint.X) * size.X.Scale
	local v3 = position.Y.Scale + (0.5 - anchorPoint.Y) * size.Y.Scale

	return UDim2.fromScale(1 - v2, v3)
end

local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function topZ(folder, ancestor)
	local zIndex = folder.ZIndex

	for _, guiObject in folder:GetDescendants() do
		if not (guiObject:IsA("GuiObject") and (not ancestor or guiObject ~= ancestor and not guiObject:IsDescendantOf(ancestor))) then
			continue
		end

		zIndex = math.max(zIndex, guiObject.ZIndex)
	end

	return zIndex
end

local function build(parent)
	local streakAnchor = Instance.new("Frame")
	streakAnchor.Name = "StreakAnchor"
	streakAnchor.AnchorPoint = Vector2.new(0.5, 0.5)
	streakAnchor.Position = UDim2.fromScale(0.5, 0.5)
	streakAnchor.Size = UDim2.fromScale(1, 1)
	streakAnchor.BackgroundTransparency = 1
	streakAnchor.BorderSizePixel = 0
	streakAnchor.Active = false
	streakAnchor.Visible = false

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.Parent = streakAnchor

	local streakBadge = Instance.new("Frame")
	streakBadge.Name = "StreakBadge"
	streakBadge.AnchorPoint = Vector2.new(0.5, 0.5)
	streakBadge.Size = UDim2.fromScale(0.58, 0.58)
	streakBadge.BackgroundTransparency = 1
	streakBadge.BorderSizePixel = 0
	streakBadge.Active = false
	streakBadge.Parent = streakAnchor

	local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint2.AspectRatio = 1
	uiAspectRatioConstraint2.Parent = streakBadge

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MinSize = Vector2.new(24, 24)
	uiSizeConstraint.Parent = streakBadge

	local pop = Instance.new("UIScale")
	pop.Name = "Pop"
	pop.Parent = streakBadge

	if WinStreak.Icon == "" then
		local placeholder = WinStreak.Placeholder or "★"
		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.fromScale(1, 1)
		icon.BackgroundTransparency = 1
		icon.Text = placeholder
		icon.TextScaled = true
		icon.Font = Enum.Font.GothamBlack
		icon.TextColor3 = WinStreak.PlaceholderColour
		icon.Active = false
		icon.Parent = streakBadge

		if placeholder == "★" then
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = WinStreak.TextOutline
			uiStroke.Thickness = 1.5
			uiStroke.Parent = icon
		end
	else
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.fromScale(1, 1)
		icon.BackgroundTransparency = 1
		icon.Image = WinStreak.Icon
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Active = false
		icon.Parent = streakBadge
	end

	local count = Instance.new("TextLabel")
	count.Name = "Count"
	count.AnchorPoint = Vector2.new(0.5, 0.5)
	count.Position = udim
	count.Size = udim2
	count.BackgroundTransparency = 1
	count.TextScaled = true
	count.FontFace = rbxassetfontsfamiliesTekojson
	count.TextColor3 = WinStreak.Text
	count.Text = ""
	count.Active = false
	count.Parent = streakBadge

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = 2
	uiStroke.Parent = count

	streakAnchor.Parent = parent

	return streakAnchor
end

local function lift(instance, instance2)
	local zIndex = topZ(instance, instance2) + 1
	local streakBadge = instance2:FindFirstChild("StreakBadge")

	instance2.ZIndex = zIndex
	streakBadge.ZIndex = zIndex + 1

	for _, guiObject in streakBadge:GetDescendants() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local zIndex2

		if guiObject.Name == "Count" then
			zIndex2 = zIndex + 3
		else
			zIndex2 = zIndex + 2
		end

		guiObject.ZIndex = zIndex2
	end
end

function PoolStreakBadge.Set(instance, p: number?, value: string?)
	if not instance then
		return
	end

	local v2 = math.floor(tonumber(p) or 0)
	local v3 = instance:FindFirstChild("StreakAnchor")

	if v2 < WinStreak.MinStreak then
		if v3 then
			v3.Visible = false
			v3:SetAttribute("Shown", 0)
		end
	else
		v3 = v3 or build(instance)

		local streakBadge = v3:FindFirstChild("StreakBadge")
		local count = streakBadge:FindFirstChild("Count")
		local shown = tonumber(v3:GetAttribute("Shown")) or 0

		streakBadge.Position = oppositeLevel(instance) or v[value or "BottomRight"] or v.BottomRight
		count.Text = tostring(v2)
		lift(instance, v3)
		v3.Visible = true
		v3:SetAttribute("Shown", v2)

		local pop = shown > 0 and shown < v2 and streakBadge:FindFirstChild("Pop")

		if pop then
			pop.Scale = 1.35
			TweenService:Create(pop, tweenInfo, { Scale = 1 }):Play()
		end
	end
end

function PoolStreakBadge.Clear(p)
	PoolStreakBadge.Set(p, nil)
end

function PoolStreakBadge.ForSeat(data)
	if typeof(data) ~= "table" or ((tonumber(data.UserId) or 0) <= 0 or data.IsBot == true) then
		return nil
	end

	return (tonumber(data.WinStreak))
end

return PoolStreakBadge