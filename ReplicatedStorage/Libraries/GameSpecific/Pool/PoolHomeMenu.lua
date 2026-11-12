local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PoolCarousel = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolCarousel)
local PoolMenuWidgets = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMenuWidgets)
require(script.Parent.PoolButtonSkin)
local PoolStatsPopup = require(script.Parent.PoolStatsPopup)
local PoolStreakBadge = require(script.Parent.PoolStreakBadge)
local PoolVip = require(script.Parent.PoolVip)
local Events = require(ReplicatedStorage.Libraries.Modules.Events)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)

local v = {
	CoinsLabel = "Coins.Amount",
	CashLabel = "Gems.Amount",
	NameLabel = "Profile.PlayerName",
	LevelLabel = "Profile.LevelBadge.Level",
	LevelFill = "Profile.LevelBar.Fill",
	Avatar = "Profile.Avatar",
	PlayRow = "PlayRow",
	OneOnOne = "PlayRow.OneOnOne",
	WithFriends = "PlayRow.WithFriends",
	Bots = "PlayRow.Bots",
	Solo = "PlayRow.Solo",
	Trickshot = "PlayRow.Trickshot",
	NineBall = "PlayRow.NineBall",
	InventoryCard = "PlayRow.InventoryCard",
	ShopCard = "PlayRow.ShopCard",
	SeasonCard = "PlayRow.SeasonCard",
	Previous = "Previous",
	Next = "Next",
	Shop = "Shop",
	FreeCoins = "FreeCoins",
	Settings = "Settings",
	SeasonTimer = "PlayRow.SeasonCard.TimeLeft",
	SeasonKey = "SeasonKey",
	ProfileButton = "Profile.StatsButton"
}

local v2 = {
	"Season",
	"OneOnOne",
	"Inventory",
	"Trickshot",
	"NineBall",
	"WithFriends",
	"Bots",
	"Solo",
	"Shop"
}

local v3 = { Inventory = "InventoryCard", Shop = "ShopCard", Season = "SeasonCard" }

local function bind(homeMenu, value: string)
	local child = homeMenu

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolHomeMenu: %s.%s is missing (looking for %q)",
					homeMenu:GetFullName(),
					value,
					childName
				),
				2
			)
		end
	end

	return child
end

local PoolHomeMenu = {}

function PoolHomeMenu.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local homeMenu = instance:WaitForChild("HomeMenu")
	homeMenu.Visible = false

	local v4 = {}

	for k, v5 in v do
		v4[k] = bind(homeMenu, v5)
	end

	local function announce(p: string) -- 3 equivalent calls inferred from this helper
		return function()
			bindableEvent:Fire(p)
		end
	end

	for _, v5 in { "FreeCoins", "Settings", "Shop" } do
		maid:GiveTask(v4[v5].Activated:Connect(announce(v5))) -- inferred equivalent call
	end

	local seasonKey = v4.SeasonKey
	local top = seasonKey:FindFirstChild("Top")

	local function labelSeasonKey() -- 1 equivalent call inferred from this helper
		local success, seasonName = pcall(Events.GetSeasonName, Events)

		if success and typeof(seasonName) == "string" and seasonName ~= "" and top and top:IsA("TextLabel") then
			top.Text = string.upper(seasonName)
		end
	end

	labelSeasonKey() -- inferred equivalent call
	maid:GiveTask(Events.Changed:Connect(labelSeasonKey))
	maid:GiveTask(seasonKey.Activated:Connect(announce("Season"))) -- inferred equivalent call

	local profileButton = v4.ProfileButton
	local pressScale = v4.ProfileButton.Parent:FindFirstChild("PressScale")

	maid:GiveTask(profileButton.Activated:Connect(announce("Profile"))) -- inferred equivalent call

	if pressScale and pressScale:IsA("UIScale") then
		maid:GiveTask(PoolStatsPopup.PressFeedback(profileButton, pressScale))
	end

	local zIndex = seasonKey.ZIndex

	for _, guiObject in seasonKey:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			zIndex = math.max(zIndex, guiObject.ZIndex)
		end
	end

	PoolMenuWidgets.Sparkles(seasonKey, Color3.fromRGB(255, 255, 255), zIndex + 1)

	local playRow = v4.PlayRow
	local carousel = PoolCarousel.new(playRow, {
		CardWidth = 0.4,
		CardHeight = 1.2,
		CardStep = 0.39,
		Shrink = 0.25,
		ShrinkY = 1 / 6
	})

	maid:GiveTask(function()
		PoolCarousel.Destroy(carousel)
	end)

	local v5 = {}

	for _, v6 in v2 do
		local v7 = v4[v3[v6] or v6]
		table.insert(v5, v7)

		maid:GiveTask(v7.Activated:Connect(function()
			if PoolCarousel.IsTapSuppressed(carousel) then
				return
			end

			if PoolCarousel.GetKey(carousel) == v6 then
				bindableEvent:Fire(v6)
			else
				PoolCarousel.FocusKey(carousel, v6)
			end
		end))
	end

	PoolCarousel.SetCards(carousel, v5, table.clone(v2))

	maid:GiveTask(carousel.Accepted:Connect(function(_, p: string?)
		if p then
			bindableEvent:Fire(p)
		end
	end))

	local previous = v4.Previous
	local nextNode = v4.Next

	local function refreshArrows() -- 1 equivalent call inferred from this helper
		previous.Visible = carousel.Index > 1
		nextNode.Visible = carousel.Index < #carousel.Cards
	end

	for k, v6 in { [previous] = -1, [nextNode] = 1 } do
		maid:GiveTask(k.Activated:Connect(function()
			PoolCarousel.Step(carousel, v6)
		end))
	end

	maid:GiveTask(carousel.Changed:Connect(refreshArrows))
	PoolCarousel.SetIndex(carousel, table.find(v2, "OneOnOne") or 1, true)

	local seasonCard = v4.SeasonCard
	local effects = Instance.new("Frame")
	effects.Name = "Effects"
	effects.BackgroundTransparency = 1
	effects.Size = UDim2.fromScale(1, 1)
	effects.ZIndex = 44
	effects.Parent = seasonCard
	maid:GiveTask(effects)

	local uiCorner = seasonCard:FindFirstChildWhichIsA("UICorner")
	local effect = UserInterfaceHelper.Effect("Shine")
	local effect2 = UserInterfaceHelper.Effect("YellowSparkles")

	if effect2 then
		local v6 = effect2.new(effects)

		maid:GiveTask(function()
			effect2.Destroy(v6)
		end)
	end

	if effect then
		local thread = task.spawn(function()
			while true do
				if UserInterfaceHelper:IsVisible(seasonCard) then
					local v6 = effect.new(effects)
					local shine = v6 and v6.maid and v6.maid.shine

					if shine and uiCorner then
						local clone = uiCorner:Clone()
						clone.Parent = shine
					end
				end

				task.wait(3.5)
			end
		end)

		maid:GiveTask(function()
			task.cancel(thread)
		end)
	end

	refreshArrows() -- inferred equivalent call
	local sunburst = homeMenu:FindFirstChild("Sunburst")

	if sunburst then
		local tween = TweenService:Create(
			sunburst,
			TweenInfo.new(60, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
			{ Rotation = 8 }
		)

		tween:Play()
		maid:GiveTask(function()
			tween:Cancel()
		end)
	end

	local seasonTimer = v4.SeasonTimer

	local function drawSeasonTimer()
		local success, result = pcall(function()
			return Events:TimeLeft()
		end)

		if not success or typeof(result) ~= "number" or result > 31536000 then
			seasonTimer.Visible = false

			return
		end

		seasonTimer.Visible = true
		seasonTimer.Text = not (result > 0) and "SEASON ENDED"
			or "ENDS IN " .. NumberHelper.FormatTimerCountdown(result)
	end

	drawSeasonTimer()

	local thread = task.spawn(function()
		while true do
			task.wait(1)
			drawSeasonTimer()
		end
	end)

	maid:GiveTask(function()
		task.cancel(thread)
	end)

	return {
		Root = homeMenu,
		CoinsLabel = v4.CoinsLabel,
		CashLabel = v4.CashLabel,
		NameLabel = v4.NameLabel,
		LevelLabel = v4.LevelLabel,
		LevelFill = v4.LevelFill,
		Avatar = v4.Avatar,
		OneOnOne = v4.OneOnOne,
		WithFriends = v4.WithFriends,
		Bots = v4.Bots,
		Solo = v4.Solo,
		Trickshot = v4.Trickshot,
		NineBall = v4.NineBall,
		InventoryCard = v4.InventoryCard,
		ShopCard = v4.ShopCard,
		SeasonCard = v4.SeasonCard,
		PlayRow = playRow,
		Previous = previous,
		Next = nextNode,
		Carousel = carousel,
		Shop = v4.Shop,
		FreeCoins = v4.FreeCoins,
		Settings = v4.Settings,
		SeasonTimer = seasonTimer,
		SeasonKey = seasonKey,
		ProfileButton = profileButton,
		Selected = bindableEvent.Event,
		Maid = maid
	}
end

function PoolHomeMenu.SetVisible(p, visible: boolean)
	p.Root.Visible = visible

	if visible then
		PoolCarousel.Relayout(p.Carousel)
	end
end

function PoolHomeMenu.SetCurrency(p, p2: number, p3: number)
	p.CoinsLabel.Text = NumberHelper:Separate((math.round(p2)))
	p.CashLabel.Text = NumberHelper:Separate((math.round(p3)))
end

function PoolHomeMenu.SetPlayer(p, p2: string, value: string?, flag: boolean?)
	PoolVip.Apply(p.NameLabel, p2, flag)
	p.Avatar.Image = value or ""
end

function PoolHomeMenu.SetWinStreak(p, p2: number?)
	PoolStreakBadge.Set(p.Avatar, p2, "BottomRight")
end

function PoolHomeMenu.SetLevel(p, p2: number, value: number)
	p.LevelLabel.Text = tostring(p2)

	TweenService:Create(p.LevelFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(math.clamp(value, 0, 1), 1)
	}):Play()
end

function PoolHomeMenu.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolHomeMenu