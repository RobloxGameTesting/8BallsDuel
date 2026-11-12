local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAchievements = require(Pool.PoolAchievements)
local PoolAudio = require(Pool.PoolAudio)
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)

local PoolAchievementsMenu = {}

local LocalPlayer = Players.LocalPlayer

local color = Color3.fromRGB(120, 215, 255)
local color2 = Color3.fromRGB(255, 213, 79)
local color3 = Color3.fromRGB(114, 220, 78)
local color4 = Color3.fromRGB(118, 122, 134)
local color5 = Color3.fromRGB(230, 170, 40)
local color6 = Color3.fromRGB(84, 90, 108)
local color7 = Color3.fromRGB(176, 186, 210)
local color8 = Color3.fromRGB(44, 58, 104)
local color9 = Color3.fromRGB(26, 32, 64)
local color10 = Color3.fromRGB(12, 14, 26)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local v = {
	Built = false,
	Gui = nil,
	Panel = nil,
	PanelSize = nil,
	Rows = {},
	Claiming = nil
}

local function data() -- 4 equivalent calls inferred from this helper
	local playerReplica = Profiles.GetPlayerReplica((tostring(LocalPlayer.UserId)))

	return playerReplica and playerReplica.Data
end

local function shade(color11: Color3, p: number) -- 1 equivalent call inferred from this helper
	return color11:Lerp(Color3.new(0, 0, 0), p)
end

local function lift(tierColour: Color3, p: number) -- 1 equivalent call inferred from this helper
	return tierColour:Lerp(Color3.new(1, 1, 1), p)
end

local function separate(p: number) -- 3 equivalent calls inferred from this helper
	return (tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function label(frame, p: string, p2: string, color11: Color3, p3: number, p4: number, p5: number, p6: number, p7: number, p8)
	local label2 = PoolMenuWidgets.Label(frame, p, p2, color11, p3)
	label2.Position = UDim2.fromScale(p4, p5)
	label2.Size = UDim2.fromScale(p6, p7)
	label2.TextXAlignment = p8 or Enum.TextXAlignment.Left

	return label2
end

local function buildRow(parent, data2, layoutOrder: number, claim)
	local frame = Instance.new("Frame")
	frame.Name = data2.Id
	frame.LayoutOrder = layoutOrder
	frame.Size = UDim2.new(1, -14, 0, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BorderSizePixel = 0
	frame.ZIndex = 20
	frame.Parent = parent
	PoolMenuWidgets.Corner(frame, 0.16)
	PoolMenuWidgets.Gradient(frame, color8, color9)
	PoolMenuWidgets.Stroke(frame, 2.5, color10, 0.1)

	local badge = Instance.new("Frame")
	badge.Name = "Badge"
	badge.AnchorPoint = Vector2.new(0, 0.5)
	badge.Position = UDim2.fromScale(0.012, 0.5)
	badge.Size = UDim2.fromScale(1, 0.84)
	badge.BackgroundColor3 = Color3.new(1, 1, 1)
	badge.BorderSizePixel = 0
	badge.ZIndex = 21
	badge.Parent = frame
	PoolMenuWidgets.Corner(badge, 0.5)

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = badge

	local gradient = PoolMenuWidgets.Gradient(badge, color6, color6)
	local stroke = PoolMenuWidgets.Stroke(badge, 3, color10)
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = badge
	local icon

	if data2.Image and data2.Image ~= "" then
		icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.Image = data2.Image
		icon.ScaleType = Enum.ScaleType.Fit
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.45)
		icon.Size = UDim2.fromScale(0.62, 0.62)
	else
		icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.Text = data2.Icon
		icon.TextScaled = true
		icon.Font = Enum.Font.GothamBold
		icon.TextColor3 = Color3.new(1, 1, 1)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.44)
		icon.Size = UDim2.fromScale(0.56, 0.56)
	end

	icon.ZIndex = 22
	icon.Parent = badge

	local label2 = PoolMenuWidgets.Label(badge, "Numeral", "", Color3.new(1, 1, 1), 24)
	label2.AnchorPoint = Vector2.new(0.5, 0.5)
	label2.Position = UDim2.fromScale(0.5, 0.9)
	label2.Size = UDim2.fromScale(0.7, 0.3)
	label2.BackgroundTransparency = 0
	label2.BackgroundColor3 = color10
	PoolMenuWidgets.Corner(label2, 0.5)

	local name = label(frame, "Name", string.upper(data2.Name), color2, 21, 0.135, 0.07, 0.3, 0.36)
	local tierText = label(frame, "Tier", "", color7, 21, 0.42, 0.13, 0.2, 0.26, Enum.TextXAlignment.Right)
	local description = label(frame, "Description", "", Color3.new(1, 1, 1), 21, 0.135, 0.43, 0.485, 0.25)

	local bar, fill = PoolMenuWidgets.Bar(frame, "Bar", color2, 21)
	bar.Position = UDim2.fromScale(0.135, 0.72)
	bar.Size = UDim2.fromScale(0.485, 0.17)

	local label3 = PoolMenuWidgets.Label(bar, "Progress", "", Color3.new(1, 1, 1), 24)
	label3.AnchorPoint = Vector2.new(0.5, 0.5)
	label3.Position = UDim2.fromScale(0.5, 0.5)
	label3.Size = UDim2.fromScale(0.9, 0.95)

	local gemIcon = Instance.new("ImageLabel")
	gemIcon.Name = "GemIcon"
	gemIcon.BackgroundTransparency = 1
	gemIcon.Image = "rbxassetid://91068843812037"
	gemIcon.ScaleType = Enum.ScaleType.Fit
	gemIcon.AnchorPoint = Vector2.new(0, 0.5)
	gemIcon.Position = UDim2.fromScale(0.628, 0.5)
	gemIcon.Size = UDim2.fromScale(0.055, 0.46)
	gemIcon.ZIndex = 21
	gemIcon.Parent = frame

	local gems = label(frame, "Gems", "", color, 21, 0.683, 0.3, 0.085, 0.4)

	local claim2 = claim:Clone()
	claim2.Name = "Claim"
	claim2.AnchorPoint = Vector2.new(1, 0.5)
	claim2.Position = UDim2.fromScale(0.985, 0.5)
	claim2.Size = UDim2.fromScale(0.2, 0.62)

	for _, uiSizeConstraint in claim2:GetDescendants() do
		if uiSizeConstraint:IsA("UISizeConstraint") and uiSizeConstraint.Parent == claim2 then
			uiSizeConstraint:Destroy()
		end
	end

	claim2.Visible = true
	claim2.Parent = frame

	for _, guiObject in claim2:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += 20
		end
	end

	claim2.ZIndex += 20

	local top = claim2:FindFirstChild("Top", true)

	local row = {
		Id = data2.Id,
		Root = frame,
		Badge = badge,
		BadgeGradient = gradient,
		BadgeStroke = stroke,
		BadgeScale = uiScale,
		Icon = icon,
		Numeral = label2,
		Name = name,
		TierText = tierText,
		Description = description,
		Fill = fill,
		Progress = label3,
		Gems = gems,
		Key = claim2,
		KeyText = top
	}

	claim2.Activated:Connect(function()
		PoolAchievementsMenu.Claim(row.Id)
	end)

	return row
