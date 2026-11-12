local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
require(Pool.PoolConstants)
local PoolMatchFoundBurst = require(Pool.PoolMatchFoundBurst)
local PoolMatchmakingConstants = require(Pool.PoolMatchmakingConstants)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolStreakBadge = require(Pool.PoolStreakBadge)
local PoolVip = require(Pool.PoolVip)

local LocalPlayer = Players.LocalPlayer

local color = Color3.fromRGB(24, 31, 43)

local v = nil
local v2 = false

local function loadFriendFaces() -- 1 equivalent call inferred from this helper
	if v or v2 then
		return
	end

	v2 = true

	task.spawn(function()
		local ids = {}
		local success, result = pcall(function()
			return Players:GetFriendsAsync(LocalPlayer.UserId)
		end)

		if success and result then
			local success2, result2 = pcall(function()
				return result:GetCurrentPage()
			end)

			if success2 then
				for _, v3 in result2 do
					if not (typeof(v3) == "table" and tonumber(v3.Id) and #ids < 40) then
						continue
					end

					table.insert(ids, v3.Id)
				end
			end
		end

		v = ids
		v2 = false
	end)
end

local function reelFaces()
	local v3 = {}
	local set = { [LocalPlayer.UserId] = true }

	local function add(p: number?) -- 3 equivalent calls inferred from this helper
		if p and p > 0 and not set[p] then
			set[p] = true
			table.insert(v3, p)
		end
	end

	for _, v4 in Players:GetPlayers() do
		add(v4.UserId) -- inferred equivalent call
	end

	for _, v4 in v or {} do
		add(v4) -- inferred equivalent call
	end

	if #v3 == 0 and RunService:IsStudio() then
		for _, studioPlaceholderUserId in PoolMatchmakingConstants.StudioPlaceholderUserIds do
			add(studioPlaceholderUserId) -- inferred equivalent call
		end
	end

	local result = {}

	for _, v4 in v3 do
		table.insert(result, PoolPlayerData.Thumbnail(v4))
	end

	if #result == 0 then
		table.insert(result, "rbxasset://textures/ui/GuiImagePlaceholder.png")
	end

	local random = Random.new()

	for i = #result, 2, -1 do
		local integer = random:NextInteger(1, i)
		local v4 = result[integer]
		local v5 = result[i]
		result[i] = v4
		result[integer] = v5
	end

	local v4 = #result

	while #result < 6 do
		table.insert(result, result[#result % v4 + 1])
	end

	return result
end

local function nextFace(state) -- 4 equivalent calls inferred from this helper
	local face = state.Faces[state.Next] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	state.Next = state.Next % #state.Faces + 1

	return face
end

local function ensureReel(state)
	if state.Reel then
		return state.Reel
	end

	local portrait = state.Right.Portrait

	local reel = Instance.new("Frame")
	reel.Name = "Reel"
	reel.Size = UDim2.fromScale(1, 1)
	reel.BackgroundTransparency = 1
	reel.BorderSizePixel = 0
	reel.ZIndex = portrait.ZIndex + 1
	reel.Visible = false

	local strips = {}

	for i = 1, 44 do
		local top = (i - 1) / 44
		local bottom = i / 44
		local midpoint = (top + bottom) / 2
		local v3 = math.sqrt((math.max(0.25 - (midpoint - 0.5) ^ 2, 0)))
		local v4 = 1 - math.abs(midpoint - 0.5) * 0.45 * 2

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Strip" .. i
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0

		imageLabel.Position = UDim2.fromScale(0.5 - v3, top)
		imageLabel.Size = UDim2.new(v3 * 2, 0, bottom - top, 1)
		imageLabel.ScaleType = Enum.ScaleType.Stretch
		imageLabel.ImageColor3 = Color3.new(v4, v4, v4)
		imageLabel.ZIndex = reel.ZIndex + 1
		imageLabel.Parent = reel

		table.insert(strips, {
			Label = imageLabel,
			Top = top,
			Bottom = bottom,
			Left = 0.5 - v3,
			Right = v3 + 0.5
		})
	end

	local rim = Instance.new("Frame")
	rim.Name = "Rim"
	rim.Size = UDim2.fromScale(1, 1)
	rim.BackgroundTransparency = 1
	rim.ZIndex = reel.ZIndex + 2
	rim.Parent = reel

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = rim

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = 3
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = rim

	reel.Parent = portrait

	local reel2 = {
		Root = reel,
		Strips = strips,
		SlotFaces = table.create(3, "rbxasset://textures/ui/GuiImagePlaceholder.png"),
		Faces = { "rbxasset://textures/ui/GuiImagePlaceholder.png" },
		Next = 1,
		State = "Idle",
		Phase = 0,
		Turned = 0,
		LandFrom = 0,
		LandTo = 0,
		LandStart = 0,
		LandFace = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		OnLanded = nil
	}

	state.Reel = reel2

	return reel2
end

local function placeSlots(data)
	local v3 = {}

	v3[1] = (data.Phase + 0) % 3 - 1
	v3[2] = (data.Phase + 1) % 3 - 1
	v3[3] = (data.Phase + 2) % 3 - 1

	for _, strip in data.Strips do
		local midpoint = (strip.Top + strip.Bottom) / 2
		local image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		local v4 = 0

		for k, v5 in v3 do
			if v5 <= midpoint and midpoint < v5 + 1 then
				image = data.SlotFaces[k]
				v4 = v5
				break
			end
		end

		local v5 = image == "rbxasset://textures/ui/GuiImagePlaceholder.png" and 256 or 150
		local label = strip.Label

		label.Image = image
		label.ImageRectOffset = Vector2.new(strip.Left * v5, (strip.Top - v4) * v5)
		label.ImageRectSize = Vector2.new((strip.Right - strip.Left) * v5, (strip.Bottom - strip.Top) * v5)
	end
end

local function turnTo(reel, phase: number)
	reel.Phase = phase

	local v3 = math.floor(phase)

	while reel.Turned < v3 do
		reel.Turned += 1

		local v4 = -reel.Turned % 3 + 1

		if reel.State == "Landing" and reel.Turned == reel.LandTo - 1 then
			reel.SlotFaces[v4] = reel.LandFace
		else
			local slotFaces = reel.SlotFaces
			slotFaces[v4] = nextFace(reel) -- inferred equivalent call
		end
	end

	placeSlots(reel)
end

local function startReel(state)
	local reel = ensureReel(state)

	reel.Faces = reelFaces()
	reel.Next = 1
	reel.State = "Spinning"
	reel.Phase = 0
	reel.Turned = 0
	reel.OnLanded = nil

	local slotFaces = reel.SlotFaces
	slotFaces[1] = nextFace(reel) -- inferred equivalent call
	local slotFaces2 = reel.SlotFaces
	slotFaces2[2] = nextFace(reel) -- inferred equivalent call
	local slotFaces3 = reel.SlotFaces
	slotFaces3[3] = nextFace(reel) -- inferred equivalent call

	placeSlots(reel)
	reel.Root.Visible = true

	local clone = table.clone(reel.Faces)

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(clone)
		end)
	end)
end

local function stopReel(p) -- 1 equivalent call inferred from this helper
	local reel = p.Reel

	if reel then
		reel.State = "Idle"
		reel.OnLanded = nil
		reel.Root.Visible = false
	end
end

local function reelSpinning(state): boolean -- 1 equivalent call inferred from this helper
	local reel = state.Reel

	return reel ~= nil and reel.State ~= "Idle"
end

local function landReel(state, landFace: string, fn)
	local reel = state.Reel

	if not reel or reel.State == "Idle" then
		fn()

		return
	end

	reel.OnLanded = fn

	if reel.State == "Landing" then
		return
	end

	reel.State = "Landing"
	reel.LandFace = landFace
	reel.LandFrom = reel.Phase
	reel.LandTo = math.floor(reel.Phase) + 3
	reel.LandStart = os.clock()

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync({ landFace })
		end)
	end)
end

local function updateReel(data, p: number)
	local reel = data.Reel

	if not reel or reel.State == "Idle" then
		return
	end

	if reel.State == "Spinning" then
		turnTo(reel, reel.Phase + p * 9)

		return
	end

	local v3 = math.clamp((os.clock() - reel.LandStart) / 0.9, 0, 1)
	local value = TweenService:GetValue(v3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	turnTo(reel, reel.LandFrom + (reel.LandTo - reel.LandFrom) * value)

	if v3 >= 1 then
		local onLanded = reel.OnLanded

		reel.State = "Idle"
		reel.OnLanded = nil
		reel.Root.Visible = false

		PoolMatchFoundBurst.Play(data.Right.Portrait, data.Root)

		if onLanded then
			onLanded()
		end
	end
end

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolSearchMenu: %s.%s is missing (looking for %q)",
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

local function bindPanel(poolSearch, p: string)
	local root = bind(poolSearch, p)

	return {
		Root = root,
		Portrait = bind(root, "Portrait"),
		Name = bind(root, "PlayerName"),
		Level = bind(root, "PlayerLevel"),
		StreakCorner = p == "Left" and "BottomLeft" or "BottomRight"
	}
end

local PoolSearchMenu = {}

function PoolSearchMenu.new(instance)
	local maid = Maid.new()

	local poolSearch = instance:WaitForChild("PoolSearch")
	poolSearch.Visible = false

	local left = bindPanel(poolSearch, "Left")
	local right = bindPanel(poolSearch, "Right")
	local cancel = bind(poolSearch, "Cancel")

	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local v3 = {
		Root = poolSearch,
		Left = left,
		Right = right,
		Reel = nil,
		Venue = bind(poolSearch, "Venue"),
		Wager = bind(poolSearch, "Stake.Wager"),
		Status = bind(poolSearch, "Status"),
		Timer = bind(poolSearch, "Elapsed"),
		Cancel = cancel,
		Spinner = bind(right.Root, "Spinner"),
		StartedAt = 0,
		Searching = false,
		RangeLevel = nil,
		RangeFrom = 0,
		RangeText = "",
		Cancelled = bindableEvent.Event,
		CancelBindable = bindableEvent,
		Maid = maid
	}

	maid:GiveTask(cancel.Activated:Connect(function()
		bindableEvent:Fire()
	end))

	return v3
end

local function setPanel(data, p: number, displayName: string, p2: number?, p3: number?, flag: boolean?) -- 1 equivalent call inferred from this helper
	if p > 0 then
		data.Portrait.Image = PoolPlayerData.Thumbnail(p)
		data.Portrait.ImageTransparency = 0
	else
		data.Portrait.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		data.Portrait.ImageTransparency = 0.55
	end

	PoolVip.Apply(data.Name, displayName, flag)
	data.Level.Text = not p2 and "" or string.format("LEVEL %d", p2)

	PoolStreakBadge.Set(data.Portrait, p3, data.StreakCorner)
end

local function refreshRange(state)
	local rangeLevel = state.RangeLevel

	if not (state.Searching and rangeLevel) then
		return
	end

	local levelRange, v3 = PoolMatchmakingConstants.GetLevelRange(rangeLevel, os.clock() - state.RangeFrom)
	local v4

	if v3 == 1e999 then
		v4 = "ANY LEVEL"
	elseif levelRange == v3 then
		v4 = string.format("LEVEL %d", levelRange)
	else
		v4 = string.format("LEVELS %d–%d", levelRange, v3)
	end

	if v4 ~= state.RangeText then
		state.RangeText = v4
		state.Right.Level.Text = v4
	end
end

function PoolSearchMenu:BeginSearch(data, flag: boolean?)
	self.Searching = true
	self.StartedAt = os.clock()
	self.Root.Visible = true
	self.Cancel.Visible = true

	self.Spinner.Visible = false
	loadFriendFaces() -- inferred equivalent call
	local venue = self.Venue
	local text

	if data.GameType == "NineBall" and data.Country then
		text = string.format("9 BALL — %s", data.Name)
	else
		text = data.Name
	end

	venue.Text = text

	self.Wager.Text = NumberHelper:Separate(data.Prize)
	self.Status.Text = "Finding an opponent"
	self.Timer.Text = "0:00"

	setPanel(
		self.Left,
		LocalPlayer.UserId,
		LocalPlayer.DisplayName,
		PoolPlayerData.GetLevel(LocalPlayer.UserId),
		PoolPlayerData.GetWinStreak(LocalPlayer.UserId),
		PoolVip.Owns(LocalPlayer.UserId)
	)
	local right = self.Right
	right.Portrait.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	right.Portrait.ImageTransparency = 0.55

	PoolVip.Apply(right.Name, "Searching...", nil)
	right.Level.Text = ""

	PoolStreakBadge.Set(right.Portrait, nil, right.StreakCorner)

	startReel(self)
	local rangeLevel

	if flag ~= false then
		rangeLevel = PoolPlayerData.GetLevel(LocalPlayer.UserId)
	end

	self.RangeLevel = rangeLevel
	self.RangeFrom = self.StartedAt
	self.RangeText = ""
	refreshRange(self)
end

function PoolSearchMenu:SetRangeLevel(rangeLevel: number)
	if not self.RangeLevel then
		return
	end

	self.RangeLevel = rangeLevel
	self.RangeFrom = os.clock()
	self.RangeText = ""
	refreshRange(self)
end

local function popSeat(p)
	p.Portrait.Size = UDim2.fromScale(0.7, 0.4)
	TweenService:Create(p.Portrait, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.9, 0.52)
	}):Play()
