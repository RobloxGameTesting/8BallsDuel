local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolCarousel = require(Pool.PoolCarousel)
local PoolConstants = require(Pool.PoolConstants)
local PoolCueUpgradeService = require(Pool.PoolCueUpgradeService)
local PoolGalaxySet = require(Pool.PoolGalaxySet)
local PoolGiftPicker = require(Pool.PoolGiftPicker)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolPriceTag = require(Pool.PoolPriceTag)
local PoolSkins = require(Pool.PoolSkins)

local PoolCueGrid = {}

local Menu = PoolConstants.Menu
local LocalPlayer = Players.LocalPlayer

PoolCueGrid.SourceIcons = {
	Galaxy = "",
	Gem = "",
	Likes = "",
	Friends = "",
	Gift = "",
	Chest = "",
	Card = "",
	Vip = "",
	Daily = "",
	Venue = "",
	Ticket = "",
	Trophy = ""
}

local function luminance(color: Color3) -- 2 equivalent calls inferred from this helper
	return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
end

local v = {}
local v2 = {
	{ "galaxy", "Galaxy" },
	{ "limited edition", "Gem" },
	{ "like", "Likes" },
	{ "friend", "Friends" },
	{ "gift box", "Gift" },
	{ "starter pack", "Chest" },
	{ "card flip", "Card" },
	{ "vip", "Vip" },
	{ "daily", "Daily" },
	{ "wins in", "Venue" },
	{ "win 10", "Venue" },
	{ "battlepass", "Ticket" },
	{ "battle pass", "Ticket" },
	{ "trickshot", "Trophy" },
	{ "tournament", "Trophy" },
	{ "event", "Trophy" }
}

for _, v3 in {
	{ Min = 24, Id = "Tier6", Label = "MYTHIC" },
	{ Min = 18, Id = "Tier5", Label = "LEGENDARY" },
	{ Min = 13, Id = "Tier4", Label = "EPIC" },
	{ Min = 10, Id = "Tier3", Label = "RARE" },
	{ Min = 8, Id = "Tier2", Label = "UNCOMMON" },
	{ Min = 0, Id = "Normal", Label = "COMMON" }
} do
	local rarityData = Rarities.GetRarityData(v3.Id)
	local keypoints

	if rarityData and rarityData.colour then
		keypoints = rarityData.colour.Keypoints
	end

	local dark

	if keypoints then
		dark = keypoints[1].Value
	else
		dark = Color3.fromRGB(170, 170, 170)
	end

	local bright

	if keypoints then
		bright = keypoints[#keypoints].Value
	else
		bright = dark
	end

	if not (luminance(bright) > luminance(dark)) then -- inferred equivalent call
		dark, bright = bright, dark
	end

	table.insert(v, {
		Id = v3.Id,
		Label = v3.Label,
		Min = v3.Min,
		Bright = bright,
		Dark = dark
	})
end

local function rarityFor(p: number) -- 1 equivalent call inferred from this helper
	for _, v3 in v do
		if v3.Min <= p then
			return v3
		end
	end

	return v[#v]
end

PoolCueGrid.RarityFor = rarityFor

local udim = UDim2.fromScale(0.03, 0.135)
local udim2 = UDim2.fromScale(0.94, 0.865)

local udim3 = UDim2.fromScale(0.86, 0.56)

local color = Color3.fromRGB(88, 196, 84)
local color2 = Color3.fromRGB(62, 138, 232)
local color3 = Color3.fromRGB(242, 198, 52)
local color4 = Color3.fromRGB(30, 33, 42)
local color5 = Color3.fromRGB(138, 98, 226)
local Competition = Menu.Competition

local color6 = Color3.new(1, 1, 1)

local function statTotal(cue: string?, p: number)
	local total = 0

	for _, v3 in PoolConstants.CueStatOrder do
		total += PoolConstants.CueRating(cue, v3, p)
	end

	return (math.round(total))
end

PoolCueGrid.StatTotal = statTotal

local function sourceFor(p)
	if typeof(p) ~= "table" then
		return nil
	end

	if typeof(p.source) == "string" and PoolCueGrid.SourceIcons[p.source] ~= nil then
		return p.source
	end

	local obtainedFrom = PoolSkins.GetObtainedFrom(p)

	if not obtainedFrom then
		return nil
	end

	local v3 = string.lower(obtainedFrom)

	for _, v4 in v2 do
		if string.find(v3, v4[1], 1, true) then
			return v4[2]
		end
	end

	return nil
end

PoolCueGrid.SourceFor = sourceFor

local function sourceImage(source: string?) -- 2 equivalent calls inferred from this helper
	local selected

	if source then
		selected = PoolCueGrid.SourceIcons[source]
	end

	return if typeof(selected) == "string" then selected else ""
end

local function galaxyTierFor(p: string)
	if PoolGalaxySet.Category ~= "cueSticks" then
		return nil
	end

	for _, tier in PoolGalaxySet.Tiers do
		if tier.Item == p then
			return tier
		end
	end

	return nil
end

local priceInRobuxesById = {}
local v3 = {}

local function galaxyPrice(galaxy, fn) -- 1 equivalent call inferred from this helper
	local v4 = priceInRobuxesById[galaxy.Id]

	if v4 or v3[galaxy.Id] then
		return v4
	end

	v3[galaxy.Id] = true

	task.spawn(function()
		for _ = 1, 10 do
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(galaxy.ProductId, Enum.InfoType.Product)
			end)

			if success and result and result.PriceInRobux then
				priceInRobuxesById[galaxy.Id] = result.PriceInRobux
				fn()

				return
			end

			task.wait(1)
		end

		v3[galaxy.Id] = nil
	end)

	return nil
end

local function buildCatalogue()
	local catalogue = {}

	for k, v4 in PoolSkins.GetAll("cueSticks") do
		if not (typeof(k) == "string" and typeof(v4) == "table") then
			continue
		end

		local cue

		if typeof(v4.cue) == "string" and v4.cue ~= "" then
			cue = v4.cue
		end

		local baseTotal = statTotal(cue, 0)

		local v5 = {
			Key = k,
			Data = v4,
			Name = tostring(v4.name or k),
			Cue = cue,
			BaseTotal = baseTotal,
			Rarity = rarityFor(baseTotal), -- inferred equivalent call
			Source = sourceFor(v4),
			ForSale = PoolSkins.IsForSale(v4),
			Price = PoolSkins.GetPrice(v4),
			Currency = PoolSkins.GetPriceCurrency(v4),
			Galaxy = 0
		}
		local galaxy

		if PoolGalaxySet.Category == "cueSticks" then
			for _, tier in PoolGalaxySet.Tiers do
				if tier.Item == k then
					galaxy = tier
					break
				end
			end
		else
			local tier = nil
			galaxy = tier
		end

		v5.Galaxy = galaxy
		catalogue[k] = v5
	end

	return catalogue
end

local function readOwned()
	local replica = PoolPlayerData.GetReplica(LocalPlayer.UserId)
	local inventory = replica and replica.Data and replica.Data.inventory
	local cueSticks = inventory and inventory.cueSticks
	local result = {}

	if typeof(cueSticks) == "table" then
		for k, cueStick in cueSticks do
			if cueStick and typeof(k) == "string" then
				result[k] = true
			end

			if not (typeof(cueStick) == "table" and typeof(cueStick.item) == "string") then
				continue
			end

			result[cueStick.item] = true
		end
	end

	local equippedName = PoolSkins.GetEquippedName(LocalPlayer.UserId, "cueSticks")

	if equippedName ~= "" then
		result[equippedName] = true
	end

	return result, equippedName
end

local function sanitise(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BaseScript") or descendant:IsA("ModuleScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		end
	end
end

local function cuePreview(parent, instance, p: number, value: number?)
	local clone = instance:Clone()
	sanitise(clone)

	local boundingBox, v4 = clone:GetBoundingBox()
	local v5 = {
		{ Direction = boundingBox.RightVector, Span = v4.X },
		{ Direction = boundingBox.UpVector, Span = v4.Y },
		{ Direction = boundingBox.LookVector, Span = v4.Z }
	}

	local v6 = 1

	local v7 = v5[2].Span > v5[v6].Span and 2 or v6
	local v8 = v5[3].Span > v5[v7].Span and 3 or v7

	local v9 = v8 == 2 and 3 or 2
	local v10 = 6 - v8 - v9
	local span = v5[v8].Span
	local span2 = v5[v10].Span
	local span3 = v5[v9].Span
	local objectSpace = boundingBox:ToObjectSpace(clone:GetPivot())

	local v11 = span * math.clamp(value or 1, 0.1, 1)
	local v12 = Vector3.new(0.6156615, 0.7880108, 0) * ((span - v11) / 2)

	local cframe = CFrame.fromMatrix(Vector3.new(0, 0, 0), v5[v8].Direction, v5[v9].Direction)
	clone:PivotTo(CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0.6156615, 0.7880108, 0), Vector3.new(0, 0, 1)) * cframe:Inverse() * boundingBox.Rotation * objectSpace)
	clone.Parent = parent

	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.Parent = parent
	parent.CurrentCamera = camera

	local function frame()
		local absoluteSize = parent.AbsoluteSize
		local v13 = not (absoluteSize.Y > 0) and 1 or math.max(absoluteSize.X, 1) / absoluteSize.Y
		local v14 = math.tan(math.rad(camera.FieldOfView) / 2)
		local v15 = v14 * v13
		local v16 = v11 / 2 * 0.6156614753256583 + span2 / 2 * 0.788010753606722
		local v17 = math.max((v11 / 2 * 0.788010753606722 + span2 / 2 * 0.6156614753256583) / v14, v16 / v15) * p + span3

		camera.CFrame = CFrame.lookAt(v12 + Vector3.new(0, 0, v17), v12)
	end

	frame()
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(frame)
end