end

local function build()
	if v.Built then
		return
	end

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local poolDailyRewardsUI = playerGui:FindFirstChild("PoolDailyRewardsUI")
		or ReplicatedStorage.UI:FindFirstChild("PoolDailyRewardsUI")

	if not poolDailyRewardsUI then
		error("[PoolAchievementsMenu] PoolDailyRewardsUI is in neither PlayerGui nor ReplicatedStorage.UI")
	end

	local poolAchievementsUI = poolDailyRewardsUI:Clone()
	poolAchievementsUI.Name = "PoolAchievementsUI"
	poolAchievementsUI.Enabled = false
	poolAchievementsUI.ResetOnSpawn = false
	poolAchievementsUI.DisplayOrder += 1

	local panel = poolAchievementsUI:FindFirstChild("Panel")

	panel.Size = UDim2.fromScale(0.78, 0.8)
	local claim = panel:FindFirstChild("Claim")

	claim.Parent = nil

	for _, childName in { "Row" } do
		local child = panel:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	local templates = poolAchievementsUI:FindFirstChild("Templates")

	if templates then
		templates:Destroy()
	end

	local title = panel:FindFirstChild("Title")
	title.Text = "ACHIEVEMENTS"
	local subtitle = panel:FindFirstChild("Subtitle")
	subtitle.Text = "Earn badges as you play. Every tier pays Gems!"

	local list = Instance.new("ScrollingFrame")
	list.Name = "List"
	list.AnchorPoint = Vector2.new(0.5, 0)
	list.Position = UDim2.fromScale(0.5, 0.25)
	list.Size = UDim2.fromScale(0.95, 0.71)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.ScrollBarImageColor3 = color2
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ZIndex = 18
	list.Parent = panel

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 4)
	uiPadding.PaddingBottom = UDim.new(0, 4)
	uiPadding.PaddingLeft = UDim.new(0, 2)
	uiPadding.Parent = list

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.Parent = list

	for k, item in PoolAchievements.List do
		table.insert(v.Rows, buildRow(list, item, k, claim))
	end

	claim:Destroy()

	local function sizeRows()
		local v2 = math.floor(math.max(list.AbsoluteSize.X - 14, 0) / 7.2)

		for _, row in v.Rows do
			row.Root.Size = UDim2.new(1, -14, 0, v2)
		end
	end

	list:GetPropertyChangedSignal("AbsoluteSize"):Connect(sizeRows)
	sizeRows()

	panel:FindFirstChild("Exit").Activated:Connect(function()
		PoolAchievementsMenu.Hide()
	end)

	poolAchievementsUI.Parent = playerGui

	v.Gui = poolAchievementsUI
	v.Panel = panel
	v.PanelSize = panel.Size

	local playerReplica = Profiles.GetPlayerReplica((tostring(LocalPlayer.UserId)))

	if playerReplica then
		pcall(function()
			playerReplica:ListenToWrite("PoolAchievementClaim", function()
				if PoolAchievementsMenu.IsVisible() then
					PoolAchievementsMenu.Refresh()
				end
			end)
		end)
	end

	v.Built = true