end

local function faceFor(p: number) -- 2 equivalent calls inferred from this helper
	if p > 0 then
		return (PoolPlayerData.Thumbnail(p))
	end

	return "rbxasset://textures/ui/GuiImagePlaceholder.png"
end

function PoolSearchMenu:SetOpponent(p: number, p2: string, p3: number?)
	self.Searching = false
	self.RangeLevel = nil
	self.Spinner.Visible = false
	self.Cancel.Visible = false
	self.Status.Text = "Opponent found"

	landReel(self, faceFor(p), function() -- inferred equivalent call
		setPanel(self.Right, p, p2, p3) -- inferred equivalent call
		popSeat(self.Right)
	end)
end

function PoolSearchMenu:SetSeats(items, p: number)
	self.RangeLevel = nil

	for _, item in items do
		local v3

		if item.UserId == LocalPlayer.UserId then
			v3 = self.Left
		else
			v3 = self.Right
		end

		local v4 = PoolStreakBadge.ForSeat(item)

		if item.UserId == LocalPlayer.UserId and v4 == nil then
			v4 = PoolPlayerData.GetWinStreak(LocalPlayer.UserId)
		end

		local v5 = PoolVip.ForSeat(item)

		if not v5 then
			if item.UserId == LocalPlayer.UserId then
				v5 = PoolVip.Owns(LocalPlayer.UserId)
			else
				v5 = false
			end
		end

		local avatarUserId = item.AvatarUserId or item.UserId

		if v3 == self.Right then
			if reelSpinning(self) then -- inferred equivalent call
				local v6 = v3
				local v7 = v5
				landReel(self, faceFor(avatarUserId), function() -- inferred equivalent call
					setPanel(v6, avatarUserId, item.DisplayName, item.Level, v4, v7)
					popSeat(v6)
				end)
			else
				setPanel(v3, avatarUserId, item.DisplayName, item.Level, v4, v5)
			end
		else
			setPanel(v3, avatarUserId, item.DisplayName, item.Level, v4, v5)
		end
	end

	self.Wager.Text = NumberHelper:Separate(p)
	self.Spinner.Visible = false
	self.Cancel.Visible = false
end

function PoolSearchMenu.SetStatus(p, text: string)
	p.Status.Text = text
end

function PoolSearchMenu.SetCancelable(p, visible: boolean)
	p.Cancel.Visible = visible
end

function PoolSearchMenu:SetJoining()
	self.Cancel.Visible = false
	self.RangeLevel = nil
	self.Status.Text = "Joining your match"
end

function PoolSearchMenu.Update(data, p: number)
	if not data.Root.Visible then
		return
	end

	if data.Searching then
		local v3 = os.clock() - data.StartedAt

		data.Timer.Text = string.format("%d:%02d", math.floor(v3 / 60), (math.floor(v3 % 60)))

		refreshRange(data)
	end

	updateReel(data, p)
end

function PoolSearchMenu.SetCountdown(p, p2: number)
	p.Timer.Text = string.format("Starting in %d", (math.max(math.ceil(p2), 0)))
end

function PoolSearchMenu:SetVisible(visible: boolean)
	self.Root.Visible = visible

	if not visible then
		self.Searching = false
		stopReel(self) -- inferred equivalent call
	end
end

function PoolSearchMenu.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolSearchMenu