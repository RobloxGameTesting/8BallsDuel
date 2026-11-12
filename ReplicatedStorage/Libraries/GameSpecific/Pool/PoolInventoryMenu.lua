local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Inventories = require(ReplicatedStorage.Libraries.Classes.Inventories)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolCarousel = require(Pool.PoolCarousel)
local PoolCueGrid = require(Pool.PoolCueGrid)
local PoolCueUpgradeService = require(Pool.PoolCueUpgradeService)
local PoolConstants = require(Pool.PoolConstants)
local PoolInspector = require(Pool.PoolInspector)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)
local PoolSkins = require(Pool.PoolSkins)

local PoolInventoryMenu = {}

local Menu = PoolConstants.Menu
local LocalPlayer = Players.LocalPlayer

local udim = UDim2.fromScale(0.05, 0.575)
local udim2 = UDim2.fromScale(0.9, 0.4)

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolInventoryMenu: %s.%s is missing (looking for %q)",
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

local function findModel(p)
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

local function fillPreview(preview, instance, previewMaid)
	preview:ClearAllChildren()

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

	clone.Parent = preview
	previewMaid:GiveTask(clone)

	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.Parent = preview
	preview.CurrentCamera = camera
	previewMaid:GiveTask(camera)

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

	local v3 = not (preview.AbsoluteSize.Y > 0) and 1 or math.max(preview.AbsoluteSize.X, 1) / preview.AbsoluteSize.Y

	local fieldOfView = math.rad(camera.FieldOfView)
	local v4 = math.atan(math.tan(fieldOfView / 2) * v3) * 2

	local v5 = math.max(maxValue2 / math.tan(fieldOfView / 2), maxValue / math.tan(v4 / 2)) * 1.15

	camera.CFrame = CFrame.lookAt(boundingBox.Position + unit * v5, boundingBox.Position)
end

