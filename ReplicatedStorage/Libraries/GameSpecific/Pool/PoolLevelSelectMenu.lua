local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolLevelCatalog = require(Pool.PoolLevelCatalog)

local PoolLevelSelectMenu = {}

local Menu = PoolConstants.Menu

local PlayPrimary = Menu.PlayPrimary
local Competition = Menu.Competition
local PlayOffline = Menu.PlayOffline

local function styleStarGlyph(parent, thickness: number) -- 2 equivalent calls inferred from this helper
	parent.Text = "★"
	parent.TextScaled = true
	parent.TextColor3 = Menu.Gold
	parent.BackgroundTransparency = 1
	parent.Font = Enum.Font.GothamBlack

	local uiStroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = Menu.TextOutline
	uiStroke.Thickness = thickness
	uiStroke.Parent = parent
end

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolLevelSelectMenu: %s.%s is missing (looking for %q)",
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

local function contentWidth(state) -- 1 equivalent call inferred from this helper
	local grid = state.Grid
	local uiPadding = grid:FindFirstChildOfClass("UIPadding")
	local v = not uiPadding and 0 or uiPadding.PaddingLeft.Offset
	local v2 = not uiPadding and 0 or uiPadding.PaddingRight.Offset

	return grid.AbsoluteSize.X - v - v2 - grid.ScrollBarThickness
end

local function solveColumns(p: number) -- 1 equivalent call inferred from this helper
	if p <= 0 then
		return 3
	end

	return (math.clamp(math.floor((p + 10) / 128), 3, 9))
end

local function applyColumns(state)
	local v = contentWidth(state) -- inferred equivalent call
	local columns = solveColumns(v) -- inferred equivalent call
	local offset = state.Layout.CellPadding.X.Offset
	local v2 = math.max(math.floor((v - (columns - 1) * offset) / columns), 1)

	state.Layout.CellSize = UDim2.fromOffset(v2, v2)

	local v3 = columns ~= state.Columns
	state.Columns = columns

	return v3
end

local function cellHeight(data) -- 2 equivalent calls inferred from this helper
	return (math.max(data.Layout.AbsoluteCellSize.Y, data.Layout.CellSize.Y.Offset))
end

local function loadedHeight(data) -- 1 equivalent call inferred from this helper
	local v = math.ceil(data.Loaded / math.max(data.Columns, 1))
	local offset = data.Layout.CellPadding.Y.Offset
	return v * cellHeight(data) + math.max(v - 1, 0) * offset -- inferred equivalent call
end

local function paintTile(p, instance, layoutOrder: number)
	local v = p.Stars[layoutOrder] or 0
	local v2 = layoutOrder <= p.UnlockedThrough

	instance.Name = "Level" .. layoutOrder
	instance.LayoutOrder = layoutOrder

	local number = instance:FindFirstChild("Number")
	local lock = instance:FindFirstChild("Lock")
	local stars = instance:FindFirstChild("Stars")

	number.Text = tostring(layoutOrder)
	number.Visible = v2
	stars.Visible = v2
	lock.Visible = not v2

	if v2 then
		if v > 0 then
			instance.BackgroundColor3 = PlayPrimary
		else
			instance.BackgroundColor3 = Competition
		end
	else
		instance.BackgroundColor3 = PlayOffline
	end

	instance.Active = v2
	instance.Selectable = v2
	instance.AutoButtonColor = v2

	local levelStarImage = PoolConstants.LevelStarImage

	for i = 1, 4 do
		local child = stars:FindFirstChild("Star" .. i)

		if not child then
			continue
		end

		local v3 = i <= v
		local icon = child:FindFirstChild("Icon")
		local glyph = child:FindFirstChild("Glyph")

		child.BackgroundTransparency = 1

		if icon and levelStarImage ~= "" then
			icon.Visible = true
			icon.Image = levelStarImage
			local imageColor

			if v3 then
				imageColor = Color3.new(1, 1, 1)
			else
				imageColor = PoolConstants.LevelStarEmptyTint
			end

			icon.ImageColor3 = imageColor
			icon.ImageTransparency = v3 and 0 or PoolConstants.LevelStarEmptyTransparency

			if glyph then
				glyph.Visible = false
			end
		else
			if icon then
				icon.Visible = false
			end

			if not glyph then
				glyph = Instance.new("TextLabel")
				glyph.Name = "Glyph"
				glyph.AnchorPoint = Vector2.new(0.5, 0.5)
				glyph.Position = UDim2.fromScale(0.5, 0.5)
				glyph.Size = UDim2.fromScale(1.45, 1.45)
				glyph.ZIndex = child.ZIndex
				styleStarGlyph(glyph, 1.5) -- inferred equivalent call
				glyph.Parent = child
			end

			glyph.Visible = true
			local textColor

			if v3 then
				textColor = Menu.Gold
			else
				textColor = PoolConstants.LevelStarEmptyTint
			end

			glyph.TextColor3 = textColor
		end
	end
end

local function appendRow(state)
	local v = #state.Levels

	for _ = 1, state.Columns do
		if v <= state.Loaded then
			break
		end

		state.Loaded += 1

		local loaded = state.Loaded
		local clone = state.Template:Clone()

		paintTile(state, clone, loaded)
		clone.Visible = true
		clone.Parent = state.Grid

		table.insert(state.Tiles, clone)

		state.TileMaid:GiveTask(clone.Activated:Connect(function()
			state.ChosenBindable:Fire(loaded)
		end))
	end
end

local function fill(data)
	local grid = data.Grid
	local v = cellHeight(data) -- inferred equivalent call

	if v <= 0 then
		return
	end

	local y = grid.AbsoluteWindowSize.Y

	if y <= 0 then
		y = grid.AbsoluteSize.Y
	end

	local count = 0

	while data.Loaded < #data.Levels do
		local v2 = loadedHeight(data) - (grid.CanvasPosition.Y + y) -- inferred equivalent call

		if v * 2 < v2 then
			break
		end

		appendRow(data)

		count += 1

		if count > 400 then
			warn("[PoolLevelSelectMenu] fill guard tripped; check the grid's measurements")
			break
		end
	end
end

local function clearTiles(state)
	state.TileMaid:DoCleaning()

	for _, tile in state.Tiles do
		tile:Destroy()
	end

	table.clear(state.Tiles)
	state.Loaded = 0
end

local function rebuild(state) -- 1 equivalent call inferred from this helper
	clearTiles(state)
	applyColumns(state)
	state.Grid.CanvasPosition = Vector2.zero
	fill(state)
end

function PoolLevelSelectMenu.new(instance)
	local maid = Maid.new()
	local tileMaid = Maid.new()
	maid:GiveTask(tileMaid)

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local bindableEvent4 = Instance.new("BindableEvent")
	local bindableEvent5 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)
	maid:GiveTask(bindableEvent3)
	maid:GiveTask(bindableEvent4)
	maid:GiveTask(bindableEvent5)

	local levelSelect = instance:WaitForChild("LevelSelect")
	levelSelect.Visible = false

	local grid = bind(levelSelect, "Grid")

	local starProgress = levelSelect:FindFirstChild("StarProgress")

	local lives = levelSelect:FindFirstChild("Lives")

	local v = {}
	v.Root = levelSelect
	v.Grid = grid
	v.Layout = bind(grid, "UIGridLayout")
	v.Template = bind(levelSelect, "TileTemplate")
	v.Back = bind(levelSelect, "Back")
	v.Levels = PoolLevelCatalog.All()
	v.Stars = {}
	v.UnlockedThrough = 1
	v.Columns = 0
	v.Loaded = 0
	v.Tiles = {}
	v.Chosen = bindableEvent.Event
	v.ChosenBindable = bindableEvent
	v.Closed = bindableEvent2.Event
	v.CloseBindable = bindableEvent2
	v.CreateButton = levelSelect:FindFirstChild("Create")
	v.CreateRequested = bindableEvent3.Event
	v.CreateBindable = bindableEvent3
	v.CommunityButton = levelSelect:FindFirstChild("Community")
	v.CommunityRequested = bindableEvent5.Event
	v.CommunityBindable = bindableEvent5
	local progressFill

	if starProgress then
		progressFill = starProgress:FindFirstChild("Fill", true)
	end

	v.ProgressFill = progressFill
	local progressCount

	if starProgress then
		progressCount = starProgress:FindFirstChild("Count", true)
	end

	v.ProgressCount = progressCount
	local presentButton

	if starProgress then
		presentButton = starProgress:FindFirstChild("Present", true)
	end

	v.PresentButton = presentButton
	v.PresentPressed = bindableEvent4.Event
	v.PresentBindable = bindableEvent4
	v.PacksReady = 0
	v.PresentWiggle = nil
	v.TotalStars = -1
	v.FillTween = nil
	v.StarAnimToken = 0
	v.StarFlights = {}
	local livesHeart

	if lives then
		livesHeart = lives:FindFirstChild("Heart")
	end

	v.LivesHeart = livesHeart
	local livesCount

	if lives then
		livesCount = lives:FindFirstChild("Count", true)
	end

	v.LivesCount = livesCount
	local livesTimer

	if lives then
		livesTimer = lives:FindFirstChild("Timer")
	end

	v.LivesTimer = livesTimer
	v.TileMaid = tileMaid
	v.Maid = maid

	maid:GiveTask(v.Back.Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	if v.CreateButton then
		maid:GiveTask(v.CreateButton.Activated:Connect(function()
			bindableEvent3:Fire()
		end))
	end

	if v.CommunityButton then
		maid:GiveTask(v.CommunityButton.Activated:Connect(function()
			bindableEvent5:Fire()
		end))
	end

	if v.PresentButton then
		maid:GiveTask(v.PresentButton.Activated:Connect(function()
			bindableEvent4:Fire((math.max(v.TotalStars, 0)))
		end))
	end

	maid:GiveTask(grid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		fill(v)
	end))

	maid:GiveTask(grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if applyColumns(v) then
			clearTiles(v)
		end

		fill(v)
	end))

	return v
end

function PoolLevelSelectMenu.PresentProgress(p: number)
	local v = math.max(PoolConstants.StarsPerPresent or 100, 1)
	local v2 = math.floor(math.max(p, 0) / v)

	return p - v2 * v, v, v2
end

local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function drawStarBar(state, p: number, flag: boolean?) -- 4 equivalent calls inferred from this helper
	local presentProgress, v = PoolLevelSelectMenu.PresentProgress(p)
	local progressFill = state.ProgressFill

	if state.ProgressCount then
		state.ProgressCount.Text = string.format("%d / %d ★", presentProgress, v)
	end

	if not progressFill then
		return
	end

	local udim = UDim2.new(presentProgress / v, 0, progressFill.Size.Y.Scale, progressFill.Size.Y.Offset)

	progressFill.Visible = presentProgress > 0

	if state.FillTween then
		state.FillTween:Cancel()
		state.FillTween = nil
	end

	if not (flag and presentProgress > 0 and progressFill.Size.X.Scale < udim.X.Scale) then
		progressFill.Size = udim

		return
	end

	local tween = TweenService:Create(progressFill, tweenInfo, { Size = udim })
	state.FillTween = tween
	tween:Play()
end

local function popPresent(data, scale: number)
	local presentButton = data.PresentButton
	local uiScale = presentButton and presentButton:FindFirstChildOfClass("UIScale")

	if uiScale then
		uiScale.Scale = scale
		TweenService:Create(uiScale, tweenInfo2, { Scale = 1 }):Play()
	end
end

local function clearFlights(state) -- 2 equivalent calls inferred from this helper
	for _, starFlight in state.StarFlights do
		starFlight:Destroy()
	end

	table.clear(state.StarFlights)
end

local function makeFlyingStar(data, zIndex: number)
	local levelStarImage = PoolConstants.LevelStarImage
	local flyingStar

	if typeof(levelStarImage) == "string" and levelStarImage ~= "" then
		flyingStar = Instance.new("ImageLabel")
		flyingStar.Image = levelStarImage
		flyingStar.ScaleType = Enum.ScaleType.Fit
		flyingStar.BackgroundTransparency = 1
	else
		flyingStar = Instance.new("TextLabel")
		styleStarGlyph(flyingStar, 2.5) -- inferred equivalent call
	end

	flyingStar.Name = "FlyingStar"
	flyingStar.AnchorPoint = Vector2.new(0.5, 0.5)
	flyingStar.Size = UDim2.fromScale(0.085, 0.085)
	flyingStar.SizeConstraint = Enum.SizeConstraint.RelativeYY
	flyingStar.ZIndex = zIndex

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 0
	uiScale.Parent = flyingStar

	flyingStar.Parent = data.Root
	table.insert(data.StarFlights, flyingStar)

	return flyingStar
end

local function flyStars(data, totalStars: number, totalStars2: number, starAnimToken: number)
	local root = data.Root
	local progressFill = data.ProgressFill
	local parent

	if progressFill then
		parent = progressFill.Parent
	else
		parent = nil
	end

	if parent and root.Visible then
		local v = totalStars2 - totalStars
		local v2 = math.clamp(v, 1, 12)
		local v3 = totalStars
		local count = 0
		local v4

		if data.PresentButton then
			v4 = data.PresentButton.ZIndex
		else
			v4 = parent.ZIndex
		end

		local zIndex = v4 + 10
		local random = Random.new()

		local function overtaken(): boolean -- 3 equivalent calls inferred from this helper
			return data.StarAnimToken ~= starAnimToken or not (root.Visible and root.Parent)
		end

		for i = 1, v2 do
			local v5 = math.floor(v / v2) + (i <= v % v2 and 1 or 0)

			task.delay((i - 1) * 0.09, function()
				if overtaken() then -- inferred equivalent call
					return
				end

				local flyingStar = makeFlyingStar(data, zIndex)
				local uiScale = flyingStar:FindFirstChildOfClass("UIScale")
				local absolutePosition = root.AbsolutePosition
				local absoluteSize = root.AbsoluteSize
				local v6 = absolutePosition + absoluteSize / 2 + Vector2.new(
					random:NextNumber(-0.06, 0.06),
					random:NextNumber(-0.05, 0.05)
				) * absoluteSize

				local v7 = Vector2.new(random:NextNumber(-0.28, 0.28), random:NextNumber(-0.3, -0.05)) * absoluteSize
				local number = random:NextNumber(-260, 260)
				local total = 0

				while total < 0.62 do
					total += RunService.Heartbeat:Wait()

					if overtaken() or not flyingStar.Parent then -- inferred equivalent call
						flyingStar:Destroy()

						return
					end

					local v8 = math.min(total / 0.62, 1)

					local v9 = v8 * v8 * (1.6 - v8 * 0.6)
					local v10

					if progressFill and progressFill.Visible then
						v10 = progressFill.AbsolutePosition + Vector2.new(
							progressFill.AbsoluteSize.X,
							progressFill.AbsoluteSize.Y / 2
						)
					else
						v10 = parent.AbsolutePosition + Vector2.new(0, parent.AbsoluteSize.Y / 2)
					end

					local v11 = v6 + (v10 - v6) * 0.5 + v7
					local v12 = 1 - v9
					local v13 = v6 * (v12 * v12) + v11 * (v12 * 2 * v9) + v10 * (v9 * v9)

					flyingStar.Position = UDim2.fromOffset(v13.X - absolutePosition.X, v13.Y - absolutePosition.Y)
					flyingStar.Rotation = number * v8
					local scale

					if v8 < 0.18 then
						scale = v8 / 0.18 * 1.35
					else
						scale = 1.35 - (v8 - 0.18) / 0.82 * 0.85
					end

					uiScale.Scale = scale
				end

				flyingStar:Destroy()

				local index = table.find(data.StarFlights, flyingStar)

				if index then
					table.remove(data.StarFlights, index)
				end

				if overtaken() then -- inferred equivalent call
					return
				end

				v3 += v5
				count += 1
				drawStarBar(data, math.min(v3, totalStars2), true)
				popPresent(data, 0.9)

				if count == v2 then
					drawStarBar(data, totalStars2, true)
					popPresent(data, 0.75)
				end
			end)
		end
	else
		drawStarBar(data, totalStars2, false) -- inferred equivalent call
	end
