local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local MonetizationConstants = require(ReplicatedStorage.Libraries.Constants.MonetizationConstants)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolStarterPackCard = require(Pool.PoolStarterPackCard)
local PoolWorldPass = require(Pool.PoolWorldPass)
local PoolWorldPassCard = require(Pool.PoolWorldPassCard)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)
local PoolPriceTag = require(script.Parent.PoolPriceTag)

local POOL_WORLD_PASS_INFO = MonetizationConstants.POOL_WORLD_PASS_INFO

local v = POOL_WORLD_PASS_INFO.fallbackPrice

local function localUserId() -- 1 equivalent call inferred from this helper
	local localPlayer = Players.LocalPlayer

	return if localPlayer then localPlayer.UserId else 0
end

local function buildOffers(callback)
	return {
		{
			Id = "VIP",
			Title = "VIP",
			Colour = Color3.fromRGB(255, 196, 40),
			Sellable = false,
			IsShown = function(): boolean
				return true
			end,
			Subtitle = function(): string
				return "COMING SOON"
			end,
			OnPress = function() end
		},
		{
			Id = "WorldPass",
			Title = "WORLD PASS",
			Colour = Color3.fromRGB(58, 142, 255),
			Sellable = true,
			IsShown = function(): boolean
				return not PoolWorldPass.Owns(localUserId()) -- inferred equivalent call
			end,
			Subtitle = function()
				return "R$ " .. NumberHelper:Separate(v) .. " · ALL WORLDS"
			end,
			OnPress = function()
				PoolWorldPassCard.Prompt()
			end
		},
		{
			Id = "StarterPack",
			Title = "STARTER PACK",
			Colour = Color3.fromRGB(235, 70, 60),
			Sellable = true,
			IsShown = function()
				return PoolStarterPackCard.CanBuy()
			end,
			Subtitle = function()
				return PoolStarterPackCard.FormatDeadline(PoolStarterPackCard.GetTimeLeft())
			end,
			OnPress = function()
				callback()
			end
		}
	}
end

local function paintDots(data)
	local dots = data.Dots
	local count = #data.Showing

	for _, frame in dots:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	dots.Visible = data.Button.Visible and count > 1

	for i = 1, count do
		local frame = Instance.new("Frame")
		frame.Name = "Dot" .. i

		frame.Size = UDim2.fromScale(1, 1)
		frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = i == data.Index and 0 or 0.6
		frame.ZIndex = dots.ZIndex
		frame.LayoutOrder = i
		frame.Parent = dots

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = frame
	end
end

local function pulse(p)
	p.Scale.Scale = 0.9

	TweenService:Create(p.Scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function paint(data)
	local v2 = data.Showing[data.Index]

	if not v2 then
		return
	end

	PoolButtonSkin.SetColour(data.Button, v2.Colour)

	if data.BevelStroke then
		data.BevelStroke.Color = v2.Colour:Lerp(Color3.new(0, 0, 0), 0.55)
	end

	data.Top.Text = v2.Title

	local success, result = pcall(v2.Subtitle)

	PoolPriceTag.SetText(data.Bottom, (not success or typeof(result) ~= "string") and "" or result)
end

local function refresh(result)
	local v2 = result.Showing[result.Index]
	local offers = {}
	local v3 = false

	for _, offer in result.Offers do
		local success, result2 = pcall(offer.IsShown)

		if not (success and result2) then
			continue
		end

		table.insert(offers, offer)
		v3 = v3 or offer.Sellable
	end

	local v4 = #offers ~= #result.Showing

	if not v4 then
		for k, v5 in offers do
			if result.Showing[k] ~= v5 then
				v4 = true
				break
			end
		end
	end

	result.Showing = offers
	result.Button.Visible = false

	if not result.Button.Visible then
		result.Dots.Visible = false

		return
	end

	if v4 then
		result.Index = math.max(table.find(offers, v2) or 1, 1)
		paintDots(result)
	end

	paint(result)
end

local function turnOver(result) -- 1 equivalent call inferred from this helper
	if #result.Showing <= 1 then
		return
	end

	result.Index = result.Index % #result.Showing + 1

	paintDots(result)
	paint(result)
	pulse(result)
end

local PoolOfferCarousel = {}

function PoolOfferCarousel.new(parent, callback)
	local maid = Maid.new()
	local offers = parent:WaitForChild("FreeCoins"):Clone()
	offers.Name = "Offers"
	offers.Visible = false
	offers.Parent = parent
	maid:GiveTask(offers)

	local top = offers:WaitForChild("Top")
	local bottom = offers:WaitForChild("Bottom")
	PoolPriceTag.Attach(bottom)

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = offers

	local uiGradient = offers:FindFirstChildOfClass("UIGradient")

	if uiGradient then
		uiGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 165))
	end

	local bevel = offers:FindFirstChild("Bevel")
	local uiStroke = bevel and bevel:FindFirstChildOfClass("UIStroke")

	local zIndex = offers.ZIndex

	for _, guiObject in offers:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			zIndex = math.max(zIndex, guiObject.ZIndex)
		end
	end

	local offerDots = Instance.new("Frame")
	offerDots.Name = "OfferDots"
	offerDots.AnchorPoint = Vector2.new(0.5, 0)
	offerDots.Position = UDim2.new(
		offers.Position.X.Scale + offers.Size.X.Scale * (0.5 - offers.AnchorPoint.X),
		offers.Position.X.Offset,
		offers.Position.Y.Scale + offers.Size.Y.Scale * (1 - offers.AnchorPoint.Y),
		offers.Position.Y.Offset + 5
	)

	offerDots.Size = UDim2.new(offers.Size.X.Scale, 0, 0, 8)
	offerDots.BackgroundTransparency = 1
	offerDots.Visible = false
	offerDots.ZIndex = zIndex + 1
	offerDots.Parent = parent
	maid:GiveTask(offerDots)

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 6)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = offerDots

	local result = {
		Button = offers,
		Top = top,
		Bottom = bottom,
		Scale = uiScale,
		Dots = offerDots,
		BevelStroke = uiStroke,
		Offers = buildOffers(callback),
		Showing = {},
		Index = 1,
		NextTurnAt = os.clock() + 4,
		Maid = maid
	}

	maid:GiveTask(offers.Activated:Connect(function()
		local v2 = result.Showing[result.Index]

		if not v2 then
			return
		end

		pulse(result)

		result.NextTurnAt = os.clock() + 8

		task.spawn(v2.OnPress)
	end))

	task.spawn(function()
		local success, result2 = pcall(function()
			return MarketplaceService:GetProductInfoAsync(POOL_WORLD_PASS_INFO.gamepassId, Enum.InfoType.GamePass)
		end)

		if success and result2 and typeof(result2.PriceInRobux) == "number" then
			v = result2.PriceInRobux
		end
	end)

	local flag = true

	maid:GiveTask(function()
		flag = false
	end)

	task.spawn(function()
		while flag do
			refresh(result)

			if os.clock() >= result.NextTurnAt then
				result.NextTurnAt = os.clock() + 4
				turnOver(result) -- inferred equivalent call
			end

			task.wait(0.5)
		end
	end)

	refresh(result)

	return result
end

function PoolOfferCarousel:Destroy()
	self.Maid:DoCleaning()
end

return PoolOfferCarousel