function PoolInventoryMenu.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local bindableEvent4 = Instance.new("BindableEvent")
	local bindableEvent5 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent3)
	maid:GiveTask(bindableEvent4)
	maid:GiveTask(bindableEvent5)

	local inventoryMenu = instance:WaitForChild("InventoryMenu")
	inventoryMenu.Visible = false

	local v = bind(inventoryMenu, "Grid")
	local v2 = bind(inventoryMenu, "Equipped")

	local tabButtons = {}
	local rows = {}

	for _, category in PoolSkins.Categories do
		tabButtons[category.Id] = bind(inventoryMenu, "Tabs." .. category.Id)

		local root = bind(v2, category.Id)

		rows[category.Id] = {
			Root = root,
			Preview = bind(root, "Preview"),
			Name = bind(root, "ItemName"),
			Detail = bind(root, "ItemDetail"),
			Upgrade = nil,
			UpgradeLabel = nil
		}
	end

	local v3 = {
		Root = inventoryMenu,
		Grid = v,
		Empty = bind(inventoryMenu, "Empty"),
		CoinsLabel = bind(inventoryMenu, "Coins.Amount"),
		GemsLabel = bind(inventoryMenu, "Gems.Amount"),
		TabButtons = tabButtons,
		Rows = rows,
		Inventories = {},
		Carousels = {},
		Ghosts = {},
		Category = PoolSkins.Categories[1].Id,
		Inspector = nil,
		Back = bind(inventoryMenu, "Back"),
		EquipRequested = bindableEvent.Event,
		EquipBindable = bindableEvent,
		BuyRequested = bindableEvent2.Event,
		BuyBindable = bindableEvent2,
		UpgradeRequested = bindableEvent4.Event,
		UpgradeBindable = bindableEvent4,
		Closed = bindableEvent3.Event,
		CloseBindable = bindableEvent3,
		CategoryViewed = bindableEvent5.Event,
		CategoryViewedBindable = bindableEvent5,
		PreviewMaid = Maid.new(),
		CueGrid = nil,
		Viewing = false,
		CueCard = nil,
		Maid = maid
	}

	maid:GiveTask(v3.PreviewMaid)

	for _, category in PoolSkins.Categories do
		local frame = Instance.new("Frame")
		frame.Name = category.Id
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Visible = false
		frame.Parent = v
		maid:GiveTask(frame)

		local v4 = category.Id == "cueSticks"

		local v5 = PoolCarousel.new(frame, {
			CardWidth = v4 and 0.78 or 0.46,
			CardHeight = v4 and 0.5 or 0.72,
			CardStep = v4 and 0.82 or 0.5,
			Shrink = v4 and 0.08 or 0.14,
			Gestures = false,
			Virtual = category.Id == "cueSticks"
		})

		v3.Carousels[category.Id] = v5

		maid:GiveTask(function()
			PoolCarousel.Destroy(v5)
		end)

		if category.Id == "cueSticks" then
			continue
		end

		local v6 = Inventories.new(LocalPlayer, frame, category.Id, v4 and "Cue" or "Generic")

		Inventories.SetCallback(v6, function(value)
			if PoolCarousel.IsTapSuppressed(v5) then
				return
			end

			if typeof(value) == "string" then
				bindableEvent:Fire(category.Id, value)
			end
		end)

		maid:GiveTask(v5.Accepted:Connect(function(_, value)
			if typeof(value) == "string" and PoolSkins.Owns(LocalPlayer.UserId, category.Id, value) then
				bindableEvent:Fire(category.Id, value)
			end
		end))

		maid:GiveTask(v6.updatedEvent.Event:Connect(function()
			PoolInventoryMenu.DressSlots(v3, category.Id)
			PoolInventoryMenu.Repage(v3, category.Id)
		end))

		v3.Inventories[category.Id] = v6

		PoolInventoryMenu.DressSlots(v3, category.Id)

		PoolInventoryMenu.Repage(v3, category.Id)
	end

	for k, v4 in tabButtons do
		maid:GiveTask(v4.Activated:Connect(function()
			PoolInventoryMenu.SetCategory(v3, k)
		end))
	end

	maid:GiveTask(v3.Back.Activated:Connect(function()
		bindableEvent3:Fire()
	end))

	maid:GiveTask(v:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		PoolInventoryMenu.Reflow(v3)
	end))

	v3.CueGrid = PoolCueGrid.new(v3, {
		Repage = function()
			PoolInventoryMenu.Repage(v3, "cueSticks")
		end,
		Sync = function()
			PoolInventoryMenu.SyncStage(v3)
		end
	})

	maid:GiveTask(function()
		if v3.CueGrid then
			PoolCueGrid.Destroy(v3.CueGrid)
		end
	end)

	PoolInventoryMenu.Repage(v3, "cueSticks")

	PoolInventoryMenu.Reflow(v3)
	PoolInventoryMenu.SetCategory(v3, v3.Category)
	PoolInventoryMenu.RefreshEquipped(v3)

	v3.Inspector = PoolInspector.new(v3)
	maid:GiveTask(function()
		PoolInspector.Destroy(v3.Inspector)
	end)

	return v3
end

function PoolInventoryMenu.GhostCard(data, childName: string, name: string)
	local v = data.Ghosts[childName]

	if not v then
		v = {}
		data.Ghosts[childName] = v
	end

	local v2 = v[name]

	if v2 and v2.Parent then
		return v2
	end

	local child = data.Grid:FindFirstChild(childName)

	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = child or data.Grid

	v[name] = frame
	data.Maid:GiveTask(frame)

	return frame
end

