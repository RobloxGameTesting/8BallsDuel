local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolSkins = require(Pool.PoolSkins)
local PoolStarterPackCard = require(Pool.PoolStarterPackCard)

local POOL_STARTER_PACK_INFO = MonetizationConstants.POOL_STARTER_PACK_INFO

local function need(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolStarterPackPopup: %s.%s is missing (looking for %q)",
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

local function setText(instance, childName: string, text: string) -- 4 equivalent calls inferred from this helper
	local label = instance:FindFirstChild(childName, true)

	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function fillItem(guiObject, skin)
	local item = PoolSkins.GetItem(skin.category, skin.item)
	local preview = guiObject:FindFirstChild("Preview")
	local icon = guiObject:FindFirstChild("Icon")
	local image = (not item or typeof(item.image) ~= "string") and "" or item.image
	local skinModel = PoolMenuWidgets.FindSkinModel(item)

	if preview and preview:IsA("ViewportFrame") and skinModel then
		preview.Visible = true

		if skin.category == "cueSticks" then
			PoolMenuWidgets.CuePreview(preview, skinModel)
		else
			PoolMenuWidgets.ModelPreview(preview, skinModel)
		end

		if icon and icon:IsA("GuiObject") then
			icon.Visible = false
		end
	else
		if preview and preview:IsA("GuiObject") then
			preview.Visible = false
		end

		if icon and icon:IsA("ImageLabel") then
			icon.Image = image
			icon.Visible = image ~= ""
		end
	end

	local category = PoolSkins.GetCategory(skin.category)
	local v

	if item and item.itemType then
		v = tostring(item.itemType)
	else
		v = not (category and category.Label) and "" or tostring(category.Label)
	end

	local v2

	if item and item.name then
		v2 = tostring(item.name)
	else
		v2 = tostring(skin.item)
	end

	setText(guiObject, "ItemName", string.upper(v2)) -- inferred equivalent call

	setText(guiObject, "Type", string.upper((v:gsub("(%l)(%u)", "%1 %2")))) -- inferred equivalent call
end

local function packValue()
	local total = 0

	for _, skin in POOL_STARTER_PACK_INFO.skins do
		local item = PoolSkins.GetItem(skin.category, skin.item)

		if item and PoolSkins.GetPriceCurrency(item) == "Coins" then
			total += PoolSkins.GetPrice(item)
		end
	end

	return total
end

local function fill(p)
	local count = 0

	for _, skin in POOL_STARTER_PACK_INFO.skins do
		count += 1

		local guiObject = p.Rewards:FindFirstChild("Item" .. count)

		if guiObject then
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = true
			end

			fillItem(guiObject, skin)
		else
			warn(string.format(
				"[PoolStarterPackPopup] no Item%d tile for %s; add one to Card.Rewards",
				count,
				(tostring(skin.item))
			))
		end
	end

	local v = count + 1

	while p.Rewards:FindFirstChild("Item" .. v) do
		local findFirstChild = p.Rewards:FindFirstChild("Item" .. v)
		findFirstChild.Visible = false
		v += 1
	end

	local coins = p.Rewards:FindFirstChild("Coins")

	if coins then
		setText(coins, "ItemName", "+" .. NumberHelper:Separate(tonumber(POOL_STARTER_PACK_INFO.gems) or 0)) -- inferred equivalent call
		setText(coins, "Type", "GEMS") -- inferred equivalent call
		local itemName = coins:FindFirstChild("ItemName", true)

		if itemName and itemName:IsA("TextLabel") then
			itemName.TextColor3 = Color3.fromRGB(120, 215, 255)
		end

		local icon = coins:FindFirstChild("Icon", true)

		if icon and icon:IsA("ImageLabel") then
			icon.Image = "rbxassetid://91068843812037"
		end
	end

	if p.Value then
		p.Value.Text = string.format(
			"Worth over %s coins + %s Gems!",
			NumberHelper:Separate(packValue()),
			NumberHelper:Separate(tonumber(POOL_STARTER_PACK_INFO.gems) or 0)
		)
	end
end

local PoolStarterPackPopup = {}

function PoolStarterPackPopup.new(instance)
	local maid = Maid.new()
	local starterPackPopup = instance:WaitForChild("StarterPackPopup")
	local card = need(starterPackPopup, "Card")

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)

	local price = card:FindFirstChild("Price", true)
	local value = card:FindFirstChild("Value")
	local subtitle = card:FindFirstChild("Subtitle")

	local v = {
		Root = starterPackPopup,
		Card = card,
		Scale = card:FindFirstChildOfClass("UIScale"),
		DimTransparency = starterPackPopup.BackgroundTransparency,
		Buy = need(card, "Buy"),
		Decline = need(card, "Decline"),
		Close = need(card, "Close"),
		Price = 0,
		Value = 0,
		Subtitle = 0,
		Rewards = 0,
		Confirmed = 0,
		Declined = 0,
		ConfirmBindable = 0,
		DeclineBindable = 0,
		PreviousSelection = nil,
		Maid = 0
	}

	if not (price and price:IsA("TextLabel")) then
		price = nil
	end

	v.Price = price

	if not (value and value:IsA("TextLabel")) then
		value = nil
	end

	v.Value = value

	if not (subtitle and subtitle:IsA("TextLabel")) then
		subtitle = nil
	end

	v.Subtitle = subtitle
	v.Rewards = need(card, "Rewards")
	v.Confirmed = bindableEvent.Event
	v.Declined = bindableEvent2.Event
	v.ConfirmBindable = bindableEvent
	v.DeclineBindable = bindableEvent2

	v.Maid = maid

	starterPackPopup.Visible = false
	fill(v)

	maid:GiveTask(v.Buy.Activated:Connect(function()
		if starterPackPopup.Visible then
			bindableEvent:Fire()
		end
	end))

	for _, v2 in { v.Decline, v.Close } do
		maid:GiveTask(v2.Activated:Connect(function()
			if starterPackPopup.Visible then
				bindableEvent2:Fire()
			end
		end))
	end

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonB and starterPackPopup.Visible then
			bindableEvent2:Fire()
		end
	end))

	local thread = task.spawn(function()
		while true do
			if starterPackPopup.Visible then
				local timeLeft = PoolStarterPackCard.GetTimeLeft()

				if v.Subtitle then
					v.Subtitle.Text = PoolStarterPackCard.FormatDeadline(timeLeft)
				end

				if timeLeft <= 0 then
					bindableEvent2:Fire()
				end
			end

			task.wait(1)
		end
	end)

	maid:GiveTask(function()
		task.cancel(thread)
	end)

	task.spawn(function()
		for _ = 1, 10 do
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfoAsync(POOL_STARTER_PACK_INFO.productId, Enum.InfoType.Product)
			end)

			if success and result and result.PriceInRobux then
				if v.Price then
					v.Price.Text = NumberHelper:Separate(result.PriceInRobux)
				end

				break
			end

			task.wait(1)
		end
	end)

	return v