end

local function paintStarBar(state, totalStars: number)
	local totalStars2 = state.TotalStars
	state.TotalStars = totalStars
	state.StarAnimToken += 1
	clearFlights(state) -- inferred equivalent call

	if totalStars2 < 0 or totalStars <= totalStars2 or not state.ProgressFill then
		drawStarBar(state, totalStars, false) -- inferred equivalent call
	else
		drawStarBar(state, totalStars2, false) -- inferred equivalent call
		local starAnimToken = state.StarAnimToken

		task.delay(0.35, function()
			if state.StarAnimToken ~= starAnimToken then
				return
			end

			flyStars(state, totalStars2, totalStars, starAnimToken)
		end)
	end
end

function PoolLevelSelectMenu:SetProgress(stars, p: number)
	self.Stars = stars
	self.UnlockedThrough = math.max(p, 1)
	local total = 0

	for _, value in stars do
		total += math.clamp(value, 0, 4)
	end

	paintStarBar(self, total)

	for k, tile in self.Tiles do
		paintTile(self, tile, k)
	end
end

local tweenInfo3 = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0)

function PoolLevelSelectMenu:SetPacksReady(p: number)
	self.PacksReady = math.max(p, 0)

	local presentButton = self.PresentButton

	if not presentButton then
		return
	end

	local badge = presentButton:FindFirstChild("Badge")
	local count = badge and badge:FindFirstChild("Count")

	if badge then
		badge.Visible = self.PacksReady > 0
	end

	if count then
		count.Text = self.PacksReady > 9 and "9+" or tostring(self.PacksReady)
	end

	if self.PacksReady > 0 then
		if not self.PresentWiggle then
			presentButton.Rotation = -7

			local tween = TweenService:Create(presentButton, tweenInfo3, { Rotation = 7 })
			self.PresentWiggle = tween
			tween:Play()
		end
	elseif self.PresentWiggle then
		self.PresentWiggle:Cancel()
		self.PresentWiggle = nil
		presentButton.Rotation = 0
	end
end

local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(110, 110, 120)

function PoolLevelSelectMenu.SetLives(data, p: number, p2: number?)
	if data.LivesCount then
		data.LivesCount.Text = tostring(p)
	end

	if data.LivesHeart then
		local livesHeart = data.LivesHeart
		local imageColor = if p > 0 then color else color2
		livesHeart.ImageColor3 = imageColor
	end

	if data.LivesTimer then
		if p2 then
			local v = math.max(0, (math.ceil(p2)))

			data.LivesTimer.Text = string.format("%d:%02d", v // 60, v % 60)
		else
			data.LivesTimer.Text = "FULL"
		end
	end
end

function PoolLevelSelectMenu:SetVisible(visible: boolean)
	self.Root.Visible = visible

	if visible then
		task.defer(function()
			if not self.Root.Visible then
				return
			end

			rebuild(self) -- inferred equivalent call

			if Device:Get() == "Console" and self.Tiles[1] then
				GuiService.SelectedObject = self.Tiles[1]
			end
		end)
		return
	end

	self.StarAnimToken += 1
	clearFlights(self) -- inferred equivalent call

	if self.TotalStars >= 0 then
		drawStarBar(self, self.TotalStars, false) -- inferred equivalent call
	end

	local selectedObject = GuiService.SelectedObject

	if selectedObject and selectedObject:IsDescendantOf(self.Root) then
		GuiService.SelectedObject = nil
	end
end

function PoolLevelSelectMenu:Destroy()
	clearTiles(self)
	self.Maid:DoCleaning()
end

return PoolLevelSelectMenu