end

local function fillRow(row, p)
	local v2 = PoolAchievements.Get(row.Id)

	if not v2 then
		return
	end

	local status = PoolAchievements.Status(p, row.Id, LocalPlayer.UserId)
	local count = #v2.Tiers
	local nextNode = status.Next or v2.Tiers[count]

	if status.Reached > 0 then
		local tierColour = PoolAchievements.TierColour(status.Reached)

		row.BadgeGradient.Color = ColorSequence.new(lift(tierColour, 0.25), shade(tierColour, 0.25)) -- inferred equivalent call
		row.BadgeStroke.Color = shade(tierColour, 0.6) -- inferred equivalent call
		row.Icon.Visible = true

		if row.Icon:IsA("TextLabel") then
			row.Icon.TextTransparency = 0
		elseif row.Icon:IsA("ImageLabel") then
			row.Icon.ImageTransparency = 0
		end

		row.Numeral.Text = PoolAchievements.Numeral(status.Reached)
		row.Numeral.Visible = count > 1
	else
		row.BadgeGradient.Color = ColorSequence.new(color6, shade(color6, 0.35))
		row.BadgeStroke.Color = color10

		if row.Icon:IsA("TextLabel") then
			row.Icon.TextTransparency = 0.55
		elseif row.Icon:IsA("ImageLabel") then
			row.Icon.ImageTransparency = 0.55
		end

		row.Numeral.Visible = false
	end

	row.TierText.Text = not (count > 1) and "" or string.format("TIER %d / %d", status.Claimed, count)

	if status.Done then
		row.Description.Text = PoolAchievements.Describe(v2, nextNode) .. " - complete!"
	else
		row.Description.Text = PoolAchievements.Describe(v2, nextNode)
	end

	local goal = nextNode.Goal
	local v3 = math.min(status.Value, goal)

	row.Fill.Size = UDim2.fromScale(not (goal > 0) and 1 or math.clamp(v3 / goal, 0, 1), 1)
	row.Fill.Visible = v3 > 0

	local progress = row.Progress
	local text

	if nextNode.Label then
		text = goal <= status.Value and "BEATEN" or "NOT YET"
	else
		text = string.format("%s / %s", separate(v3), separate(goal)) -- inferred equivalent call
	end

	progress.Text = text
	row.Gems.Text = "+" .. separate(nextNode.Gems) -- inferred equivalent call

	local key = row.Key

	if v.Claiming == row.Id then
		key.Active = false
		key.AutoButtonColor = false
		PoolButtonSkin.SetColour(key, color4)
		row.KeyText.Text = "..."
	elseif status.Claimable then
		key.Active = true
		key.AutoButtonColor = true
		PoolButtonSkin.SetColour(key, color3)
		row.KeyText.Text = "CLAIM"
	elseif status.Done then
		key.Active = false
		key.AutoButtonColor = false
		PoolButtonSkin.SetColour(key, color5)
		row.KeyText.Text = "COMPLETE"
	else
		key.Active = false
		key.AutoButtonColor = false
		PoolButtonSkin.SetColour(key, color4)
		row.KeyText.Text = "LOCKED"
	end