function PoolInventoryMenu:Repage(p: string)
	local carousel = self.Carousels[p]
	local inventory = self.Inventories[p]

	if carousel and p == "cueSticks" then
		local cueCard = self.CueCard

		if not cueCard then
			cueCard = Instance.new("Frame")
			cueCard.Name = "CueCard"
			cueCard.BackgroundTransparency = 1
			cueCard.BorderSizePixel = 0
			cueCard.Active = false
			cueCard.Visible = false
			cueCard.Parent = carousel.Track
			self.Maid:GiveTask(cueCard)
			self.CueCard = cueCard
		end

		local v = not self.CueGrid and {} or table.clone(PoolCueGrid.GetOrder(self.CueGrid))

		PoolCarousel.SetCards(carousel, table.create(#v, cueCard), v)

		if self.Inspector and self.Inspector.Open and self.Category == "cueSticks" then
			PoolInspector.Rebuild(self.Inspector)
		end
	else
		if not (carousel and inventory) then
			return
		end

		local slots = Inventories.GetSlots(inventory)
		local guiObjects = {}
		local v = {}

		for k, guiObject in slots do
			if not (typeof(k) == "string" and typeof(guiObject) == "Instance" and guiObject:IsA("GuiObject")) then
				continue
			end

			guiObjects[k] = guiObject
			table.insert(v, k)
		end

		local ghost = self.Ghosts[p]

		if ghost then
			for k, v2 in ghost do
				if not guiObjects[k] then
					continue
				end

				v2:Destroy()
				ghost[k] = nil
			end
		end

		for k in PoolSkins.GetAll(p) do
			if not guiObjects[k] then
				table.insert(v, k)
			end
		end

		local category = PoolSkins.GetCategory(p)
		local default = category and category.Default
		local v2 = {}

		for _, v3 in v do
			local item = PoolSkins.GetItem(p, v3)
			local price = PoolSkins.GetPrice(item)

			if PoolSkins.IsForSale(item) then
				if PoolSkins.GetPriceCurrency(item) == "Gems" then
					v2[v3] = 1000000000000000 + price
				else
					v2[v3] = price
				end
			else
				v2[v3] = 1e999
			end
		end

		table.sort(v, function(a: string, b: string)
			local v3 = a == default

			if v3 ~= (b == default) then
				return v3
			end

			if v2[a] == v2[b] then
				return a < b
			end

			return v2[a] < v2[b]
		end)

		local v3 = {}

		for _, v4 in v do
			table.insert(v3, guiObjects[v4] or PoolInventoryMenu.GhostCard(self, p, v4))
		end

		PoolCarousel.SetCards(carousel, v3, v)

		if self.Inspector and self.Inspector.Open and self.Category == p then
			PoolInspector.Rebuild(self.Inspector)
		end
	end
end

function PoolInventoryMenu.Reflow(p)
	for _, category in PoolSkins.Categories do
		local carousel = p.Carousels[category.Id]

		if carousel then
			PoolCarousel.Relayout(carousel)
		end
	end
end

function PoolInventoryMenu.ReflowOld(p)
	local x = p.Grid.AbsoluteSize.X

	if x <= 0 then
		return
	end

	local function cellWidth(p2: number) -- 2 equivalent calls inferred from this helper
		return (x - (p2 - 1) * 10) / p2
	end

	local v = math.clamp(math.round((x + 10) / 160), 2, 8)

	while v > 2 and cellWidth(v) < 96 do -- inferred equivalent call
		v -= 1
	end

	local v2 = math.floor(cellWidth(v)) -- inferred equivalent call
	local udim3 = UDim2.fromOffset(v2, v2)

	for _, category in PoolSkins.Categories do
		local child = p.Grid:FindFirstChild(category.Id)
		local uiGridLayout = child and child:FindFirstChildOfClass("UIGridLayout")

		if not uiGridLayout then
			continue
		end

		uiGridLayout.CellSize = udim3
		uiGridLayout.CellPadding = UDim2.fromOffset(10, 10)
	end
end

local function restack(_, _: number) end

function PoolInventoryMenu.DressSlots(data, p: string)
	if p == "cueSticks" then
		if data.CueGrid then
			PoolCueGrid.Invalidate(data.CueGrid)
		end
	else
		local inventory = data.Inventories[p]

		if not inventory then
			return
		end

		local equippedName = PoolSkins.GetEquippedName(LocalPlayer.UserId, p)
		local count = 0

		for k, guiObject in Inventories.GetSlots(inventory) do
			if not (typeof(k) == "string" and typeof(guiObject) == "Instance") then
				continue
			end

			local item = PoolSkins.GetItem(p, k)

			if not item then
				continue
			end

			count += 1

			if guiObject:IsA("GuiObject") and not guiObject:GetAttribute("Restacked") then
				local parent = guiObject.Parent
				local v

				if parent and parent:IsA("GuiObject") then
					v = parent.ZIndex
				else
					v = data.Grid.ZIndex
				end

				local _ = v + 1
				guiObject:SetAttribute("Restacked", true)
			end

			local labelTop = guiObject:FindFirstChild("LabelTop", true)
			local labelBottom = guiObject:FindFirstChild("LabelBottom", true)
			local v = k == equippedName

			if labelTop and labelTop:IsA("TextLabel") then
				labelTop.Text = tostring(item.name)
			end

			if p == "cueSticks" then
				local equipPlate = guiObject:FindFirstChild("EquipPlate", true)

				if labelBottom and labelBottom:IsA("TextLabel") then
					labelBottom.Text = v and "EQUIPPED" or "EQUIP"
					labelBottom.TextColor3 = Menu.TextPrimary
				end

				if equipPlate and equipPlate:IsA("GuiObject") then
					local backgroundColor

					if v then
						backgroundColor = Menu.PlayPrimary
					else
						backgroundColor = Menu.Panel
					end

					local v2

					if v then
						v2 = Menu.PlayPrimaryShade
					else
						v2 = Menu.PanelShade
					end

					equipPlate.BackgroundColor3 = backgroundColor

					local uiGradient = equipPlate:FindFirstChildOfClass("UIGradient")

					if uiGradient then
						uiGradient.Color = ColorSequence.new(backgroundColor, v2)
					end
				end
			elseif labelBottom and labelBottom:IsA("TextLabel") then
				labelBottom.Text = v and "EQUIPPED" or ""
				local textColor

				if v then
					textColor = Menu.PlayPrimary
				else
					textColor = Menu.TextMuted
				end

				labelBottom.TextColor3 = textColor
			end

			local background = guiObject:FindFirstChild("Background")

			if p == "cueSticks" and background and background:IsA("GuiObject") then
				local stats = background:FindFirstChild("Stats")
				local v2 = stats and stats:FindFirstChild("CueStats")

				if stats and not v2 then
					v2 = PoolMenuWidgets.CueStatPanel(stats, stats.ZIndex + 1)
					v2.Position = UDim2.fromScale(0.06, 0.08)
					v2.Size = UDim2.fromScale(0.88, 0.84)
					data.PreviewMaid:GiveTask(v2)
				end

				if v2 then
					PoolMenuWidgets.WriteCueStats(
						PoolMenuWidgets.ReadCueStats(v2),
						item.cue,
						false,
						PoolSkins.GetCueLevel(LocalPlayer.UserId, k)
					)
				end
			end

			local icon = guiObject:FindFirstChild("Icon", true)

			if not icon or not icon:IsA("GuiObject") or icon:FindFirstChildOfClass("ViewportFrame") then
				continue
			end

			local model = findModel(item)

			if not model then
				continue
			end

			local preview = Instance.new("ViewportFrame")
			preview.Name = "Preview"
			preview.Size = UDim2.fromScale(1, 1)
			preview.BackgroundTransparency = 1
			preview.LightColor = Color3.fromRGB(255, 245, 225)
			preview.Ambient = Color3.fromRGB(150, 155, 165)
			preview.ZIndex = icon.ZIndex + 1
			preview.Parent = icon
			data.PreviewMaid:GiveTask(preview)

			fillPreview(preview, model, data.PreviewMaid)
		end

		if data.Category == p then
			data.Empty.Visible = count == 0
		end
	end
end

function PoolInventoryMenu:SetCategory(category: string)
	self.Category = category

	if category ~= "cueSticks" then
		self.Viewing = false
	end

	for _, category2 in PoolSkins.Categories do
		local visible = category2.Id == category
		local tabButton = self.TabButtons[category2.Id]
		local guiObject = self.Grid:FindFirstChild(category2.Id)

		if guiObject and guiObject:IsA("GuiObject") then
			guiObject.Visible = visible
		end

		if not tabButton then
			continue
		end

		local setColour = PoolButtonSkin.SetColour
		local v = if visible then Menu.PlayFriends else Menu.Panel
		setColour(tabButton, v)

		local uiGradient = tabButton:FindFirstChildOfClass("UIGradient")

		if not uiGradient then
			continue
		end

		local color

		if visible then
			color = ColorSequence.new(Menu.PlayFriends, Menu.PlayFriendsShade)
		else
			color = ColorSequence.new(Menu.Panel, Menu.PanelShade)
		end

		uiGradient.Color = color
	end

	PoolInventoryMenu.DressSlots(self, category)

	if self.Inspector then
		if not PoolInventoryMenu.WantsStage(self) then
			PoolInspector.SetOpen(self.Inspector, false)
		end

		PoolInspector.SetCategory(self.Inspector, category)
	end

	PoolInventoryMenu.SyncStage(self)

	if self.Root.Visible then
		self.CategoryViewedBindable:Fire(category)
	end
end

function PoolInventoryMenu.RefreshEquipped(data)
	for _, category in PoolSkins.Categories do
		local row = data.Rows[category.Id]

		if not row then
			continue
		end

		local equipped = PoolSkins.GetEquipped(LocalPlayer.UserId, category.Id)
		local guiObject = row.Root:FindFirstChild("CueStats")

		if equipped then
			row.Name.Text = tostring(equipped.name)

			if category.Id == "cueSticks" then
				row.Detail.Visible = false

				if not guiObject then
					guiObject = PoolMenuWidgets.CueStatPanel(row.Root, row.Detail.ZIndex)
					data.Maid:GiveTask(guiObject)
				end

				guiObject.Position = udim
				guiObject.Size = udim2
				guiObject.Visible = true

				local equippedName = PoolSkins.GetEquippedName(LocalPlayer.UserId, category.Id)
				local offer = PoolCueUpgradeService.GetOffer(LocalPlayer.UserId, equippedName)

				PoolInventoryMenu.DressUpgrade(data, row, equippedName, offer)
				local v

				if offer and offer.Cost then
					v = offer.Level + 1
				end

				PoolMenuWidgets.WriteCueStats(
					PoolMenuWidgets.ReadCueStats(guiObject),
					equipped.cue,
					false,
					not offer and 0 or offer.Level,
					v
				)
			elseif category.Id == "poolTables" then
				row.Detail.Text = "Cosmetic only"
			else
				row.Detail.Text = "Pot celebration"
			end

			fillPreview(row.Preview, findModel(equipped), data.PreviewMaid)
		else
			row.Name.Text = "—"
			row.Detail.Text = ""

			if guiObject and guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end
	end
end

function PoolInventoryMenu.DressUpgrade(p, state, itemKey: string, data)
	if not state.Upgrade then
		local v = state.Detail.ZIndex + 4
		local button = PoolMenuWidgets.Button(state.Root, "Upgrade", Menu.Gold, v)

		button.AnchorPoint = Vector2.new(1, 0)
		button.Position = UDim2.fromScale(0.98, 0.02)
		button.Size = UDim2.fromScale(0.44, 0.17)
		p.Maid:GiveTask(button)

		state.UpgradeLabel = PoolMenuWidgets.ButtonText(button, "UPGRADE", nil, v)
		state.Upgrade = button

		p.Maid:GiveTask(button.Activated:Connect(function()
			local itemKey2 = button:GetAttribute("ItemKey")

			if button.Active and typeof(itemKey2) == "string" and itemKey2 ~= "" then
				p.UpgradeBindable:Fire(itemKey2)
			end
		end))
	end

	local upgrade = state.Upgrade
	local upgradeLabel = state.UpgradeLabel

	upgrade:SetAttribute("ItemKey", itemKey)

	if not data or data.MaxLevel <= 0 then
		upgrade.Visible = false
		return
	end

	upgrade.Visible = true

	if data.Cost then
		upgrade.Active = true
		upgrade.AutoButtonColor = true
		PoolButtonSkin.SetFaded(upgrade, 0)

		if upgradeLabel then
			upgradeLabel.Text = string.format("UPGRADE · $%s", NumberHelper:Separate(data.Cost))
		end
	else
		upgrade.Active = false
		upgrade.AutoButtonColor = false
		PoolButtonSkin.SetFaded(upgrade, 0.45)

		if upgradeLabel then
			upgradeLabel.Text = string.format("MAX · LV%d", data.Level)
		end
	end
end

function PoolInventoryMenu.SetCoins(p, p2: number)
	p.CoinsLabel.Text = NumberHelper:Separate((math.round(p2)))
end

function PoolInventoryMenu.SetGems(p, p2: number)
	p.GemsLabel.Text = NumberHelper:Separate((math.round(p2)))
end

function PoolInventoryMenu:SetVisible(visible: boolean)
	local v = visible and not self.Root.Visible

	self.Root.Visible = visible

	if v then
		for k, carousel in self.Carousels do
			PoolCarousel.FocusKey(carousel, PoolSkins.GetEquippedName(LocalPlayer.UserId, k), true)
		end
	end

	if visible then
		PoolInventoryMenu.Reflow(self)
		PoolInventoryMenu.RefreshEquipped(self)

		self.CategoryViewedBindable:Fire(self.Category)
	end

	if not visible then
		self.Viewing = false
	end

	PoolInventoryMenu.SyncStage(self)
end

function PoolInventoryMenu:Focus(p: string, p2: string?)
	local carousel = self.Carousels[p]

	if not (carousel and p2) then
		return false
	end

	if p == "cueSticks" and self.CueGrid then
		if self.Category ~= "cueSticks" then
			PoolInventoryMenu.SetCategory(self, "cueSticks")
		end

		if self.Viewing then
			self.Viewing = false
			PoolInventoryMenu.SyncStage(self)
		end

		local cueGrid = self.CueGrid

		if not PoolCueGrid.Has(cueGrid, p2) then
			return false
		end

		PoolCarousel.FocusKey(carousel, p2, true)
		PoolCueGrid.ScrollTo(cueGrid, p2)

		task.defer(function()
			PoolCueGrid.ScrollTo(cueGrid, p2)
		end)

		return PoolCueGrid.OpenDetail(cueGrid, p2)
	else
		if self.Category ~= p then
			PoolInventoryMenu.SetCategory(self, p)
		end

		local v = PoolCarousel.FocusKey(carousel, p2, true)

		if v and self.Inspector and self.Inspector.Open then
			PoolInspector.Rebuild(self.Inspector)
		end

		return v
	end
end

function PoolInventoryMenu.WantsStage(data)
	return data.Root.Visible and (data.Category ~= "cueSticks" or data.Viewing)
end

function PoolInventoryMenu.SyncStage(data)
	local visible = data.Root.Visible
	local v = data.Category == "cueSticks"
	local viewing = visible and v and data.Viewing

	if data.CueGrid then
		PoolCueGrid.SetMode(data.CueGrid, visible and v and (viewing and "View" or "Grid") or "Hidden")
	end

	local inspector = data.Inspector

	if not inspector then
		return
	end

	local wantsStage = PoolInventoryMenu.WantsStage(data)
	local v2 = inspector.ViewMode ~= viewing

	inspector.ViewMode = viewing

	if wantsStage and inspector.Open and v2 then
		PoolInspector.Refresh(inspector)
	end

	PoolInspector.SetOpen(inspector, wantsStage)
end

function PoolInventoryMenu.Destroy(p)
	for _, inventory in p.Inventories do
		pcall(Inventories.Destroy, inventory)
	end

	p.Maid:DoCleaning()
end

return PoolInventoryMenu