end

function PoolStarterPackPopup.IsVisible(p)
	return p.Root.Visible
end

function PoolStarterPackPopup:Show()
	if self.Root.Visible then
		return
	end

	self.PreviousSelection = GuiService.SelectedObject

	if self.Subtitle then
		self.Subtitle.Text = PoolStarterPackCard.FormatDeadline(PoolStarterPackCard.GetTimeLeft())
	end

	self.Root.Visible = true
	self.Root.BackgroundTransparency = 1
	TweenService:Create(self.Root, TweenInfo.new(0.25), {
		BackgroundTransparency = self.DimTransparency
	}):Play()

	if self.Scale then
		self.Scale.Scale = 0.8
		TweenService:Create(self.Scale, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end

	PoolAudio.PlayCue("MenuOpen")

	if UserInputService.GamepadEnabled then
		GuiService.SelectedObject = self.Buy
	end
end

function PoolStarterPackPopup.Hide(p)
	if not p.Root.Visible then
		return
	end

	p.Root.Visible = false

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(p.Root) then
		GuiService.SelectedObject = nil
	end

	local previousSelection = p.PreviousSelection

	if previousSelection and previousSelection.Parent and previousSelection.Visible then
		GuiService.SelectedObject = previousSelection
	end
end

function PoolStarterPackPopup.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolStarterPackPopup