local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolGalaxySet = require(Pool.PoolGalaxySet)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)
local PoolPriceTag = require(script.Parent.PoolPriceTag)
local PoolSkins = require(Pool.PoolSkins)
local PoolGiftPicker = require(script.Parent.PoolGiftPicker)

local PoolGalaxyPanel = {}

Color3.fromRGB(255, 255, 255)
Color3.fromRGB(255, 138, 232)
local color = Color3.fromRGB(236, 224, 255)
local color2 = Color3.fromRGB(150, 150, 160)

local ButtonColour = PoolPriceTag.ButtonColour
local color3 = Color3.fromRGB(104, 198, 96)
local color4 = Color3.fromRGB(26, 16, 48)

local function templateFor(parent)
	local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")
	local galaxyTemplates = screenGui and screenGui:FindFirstChild("GalaxyTemplates")
	local tierCard = galaxyTemplates and galaxyTemplates:FindFirstChild("TierCard")

	if not (tierCard and tierCard:IsA("Frame")) then
		error("PoolGalaxyPanel: PoolMenuUI.GalaxyTemplates.TierCard is missing", 2)
	end

	return tierCard
end

local function bind(instance, childName: string) -- 7 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(childName, true)

	if not child then
		error(string.format("PoolGalaxyPanel: no %q in %s", childName, instance:GetFullName()), 2)
	end

	return child
end

local function buildCard(data, instance, tier, zIndex: number)
	local clone = instance:Clone()
	clone.Name = tier.Id
	clone.Visible = true
	clone.Parent = data.Root

	local v = zIndex - clone.ZIndex

	clone.ZIndex += v

	for _, guiObject in clone:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += v
		end
	end

	local tag = bind(clone, "Tag") -- inferred equivalent call
	local itemName = bind(clone, "ItemName") -- inferred equivalent call
	local count = bind(clone, "Count") -- inferred equivalent call
	local preview = bind(clone, "Preview") -- inferred equivalent call
	local buy = bind(clone, "Buy") -- inferred equivalent call
	local priceLabel = bind(buy, "Price") -- inferred equivalent call
	local view = bind(clone, "View") -- inferred equivalent call
	local visible = tier.Tag ~= nil

	tag.Visible = visible

	if visible then
		tag.Text = tostring(tier.Tag)
	else
		local v2 = itemName.Position.Y.Scale - tag.Position.Y.Scale

		itemName.Position -= UDim2.fromScale(0, v2)
		count.Position -= UDim2.fromScale(0, v2)
	end

	local item = PoolSkins.GetItem(PoolGalaxySet.Category, tier.Item)
	local v2

	if item and item.name then
		v2 = tostring(item.name)
	else
		v2 = tier.Item
	end

	itemName.Text = string.upper(v2)

	count.Text = "..."

	local theme = data.Theme
	local v3 = theme and theme.Accents and theme.Accents[tier.Id] or tier.Accent
	local back = theme and theme.Back or color4

	if theme then
		local uiGradient = theme.NameGradient and itemName:FindFirstChildOfClass("UIGradient")

		if uiGradient then
			uiGradient.Color = theme.NameGradient
		end

		if theme.TextStroke then
			for _, v4 in { tag, itemName, count } do
				local uiStroke = v4:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Color = theme.TextStroke
				end
			end
		end
	end

	local burstSlot = clone:FindFirstChild("BurstSlot")

	if burstSlot and burstSlot:IsA("GuiObject") then
		local v4

		if theme then
			v4 = theme.Burst or v3
		else
			v4 = v3
		end

		local starburst = PoolMenuWidgets.Starburst(burstSlot.Parent, v4, burstSlot.ZIndex, 8, 18)
		starburst.AnchorPoint = burstSlot.AnchorPoint
		starburst.Position = burstSlot.Position
		starburst.Size = burstSlot.Size
		burstSlot:Destroy()

		if preview.ZIndex <= starburst.ZIndex then
			preview.ZIndex = starburst.ZIndex + 1
		end
	end

	local uiStroke = clone:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		local color5

		if theme then
			color5 = theme.Outline or v3
		else
			color5 = v3
		end

		uiStroke.Color = color5
	end

	local uiGradient = clone:FindFirstChildOfClass("UIGradient")

	if uiGradient then
		uiGradient.Color = theme and theme.Wash or ColorSequence.new(v3:Lerp(back, 0.55), back)
	end

	if theme and theme.WashTransparency then
		clone.BackgroundTransparency = theme.WashTransparency
	end

	PoolMenuWidgets.CuePreview(preview, PoolMenuWidgets.FindSkinModel(item))

	priceLabel.Text = "..."

	local card = {
		Tier = tier,
		Root = clone,
		Count = count,
		Buy = buy,
		PriceLabel = priceLabel,
		Preview = preview,
		Price = nil,
		Gift = PoolGiftPicker.Badge(buy, tier.ProductId)
	}

	data.Maid:GiveTask(view.Activated:Connect(function()
		data.ViewBindable:Fire(PoolGalaxySet.Category, tier.Item)
	end))

	data.Maid:GiveTask(buy.Activated:Connect(function()
		local localPlayer = Players.LocalPlayer

		if
			not localPlayer
			or PoolSkins.Owns(localPlayer.UserId, PoolGalaxySet.Category, tier.Item)
			or PoolGalaxySet.IsSoldOut(tier.Id)
		then
			return
		end

		Sales.Prompt(tostring(localPlayer.UserId), tier.ProductId, Enum.InfoType.Product)
	end))

	task.spawn(function()
		for _ = 1, 10 do
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(tier.ProductId, Enum.InfoType.Product)
			end)

			if success and result and result.PriceInRobux then
				card.Price = result.PriceInRobux
				PoolGalaxyPanel.Refresh(data)
				break
			end

			task.wait(1)
		end
	end)

	return card
