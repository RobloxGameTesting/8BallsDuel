local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMenuWidgets)
local PoolVenueProgress = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolVenueProgress)
local PoolVenueLootbox = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolVenueLootbox)
local PoolVip = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolVip)

local PoolVenueMenu = {}

local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolVenueMenu: %s.%s is missing (looking for %q)",
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

local color = Color3.fromRGB(0, 0, 0)

local function contentCeiling(folder)
	local zIndex = folder.ZIndex

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") and zIndex < guiObject.ZIndex then
			zIndex = guiObject.ZIndex
		end
	end

	return zIndex
end

local v = {
	Headline = { 0.71, 0.11, 0.86 },
	LevelBar = { 0.83, 0.085, 0.8 },
	Detail = { 0.925, 0.065, 0.86 }
}

local function placeLock(lock)
	for childName, v2 in v do
		local guiObject = lock:FindFirstChild(childName)

		if not (guiObject and guiObject:IsA("GuiObject")) then
			continue
		end

		guiObject.AnchorPoint = Vector2.new(0.5, 0.5)
		guiObject.Position = UDim2.fromScale(0.5, v2[1])
		guiObject.Size = UDim2.fromScale(v2[3], v2[2])
	end
end

local function buildLock(card, ring)
	local lock = card:FindFirstChild("Lock")

	if lock and lock:IsA("Frame") then
		local detail = lock:FindFirstChild("Detail")
		local headline = lock:FindFirstChild("Headline")
		local levelBar = lock:FindFirstChild("LevelBar")

		if detail and detail:IsA("TextLabel") and headline and headline:IsA("TextLabel") and levelBar then
			local fill = levelBar:FindFirstChild("Fill")

			placeLock(lock)

			if fill and fill:IsA("Frame") then
				return lock, detail, headline, fill
			end

			return lock, detail, headline, nil
		end

		lock:Destroy()
	end

	local v2 = contentCeiling(card)

	local lock2 = Instance.new("Frame")
	lock2.Name = "Lock"
	lock2.AnchorPoint = Vector2.new(0.5, 0.5)
	lock2.Position = UDim2.fromScale(0.5, 0.5)
	lock2.Size = UDim2.fromScale(1, 1)
	lock2.BackgroundColor3 = color
	lock2.BackgroundTransparency = 0.3
	lock2.BorderSizePixel = 0
	lock2.ZIndex = v2 + 8
	lock2.Visible = false

	lock2.Active = false

	local uiCorner = card:FindFirstChildOfClass("UICorner")

	if uiCorner then
		local clone = uiCorner:Clone()
		clone.Parent = lock2
	end

	local function makeLabel(name: string, p: number, p2: number, text: string)
		local selected

		if ring then
			selected = ring:Clone()
		else
			selected = Instance.new("TextLabel")
			selected.BackgroundTransparency = 1
			selected.TextScaled = true
		end

		selected.Name = name
		selected.AnchorPoint = Vector2.new(0.5, 0.5)
		selected.Position = UDim2.fromScale(0.5, p)
		selected.Size = UDim2.fromScale(0.86, p2)
		selected.ZIndex = v2 + 8 + 1
		selected.Visible = true

		selected.TextTransparency = 0
		selected.TextColor3 = Color3.fromRGB(255, 255, 255)
		selected.Text = text
		selected.Parent = lock2

		return selected
	end

	local label = makeLabel("Headline", 0.4, 0.13, "LOCKED")
	local label2 = makeLabel("Detail", 0.64, 0.08, "")

	local v3 = nil
	local progress = card:FindFirstChild("Progress")
	local levelBar

	if progress and progress:IsA("Frame") then
		levelBar = progress:Clone()
	else
		levelBar = Instance.new("Frame")
		levelBar.BackgroundColor3 = Color3.fromRGB(182, 182, 182)

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.AnchorPoint = Vector2.new(0, 0.5)
		fill.Position = UDim2.fromScale(0, 0.5)
		fill.BackgroundColor3 = Color3.fromRGB(126, 226, 118)
		fill.BorderSizePixel = 0
		fill.Parent = levelBar

		local uiCorner_2 = Instance.new("UICorner")
		uiCorner_2.Parent = levelBar
	end

	levelBar.Name = "LevelBar"
	levelBar.AnchorPoint = Vector2.new(0.5, 0.5)
	levelBar.Position = UDim2.fromScale(0.5, 0.53)
	levelBar.Size = UDim2.fromScale(0.72, 0.065)
	levelBar.Visible = true
	levelBar.Active = false
	levelBar.ZIndex = v2 + 8 + 1

	for _, guiObject in levelBar:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = v2 + 8 + 2
		end
	end

	local fill = levelBar:FindFirstChild("Fill")

	if fill and fill:IsA("Frame") then
		fill.Size = UDim2.fromScale(0, 1)
		fill.Visible = false
		v3 = fill
	end

	levelBar.Parent = lock2
	placeLock(lock2)
	lock2.Parent = card

	return lock2, label2, label, v3
end

local udim = UDim2.new(1, -6, 0.52, 0)

local function addPhoto(card, data)
	for _, childName in { "Photo", "PhotoFade", "CoinsOverlay" } do
		local child = card:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	if data.CoinsOverlay == true and PoolConstants.VenueCoinsOverlayImage ~= "" then
		local coinsOverlay = Instance.new("ImageLabel")
		coinsOverlay.Name = "CoinsOverlay"
		coinsOverlay.BackgroundTransparency = 1
		coinsOverlay.BorderSizePixel = 0
		coinsOverlay.Image = PoolConstants.VenueCoinsOverlayImage
		coinsOverlay.ScaleType = Enum.ScaleType.Fit
		coinsOverlay.AnchorPoint = Vector2.new(1, 0.5)
		coinsOverlay.Position = udim
		coinsOverlay.Size = UDim2.fromScale(0.78, 0.78)
		coinsOverlay.ZIndex = card.ZIndex + 3
		coinsOverlay.Active = false

		local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uiAspectRatioConstraint.AspectRatio = 1
		uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
		uiAspectRatioConstraint.Parent = coinsOverlay

		coinsOverlay.Parent = card
	end

	local image = data.Image

	if typeof(image) ~= "string" or image == "" then
		return
	end

	local uiCorner = card:FindFirstChildOfClass("UICorner")

	local function layer(parent, p: number)
		parent.AnchorPoint = Vector2.new(0.5, 0.5)
		parent.Position = UDim2.fromScale(0.5, 0.5)
		parent.Size = UDim2.new(1, -6, 1, -6)
		parent.BorderSizePixel = 0
		parent.ZIndex = card.ZIndex + p
		parent.Active = false

		if uiCorner then
			local clone = uiCorner:Clone()
			clone.Parent = parent
		end

		parent.Parent = card
	end

	local photo = Instance.new("ImageLabel")
	photo.Name = "Photo"
	photo.BackgroundTransparency = 1
	photo.Image = image
	photo.ScaleType = Enum.ScaleType.Crop
	layer(photo, 1)

	local photoFade = Instance.new("Frame")
	photoFade.Name = "PhotoFade"
	photoFade.BackgroundColor3 = Color3.new(0, 0, 0)
	photoFade.BackgroundTransparency = 0

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.3, 1),
		NumberSequenceKeypoint.new(0.55, 1),
		NumberSequenceKeypoint.new(1, 0.3)
	})

	uiGradient.Parent = photoFade

	layer(photoFade, 2)
end

local function layoutPrize(parent, state, coin)
	local x = parent.AbsoluteSize.X

	if x <= 0 then
		return
	end

	local v2 = math.min(state.TextBounds.X, state.AbsoluteSize.X) / x
	local v3 = not (coin and coin.Visible) and 0 or coin.AbsoluteSize.X / x
	local v4 = v3 > 0 and 0.03 or 0
	local v5 = 0.5 - (v2 + v4 + v3) / 2

	state.AnchorPoint = Vector2.new(1, 0.5)
	state.TextXAlignment = Enum.TextXAlignment.Right
	state.Position = UDim2.fromScale(v5 + v2, 0.5)

	if coin then
		coin.AnchorPoint = Vector2.new(0, 0.5)
		coin.Position = UDim2.fromScale(v5 + v2 + v4, 0.5)
	end
end

local function findCard(parent, data)
	local child = parent:FindFirstChild(data.Id)

	if child then
		return child
	end

	local child2

	if data.Country then
		child2 = parent:FindFirstChild(data.Country)
	end

	if not child2 then
		return bind(parent, data.Id)
	end

	local clone = child2:Clone()
	clone.Name = data.Id
	clone.Visible = false
	clone.Parent = parent

	return clone
end

local function bindCard(parent2, venue, k: number, ladder: string)
	local card = findCard(parent2, venue)
	local prizeLabel = bind(card, "PrizeBox.Prize")
	local feeLabel = bind(card, "Fee")

	local name = card:FindFirstChild("Name")
	local subtitle = card:FindFirstChild("Subtitle")
	local ring = card:FindFirstChild("Ring")

	if name and name:IsA("TextLabel") then
		name.Text = venue.Name
	end

	if subtitle and subtitle:IsA("TextLabel") then
		local matchType = venue.MatchType

		subtitle.Text = (typeof(matchType) ~= "string" or matchType == "")
			and "Pocket all of your balls then the 8 ball"
			or matchType
		subtitle.Visible = true
	end

	if not (ring and ring:IsA("TextLabel")) then
		ring = nil
	end

	local lock, lockDetail, lockHeadline, lockFill = buildLock(card, ring)

	prizeLabel.Text = string.format("WIN %s", NumberHelper:Separate(venue.Prize))

	local parent = prizeLabel.Parent
	local coin = parent:FindFirstChild("Coin")

	if not (coin and coin:IsA("GuiObject")) then
		coin = nil
	end

	local connections = {}

	local function relayout() -- 1 equivalent call inferred from this helper
		layoutPrize(parent, prizeLabel, coin)
	end

	table.insert(connections, prizeLabel:GetPropertyChangedSignal("TextBounds"):Connect(relayout))
	table.insert(connections, parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout))

	if coin then
		table.insert(connections, coin:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout))
	end

	relayout() -- inferred equivalent call
	local progress = card:FindFirstChild("Progress")

	if not (progress and progress:IsA("Frame")) then
		progress = nil
	end

	local fill = progress and progress:FindFirstChild("Fill")

	if not (fill and fill:IsA("Frame")) then
		fill = nil
	end

	if progress then
		progress.Visible = false
	end

	feeLabel.Text = string.format("Entry fee: %s", PoolConstants.DescribeFee(venue.EntryFee))

	feeLabel.Visible = math.round(venue.EntryFee) > 0

	addPhoto(card, venue)

	return {
		Root = card,
		Venue = venue,
		PrizeLabel = prizeLabel,
		FeeLabel = feeLabel,
		ProgressBar = progress,
		ProgressFill = fill,
		ShowProgress = false,
		Connections = connections,
		UnlockLabel = ring,
		LockOverlay = lock,
		LockHeadline = lockHeadline,
		LockFill = lockFill,
		LockDetail = lockDetail,
		HasReward = PoolVenueProgress.HasReward(venue.Id),
		Index = k,
		Affordable = false,
		Unlocked = false,
		Ladder = ladder
	}
end

function PoolVenueMenu.new(instance)
	local maid = Maid.new()
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

	local venueMenu = instance:WaitForChild("VenueMenu")
	venueMenu.Visible = false

	local track = bind(venueMenu, "Track")
	local coinsLabel = bind(venueMenu, "Coins.Amount")
	local back = bind(venueMenu, "Back")

	local title = venueMenu:FindFirstChild("Title")

	if not (title and title:IsA("TextLabel")) then
		title = nil
	end

	local v2 = {}

	for k, venue in PoolConstants.Venues do
		table.insert(v2, bindCard(track, venue, k, "EightBall"))
	end

	local nineBall = {}

	for k, nineBallVenue in PoolConstants.NineBallVenues do
		table.insert(nineBall, bindCard(track, nineBallVenue, k, "NineBall"))
	end

	local clone = table.clone(v2)

	for _, v3 in nineBall do
		table.insert(clone, v3)
	end

	local worldPass = venueMenu:FindFirstChild("WorldPass")

	if not worldPass then
		error("PoolVenueMenu: missing UI element 'WorldPass' under " .. venueMenu:GetFullName())
	end

	worldPass.Visible = false

	maid:GiveTask(worldPass.Activated:Connect(function()
		bindableEvent3:Fire()
	end))

	local friendButtons = bind(venueMenu, "FriendButtons")
	local v3 = bind(friendButtons, "PlayFriends")
	local v4 = bind(friendButtons, "InviteFriends")

	maid:GiveTask(v3.Activated:Connect(function()
		bindableEvent4:Fire()
	end))

	maid:GiveTask(v4.Activated:Connect(function()
		bindableEvent5:Fire()
	end))

	local v5 = {
		Root = venueMenu,
		Track = track,
		Cards = v2,
		Ladders = { EightBall = v2, NineBall = nineBall },
		AllCards = clone,
		Ladder = "EightBall",
		LadderIndex = {},
		ChallengeName = nil,
		ChallengeVip = nil,
		Index = 1,
		Focus = 1,
		Drag = nil,
		SuppressTap = false,
		CoinsLabel = coinsLabel,
		TitleLabel = title,
		Back = back,
		PassButton = worldPass,
		PassRequested = bindableEvent3.Event,
		PassBindable = bindableEvent3,
		Chosen = bindableEvent.Event,
		ChosenBindable = bindableEvent,
		Exit = bindableEvent2.Event,
		FriendButtons = friendButtons,
		FriendsRequested = bindableEvent4.Event,
		InviteRequested = bindableEvent5.Event,
		Maid = maid
	}

	for _, v6 in clone do
		local venue = v6.Venue
		local index = v6.Index

		for _, connection in v6.Connections do
			maid:GiveTask(connection)
		end

		maid:GiveTask(v6.Root.Activated:Connect(function()
			if v5.SuppressTap then
				return
			end

			if v5.Index == index then
				bindableEvent:Fire(venue, index)
			else
				PoolVenueMenu.SetIndex(v5, index)
			end
		end))
	end

	for k, v6 in { Previous = -1, Next = 1 } do
		maid:GiveTask(bind(venueMenu, k).Activated:Connect(function()
			PoolVenueMenu.SetIndex(v5, v5.Index + v6)
		end))
	end

	PoolVenueMenu.BindScrolling(v5)

	maid:GiveTask(back.Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	PoolVenueMenu.SetLadder(v5, "EightBall")

	return v5
end

local function applyLayout(p, p2: number, flag: boolean?)
	local v2 = math.round(p2)

	for _, card in p.Cards do
		local v3 = card.Index - p2
		local v4 = math.clamp(1 - math.abs(v3), 0, 1) * 0.14 + 0.86

		local v5 = {
			Position = UDim2.fromScale(v3 * 0.46 + 0.5, 0.5),
			Size = UDim2.fromScale(v4 * 0.42, v4 * 0.527)
		}
		local v6

		if p.Track then
			v6 = p.Track.ZIndex
		else
			v6 = card.Root.Parent.ZIndex
		end

		card.Root.ZIndex = v6 + (card.Index == v2 and 3 or 1)

		if flag then
			card.Root.Position = v5.Position
			card.Root.Size = v5.Size
		else
			TweenService:Create(card.Root, tweenInfo, v5):Play()
		end
	end
end

local function pixelsToCards(state, p: number) -- 1 equivalent call inferred from this helper
	local x = state.Track.AbsoluteSize.X

	if x <= 0 then
		return 0
	end

	return p / (x * 0.46)
end

function PoolVenueMenu:BindScrolling()
	local maid = self.Maid

	local function awake() -- 4 equivalent calls inferred from this helper
		return self.Root.Visible
	end

	local function finishDrag()
		local drag = self.Drag

		if not drag then
			return
		end

		self.Drag = nil

		local card = drag.Card

		if card and drag.Furthest <= 12 and card.Index ~= self.Index then
			self.SuppressTap = true
			PoolVenueMenu.SetIndex(self, card.Index)

			task.defer(function()
				self.SuppressTap = false
			end)
		else
			local v2 = self.Focus - drag.StartFocus
			local v3 = math.round(self.Focus)

			if v3 == drag.StartFocus and math.abs(v2) >= 0.2 then
				v3 = drag.StartFocus + (v2 > 0 and 1 or -1)
			end

			PoolVenueMenu.SetIndex(self, v3)

			task.defer(function()
				self.SuppressTap = false
			end)
		end
	end

	local function beginDrag(input, card)
		if
			not awake() -- inferred equivalent call
			or input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local drag = self.Drag

		if not drag then
			self.Drag = {
				Input = input,
				StartX = input.Position.X,
				StartFocus = self.Focus,
				Furthest = 0,
				Card = card
			}
		elseif card and not drag.Card and drag.Furthest == 0 and drag.Input.UserInputType == input.UserInputType then
			drag.Card = card
		end
	end

	maid:GiveTask(self.Track.InputBegan:Connect(function(input)
		beginDrag(input)
	end))

	for _, allCard in self.AllCards do
		maid:GiveTask(allCard.Root.InputBegan:Connect(function(input)
			beginDrag(input, allCard)
		end))

		maid:GiveTask(allCard.LockOverlay.InputBegan:Connect(function(input)
			beginDrag(input, allCard)
		end))
	end

	local function isDragMovement(drag, input): boolean -- 1 equivalent call inferred from this helper
		if drag.Input.UserInputType == Enum.UserInputType.Touch then
			return input == drag.Input
		end

		return input.UserInputType == Enum.UserInputType.MouseMovement
	end

	local function isDragRelease(drag, input): boolean -- 1 equivalent call inferred from this helper
		if drag.Input.UserInputType == Enum.UserInputType.Touch then
			return input == drag.Input
		end

		return input.UserInputType == Enum.UserInputType.MouseButton1
	end

	maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		local drag = self.Drag

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if awake() and not drag then -- inferred equivalent call
				PoolVenueMenu.SetIndex(self, self.Index - math.sign(input.Position.Z))
			end
		elseif drag and isDragMovement(drag, input) then -- inferred equivalent call
			local v2 = input.Position.X - drag.StartX
			drag.Furthest = math.max(drag.Furthest, (math.abs(v2)))

			if drag.Furthest > 12 then
				self.SuppressTap = true
			end

			local v3 = drag.StartFocus - pixelsToCards(self, v2) -- inferred equivalent call

			self.Focus = math.clamp(v3, 1, #self.Cards)

			applyLayout(self, self.Focus, true)
		end
	end))

	maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		local drag = self.Drag

		if drag and isDragRelease(drag, input) then -- inferred equivalent call
			finishDrag()
		end
	end))

	maid:GiveTask(UserInputService.WindowFocusReleased:Connect(finishDrag))

	local v2 = 0

	local function step(x: number) -- 3 equivalent calls inferred from this helper
		local now = os.clock()

		if now - v2 < 0.26 then
			return
		end

		v2 = now

		PoolVenueMenu.SetIndex(self, self.Index + x)
	end

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not awake() or gameProcessed then -- inferred equivalent call
			return
		end

		if input.KeyCode == Enum.KeyCode.DPadLeft or input.KeyCode == Enum.KeyCode.Left then
			step(-1) -- inferred equivalent call
		elseif input.KeyCode == Enum.KeyCode.DPadRight or input.KeyCode == Enum.KeyCode.Right then
			step(1) -- inferred equivalent call
		elseif input.KeyCode == Enum.KeyCode.ButtonA then
			local card = self.Cards[self.Index]

			if card and card.Root.Active then
				PoolVenueMenu.Choose(self, self.Index)
			end
		end
	end))

	maid:GiveTask(UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if not awake() or gameProcessed or input.KeyCode ~= Enum.KeyCode.Thumbstick1 then -- inferred equivalent call
			return
		end

		if math.abs(input.Position.X) < 0.6 then
			v2 = 0

			return
		end

		step(math.sign(input.Position.X)) -- inferred equivalent call
	end))