local function newViewport(parent, zIndex: number)
	local preview = Instance.new("ViewportFrame")
	preview.Name = "Preview"
	preview.BackgroundTransparency = 1
	preview.BorderSizePixel = 0
	preview.Size = UDim2.fromScale(1, 1)
	preview.LightColor = Color3.fromRGB(255, 245, 225)
	preview.Ambient = Color3.fromRGB(150, 155, 165)
	preview.ZIndex = zIndex
	preview.Parent = parent

	return preview
end

local function frame(parent, name: string, zIndex: number) -- 9 equivalent calls inferred from this helper
	local frame2 = Instance.new("Frame")
	frame2.Name = name
	frame2.BackgroundTransparency = 1
	frame2.BorderSizePixel = 0
	frame2.ZIndex = zIndex
	frame2.Parent = parent

	return frame2
end

local function thinStroke(instance, thickness: number) -- 5 equivalent calls inferred from this helper
	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Thickness = thickness
	end
end

local function newTile(p)
	local tile = Instance.new("TextButton")
	tile.Name = "Tile"
	tile.AutoButtonColor = false
	tile.Text = ""
	tile.BackgroundTransparency = 1
	tile.BorderSizePixel = 0
	tile.ZIndex = 430
	tile.Visible = false
	tile.Parent = p.Scroller

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = tile

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.fromScale(1, 1)
	card.BackgroundColor3 = Color3.new(1, 1, 1)
	card.BorderSizePixel = 0
	card.ZIndex = 431
	card.Parent = tile
	PoolMenuWidgets.Corner(card, 0.1)

	local gradient = PoolMenuWidgets.Gradient(card, Color3.new(1, 1, 1), Color3.new(0, 0, 0))
	local stroke = PoolMenuWidgets.Stroke(card, 2.5, Color3.new(1, 1, 1))
	local parent = frame(card, "Shine", 432) -- inferred equivalent call
	parent.BackgroundTransparency = 0
	parent.BackgroundColor3 = Color3.new(1, 1, 1)
	parent.Size = UDim2.fromScale(1, 0.5)
	PoolMenuWidgets.Corner(parent, 0.18)

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new(0.82, 1)
	uiGradient.Parent = parent
	local v4 = frame(card, "Holder", 433) -- inferred equivalent call
	v4.Position = UDim2.fromScale(0.04, 0.03)
	v4.Size = UDim2.fromScale(0.92, 0.76)
	local powerPill = frame(card, "Power", 435) -- inferred equivalent call
	powerPill.Visible = false
	powerPill.BackgroundTransparency = 0.25
	powerPill.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
	powerPill.Position = UDim2.fromScale(0.05, 0.05)
	powerPill.Size = UDim2.fromScale(0.34, 0.15)
	PoolMenuWidgets.Corner(powerPill, 0.4)

	local label = PoolMenuWidgets.Label(powerPill, "Value", "0", Menu.Gold, 436)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.52)
	label.Size = UDim2.fromScale(0.86, 0.86)
	thinStroke(label, 1.5) -- inferred equivalent call
	local source = Instance.new("ImageLabel")
	source.Name = "Source"
	source.BackgroundTransparency = 1
	source.ScaleType = Enum.ScaleType.Fit
	source.AnchorPoint = Vector2.new(1, 1)
	source.Position = UDim2.fromScale(0.96, 0.8)
	source.Size = UDim2.fromScale(0.28, 0.28)
	source.ZIndex = 435
	source.Visible = false
	source.Parent = card

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.Parent = source
	local strip = frame(card, "Strip", 435) -- inferred equivalent call
	strip.BackgroundTransparency = 0.3
	strip.BackgroundColor3 = Color3.fromRGB(10, 13, 20)
	strip.AnchorPoint = Vector2.new(0.5, 1)
	strip.Position = UDim2.fromScale(0.5, 0.965)
	strip.Size = UDim2.fromScale(0.92, 0.17)
	PoolMenuWidgets.Corner(strip, 0.3)

	local lockOverlay = Instance.new("CanvasGroup")
	lockOverlay.Name = "LockOverlay"
	lockOverlay.BackgroundTransparency = 1
	lockOverlay.BorderSizePixel = 0
	lockOverlay.AnchorPoint = Vector2.new(0.5, 0.5)
	lockOverlay.Position = UDim2.fromScale(0.5, 0.5)
	lockOverlay.Size = UDim2.fromScale(1, 0.42)
	lockOverlay.GroupTransparency = 0.35
	lockOverlay.ZIndex = 436
	lockOverlay.Visible = false
	lockOverlay.Parent = v4

	local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint2.AspectRatio = 0.76
	uiAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint2.Parent = lockOverlay

	local v5 = PoolMenuWidgets.LockIcon(lockOverlay, color6, 436)
	v5.AnchorPoint = Vector2.new(0.5, 0.5)
	v5.Position = UDim2.fromScale(0.5, 0.5)
	v5.Size = UDim2.fromScale(1, 0.86)

	local shackle = v5:FindFirstChild("Shackle")
	local uiStroke = shackle and shackle:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		local function weigh() -- 1 equivalent call inferred from this helper
			uiStroke.Thickness = math.max(2, (math.floor(lockOverlay.AbsoluteSize.Y * 0.08 + 0.5)))
		end

		weigh() -- inferred equivalent call
		lockOverlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(weigh)
	end

	local label2 = PoolMenuWidgets.Label(strip, "Label", "", Menu.TextPrimary, 436)
	label2.AnchorPoint = Vector2.new(0.5, 0.5)
	label2.Position = UDim2.fromScale(0.5, 0.52)
	label2.Size = UDim2.fromScale(0.9, 0.8)
	thinStroke(label2, 1.5) -- inferred equivalent call
	local tile2 = {
		Root = tile,
		Card = card,
		Gradient = gradient,
		Stroke = stroke,
		Holder = v4,
		Viewport = nil,
		PowerPill = powerPill,
		Power = label,
		Source = source,
		Strip = strip,
		StripLabel = label2,
		Lock = lockOverlay,
		Scale = uiScale,
		Key = nil,
		LoadedKey = nil,
		Dim = false,
		Stamp = nil
	}

	tile.MouseEnter:Connect(function()
		uiScale.Scale = 1.04
	end)

	tile.MouseLeave:Connect(function()
		uiScale.Scale = 1
	end)

	tile.Activated:Connect(function()
		local key = tile2.Key

		if key then
			PoolCueGrid.View(p, key)
		end
	end)

	p.Maid:GiveTask(tile)

	return tile2
end

local function dropPreview(state) -- 2 equivalent calls inferred from this helper
	if state.Viewport then
		state.Viewport:Destroy()
		state.Viewport = nil
	end

	state.LoadedKey = nil
end

local function loadPreview(data, tile)
	local key = tile.Key
	dropPreview(tile) -- inferred equivalent call
	tile.LoadedKey = key

	local v4 = key and data.Catalogue[key]
	local v5 = v4 and PoolMenuWidgets.FindSkinModel(v4.Data)

	if not v5 then
		return
	end

	local viewport = newViewport(tile.Holder, 434)
	tile.Viewport = viewport

	local success, result = pcall(cuePreview, viewport, v5, 1.04, 0.4)

	if not success then
		warn("PoolCueGrid: preview failed for " .. tostring(key) .. ": " .. tostring(result))
	end
end

local function dress(data, state, i: number)
	local name = data.Order[i]
	local v4 = name and data.Catalogue[name]

	if not (name and v4) then
		state.Root.Visible = false

		return
	end

	if state.Key ~= name then
		state.Key = name

		if state.LoadedKey ~= name then
			dropPreview(state) -- inferred equivalent call
		end
	end

	state.Root.Visible = true
	state.Root.Name = name

	local v5 = data.Owned[name] == true
	local v6 = name == data.Equipped
	local v7 = not v5 and 0 or PoolSkins.GetCueLevel(LocalPlayer.UserId, name)
	local stamp = string.format("%s|%s|%s|%d", name, tostring(v5), tostring(v6), v7)

	if state.Stamp == stamp then
		return
	end

	state.Stamp = stamp

	local rarity = v4.Rarity

	state.Gradient.Color = ColorSequence.new(
		rarity.Bright:Lerp(Color3.new(0, 0, 0), 0.32),
		rarity.Dark:Lerp(Color3.new(0, 0, 0), 0.66)
	)

	local stroke = state.Stroke
	local color7 = if v6 then color else rarity.Bright
	stroke.Color = color7
	state.Stroke.Thickness = v6 and 3.5 or 2.5

	state.Power.Text = tostring(statTotal(v4.Cue, v7))

	local image = sourceImage(v4.Source) -- inferred equivalent call

	state.Source.Image = image
	state.Source.Visible = image ~= ""

	state.Dim = not v5
	state.Lock.Visible = not v5

	if v6 then
		state.Strip.BackgroundColor3 = color
		state.Strip.BackgroundTransparency = 0.05
		state.StripLabel.Text = "EQUIPPED"
		state.StripLabel.TextColor3 = Menu.TextPrimary
	elseif v5 then
		state.Strip.BackgroundColor3 = Color3.fromRGB(10, 13, 20)
		state.Strip.BackgroundTransparency = 0.3
		state.StripLabel.Text = v4.Name
		state.StripLabel.TextColor3 = Menu.TextPrimary
	else
		state.Strip.BackgroundColor3 = Color3.fromRGB(10, 13, 20)
		state.Strip.BackgroundTransparency = 0.3

		local stripLabel = state.StripLabel
		local text

		if v4.ForSale then
			text = PoolSkins.FormatPrice(v4.Price, v4.Currency)
		else
			text = v4.Name
		end

		stripLabel.Text = text
		local stripLabel2 = state.StripLabel
		local textColor

		if v4.ForSale then
			textColor = Menu.Gold
		else
			textColor = Menu.TextMuted
		end

		stripLabel2.TextColor3 = textColor
	end
end

local function acquire(state, p: string)
	for k, v4 in state.Free do
		if v4.LoadedKey == p then
			table.remove(state.Free, k)

			return v4
		end
	end

	return table.remove(state.Free) or newTile(state)
end

local function release(state, state2) -- 1 equivalent call inferred from this helper
	state2.Root.Visible = false
	state2.Key = nil
	state2.Scale.Scale = 1
	table.insert(state.Free, state2)
end

local function bottomClear(p) -- 2 equivalent calls inferred from this helper
	return (math.floor(p.Root.AbsoluteSize.Y * 0.17))
end