end

function PoolGalaxyPanel.new(parent, zIndex: number, theme)
	local maid = Maid.new()

	local v = templateFor(parent)

	local galaxyRow = Instance.new("Frame")
	galaxyRow.Name = "GalaxyRow"
	galaxyRow.Size = UDim2.fromScale(1, 1)
	galaxyRow.BackgroundTransparency = 1
	galaxyRow.BorderSizePixel = 0
	galaxyRow.ZIndex = zIndex
	galaxyRow.Parent = parent

	maid:GiveTask(galaxyRow)

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0.015, 0)
	uiListLayout.Parent = galaxyRow

	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local v2 = {
		Root = galaxyRow,
		Cards = {},
		Replica = nil,
		Theme = theme,
		Viewed = bindableEvent.Event,
		ViewBindable = bindableEvent,
		Maid = maid
	}

	for k, tier in PoolGalaxySet.Tiers do
		local card = buildCard(v2, v, tier, zIndex)

		card.Root.LayoutOrder = k

		card.Root.Size = UDim2.fromScale(1 / #PoolGalaxySet.Tiers - 0.02, 1)

		table.insert(v2.Cards, card)
	end

	for _, tier in PoolGalaxySet.Tiers do
		maid:GiveTask(ReplicatedStorage:GetAttributeChangedSignal(PoolGalaxySet.SoldAttribute(tier.Id)):Connect(function()
			PoolGalaxyPanel.Refresh(v2)
		end))
	end

	PoolGalaxyPanel.Refresh(v2)

	return v2
end

function PoolGalaxyPanel:SetReplica(replica)
	self.Replica = replica

	if replica then
		local success, result = pcall(function()
			return replica:ListenToWrite("Inventory", function()
				PoolGalaxyPanel.Refresh(self)
			end)
		end)

		if success and result then
			self.Maid:GiveTask(function()
				result:Disconnect()
			end)
		end
	end

	PoolGalaxyPanel.Refresh(self)
end

function PoolGalaxyPanel.Refresh(p)
	local localPlayer = Players.LocalPlayer

	for _, card in p.Cards do
		local tier = card.Tier
		local remaining = PoolGalaxySet.GetRemaining(tier.Id)
		local v

		if localPlayer == nil then
			v = false
		else
			v = PoolSkins.Owns(localPlayer.UserId, PoolGalaxySet.Category, tier.Item)
		end

		card.Count.Text = not remaining and "..."
			or string.format("%s / %s Left", NumberHelper:Separate(remaining), NumberHelper:Separate(tier.Stock))

		local count = card.Count
		local textColor

		if remaining == 0 then
			textColor = color2
		else
			textColor = p.Theme and p.Theme.Count or color
		end

		count.TextColor3 = textColor

		card.Gift.Visible = remaining ~= 0

		if v then
			PoolButtonSkin.SetColour(card.Buy, color3)
			card.Buy.AutoButtonColor = false
			PoolPriceTag.SetText(card.PriceLabel, "OWNED")
		elseif remaining == 0 then
			PoolButtonSkin.SetColour(card.Buy, color2)
			card.Buy.AutoButtonColor = false
			PoolPriceTag.SetText(card.PriceLabel, "SOLD OUT")
		else
			PoolButtonSkin.SetColour(card.Buy, ButtonColour)
			card.Buy.AutoButtonColor = true

			PoolPriceTag.SetText(
				card.PriceLabel,
				"R$ " .. (not card.Price and "..." or NumberHelper:Separate(card.Price))
			)
		end
	end
end

function PoolGalaxyPanel:Destroy()
	self.Maid:DoCleaning()
end

return PoolGalaxyPanel