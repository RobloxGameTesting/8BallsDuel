local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolCarousel = require(Pool.PoolCarousel)
local PoolConstants = require(Pool.PoolConstants)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)
local PoolPriceTag = require(script.Parent.PoolPriceTag)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolSkins = require(Pool.PoolSkins)
local PoolVisuals = require(Pool.PoolVisuals)
local PoolGalaxySet = require(Pool.PoolGalaxySet)
local PoolCueUpgradeService = require(Pool.PoolCueUpgradeService)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local PoolGiftPicker = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolGiftPicker)

local PoolInspector = {}

local Menu = PoolConstants.Menu
local LocalPlayer = Players.LocalPlayer

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local color = Color3.fromRGB(88, 196, 84)
local color2 = Color3.fromRGB(62, 138, 232)
local color3 = Color3.fromRGB(242, 198, 52)

local color4 = Color3.fromRGB(30, 33, 42)

local color5 = Color3.fromRGB(138, 98, 226)

local ButtonColour = PoolPriceTag.ButtonColour

local Gold = Menu.Gold

local v = { "Sunburst", "Background", "Equipped", "Title", "Empty", "Grid" }

local function fieldsOfView() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera

	return
		0.7853981633974483,
		math.atan((not (currentCamera and currentCamera.ViewportSize.Y > 0) and 1 or math.max(currentCamera.ViewportSize.X, 1) / currentCamera.ViewportSize.Y) * 0.41421356237309503) * 2
end

local function sanitise(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("BaseScript") then
			descendant:Destroy()
		end
	end
end

local function spinAxis(vector3: Vector3)
	local v2 = math.max(vector3.X, vector3.Y, vector3.Z)
	local v3 = math.min(vector3.X, vector3.Y, vector3.Z)
	local v4 = vector3.X + vector3.Y + vector3.Z - v2 - v3

	if v4 <= 0 or v2 < v4 * 2.5 then
		return Vector3.new(0, 1, 0)
	end

	if v2 == vector3.X then
		return Vector3.new(1, 0, 0)
	end

	if v2 == vector3.Z then
		return Vector3.new(0, 0, 1)
	end

	return Vector3.new(0, 1, 0)
end

local function place(data, key: string)
	local v2 = { Key = key, Position = Vector3.new(0, 12000, 0) }

	local item = PoolSkins.GetItem(data.Category, key)
	local v3

	if item then
		v3 = PoolMenuWidgets.FindSkinModel(item)
	end

	if v3 then
		local clone = v3:Clone()
		sanitise(clone)
		clone.Name = key
		clone.Parent = data.Folder
		data.SceneMaid:GiveTask(clone)

		local _, v4 = clone:GetBoundingBox()
		local v5 = math.max(v4.X, v4.Y, v4.Z)

		if v5 > 0 then
			clone:ScaleTo(clone:GetScale() * 10 / v5)
		end

		local boundingBox, v6 = clone:GetBoundingBox()
		clone:PivotTo(clone:GetPivot() + (v2.Position - boundingBox.Position))

		v2.Model = clone
		v2.BasePivot = clone:GetPivot()

		local axis = spinAxis(v6)
		local v7 = v6 / 2

		local function sweep(p: number, p2: number) -- 6 equivalent calls inferred from this helper
			return (math.sqrt(p * p + p2 * p2))
		end

		if axis == Vector3.new(1, 0, 0) then
			v2.HalfWidth = v7.X
			v2.HalfHeight = sweep(v7.Y, v7.Z) -- inferred equivalent call
			v2.HalfDepth = sweep(v7.Y, v7.Z) -- inferred equivalent call
		elseif axis == Vector3.new(0, 0, 1) then
			v2.HalfWidth = sweep(v7.X, v7.Y) -- inferred equivalent call
			v2.HalfHeight = sweep(v7.X, v7.Y) -- inferred equivalent call
			v2.HalfDepth = v7.Z
		else
			v2.HalfWidth = sweep(v7.X, v7.Z) -- inferred equivalent call
			v2.HalfHeight = v7.Y
			v2.HalfDepth = sweep(v7.X, v7.Z) -- inferred equivalent call
		end

		v2.Axis = axis

		return v2
	end

	if data.Category == "poolEffects" then
		v2.Effect = key
	end

	return v2
end

local v2 = { Elevation = 0.5235987755982988, Bearing = 3.7524578917878086 }

local v3 = {
	cueSticks = { Elevation = 1.3962634015954636, Bearing = 3.3161255787892263 }
}

local v4 = { cueSticks = true }

local function cameraAngle(p) -- 2 equivalent calls inferred from this helper
	return v3[p.Category] or v2
end

local function framing(state)
	local v5, v6 = fieldsOfView() -- inferred equivalent call
	local elevation = cameraAngle(state).Elevation -- inferred equivalent call
	local maxHalfWidth = 0
	local maxHalfHeight = 0
	local maxHalfDepth = 0

	if v4[state.Category] then
		maxHalfWidth = 5
	else
		for _, slot in state.Slots do
			maxHalfWidth = math.max(maxHalfWidth, slot.HalfWidth or 0)
			maxHalfHeight = math.max(maxHalfHeight, slot.HalfHeight or 0)
			maxHalfDepth = math.max(maxHalfDepth, slot.HalfDepth or 0)
		end
	end

	if maxHalfWidth <= 0 and maxHalfHeight <= 0 then
		maxHalfHeight = 2.5
		maxHalfDepth = 2.5
		maxHalfWidth = 2.5
	end

	local v7 = math.max(
		(maxHalfHeight * math.cos(elevation) + maxHalfDepth * math.sin(elevation)) / math.tan(v5 / 2),
		maxHalfWidth / math.tan(v6 / 2)
	) * 1.45

	return v7, v7 * 2 * math.tan(v6 / 2)
end

function PoolInspector:Rebuild()
	self.SceneMaid:DoCleaning()
	self.Slots = {}
	self.Folder = nil
	self.Lamp = nil

	if self.AnchorTween then
		self.AnchorTween:Cancel()
		self.AnchorTween = nil
	end

	self.AnchorTarget = nil

	if not self.Open then
		return
	end

	local poolInspectorStage = Instance.new("Folder")
	poolInspectorStage.Name = "PoolInspectorStage"
	poolInspectorStage.Parent = workspace

	self.Folder = poolInspectorStage
	self.SceneMaid:GiveTask(poolInspectorStage)

	local key = Instance.new("Part")
	key.Name = "Key"
	key.Size = Vector3.new(1, 1, 1)
	key.Transparency = 1
	key.Anchored = true
	key.CanCollide = false
	key.CanQuery = false
	key.CanTouch = false
	key.CFrame = CFrame.new(Vector3.new(0, 12012, -14))
	key.Parent = poolInspectorStage

	self.Lamp = key

	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 3
	pointLight.Range = 120
	pointLight.Color = Color3.fromRGB(255, 244, 226)
	pointLight.Parent = key

	local carousel = self.Menu.Carousels[self.Category]

	if carousel then
		local key2 = PoolCarousel.GetKey(carousel)

		for k, key3 in carousel.Keys do
			if key3 == key2 then
				table.insert(self.Slots, place(self, key3))
				self.LoadedIndex = k
			else
				table.insert(self.Slots, { Key = key3, Position = Vector3.new(0, 12000, 0) })
			end
		end
	end

	local distance, v5 = framing(self)

	self.Distance = distance
	self.Spacing = v5 * 0.86

	for k, slot in self.Slots do
		local position = Vector3.new(0, 12000, 0) + Vector3.new((k - 1) * self.Spacing, 0, 0)
		local model = slot.Model

		slot.Position = position

		if not model then
			continue
		end

		model:PivotTo(model:GetPivot() + (position - Vector3.new(0, 12000, 0)))
		slot.BasePivot = model:GetPivot()
	end

	PoolInspector.Refresh(self)
end

local function setPriceIcon(data, priceCurrency: string?) -- 5 equivalent calls inferred from this helper
	local currencyIcon = data.CurrencyIcon

	if not currencyIcon then
		return
	end

	if not priceCurrency then
		currencyIcon.Visible = false

		return
	end

	currencyIcon.Image = data.CurrencyImages[priceCurrency] or data.CurrencyImages.Coins
	currencyIcon.Visible = true
end

local function layoutPrice(data)
	local equipLabel = data.EquipLabel
	local currencyIcon = data.CurrencyIcon
	local equipButton = data.EquipButton

	if not (equipLabel and currencyIcon and equipButton) then
		return
	end

	if currencyIcon.Visible then
		local x = equipButton.AbsoluteSize.X
		local x2 = currencyIcon.AbsoluteSize.X

		if x <= 0 or x2 <= 0 then
			return
		end

		local v5 = x2 * 0.3
		local v6 = x2 + v5
		local labelSize = data.LabelSize
		local v7 = math.max(labelSize.X.Scale * x + labelSize.X.Offset - v6, 0)

		local udim = UDim2.new(0, v7, labelSize.Y.Scale, labelSize.Y.Offset)

		if equipLabel.Size ~= udim then
			equipLabel.Size = udim
		end

		local v8 = math.min(equipLabel.TextBounds.X, v7)
		local v9 = v8 + v6
		local labelPosition = data.LabelPosition

		local udim2 = UDim2.new(
			labelPosition.X.Scale,
			labelPosition.X.Offset - v6 / 2,
			labelPosition.Y.Scale,
			labelPosition.Y.Offset
		)

		if equipLabel.Position ~= udim2 then
			equipLabel.Position = udim2
		end

		currencyIcon.Position = UDim2.new(
			labelPosition.X.Scale,
			labelPosition.X.Offset - v9 / 2 + v8 + v5,
			labelPosition.Y.Scale,
			labelPosition.Y.Offset
		)
	else
		if equipLabel.Size ~= data.LabelSize then
			equipLabel.Size = data.LabelSize
		end

		if equipLabel.Position ~= data.LabelPosition then
			equipLabel.Position = data.LabelPosition
		end
	end
end

local function galaxyTierFor(p: string)
	for _, tier in PoolGalaxySet.Tiers do
		if tier.Item == p then
			return tier
		end
	end

	return nil
end

local priceInRobuxesById = {}
local v5 = {}

local function galaxyPrice(data, p) -- 1 equivalent call inferred from this helper
	local v6 = priceInRobuxesById[p.Id]

	if v6 or v5[p.Id] then
		return v6
	end

	v5[p.Id] = true

	task.spawn(function()
		for _ = 1, 10 do
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(p.ProductId, Enum.InfoType.Product)
			end)

			if success and result and result.PriceInRobux then
				priceInRobuxesById[p.Id] = result.PriceInRobux

				if data.Open then
					PoolInspector.Refresh(data)
				end

				return
			end

			task.wait(1)
		end

		v5[p.Id] = nil
	end)

	return nil
end

local function layoutKeys(data, p)
	local equipButton = data.EquipButton
	local equipPosition = data.EquipPosition
	local cueViewExit

	if data.ViewMode then
		cueViewExit = data.Root:FindFirstChild("CueViewExit")
	end

	local v6 = {}

	if cueViewExit and cueViewExit:IsA("GuiObject") then
		table.insert(v6, cueViewExit)
	end

	table.insert(v6, equipButton)

	if p then
		table.insert(v6, p)
	end

	if #v6 == 1 then
		if equipButton.Position ~= equipPosition then
			equipButton.Position = equipPosition
		end
	else
		local v7 = (#v6 - 1) * 0.012

		for _, v8 in v6 do
			v7 += v8.Size.X.Scale
		end

		local v8 = equipPosition.X.Scale - v7 / 2

		for _, v9 in v6 do
			local scale = v9.Size.X.Scale
			local udim = UDim2.new(
				v8 + scale * v9.AnchorPoint.X,
				equipPosition.X.Offset,
				equipPosition.Y.Scale,
				equipPosition.Y.Offset
			)

			if v9.Position ~= udim then
				v9.Position = udim
			end

			v8 += scale + 0.012
		end
	end
end

local function showBalanceFor(p, visible: boolean) -- 3 equivalent calls inferred from this helper
	if p.CoinsPill then
		p.CoinsPill.Visible = not visible
	end

	if p.GemsPill then
		p.GemsPill.Visible = visible
	end
end

function PoolInspector.Refresh(data)
	local carousel = data.Menu.Carousels[data.Category]
	local v6

	if carousel then
		v6 = PoolCarousel.GetKey(carousel)
	end

	local v7

	if v6 then
		v7 = PoolSkins.GetItem(data.Category, v6)
	end

	if v7 then
		local v8 = carousel and #carousel.Keys or 0
		local v9 = not carousel and 0 or carousel.Index

		local nameLabel = data.NameLabel
		local text

		if v8 > 1 then
			text = string.format("%s  %d/%d", tostring(v7.name), v9, v8)
		else
			text = tostring(v7.name)
		end

		nameLabel.Text = text

		local category = PoolSkins.GetCategory(data.Category)

		data.TypeLabel.Text = string.upper((tostring(v7.itemType or category and category.Label or "")))
		local v10

		if data.Category == "cueSticks" and PoolSkins.Owns(LocalPlayer.UserId, data.Category, v6) then
			v10 = PoolCueUpgradeService.GetOffer(LocalPlayer.UserId, v6)
		end

		if data.Category == "cueSticks" then
			data.StatPanel.Visible = true

			local writeCueStats = PoolMenuWidgets.WriteCueStats
			local cueStats = PoolMenuWidgets.ReadCueStats(data.StatPanel)
			local cue = v7.cue

			local cueLevel = PoolSkins.GetCueLevel(LocalPlayer.UserId, v6)
			local v11

			if v10 and v10.Cost then
				v11 = v10.Level + 1
			end

			writeCueStats(cueStats, cue, false, cueLevel, v11)
		else
			data.StatPanel.Visible = false
		end

		local owns = PoolSkins.Owns(LocalPlayer.UserId, data.Category, v6)
		local v11 = owns and PoolSkins.GetEquippedName(LocalPlayer.UserId, data.Category) == v6
		local price = PoolSkins.GetPrice(v7)
		local priceCurrency = PoolSkins.GetPriceCurrency(v7)

		local v12 = not owns and PoolSkins.IsForSale(v7)
		local v13 = not (owns or v12)
		showBalanceFor(data, PoolSkins.IsForSale(v7) and priceCurrency == "Gems") -- inferred equivalent call
		local v14

		if priceCurrency == "Gems" then
			v14 = PoolPlayerData.GetGems(LocalPlayer.UserId)
		else
			v14 = PoolPlayerData.GetCoins(LocalPlayer.UserId)
		end

		local v15 = v12 and price <= v14

		data.EquipButton.Visible = true

		data.LockIcon.Visible = not (owns or v15)
		local v16 = owns and not v11 or v15 or v13
		data.EquipButton.Active = v16
		data.EquipButton.AutoButtonColor = v16

		if v11 then
			PoolButtonSkin.SetColour(data.EquipButton, color)
			data.EquipLabel.TextColor3 = Menu.TextPrimary
			data.EquipLabel.Text = "EQUIPPED"
			setPriceIcon(data) -- inferred equivalent call
		elseif owns then
			PoolButtonSkin.SetColour(data.EquipButton, color2)
			data.EquipLabel.TextColor3 = Menu.TextPrimary
			data.EquipLabel.Text = "EQUIP"
			setPriceIcon(data) -- inferred equivalent call
		elseif v15 then
			PoolButtonSkin.SetColour(data.EquipButton, color3)

			data.EquipLabel.TextColor3 = Menu.TextPrimary
			data.EquipLabel.Text = "BUY · " .. PoolSkins.FormatAmount(price)
			setPriceIcon(data, priceCurrency) -- inferred equivalent call
		elseif v13 then
			PoolButtonSkin.SetColour(data.EquipButton, color5)
			data.EquipLabel.TextColor3 = Menu.TextPrimary
			data.EquipLabel.Text = "INFO"
			setPriceIcon(data) -- inferred equivalent call
		else
			PoolButtonSkin.SetColour(data.EquipButton, color4)
			data.EquipLabel.TextColor3 = Menu.TextMuted

			data.EquipLabel.Text = PoolSkins.FormatAmount(price)
			setPriceIcon(data, priceCurrency) -- inferred equivalent call
		end

		local v17

		if data.Category == PoolGalaxySet.Category then
			for _, tier in PoolGalaxySet.Tiers do
				if tier.Item == v6 then
					v17 = tier
					break
				end
			end
		end

		local visible

		if v17 == nil then
			visible = false
		else
			visible = not (owns or PoolGalaxySet.IsSoldOut(v17.Id))
		end

		data.GalaxyBuy.Visible = visible

		if visible and v17 then
			local v18 = galaxyPrice(data, v17) -- inferred equivalent call
			PoolPriceTag.SetText(data.GalaxyBuyLabel, not v18 and "BUY" or "R$ " .. NumberHelper:Separate(v18))
		end

		local visible2

		if v10 == nil then
			visible2 = false
		else
			visible2 = v10.MaxLevel > 0
		end

		data.UpgradeButton.Visible = visible2

		if visible2 and v10 then
			local v18 = v10.Cost ~= nil

			data.UpgradeButton.Active = v18
			data.UpgradeButton.AutoButtonColor = v18
			local upgradeLabel = data.UpgradeLabel
			local text2

			if v10.Cost then
				text2 = string.format("UPGRADE · $%s", PoolSkins.FormatAmount(v10.Cost))
			else
				text2 = string.format("MAX · LV%d", v10.Level)
			end

			upgradeLabel.Text = text2
		end

		local v18

		if visible then
			v18 = data.GalaxyBuy
		elseif visible2 then
			v18 = data.UpgradeButton
		end

		layoutKeys(data, v18)

		layoutPrice(data)
	else
		data.NameLabel.Text = "—"
		data.TypeLabel.Text = ""
		data.StatPanel.Visible = false
		data.EquipButton.Visible = false
		data.LockIcon.Visible = false
		data.GalaxyBuy.Visible = false
		data.UpgradeButton.Visible = false
		showBalanceFor(data, false) -- inferred equivalent call
	end
end

local loadFocused

local function update(state, _: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local carousel = state.Menu.Carousels[state.Category]
	local v6 = not carousel and 1 or carousel.Focus

	state.Distance = framing(state)

	local anchorTarget = Vector3.new(0, 12000, 0) + Vector3.new((v6 - 1) * state.Spacing, 0, 0)
	local anchor = state.Anchor

	if anchor then
		local v7

		if carousel == nil then
			v7 = false
		else
			v7 = carousel.Drag ~= nil
		end

		if v7 or state.AnchorTarget == nil then
			if state.AnchorTween then
				state.AnchorTween:Cancel()
				state.AnchorTween = nil
			end

			anchor.CFrame = CFrame.new(anchorTarget)
			state.AnchorTarget = anchorTarget
		elseif (state.AnchorTarget - anchorTarget).Magnitude > 0.001 then
			if state.AnchorTween then
				state.AnchorTween:Cancel()
			end

			state.AnchorTarget = anchorTarget
			state.AnchorTween = TweenService:Create(anchor, tweenInfo, {
				CFrame = CFrame.new(anchorTarget)
			})
			state.AnchorTween:Play()
		end
	end

	local lamp = state.Lamp

	if lamp then
		lamp.CFrame = CFrame.new(currentCamera.CFrame.Position + Vector3.new(0, state.Distance * 0.3, 0))
	end

	local v7 = math.clamp(math.round(v6), 1, (math.max(#state.Slots, 1)))

	if state.LoadedIndex ~= v7 then
		loadFocused(state, v7)
	end

	local slot = state.Slots[v7]

	if not slot then
		return
	end

	if slot.Effect and os.clock() >= state.NextEffect then
		state.NextEffect = os.clock() + 1.1

		local soundedEffect = string.format("%s#%d", tostring(slot.Effect), v7)
		local v8 = state.SoundedEffect == soundedEffect

		state.SoundedEffect = soundedEffect

		pcall(PoolVisuals.PlayPot, slot.Position, slot.Effect, v8)
	end
end

loadFocused = function(state, loadedIndex: number)
	if state.LoadedIndex == loadedIndex or not state.Folder then
		return
	end

	local slot = state.Slots[state.LoadedIndex or 0]

	if slot then
		if slot.Model then
			slot.Model:Destroy()
		end

		state.Slots[state.LoadedIndex] = { Key = slot.Key, Position = slot.Position }
	end

	local slot2 = state.Slots[loadedIndex]

	if not slot2 then
		state.LoadedIndex = nil

		return
	end

	local v6 = place(state, slot2.Key)
	local position = slot2.Position

	if v6.Model then
		v6.Model:PivotTo(v6.Model:GetPivot() + (position - Vector3.new(0, 12000, 0)))
		v6.BasePivot = v6.Model:GetPivot()
	end

	v6.Position = position
	state.Slots[loadedIndex] = v6
	state.LoadedIndex = loadedIndex
end

function PoolInspector:SetCategory(category: string)
	if self.Category == category then
		return
	end

	self.Category = category
	self.SoundedEffect = nil

	if self.Open then
		PoolInspector.Rebuild(self)

		PoolInspector.FrameCamera(self)
	end
end

function PoolInspector.FrameCamera(data)
	local currentCamera = workspace.CurrentCamera
	local anchor = data.Anchor

	if not (currentCamera and anchor and data.Open) then
		return
	end

	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.CameraSubject = anchor

	local distance = data.Distance

	LocalPlayer.CameraMinZoomDistance = distance
	LocalPlayer.CameraMaxZoomDistance = distance

	task.defer(function()
		if not data.Open then
			return
		end

		LocalPlayer.CameraMinZoomDistance = distance * 0.45
		LocalPlayer.CameraMaxZoomDistance = distance * 2.2
	end)
end

function PoolInspector.AimCamera(p)
	local currentCamera = workspace.CurrentCamera
	local anchor = p.Anchor

	if not (currentCamera and anchor) then
		return
	end

	local position = anchor.Position
	local v6 = cameraAngle(p) -- inferred equivalent call
	local v7 = math.cos(v6.Elevation)
	local vector3 = Vector3.new(math.sin(v6.Bearing) * v7, math.sin(v6.Elevation), -math.cos(v6.Bearing) * v7)

	currentCamera.CFrame = CFrame.lookAt(position + vector3 * math.max(p.Distance, 1), position)
end

function PoolInspector:SetOpen(flag: boolean)
	if self.Open == flag then
		return
	end

	self.Open = flag

	local currentCamera = workspace.CurrentCamera

	for _, childName in v do
		local guiObject = self.Root:FindFirstChild(childName)

		if not (guiObject and guiObject:IsA("GuiObject")) then
			continue
		end

		if flag then
			if guiObject:GetAttribute("InspectorShown") == nil then
				guiObject:SetAttribute("InspectorShown", guiObject.Visible)
			end

			guiObject.Visible = false
		else
			local inspectorShown = guiObject:GetAttribute("InspectorShown")

			guiObject.Visible = typeof(inspectorShown) ~= "boolean" or inspectorShown
			guiObject:SetAttribute("InspectorShown", nil)
		end
	end

	self.Info.Visible = flag
	self.EquipButton.Visible = flag
	self.PrevButton.Visible = flag
	self.NextButton.Visible = flag

	if not flag then
		self.LockIcon.Visible = false
		self.GalaxyBuy.Visible = false
		self.UpgradeButton.Visible = false
		showBalanceFor(self, false) -- inferred equivalent call
		self.StatPanel.Visible = false
	end

	if flag then
		self.NextEffect = 0
		self.SoundedEffect = nil

		if currentCamera then
			self.RestoreCameraType = currentCamera.CameraType
			self.RestoreFieldOfView = currentCamera.FieldOfView
			self.RestoreFieldOfViewMode = currentCamera.FieldOfViewMode
			self.RestoreSubject = currentCamera.CameraSubject
			self.RestoreCFrame = currentCamera.CFrame
			self.RestoreFocus = currentCamera.Focus
			self.RestoreMinZoom = LocalPlayer.CameraMinZoomDistance
			self.RestoreMaxZoom = LocalPlayer.CameraMaxZoomDistance

			currentCamera.FieldOfView = 45
			currentCamera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
		end

		local poolInspectorAnchor = Instance.new("Part")
		poolInspectorAnchor.Name = "PoolInspectorAnchor"
		poolInspectorAnchor.Size = Vector3.new(1, 1, 1)
		poolInspectorAnchor.Transparency = 1
		poolInspectorAnchor.Anchored = true
		poolInspectorAnchor.CanCollide = false
		poolInspectorAnchor.CanQuery = false
		poolInspectorAnchor.CanTouch = false
		poolInspectorAnchor.CastShadow = false
		poolInspectorAnchor.CFrame = CFrame.new(Vector3.new(0, 12000, 0))
		poolInspectorAnchor.Parent = workspace

		self.Anchor = poolInspectorAnchor
		self.LoopMaid:GiveTask(poolInspectorAnchor)

		PoolInspector.Rebuild(self)
		update(self, 0)

		PoolInspector.FrameCamera(self)

		PoolInspector.AimCamera(self)

		task.spawn(function()
			RunService.RenderStepped:Wait()

			if not self.Open then
				return
			end

			PoolInspector.AimCamera(self)
			RunService.RenderStepped:Wait()

			if not self.Open then
				return
			end

			PoolInspector.AimCamera(self)
		end)

		self.LoopMaid:GiveTask(RunService.RenderStepped:Connect(function(dt)
			update(self, dt)
		end))
	else
		self.LoopMaid:DoCleaning()
		self.SceneMaid:DoCleaning()
		self.Slots = {}
		self.Folder = nil
		self.Anchor = nil
		self.AnchorTarget = nil

		if self.AnchorTween then
			self.AnchorTween:Cancel()
			self.AnchorTween = nil
		end

		LocalPlayer.CameraMinZoomDistance = self.RestoreMinZoom or 0.5
		LocalPlayer.CameraMaxZoomDistance = self.RestoreMaxZoom or 128

		if currentCamera then
			currentCamera.FieldOfView = self.RestoreFieldOfView or 70
			currentCamera.FieldOfViewMode = self.RestoreFieldOfViewMode or Enum.FieldOfViewMode.Vertical
			currentCamera.CameraType = self.RestoreCameraType or Enum.CameraType.Custom

			if self.RestoreCFrame then
				currentCamera.CFrame = self.RestoreCFrame
			end

			if self.RestoreFocus then
				currentCamera.Focus = self.RestoreFocus
			end

			local restoreSubject = self.RestoreSubject

			if restoreSubject and restoreSubject.Parent then
				currentCamera.CameraSubject = restoreSubject
			else
				local character = LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					currentCamera.CameraSubject = humanoid
				else
					pcall(function()
						currentCamera.CameraSubject = nil
					end)
				end
			end
		end

		local restoreCameraType = self.RestoreCameraType
		local restoreCFrame = self.RestoreCFrame
		local restoreFocus = self.RestoreFocus

		if
			restoreCFrame
			and (restoreCameraType == Enum.CameraType.Fixed or restoreCameraType == Enum.CameraType.Scriptable)
		then
			local count = 0

			pcall(function()
				RunService:UnbindFromRenderStep("PoolInspectorRestore")
			end)

			RunService:BindToRenderStep("PoolInspectorRestore", Enum.RenderPriority.Camera.Value + 1, function()
				count += 1

				local currentCamera2 = workspace.CurrentCamera

				if self.Open or count > 2 or not currentCamera2 then
					RunService:UnbindFromRenderStep("PoolInspectorRestore")
				elseif currentCamera2.CameraType == restoreCameraType then
					currentCamera2.CFrame = restoreCFrame

					if restoreFocus then
						currentCamera2.Focus = restoreFocus
					end
				end
			end)
		end
	end
end

local function expect(instance, childName: string) -- 10 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(childName)

	if not child then
		error("PoolInspector: missing UI element '" .. childName .. "' under " .. instance:GetFullName())
	end

	return child
end

local function build(state, root)
	local info = expect(root, "InspectorInfo") -- inferred equivalent call
	local v6 = expect(root, "InspectorEquip") -- inferred equivalent call
	local coins = root:FindFirstChild("Coins")
	local gems = root:FindFirstChild("Gems")

	if not (coins and coins:IsA("GuiObject")) then
		coins = nil
	end

	state.CoinsPill = coins

	if not (gems and gems:IsA("GuiObject")) then
		gems = nil
	end

	state.GemsPill = gems

	state.Info = info
	state.NameLabel = expect(info, "ItemName") -- inferred equivalent call
	state.TypeLabel = expect(info, "ItemType") -- inferred equivalent call
	state.EquipButton = v6
	state.EquipLabel = expect(v6, "Top") -- inferred equivalent call
	state.LockIcon = expect(v6, "Lock") -- inferred equivalent call
	state.LabelSize = state.EquipLabel.Size
	state.LabelPosition = state.EquipLabel.Position

	local homeMenu = root.Parent and root.Parent:FindFirstChild("HomeMenu")

	local function iconFrom(childName: string, p: string) -- 2 equivalent calls inferred from this helper
		local child = homeMenu and homeMenu:FindFirstChild(childName)
		local coin = child and child:FindFirstChild("Coin")

		if coin and coin:IsA("ImageLabel") and coin.Image ~= "" then
			return coin.Image
		end

		return p
	end

	state.CurrencyImages = {
		Coins = iconFrom("Coins", "rbxassetid://140250576355900"), -- inferred equivalent call
		Gems = iconFrom("Gems", "rbxassetid://91068843812037") -- inferred equivalent call
	}

	local currencyIcon = v6:FindFirstChild("CurrencyIcon")

	if not (currencyIcon and currencyIcon:IsA("ImageLabel")) then
		currencyIcon = Instance.new("ImageLabel")
		currencyIcon.Name = "CurrencyIcon"
		currencyIcon.BackgroundTransparency = 1
		currencyIcon.ScaleType = Enum.ScaleType.Fit
		currencyIcon.AnchorPoint = Vector2.new(0, 0.5)
		currencyIcon.Size = UDim2.fromScale(1, 0.56)
		currencyIcon.ZIndex = state.EquipLabel.ZIndex

		local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
		uiAspectRatioConstraint.Parent = currencyIcon

		currencyIcon.Parent = v6
	end

	state.CurrencyIcon = currencyIcon
	state.CurrencyIcon.Visible = false
	state.PrevButton = expect(root, "InspectorPrev") -- inferred equivalent call
	state.NextButton = expect(root, "InspectorNext") -- inferred equivalent call

	local cueStatPanel = PoolMenuWidgets.CueStatPanel(root, v6.ZIndex)
	cueStatPanel.AnchorPoint = Vector2.new(0.5, 1)
	cueStatPanel.Position = UDim2.fromScale(0.5, 0.815)
	cueStatPanel.Size = UDim2.fromScale(0.46, 0.115)

	state.StatPanel = cueStatPanel

	local inspectorGalaxyBuy = v6:Clone()
	inspectorGalaxyBuy.Name = "InspectorGalaxyBuy"

	for _, childName in { "Lock", "CurrencyIcon" } do
		local child = inspectorGalaxyBuy:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	inspectorGalaxyBuy.AnchorPoint = Vector2.new(0.5, v6.AnchorPoint.Y)
	inspectorGalaxyBuy.Size = UDim2.fromScale(0.2, v6.Size.Y.Scale)
	PoolButtonSkin.SetColour(inspectorGalaxyBuy, ButtonColour)
	inspectorGalaxyBuy.AutoButtonColor = true
	inspectorGalaxyBuy.Active = true
	inspectorGalaxyBuy.Visible = false
	inspectorGalaxyBuy.Parent = root

	state.GalaxyBuy = inspectorGalaxyBuy
	state.EquipPosition = v6.Position
	state.GalaxyBuyLabel = expect(inspectorGalaxyBuy, "Top") -- inferred equivalent call
	PoolPriceTag.Attach(state.GalaxyBuyLabel)
	PoolPriceTag.SetText(state.GalaxyBuyLabel, "BUY")
	state.GalaxyBuyLabel.TextColor3 = Menu.TextPrimary

	local inspectorUpgrade = v6:Clone()
	inspectorUpgrade.Name = "InspectorUpgrade"

	for _, childName in { "Lock", "CurrencyIcon" } do
		local child = inspectorUpgrade:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	inspectorUpgrade.AnchorPoint = Vector2.new(0.5, v6.AnchorPoint.Y)
	inspectorUpgrade.Size = UDim2.fromScale(0.24, v6.Size.Y.Scale)
	PoolButtonSkin.SetColour(inspectorUpgrade, Gold)
	inspectorUpgrade.AutoButtonColor = true
	inspectorUpgrade.Active = true
	inspectorUpgrade.Visible = false
	inspectorUpgrade.Parent = root

	state.UpgradeButton = inspectorUpgrade
	state.UpgradeLabel = expect(inspectorUpgrade, "Top") -- inferred equivalent call
	state.UpgradeLabel.Text = "UPGRADE"
	state.UpgradeLabel.TextColor3 = Menu.TextPrimary

	info.Visible = false
	cueStatPanel.Visible = false
	v6.Visible = false
	state.LockIcon.Visible = false
	state.PrevButton.Visible = false
	state.NextButton.Visible = false
end

function PoolInspector.new(menu)
	local v6 = {
		Menu = menu,
		Root = menu.Root,
		Folder = nil,
		Slots = {},
		Category = menu.Category,
		Open = false,
		ViewMode = false,
		Spacing = 10,
		Distance = 20,
		Lamp = nil,
		AnchorTarget = nil,
		AnchorTween = nil,
		Anchor = nil,
		Drag = nil,
		Info = nil,
		NameLabel = nil,
		TypeLabel = nil,
		StatPanel = nil,
		EquipButton = nil,
		EquipLabel = nil,
		GalaxyBuy = nil,
		GalaxyBuyLabel = nil,
		UpgradeButton = nil,
		UpgradeLabel = nil,
		CoinsPill = nil,
		GemsPill = nil,
		EquipPosition = UDim2.new(),
		CurrencyIcon = nil,
		CurrencyImages = {},
		LabelSize = UDim2.new(),
		LabelPosition = UDim2.new(),
		LockIcon = nil,
		PrevButton = nil,
		NextButton = nil,
		RestoreCameraType = nil,
		RestoreFieldOfView = nil,
		RestoreFieldOfViewMode = nil,
		RestoreSubject = nil,
		RestoreCFrame = nil,
		RestoreFocus = nil,
		RestoreMinZoom = nil,
		RestoreMaxZoom = nil,
		NextEffect = 0,
		SoundedEffect = nil,
		SceneMaid = Maid.new(),
		LoopMaid = Maid.new(),
		Maid = Maid.new()
	}

	v6.Maid:GiveTask(v6.SceneMaid)
	v6.Maid:GiveTask(v6.LoopMaid)

	build(v6, v6.Root)

	local function relayout()
		layoutPrice(v6)
	end

	v6.Maid:GiveTask(v6.EquipLabel:GetPropertyChangedSignal("TextBounds"):Connect(relayout))
	v6.Maid:GiveTask(v6.EquipButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout))
	v6.Maid:GiveTask(v6.CurrencyIcon:GetPropertyChangedSignal("Visible"):Connect(relayout))

	v6.Maid:GiveTask(v6.EquipButton.Activated:Connect(function()
		local carousel = v6.Menu.Carousels[v6.Category]
		local v7

		if carousel then
			v7 = PoolCarousel.GetKey(carousel)
		end

		if not (v7 and v6.EquipButton.Active) then
			return
		end

		if PoolSkins.Owns(LocalPlayer.UserId, v6.Category, v7) then
			if PoolSkins.GetEquippedName(LocalPlayer.UserId, v6.Category) == v7 then
				return
			end

			v6.Menu.EquipBindable:Fire(v6.Category, v7)
		else
			local item = PoolSkins.GetItem(v6.Category, v7)

			if PoolSkins.IsForSale(item) then
				v6.Menu.BuyBindable:Fire(v6.Category, v7)
				return
			end

			if item and item.name then
				v7 = tostring(item.name)
			end

			Notifications.new("TextNotification", {
				message = string.format("%s: %s", v7, PoolSkins.GetObtainedFrom(item) or "Can't be bought in the shop."),
				colour = color5:Lerp(Color3.new(1, 1, 1), 0.45),
				length = 5
			})
		end
	end))

	v6.Maid:GiveTask(v6.GalaxyBuy.Activated:Connect(function()
		local carousel = v6.Menu.Carousels[v6.Category]
		local v7

		if carousel then
			v7 = PoolCarousel.GetKey(carousel)
		end

		local v8

		if v7 and v6.Category == PoolGalaxySet.Category then
			for _, tier in PoolGalaxySet.Tiers do
				if tier.Item == v7 then
					v8 = tier
					break
				end
			end
		end

		if
			not (v8 and v6.GalaxyBuy.Visible)
			or (PoolSkins.Owns(LocalPlayer.UserId, PoolGalaxySet.Category, v8.Item) or PoolGalaxySet.IsSoldOut(v8.Id))
		then
			return
		end

		Sales.Prompt(tostring(LocalPlayer.UserId), v8.ProductId, Enum.InfoType.Product)
	end))

	v6.Maid:GiveTask(PoolGiftPicker.Badge(v6.GalaxyBuy, function()
		local carousel = v6.Menu.Carousels[v6.Category]
		local v7

		if carousel then
			v7 = PoolCarousel.GetKey(carousel)
		end

		local v8

		if v7 and v6.Category == PoolGalaxySet.Category then
			for _, tier in PoolGalaxySet.Tiers do
				if tier.Item == v7 then
					v8 = tier
					break
				end
			end
		end

		if v8 and not PoolGalaxySet.IsSoldOut(v8.Id) then
			return v8.ProductId
		end

		return nil
	end))

	v6.Maid:GiveTask(v6.UpgradeButton.Activated:Connect(function()
		local carousel = v6.Menu.Carousels[v6.Category]
		local v7

		if carousel then
			v7 = PoolCarousel.GetKey(carousel)
		end

		if not v7 or v6.Category ~= "cueSticks" or not v6.UpgradeButton.Active then
			return
		end

		local offer = PoolCueUpgradeService.GetOffer(LocalPlayer.UserId, v7)

		if offer and offer.Cost then
			v6.Menu.UpgradeBindable:Fire(v7)
		end
	end))

	for _, tier in PoolGalaxySet.Tiers do
		v6.Maid:GiveTask(ReplicatedStorage:GetAttributeChangedSignal(PoolGalaxySet.SoldAttribute(tier.Id)):Connect(function()
			if v6.Open then
				PoolInspector.Refresh(v6)
			end
		end))
	end

	local replica = PoolPlayerData.GetReplica(LocalPlayer.UserId)

	if replica then
		local connection = replica:ListenToWrite("Currency1", function()
			if v6.Open then
				PoolInspector.Refresh(v6)
			end
		end)

		v6.Maid:GiveTask(function()
			connection:Disconnect()
		end)

		local connection2 = replica:ListenToWrite("Currency2", function()
			if v6.Open then
				PoolInspector.Refresh(v6)
			end
		end)

		v6.Maid:GiveTask(function()
			connection2:Disconnect()
		end)

		for _, v7 in { "Equipped", "Inventory", "PoolCueUpgrades" } do
			local connection3 = replica:ListenToWrite(v7, function()
				if v6.Open then
					PoolInspector.Refresh(v6)
				end
			end)

			v6.Maid:GiveTask(function()
				connection3:Disconnect()
			end)
		end
	end

	local function page(p: number) -- 2 equivalent calls inferred from this helper
		local carousel = v6.Menu.Carousels[v6.Category]

		if carousel then
			PoolCarousel.Step(carousel, p)
		end
	end

	v6.Maid:GiveTask(v6.PrevButton.Activated:Connect(function()
		page(-1) -- inferred equivalent call
	end))

	v6.Maid:GiveTask(v6.NextButton.Activated:Connect(function()
		page(1) -- inferred equivalent call
	end))

	for k, carousel in menu.Carousels do
		v6.Maid:GiveTask(carousel.Changed:Connect(function()
			if v6.Open and v6.Category == k then
				PoolInspector.Refresh(v6)
			end
		end))
	end

	return v6
end

function PoolInspector:Destroy()
	if self.Open then
		PoolInspector.SetOpen(self, false)
	end

	self.Maid:DoCleaning()
end

return PoolInspector