end

function PoolAchievementsMenu.IsVisible()
	return v.Gui ~= nil and v.Gui.Enabled
end

function PoolAchievementsMenu.CountClaimable()
	return PoolAchievements.CountClaimable(data(), LocalPlayer.UserId) -- inferred equivalent call
end

function PoolAchievementsMenu.Refresh()
	build()
	local v2 = data() -- inferred equivalent call

	for _, row in v.Rows do
		fillRow(row, v2)
	end
end

function PoolAchievementsMenu.Show()
	build()
	PoolAchievementsMenu.Refresh()

	local gui = v.Gui
	local panel = v.Panel
	local panelSize = v.PanelSize

	gui.Enabled = true
	panel.Size = UDim2.new(panelSize.X.Scale * 0.6, 0, panelSize.Y.Scale * 0.6, 0)
	TweenService:Create(panel, tweenInfo, { Size = panelSize }):Play()

	pcall(function()
		PoolAudio.PlayCue("MenuOpen")
	end)
end

function PoolAchievementsMenu.Hide()
	if v.Gui then
		v.Gui.Enabled = false
	end
end

function PoolAchievementsMenu.Claim(claiming: string)
	if v.Claiming or not PoolAchievements.Status(data(), claiming, LocalPlayer.UserId).Claimable then -- inferred equivalent call
		return
	end

	v.Claiming = claiming
	PoolAchievementsMenu.Refresh()

	local v2 = nil
	local connection = RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
		if p == "AchievementClaimed" or p == "AchievementRefused" then
			v2 = { p, ... }
		end
	end)

	RemoteSignals.FireServer(RemoteEnums.Pool, "ClaimAchievement", claiming)

	local lastTime = os.clock()

	while not v2 and os.clock() - lastTime < 8 do
		task.wait()
	end

	connection:Disconnect()
	v.Claiming = nil

	if v2 and v2[1] == "AchievementClaimed" and typeof(v2[2]) == "table" then
		local v3 = v2[2]

		for _, row in v.Rows do
			if row.Id ~= v3.Id then
				continue
			end

			row.BadgeScale.Scale = 1.3
			TweenService:Create(row.BadgeScale, tweenInfo, { Scale = 1 }):Play()
		end

		pcall(function()
			PoolAudio.PlayCue("PayoutCoin1")
		end)

		Notifications.new("TextNotification", {
			message = string.format(
				"%s %s: +%d GEMS!",
				string.upper((tostring(v3.Name))),
				PoolAchievements.Numeral(v3.Tier),
				v3.Gems
			),
			colour = color,
			length = 4
		})
	else
		Notifications.new("TextNotification", {
			message = not v2 and "The server didn't answer. Try again in a moment." or tostring(v2[3]),
			colour = Color3.fromRGB(238, 108, 108)
		})
	end

	PoolAchievementsMenu.Refresh()
end

function PoolAchievementsMenu.Watch(callback)
	task.spawn(function()
		local v2 = nil
		local v3 = -1

		while true do
			local v4 = data() -- inferred equivalent call

			if v4 then
				local reachedsById = {}

				for _, item in PoolAchievements.List do
					local status = PoolAchievements.Status(v4, item.Id, LocalPlayer.UserId)

					reachedsById[item.Id] = status.Reached
					local v5

					if v2 then
						v5 = v2[item.Id] or 0
					else
						v5 = status.Reached
					end

					if not (v5 < status.Reached and status.Reached > status.Claimed) then
						continue
					end

					local tier = item.Tiers[status.Reached]

					Notifications.new("TextNotification", {
						message = string.format(
							"ACHIEVEMENT UNLOCKED: %s%s! Claim %d Gems in Achievements",
							string.upper(item.Name),
							not (#item.Tiers > 1) and "" or " " .. PoolAchievements.Numeral(status.Reached),
							not tier and 0 or tier.Gems
						),
						colour = color2,
						length = 6
					})
				end

				local countClaimable = PoolAchievements.CountClaimable(v4, LocalPlayer.UserId)

				if countClaimable ~= v3 then
					pcall(callback, countClaimable)

					if PoolAchievementsMenu.IsVisible() and not v.Claiming then
						PoolAchievementsMenu.Refresh()
					end

					v3 = countClaimable
				end

				v2 = reachedsById
			end

			task.wait(1)
		end
	end)
end

return PoolAchievementsMenu