end

function PoolVenueMenu.Choose(p, p2: number)
	local card = p.Cards[p2]

	if not card then
		return
	end

	p.ChosenBindable:Fire(card.Venue, p2)
end

function PoolVenueMenu:SetIndex(value: number, flag: boolean?)
	local focus = math.clamp(value, 1, #self.Cards)

	self.Index = focus
	self.Focus = focus

	applyLayout(self, focus, flag)
end

function PoolVenueMenu.GetVenue(p)
	return p.Cards[p.Index].Venue
end

local function repaint(allCard)
	local unlocked = allCard.Affordable and allCard.Unlocked
	local backgroundColor

	if unlocked then
		backgroundColor = allCard.Venue.Colour
	elseif allCard.Unlocked then
		backgroundColor = allCard.Venue.Colour:Lerp(Color3.fromRGB(40, 46, 52), 0.7)
	else
		backgroundColor = allCard.Venue.Colour:Lerp(Color3.fromRGB(28, 32, 38), 0.82)
	end

	allCard.Root.BackgroundColor3 = backgroundColor

	allCard.Root.Active = allCard.Unlocked

	allCard.FeeLabel.TextTransparency = unlocked and 0 or 0.4

	allCard.LockOverlay.Visible = not allCard.Unlocked

	if allCard.UnlockLabel then
		allCard.UnlockLabel.Visible = allCard.Unlocked and allCard.HasReward
	end

	if allCard.ProgressBar then
		allCard.ProgressBar.Visible = allCard.Unlocked and allCard.ShowProgress
	end
end

function PoolVenueMenu.SetCoins(p, p2: number)
	p.CoinsLabel.Text = NumberHelper:Separate((math.round(p2)))

	for _, allCard in p.AllCards do
		allCard.Affordable = allCard.Venue.EntryFee <= p2

		repaint(allCard)
	end
end

function PoolVenueMenu.SetProgress(data, options, flag: boolean?, value: number?, value2: number?, options2)
	data.PassButton.Visible = flag ~= true

	local friendButtons = data.FriendButtons
	local passButton = data.PassButton
	local v2 = friendButtons:GetAttribute("TopBarX")

	if typeof(v2) ~= "number" then
		v2 = friendButtons.Position.X.Scale
		friendButtons:SetAttribute("TopBarX", v2)
	end

	local v3 = passButton.Position.X.Scale + passButton.Size.X.Scale * (1 - passButton.AnchorPoint.X) - friendButtons.Size.X.Scale * (1 - friendButtons.AnchorPoint.X)

	if passButton.Visible then
		v3 = v2
	end

	friendButtons.Position = UDim2.new(v3, 0, friendButtons.Position.Y.Scale, friendButtons.Position.Y.Offset)

	local poolVenueWins = options or {}
	local v4 = math.max(math.floor(value or 1), 1)
	local v5 = math.max(value2 or 0, 0)
	local winsPerBox = PoolVenueLootbox.WinsPerBox()

	local v6 = {
		poolVenueWins = poolVenueWins,
		poolVenueBoxes = options2 or {}
	}

	for _, allCard in data.AllCards do
		local id = allCard.Venue.Id
		local v7 = PoolVenueProgress.UnlockLevel(id)

		allCard.Unlocked = PoolVenueProgress.IsUnlocked(id, v4, poolVenueWins, flag == true)

		allCard.LockHeadline.Text = string.format("UNLOCKED AT LEVEL %d", v7)
		allCard.LockDetail.Text = string.format("LEVEL %d / %d", math.min(v4, v7), v7)

		if allCard.LockFill then
			local levelProgress = PoolVenueProgress.LevelProgress(v5, v7)

			allCard.LockFill.Size = UDim2.fromScale(levelProgress, 1)

			allCard.LockFill.Visible = levelProgress > 0
		end

		local v8 = allCard.HasReward and PoolVenueLootbox.Waiting(v6, id) > 0
		local progress = PoolVenueLootbox.Progress(v6, id)

		allCard.ShowProgress = allCard.HasReward

		if allCard.ProgressFill then
			local v9 = v8 and 1 or math.clamp(progress / winsPerBox, 0, 1)

			allCard.ProgressFill.Size = UDim2.fromScale(v9, 1)
			allCard.ProgressFill.Visible = v9 > 0
		end

		local unlockLabel = allCard.UnlockLabel

		if unlockLabel then
			if allCard.HasReward then
				if v8 then
					unlockLabel.Text = "Lootbox ready to open!"
				else
					unlockLabel.Text = string.format("%d/%d wins for a lootbox", progress, winsPerBox)
				end
			else
				unlockLabel.Text = ""
			end
		end

		repaint(allCard)
	end
end

function PoolVenueMenu.SetVisible(p, visible: boolean)
	p.Root.Visible = visible
end

local function applyTitle(data)
	local titleLabel = data.TitleLabel

	if not titleLabel then
		return
	end

	local challengeName = data.ChallengeName
	local formatted

	if challengeName then
		formatted = PoolVip.Format(string.upper(challengeName), data.ChallengeVip)
	end

	titleLabel.RichText = true
	local text

	if formatted and data.Ladder == "NineBall" then
		text = string.format("CHALLENGE %s TO 9 BALL", formatted)
	elseif formatted then
		text = string.format("CHALLENGE %s", formatted)
	else
		text = data.Ladder == "NineBall" and "PICK A 9 BALL VENUE" or "PICK A VENUE"
	end

	titleLabel.Text = text
end

function PoolVenueMenu:SetLadder(ladder: string)
	local ladder2 = self.Ladders[ladder]

	if not ladder2 or #ladder2 == 0 then
		return
	end

	local v2 = self.Index

	if self.Ladder ~= ladder then
		self.LadderIndex[self.Ladder] = self.Index
		self.Ladder = ladder
		self.Cards = ladder2
		self.Drag = nil
		self.SuppressTap = false
		v2 = self.LadderIndex[ladder] or 1
	end

	for k, ladder3 in self.Ladders do
		for _, v3 in ladder3 do
			v3.Root.Visible = k == ladder
		end
	end

	PoolVenueMenu.SetIndex(self, v2, true)
	applyTitle(self)
end

function PoolVenueMenu.SetFriendButtonsVisible(p, visible: boolean)
	p.FriendButtons.Visible = visible
end

function PoolVenueMenu:SetChallengeTarget(challengeName: string?, flag: boolean?)
	local v2

	if challengeName == nil then
		v2 = false
	else
		v2 = challengeName ~= ""
	end

	if not v2 then
		challengeName = nil
	end

	self.ChallengeName = challengeName
	self.ChallengeVip = v2 and flag == true
	applyTitle(self)

	if not self.TitleLabel then
		return
	end

	for _, allCard in self.AllCards do
		local parent = allCard.PrizeLabel.Parent
		local coin = parent and parent:FindFirstChild("Coin")

		if coin and coin:IsA("GuiObject") then
			coin.Visible = not v2
		end

		allCard.PrizeLabel.Text = v2 and "FRIENDLY MATCH"
			or string.format("WIN %s", NumberHelper:Separate(allCard.Venue.Prize))
	end
end

function PoolVenueMenu:Destroy()
	self.Maid:DoCleaning()
end

return PoolVenueMenu