local function measure(state): boolean
	local scroller = state.Scroller
	local absoluteSize = scroller.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return false
	end

	local v4 = bottomClear(state) -- inferred equivalent call
	local v5 = absoluteSize.X - 8 - 12
	local v6 = math.max(math.min(150, (absoluteSize.Y - v4 - 12) / 2.4 / 1.12), 78)
	local columns = math.clamp(math.floor((v5 + 10) / (v6 + 10)), 3, 10)
	local tileWidth = math.max(math.floor((v5 - (columns - 1) * 10) / columns), 1)
	local tileHeight = math.floor(tileWidth * 1.12)
	local v7 = math.ceil(#state.Order / columns)

	state.Columns = columns
	state.TileWidth = tileWidth
	state.TileHeight = tileHeight

	local udim4 = UDim2.fromOffset(0, v7 * tileHeight + 12 + math.max(v7 - 1, 0) * 10 + v4)

	if scroller.CanvasSize ~= udim4 then
		scroller.CanvasSize = udim4
	end

	return true
end

local function updateVisible(state)
	local columns = state.Columns

	if columns <= 0 then
		return
	end

	local v4 = state.TileHeight + 10
	local y = state.Scroller.CanvasPosition.Y
	local y2 = state.Scroller.AbsoluteSize.Y
	local count = #state.Order

	local v5 = math.max(math.floor((y - 6) / v4), 0)
	local v6 = math.max(math.floor((y + y2 - 6) / v4), 0)
	local v7 = math.max(v5 - 1, 0)
	local v8 = v6 + 1

	local first = v7 * columns + 1
	local last = math.min((v8 + 1) * columns, count)

	state.First = first
	state.Last = last
	state.VisibleFirst = v5 * columns + 1
	state.VisibleLast = math.min((v6 + 1) * columns, count)

	local v9 = {}

	for _, tile in state.Tiles do
		if tile.Key then
			v9[tile.Key] = tile
		end
	end

	local tiles = {}

	for i = first, last do
		local v10 = state.Order[i]

		if not v10 then
			continue
		end

		local v11 = v9[v10]

		if v11 then
			v9[v10] = nil
		else
			v11 = acquire(state, v10)
		end

		local v12 = (i - 1) // columns
		local v13 = (i - 1) % columns

		v11.Root.Position = UDim2.fromOffset(v13 * (state.TileWidth + 10) + 6, v12 * v4 + 6)
		v11.Root.Size = UDim2.fromOffset(state.TileWidth, state.TileHeight)

		dress(state, v11, i)
		tiles[i] = v11
	end

	for _, v10 in v9 do
		release(state, v10) -- inferred equivalent call
	end

	state.Tiles = tiles
end

local function pump(data)
	local v4 = 3

	local function try(i: number) -- 2 equivalent calls inferred from this helper
		local tile = data.Tiles[i]

		if tile and tile.Key and tile.LoadedKey ~= tile.Key then
			loadPreview(data, tile)
			v4 -= 1
		end
	end

	for i = data.VisibleFirst, data.VisibleLast do
		if v4 <= 0 then
			return
		end

		try(i) -- inferred equivalent call
	end

	for i = data.First, data.Last do
		if v4 <= 0 then
			break
		end

		try(i) -- inferred equivalent call
	end
end

local function layoutButtons(detail)
	local v4 = { detail.Primary, detail.View }

	local function lay(list, p: number, p2: number)
		local v5 = (0.49 - (#list - 1) * 0.02) / #list

		for k, item in list do
			item.AnchorPoint = Vector2.new(0, 0)
			item.Position = UDim2.fromScale((k - 1) * (v5 + 0.02) + 0.47, p)
			item.Size = UDim2.fromScale(v5, p2)
		end
	end

	if not detail.Secondary.Visible then
		lay(v4, 0.73, 0.16)

		return
	end

	lay(v4, 0.655, 0.135)
	lay({ detail.Secondary }, 0.81, 0.135)
end

local function setButton(p, p2, color7: Color3, text: string, flag: boolean)
	PoolButtonSkin.SetColour(p, color7)
	p.Active = flag
	p.AutoButtonColor = flag
	PoolButtonSkin.SetFaded(p, flag and 0 or 0.15)
	p2.Text = text
	local textColor = if flag then Menu.TextPrimary else Menu.TextMuted
	p2.TextColor3 = textColor
end

local function refreshDetail(state)
	local detail = state.Detail
	local detailKey = state.DetailKey

	if not (detailKey and detail.Root.Visible) then
		return
	end

	local v4 = state.Catalogue[detailKey]

	if v4 then
		local v5 = state.Owned[detailKey] == true
		local v6 = v5 and detailKey == state.Equipped
		local v7

		if v5 then
			v7 = PoolCueUpgradeService.GetOffer(LocalPlayer.UserId, detailKey)
		end

		local v8 = not v7 and 0 or v7.Level
		local rarity = v4.Rarity

		detail.PreviewGradient.Color = ColorSequence.new(
			rarity.Bright:Lerp(Color3.new(0, 0, 0), 0.25),
			rarity.Dark:Lerp(Color3.new(0, 0, 0), 0.62)
		)

		detail.PreviewStroke.Color = rarity.Bright
		detail.RarityLabel.Text = rarity.Label
		detail.RarityLabel.TextColor3 = rarity.Bright:Lerp(Color3.new(1, 1, 1), 0.35)

		if detail.PreviewKey ~= detailKey then
			if detail.Viewport then
				detail.Viewport:Destroy()
				detail.Viewport = nil
			end

			detail.PreviewKey = detailKey

			local skinModel = PoolMenuWidgets.FindSkinModel(v4.Data)

			if skinModel then
				local viewport = newViewport(detail.PreviewHolder, 704)
				detail.Viewport = viewport
				pcall(cuePreview, viewport, skinModel, 1.02)
			end
		end

		if detail.Viewport then
			local viewport = detail.Viewport
			local imageColor

			if v5 then
				imageColor = Color3.new(1, 1, 1)
			else
				imageColor = Color3.fromRGB(150, 150, 160)
			end

			viewport.ImageColor3 = imageColor
		end

		detail.Name.Text = v4.Name

		detail.Subtitle.Text = rarity.Label
		detail.Subtitle.TextColor3 = rarity.Bright:Lerp(Color3.new(1, 1, 1), 0.45)
		local text

		if v4.ForSale then
			text = "Sold in the shop for " .. PoolSkins.FormatPrice(v4.Price, v4.Currency)
		else
			text = PoolSkins.GetObtainedFrom(v4.Data) or "Can't be bought in the shop."
		end

		if v5 then
			text = "OWNED  ·  " .. text
		end

		local image = sourceImage(v4.Source) -- inferred equivalent call

		detail.SourceIcon.Image = image
		detail.SourceIcon.Visible = image ~= ""
		detail.SourceText.Text = text

		if detail.SourceIcon.Visible then
			detail.SourceText.Position = UDim2.fromScale(0.545, 0.275)
			detail.SourceText.Size = UDim2.fromScale(0.415, 0.09)
		else
			detail.SourceText.Position = UDim2.fromScale(0.47, 0.275)
			detail.SourceText.Size = UDim2.fromScale(0.49, 0.09)
		end

		if v7 and v7.MaxLevel > 0 then
			detail.Level.Text = string.format("LEVEL %d / %d", v7.Level, v7.MaxLevel)
		elseif v5 then
			detail.Level.Text = ""
		else
			detail.Level.Text = "NOT OWNED"
		end

		local v9

		if v7 and v7.Cost then
			v9 = v7.Level + 1
		end

		PoolMenuWidgets.WriteCueStats(PoolMenuWidgets.ReadCueStats(detail.Stats), v4.Cue, false, v8, v9)
		local v10

		if v4.Currency == "Gems" then
			v10 = PoolPlayerData.GetGems(LocalPlayer.UserId)
		else
			v10 = PoolPlayerData.GetCoins(LocalPlayer.UserId)
		end

		local forSale = not v5 and v4.ForSale
		local v11 = forSale and v4.Price <= v10

		if v6 then
			local primary = detail.Primary
			local primaryLabel = detail.PrimaryLabel
			PoolButtonSkin.SetColour(primary, color)
			primary.Active = false
			primary.AutoButtonColor = false
			PoolButtonSkin.SetFaded(primary, 0.15)
			primaryLabel.Text = "EQUIPPED"
			primaryLabel.TextColor3 = Menu.TextMuted
		elseif v5 then
			local primary = detail.Primary
			local primaryLabel = detail.PrimaryLabel
			PoolButtonSkin.SetColour(primary, color2)
			primary.Active = true
			primary.AutoButtonColor = true
			PoolButtonSkin.SetFaded(primary, 0)
			primaryLabel.Text = "EQUIP"
			primaryLabel.TextColor3 = Menu.TextPrimary
		elseif v11 then
			local primary = detail.Primary
			local primaryLabel = detail.PrimaryLabel

			local text2 = "BUY · " .. PoolSkins.FormatPrice(v4.Price, v4.Currency)
			PoolButtonSkin.SetColour(primary, color3)
			primary.Active = true
			primary.AutoButtonColor = true
			PoolButtonSkin.SetFaded(primary, 0)
			primaryLabel.Text = text2
			primaryLabel.TextColor3 = Menu.TextPrimary
		elseif forSale then
			local primary = detail.Primary
			local primaryLabel = detail.PrimaryLabel
			local formatPrice = PoolSkins.FormatPrice(v4.Price, v4.Currency)
			PoolButtonSkin.SetColour(primary, color4)
			primary.Active = false
			primary.AutoButtonColor = false
			PoolButtonSkin.SetFaded(primary, 0.15)
			primaryLabel.Text = formatPrice
			primaryLabel.TextColor3 = Menu.TextMuted
		else
			local primary = detail.Primary
			local primaryLabel = detail.PrimaryLabel
			PoolButtonSkin.SetColour(primary, color5)
			primary.Active = true
			primary.AutoButtonColor = true
			PoolButtonSkin.SetFaded(primary, 0)
			primaryLabel.Text = "INFO"
			primaryLabel.TextColor3 = Menu.TextPrimary
		end

		local galaxy = v4.Galaxy
		local v12

		if galaxy == nil then
			v12 = false
		else
			v12 = not (v5 or PoolGalaxySet.IsSoldOut(galaxy.Id))
		end

		if v7 and v7.MaxLevel > 0 then
			detail.Secondary.Visible = true
			detail.SecondaryMode = "Upgrade"
			PoolPriceTag.SetText(detail.SecondaryLabel, "")

			if v7.Cost then
				local secondary = detail.Secondary
				local secondaryLabel = detail.SecondaryLabel
				local gold = Menu.Gold
				local text2 = string.format("UPGRADE · $%s", PoolSkins.FormatAmount(v7.Cost))
				PoolButtonSkin.SetColour(secondary, gold)
				secondary.Active = true
				secondary.AutoButtonColor = true
				PoolButtonSkin.SetFaded(secondary, 0)
				secondaryLabel.Text = text2
				secondaryLabel.TextColor3 = Menu.TextPrimary
			else
				local secondary = detail.Secondary
				local secondaryLabel = detail.SecondaryLabel
				local gold = Menu.Gold
				local text2 = string.format("MAX · LV%d", v7.Level)
				PoolButtonSkin.SetColour(secondary, gold)
				secondary.Active = false
				secondary.AutoButtonColor = false
				PoolButtonSkin.SetFaded(secondary, 0.15)
				secondaryLabel.Text = text2
				secondaryLabel.TextColor3 = Menu.TextMuted
			end
		elseif v12 and galaxy then
			detail.Secondary.Visible = true
			detail.SecondaryMode = "Robux"
			local secondary = detail.Secondary
			local secondaryLabel = detail.SecondaryLabel
			local buttonColour = PoolPriceTag.ButtonColour
			PoolButtonSkin.SetColour(secondary, buttonColour)
			secondary.Active = true
			secondary.AutoButtonColor = true
			PoolButtonSkin.SetFaded(secondary, 0)
			secondaryLabel.Text = "BUY"
			secondaryLabel.TextColor3 = Menu.TextPrimary

			local function fn()
				refreshDetail(state)
			end

			local v13 = galaxyPrice(galaxy, fn) -- inferred equivalent call
			PoolPriceTag.SetText(detail.SecondaryLabel, not v13 and "BUY" or "R$ " .. tostring(v13))
		else
			detail.Secondary.Visible = false
			detail.SecondaryMode = nil
		end

		if state.GiftBadge then
			state.GiftBadge.Visible = detail.SecondaryMode == "Robux"
		end

		layoutButtons(detail)
	else
		detail.Root.Visible = false
		state.DetailKey = nil
	end
end

local function buildDetail(_, root)
	local v4 = frame(root, "CueDetail", 690) -- inferred equivalent call
	v4.Size = UDim2.fromScale(1, 1)
	v4.Visible = false

	local dimmer = Instance.new("TextButton")
	dimmer.Name = "Dimmer"
	dimmer.AutoButtonColor = false
	dimmer.Text = ""
	dimmer.BackgroundColor3 = Color3.new(0, 0, 0)
	dimmer.BackgroundTransparency = 0.42
	dimmer.BorderSizePixel = 0
	dimmer.Size = UDim2.fromScale(1, 1)
	dimmer.ZIndex = 690
	dimmer.Parent = v4

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Active = true
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.53)
	panel.Size = UDim2.fromScale(0.68, 0.74)
	panel.BackgroundColor3 = Menu.Panel
	panel.BorderSizePixel = 0
	panel.ZIndex = 700
	panel.Parent = v4
	PoolMenuWidgets.Corner(panel, 0.05)
	PoolMenuWidgets.Gradient(panel, Menu.Panel, Menu.PanelShade)
	PoolMenuWidgets.Stroke(panel, 3, Color3.fromRGB(8, 10, 14), 0.1)

	local previewCard = Instance.new("Frame")
	previewCard.Name = "PreviewCard"
	previewCard.Position = UDim2.fromScale(0.025, 0.05)
	previewCard.Size = UDim2.fromScale(0.415, 0.9)
	previewCard.BackgroundColor3 = Color3.new(1, 1, 1)
	previewCard.BorderSizePixel = 0
	previewCard.ZIndex = 702
	previewCard.Parent = panel
	PoolMenuWidgets.Corner(previewCard, 0.06)

	local gradient = PoolMenuWidgets.Gradient(previewCard, Color3.new(1, 1, 1), Color3.new(0, 0, 0))
	local stroke = PoolMenuWidgets.Stroke(previewCard, 3, Color3.new(1, 1, 1))
	local previewHolder = frame(previewCard, "Holder", 703) -- inferred equivalent call
	previewHolder.Position = UDim2.fromScale(0.05, 0.04)
	previewHolder.Size = UDim2.fromScale(0.9, 0.78)

	local label = PoolMenuWidgets.Label(previewCard, "Rarity", "", Menu.TextPrimary, 705)
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.fromScale(0.5, 0.965)
	label.Size = UDim2.fromScale(0.86, 0.12)

	local label2 = PoolMenuWidgets.Label(panel, "ItemName", "", Menu.TextPrimary, 702)
	label2.Position = UDim2.fromScale(0.47, 0.06)
	label2.Size = UDim2.fromScale(0.41, 0.13)
	label2.TextXAlignment = Enum.TextXAlignment.Left

	local label3 = PoolMenuWidgets.Label(panel, "Subtitle", "", Menu.TextMuted, 702)
	label3.Position = UDim2.fromScale(0.47, 0.19)
	label3.Size = UDim2.fromScale(0.49, 0.065)
	label3.TextXAlignment = Enum.TextXAlignment.Left
	thinStroke(label3, 1.5) -- inferred equivalent call
	local sourceIcon = Instance.new("ImageLabel")
	sourceIcon.Name = "SourceIcon"
	sourceIcon.BackgroundTransparency = 1
	sourceIcon.ScaleType = Enum.ScaleType.Fit
	sourceIcon.Position = UDim2.fromScale(0.47, 0.27)
	sourceIcon.Size = UDim2.fromScale(0.06, 0.1)
	sourceIcon.ZIndex = 702
	sourceIcon.Visible = false
	sourceIcon.Parent = panel

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = sourceIcon

	local label4 = PoolMenuWidgets.Label(panel, "Source", "", Menu.TextMuted, 702)
	label4.TextXAlignment = Enum.TextXAlignment.Left
	label4.TextWrapped = true
	label4.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	thinStroke(label4, 1) -- inferred equivalent call
	local label5 = PoolMenuWidgets.Label(panel, "Level", "", Menu.Gold, 702)
	label5.Position = UDim2.fromScale(0.47, 0.375)
	label5.Size = UDim2.fromScale(0.49, 0.055)
	label5.TextXAlignment = Enum.TextXAlignment.Left
	thinStroke(label5, 1.5) -- inferred equivalent call
	local cueStatPanel = PoolMenuWidgets.CueStatPanel(panel, 702)
	cueStatPanel.Position = UDim2.fromScale(0.47, 0.445)
	cueStatPanel.Size = UDim2.fromScale(0.49, 0.19)

	local button = PoolMenuWidgets.Button(panel, "Primary", color2, 704)
	local buttonText = PoolMenuWidgets.ButtonText(button, "EQUIP", nil, 704)
	buttonText.Size = udim3

	local button2 = PoolMenuWidgets.Button(panel, "Secondary", Menu.Gold, 704)
	local buttonText2 = PoolMenuWidgets.ButtonText(button2, "UPGRADE", nil, 704)
	buttonText2.Size = udim3
	PoolPriceTag.Attach(buttonText2)
	button2.Visible = false

	local button3 = PoolMenuWidgets.Button(panel, "View", Competition, 704)
	local buttonText_2 = PoolMenuWidgets.ButtonText(button3, "VIEW", nil, 704)
	buttonText_2.Size = udim3

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.fromScale(0.985, 0.03)
	close.Size = UDim2.fromScale(0.08, 0.13)
	close.BackgroundColor3 = PoolButtonSkin.Exit.Colour
	close.BorderSizePixel = 0
	close.Text = ""
	close.ZIndex = 706
	close.Parent = panel

	local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint2.AspectRatio = 1
	uiAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint2.Parent = close

	PoolButtonSkin.ApplyExit(close)

	local detail = {
		Root = v4,
		Dimmer = dimmer,
		Panel = panel,
		PreviewCard = previewCard,
		PreviewGradient = gradient,
		PreviewStroke = stroke,
		PreviewHolder = previewHolder,
		Viewport = nil,
		PreviewKey = nil,
		RarityLabel = label,
		Name = label2,
		Subtitle = label3,
		SourceIcon = sourceIcon,
		SourceText = label4,
		Level = label5,
		Stats = cueStatPanel,
		Primary = button,
		PrimaryLabel = buttonText,
		Secondary = button2,
		SecondaryLabel = buttonText2,
		SecondaryMode = nil,
		View = button3,
		Close = close
	}

	layoutButtons(detail)

	return detail
end

function PoolCueGrid.GetOrder(p)
	return p.Order
end

function PoolCueGrid.Has(p, p2: string): boolean
	return p.Catalogue[p2] ~= nil
end

function PoolCueGrid:Refresh()
	if self.CatalogueDirty then
		self.Catalogue = buildCatalogue()
		self.CatalogueDirty = false
	end

	local owned2, equipped2 = readOwned()
	self.Owned = owned2
	self.Equipped = equipped2

	local catalogue = self.Catalogue
	local owned = self.Owned
	local equipped = self.Equipped
	local order = {}
	local count = 0

	for k in catalogue do
		table.insert(order, k)

		if owned[k] then
			count += 1
		end
	end

	table.sort(order, function(a: string, b: string)
		local v4 = owned[a] == true

		if v4 ~= (owned[b] == true) then
			return v4
		end

		local v5 = a == equipped

		if v5 ~= (b == equipped) then
			return v5
		end

		local v6 = catalogue[a]
		local v7 = catalogue[b]

		if v6.BaseTotal ~= v7.BaseTotal then
			return v6.BaseTotal < v7.BaseTotal
		end

		if v6.Name == v7.Name then
			return a < b
		end

		return v6.Name < v7.Name
	end)

	local v4 = #order ~= #self.Order

	if not v4 then
		for k, v5 in order do
			if self.Order[k] ~= v5 then
				v4 = true
				break
			end
		end
	end

	self.Order = order
	self.OwnedCount = count
	self.Dirty = false
	self.Counter.Text = string.format("OWNED  %d / %d", count, #order)

	for _, tile in self.Tiles do
		tile.Stamp = nil
	end

	for _, v5 in self.Free do
		v5.Stamp = nil
	end

	if measure(self) then
		updateVisible(self)
	end

	refreshDetail(self)

	if v4 and self.Callbacks.Repage then
		self.Callbacks.Repage()
	end
end

function PoolCueGrid:Invalidate()
	self.Dirty = true

	if self.Mode ~= "Grid" or self.RefreshQueued then
		return
	end

	self.RefreshQueued = true

	task.defer(function()
		self.RefreshQueued = false

		if self.Mode == "Grid" and self.Dirty then
			PoolCueGrid.Refresh(self)
		end
	end)
end

function PoolCueGrid.RefreshDetail(p)
	refreshDetail(p)
end

local function openDetail(state, detailKey: string): boolean
	if not state.Catalogue[detailKey] then
		return false
	end

	state.DetailKey = detailKey
	state.Detail.Root.Visible = true

	for _, tile in state.Tiles do
		tile.Scale.Scale = 1
	end

	refreshDetail(state)

	return true
end

function PoolCueGrid.OpenDetail(p, p2: string): boolean
	if not p.Catalogue[p2] then
		return false
	end

	PoolCueGrid.View(p, p2)

	return true
end

function PoolCueGrid:CloseDetail()
	self.DetailKey = nil
	self.Detail.Root.Visible = false

	if self.Detail.Viewport then
		self.Detail.Viewport:Destroy()
		self.Detail.Viewport = nil
	end

	self.Detail.PreviewKey = nil
end

function PoolCueGrid.ScrollTo(data, p: string)
	local index = table.find(data.Order, p)

	if not index or data.Columns <= 0 then
		return
	end

	local scroller = data.Scroller
	local v4 = 6 + (index - 1) // data.Columns * (data.TileHeight + 10) - (scroller.AbsoluteSize.Y - bottomClear(data) - data.TileHeight) / 2 -- inferred equivalent call
	local v5 = math.max(scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y, 0)

	scroller.CanvasPosition = Vector2.new(0, (math.clamp(v4, 0, v5)))
end

function PoolCueGrid:SetMode(mode: string)
	if self.Mode == mode then
		return
	end

	self.Mode = mode
	self.Root.Visible = mode == "Grid"
	self.ExitButton.Visible = mode == "View"

	local tabs = self.Menu.Root:FindFirstChild("Tabs")

	if tabs and tabs:IsA("GuiObject") then
		tabs.Visible = mode ~= "View"
	end

	self.Menu.Back.Visible = mode ~= "View"

	if mode ~= "Grid" then
		PoolCueGrid.CloseDetail(self)
	end

	self.PumpMaid:DoCleaning()

	if mode == "Grid" then
		self.PumpMaid:GiveTask(RunService.Heartbeat:Connect(function()
			pump(self)
		end))

		PoolCueGrid.Refresh(self)
	end
end

function PoolCueGrid.View(p, p2: string)
	local cueSticks = p.Menu.Carousels.cueSticks

	PoolCueGrid.CloseDetail(p)

	if cueSticks then
		PoolCarousel.FocusKey(cueSticks, p2, true)
	end

	p.Menu.Viewing = true

	if p.Callbacks.Sync then
		p.Callbacks.Sync()
	end
end

function PoolCueGrid.ExitView(data)
	if not data.Menu.Viewing then
		return
	end

	local cueSticks = data.Menu.Carousels.cueSticks
	local v4

	if cueSticks then
		v4 = PoolCarousel.GetKey(cueSticks)
	end

	data.Menu.Viewing = false

	if data.Callbacks.Sync then
		data.Callbacks.Sync()
	end

	if v4 and data.Mode == "Grid" then
		PoolCueGrid.ScrollTo(data, v4)
	end
end

function PoolCueGrid.new(menu, options)
	local maid = Maid.new()
	local pumpMaid = Maid.new()
	maid:GiveTask(pumpMaid)

	local root = menu.Root
	local v4 = frame(root, "CueGrid", 420) -- inferred equivalent call
	v4.Size = UDim2.fromScale(1, 1)
	v4.Visible = false
	maid:GiveTask(v4)

	local background = root:FindFirstChild("Background")
	local backdrop = Instance.new("ImageLabel")
	backdrop.Name = "Backdrop"
	backdrop.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
	backdrop.BorderSizePixel = 0
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.ScaleType = Enum.ScaleType.Crop
	backdrop.Image = not (background and background:IsA("ImageLabel")) and "" or background.Image
	backdrop.ImageColor3 = Color3.fromRGB(120, 120, 130)
	backdrop.ZIndex = 40
	backdrop.Parent = v4
	local parent = frame(backdrop, "Shade", 41) -- inferred equivalent call
	parent.Size = UDim2.fromScale(1, 1)
	parent.BackgroundTransparency = 0
	parent.BackgroundColor3 = Color3.new(0, 0, 0)

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new(0.55, 0.2)
	uiGradient.Parent = parent

	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Scroller"
	scroller.Position = udim
	scroller.Size = udim2
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollingDirection = Enum.ScrollingDirection.Y
	scroller.ScrollBarThickness = 8
	scroller.ScrollBarImageColor3 = Color3.fromRGB(230, 236, 245)
	scroller.ScrollBarImageTransparency = 0.35
	scroller.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scroller.CanvasSize = UDim2.new()
	scroller.ZIndex = 420
	scroller.Parent = v4
	local frame2 = frame(v4, "CounterPill", 650) -- inferred equivalent call
	frame2.BackgroundTransparency = 0.25
	frame2.BackgroundColor3 = Color3.fromRGB(10, 13, 20)
	frame2.AnchorPoint = Vector2.new(0, 0.5)
	frame2.Position = UDim2.fromScale(0.03, 0.885)
	frame2.Size = UDim2.fromScale(0.2, 0.075)
	PoolMenuWidgets.Corner(frame2, 0.4)

	local label = PoolMenuWidgets.Label(frame2, "Counter", "", Menu.TextPrimary, 651)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.52)
	label.Size = UDim2.fromScale(0.86, 0.72)

	local button = PoolMenuWidgets.Button(root, "CueViewExit", PoolButtonSkin.Exit.Colour, 650)

	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.fromScale(0.5, 0.94)
	button.Size = UDim2.fromScale(0.16, 0.11)
	button.Visible = false
	local buttonText = PoolMenuWidgets.ButtonText(button, "EXIT", nil, 650)
	buttonText.Size = udim3
	maid:GiveTask(button)

	local v5 = {
		Menu = menu,
		Callbacks = options or {},
		Root = v4,
		Scroller = scroller,
		Counter = label,
		ExitButton = button,
		Detail = nil,
		DetailKey = nil,
		Catalogue = {},
		CatalogueDirty = true,
		Order = {},
		Owned = {},
		OwnedCount = 0,
		Equipped = "",
		Tiles = {},
		Free = {},
		Columns = 0,
		TileWidth = 0,
		TileHeight = 0,
		First = 1,
		Last = 0,
		VisibleFirst = 1,
		VisibleLast = 0,
		Mode = "Hidden",
		Dirty = true,
		RefreshQueued = false,
		GiftBadge = nil,
		PumpMaid = pumpMaid,
		Maid = maid
	}

	v5.Detail = buildDetail(v5, root)
	maid:GiveTask(v5.Detail.Root)

	local detail = v5.Detail

	maid:GiveTask(scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if v5.Mode == "Grid" then
			updateVisible(v5)
		end
	end))

	maid:GiveTask(scroller:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if v5.Mode == "Grid" and measure(v5) then
			for _, tile in v5.Tiles do
				tile.Stamp = nil
			end

			updateVisible(v5)
		end
	end))

	maid:GiveTask(detail.Dimmer.Activated:Connect(function()
		PoolCueGrid.CloseDetail(v5)
	end))

	maid:GiveTask(detail.Close.Activated:Connect(function()
		PoolCueGrid.CloseDetail(v5)
	end))

	maid:GiveTask(detail.View.Activated:Connect(function()
		local detailKey = v5.DetailKey

		if detailKey then
			PoolCueGrid.View(v5, detailKey)
		end
	end))

	maid:GiveTask(detail.Primary.Activated:Connect(function()
		local detailKey = v5.DetailKey
		local v6 = detailKey and v5.Catalogue[detailKey]

		if not (detailKey and v6 and detail.Primary.Active) then
			return
		end

		if
			PoolSkins.Owns(LocalPlayer.UserId, "cueSticks", detailKey)
			or detailKey == PoolSkins.GetEquippedName(LocalPlayer.UserId, "cueSticks")
		then
			if PoolSkins.GetEquippedName(LocalPlayer.UserId, "cueSticks") ~= detailKey then
				menu.EquipBindable:Fire("cueSticks", detailKey)
			end
		elseif PoolSkins.IsForSale(v6.Data) then
			menu.BuyBindable:Fire("cueSticks", detailKey)
		else
			Notifications.new("TextNotification", {
				message = string.format(
					"%s: %s",
					v6.Name,
					PoolSkins.GetObtainedFrom(v6.Data) or "Can't be bought in the shop."
				),
				colour = color5:Lerp(Color3.new(1, 1, 1), 0.45),
				length = 5
			})
		end
	end))

	maid:GiveTask(detail.Secondary.Activated:Connect(function()
		local detailKey = v5.DetailKey
		local v6 = detailKey and v5.Catalogue[detailKey]

		if not (detailKey and v6 and detail.Secondary.Active and detail.Secondary.Visible) then
			return
		end

		if detail.SecondaryMode == "Upgrade" then
			menu.UpgradeBindable:Fire(detailKey)
		elseif detail.SecondaryMode == "Robux" then
			local galaxy = v6.Galaxy

			if
				galaxy
				and not (PoolSkins.Owns(LocalPlayer.UserId, "cueSticks", detailKey) or PoolGalaxySet.IsSoldOut(galaxy.Id))
			then
				Sales.Prompt(tostring(LocalPlayer.UserId), galaxy.ProductId, Enum.InfoType.Product)
			end
		end
	end))

	local success, result = pcall(PoolGiftPicker.Badge, detail.Secondary, function()
		local detailKey = v5.DetailKey
		local v6 = detailKey and v5.Catalogue[detailKey]
		local galaxy = v6 and v6.Galaxy

		if detail.SecondaryMode == "Robux" and galaxy and not PoolGalaxySet.IsSoldOut(galaxy.Id) then
			return galaxy.ProductId
		end

		return nil
	end)

	if success and result then
		maid:GiveTask(result)
		v5.GiftBadge = result
		result.Visible = false
	end

	maid:GiveTask(button.Activated:Connect(function()
		PoolCueGrid.ExitView(v5)
	end))

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not root.Visible then
			return
		end

		local keyCode = input.KeyCode

		if v5.Mode == "View" then
			local cueSticks = menu.Carousels.cueSticks

			if keyCode == Enum.KeyCode.Left or keyCode == Enum.KeyCode.DPadLeft then
				if cueSticks then
					PoolCarousel.Step(cueSticks, -1)
				end
			elseif keyCode == Enum.KeyCode.Right or keyCode == Enum.KeyCode.DPadRight then
				if cueSticks then
					PoolCarousel.Step(cueSticks, 1)
				end
			elseif keyCode == Enum.KeyCode.ButtonB then
				PoolCueGrid.ExitView(v5)
			end
		elseif v5.Mode == "Grid" and keyCode == Enum.KeyCode.ButtonB and v5.DetailKey then
			PoolCueGrid.CloseDetail(v5)
		end
	end))

	local function watch(replica)
		for _, v6 in { "Inventory", "Equipped", "PoolCueUpgrades" } do
			local connection = replica:ListenToWrite(v6, function(value)
				if v6 == "Inventory" and typeof(value) == "string" and value ~= "cueSticks" then
					return
				end

				PoolCueGrid.Invalidate(v5)
			end)

			maid:GiveTask(function()
				connection:Disconnect()
			end)
		end

		for _, v6 in { "Currency1", "Currency2" } do
			local connection = replica:ListenToWrite(v6, function()
				refreshDetail(v5)
			end)

			maid:GiveTask(function()
				connection:Disconnect()
			end)
		end
	end

	local replica = PoolPlayerData.GetReplica(LocalPlayer.UserId)

	if replica then
		watch(replica)
	else
		task.spawn(function()
			for _ = 1, 120 do
				task.wait(0.5)

				local replica2 = PoolPlayerData.GetReplica(LocalPlayer.UserId)

				if replica2 then
					watch(replica2)
					PoolCueGrid.Invalidate(v5)
					break
				end
			end
		end)
	end

	local cueSticks = ReplicatedStorage.Assets.Skins:FindFirstChild("CueSticks")

	if cueSticks then
		local function dirty()
			v5.CatalogueDirty = true
			PoolCueGrid.Invalidate(v5)
		end

		maid:GiveTask(cueSticks.ChildAdded:Connect(dirty))
		maid:GiveTask(cueSticks.ChildRemoved:Connect(dirty))
	end

	PoolCueGrid.Refresh(v5)

	return v5
end

function PoolCueGrid:Destroy()
	self.Maid:DoCleaning()
	self.Tiles = {}
	self.Free = {}
end

return PoolCueGrid