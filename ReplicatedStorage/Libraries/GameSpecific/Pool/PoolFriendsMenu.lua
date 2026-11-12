local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)
local PoolStreakBadge = require(script.Parent.PoolStreakBadge)
local PoolVip = require(script.Parent.PoolVip)

local PoolFriendsMenu = {}

local Menu = PoolConstants.Menu
local LocalPlayer = Players.LocalPlayer

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolFriendsMenu: %s.%s is missing (looking for %q)",
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

local function bindSection(p, p2: string)
	local root = bind(p, p2)
	local grid = bind(root, "Grid")

	return {
		Root = root,
		Grid = grid,
		Layout = bind(grid, "UIGridLayout"),
		Heading = bind(root, "Header.Heading"),
		Count = bind(root, "Header.Count"),
		Empty = bind(root, "Empty"),
		Cards = {}
	}
end

local function bindCard(card)
	return {
		Root = card,
		Avatar = bind(card, "Avatar"),
		Level = bind(card, "Avatar.LevelBadge.Level"),
		Name = bind(card, "PlayerName"),
		Coins = bind(card, "Coins.Amount"),
		Status = bind(card, "Status"),
		Challenge = bind(card, "Challenge"),
		UserId = 0,
		DisplayName = "",
		Vip = false
	}
end

function PoolFriendsMenu.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")

	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)
	maid:GiveTask(bindableEvent3)

	local friendsMenu = instance:WaitForChild("FriendsMenu")
	friendsMenu.Visible = false

	local scroll = bind(friendsMenu, "Scroll")
	local template = bind(friendsMenu, "CardTemplate")

	local venueStrip = friendsMenu:FindFirstChild("VenueStrip")

	if venueStrip and venueStrip:IsA("GuiObject") then
		venueStrip.Visible = false
	end

	local v = {
		Root = friendsMenu,
		Scroll = scroll,
		Template = template,
		Friends = bindSection(scroll, "FriendsSection"),
		Others = bindSection(scroll, "ServerSection"),
		CoinsLabel = bind(friendsMenu, "Coins.Amount"),
		Back = bind(friendsMenu, "Back"),
		Invite = bind(friendsMenu, "Invite"),
		Challenged = bindableEvent.Event,
		ChallengeBindable = bindableEvent,
		InviteRequested = bindableEvent2.Event,
		InviteBindable = bindableEvent2,
		Closed = bindableEvent3.Event,
		CloseBindable = bindableEvent3,
		Maid = maid
	}

	maid:GiveTask(v.Back.Activated:Connect(function()
		bindableEvent3:Fire()
	end))

	maid:GiveTask(v.Invite.Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	maid:GiveTask(scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		PoolFriendsMenu.Reflow(v)
	end))

	PoolFriendsMenu.Reflow(v)

	return v
end

function PoolFriendsMenu.Reflow(data)
	local x = data.Scroll.AbsoluteSize.X

	if x <= 0 then
		return
	end

	local function cellWidth(p: number) -- 2 equivalent calls inferred from this helper
		return (x - (p - 1) * 10) / p
	end

	local v = math.clamp(math.round((x + 10) / 210), 2, 10)

	while v > 2 and cellWidth(v) < 108 do -- inferred equivalent call
		v -= 1
	end

	local v2 = math.floor(cellWidth(v)) -- inferred equivalent call
	local udim = UDim2.fromOffset(v2, (math.floor(v2 / 0.74)))

	for _, v3 in { data.Friends, data.Others } do
		v3.Layout.CellSize = udim
		v3.Layout.CellPadding = UDim2.fromOffset(10, 10)
	end
end

local function cardAt(data, data2, k: number)
	local card = data2.Cards[k]

	if card then
		return card
	end

	local card2 = data.Template:Clone()
	card2.Name = "Card"
	card2.Visible = false
	card2.Parent = data2.Grid
	data.Maid:GiveTask(card2)

	local v = bindCard(card2)

	data.Maid:GiveTask(v.Challenge.Activated:Connect(function()
		if v.UserId ~= 0 then
			data.ChallengeBindable:Fire(v.UserId, v.DisplayName, v.Vip)
		end
	end))

	data2.Cards[k] = v

	return v
end

local function fillCard(state, player)
	local userId = tonumber(player.UserId) or 0
	local displayName = tostring(player.DisplayName or player.Name or "Player")

	state.UserId = userId
	state.DisplayName = displayName
	state.Vip = player.Vip == true
	state.Avatar.Image = PoolPlayerData.Thumbnail(userId)

	PoolVip.Apply(state.Name, displayName, state.Vip)
	state.Level.Text = tostring((math.max(tonumber(player.Level) or 1, 1)))
	state.Coins.Text = NumberHelper:Separate((math.round(tonumber(player.Coins) or 0)))

	PoolStreakBadge.Set(state.Avatar, tonumber(player.WinStreak), "BottomLeft")

	local busy = player.Busy == true

	state.Status.Text = busy and "In a game" or "Available"
	local status = state.Status
	local textColor

	if busy then
		textColor = Color3.fromRGB(248, 172, 88)
	else
		textColor = Color3.fromRGB(126, 226, 118)
	end

	status.TextColor3 = textColor

	state.Challenge.Active = not busy
	state.Challenge.AutoButtonColor = not busy
	local setColour = PoolButtonSkin.SetColour
	local challenge = state.Challenge
	local v

	if busy then
		v = Menu.PlayOffline:Lerp(Color3.fromRGB(255, 255, 255), 1)
	else
		v = Menu.PlayPrimary
	end

	setColour(challenge, v)

	local top = state.Challenge:FindFirstChild("Top")

	if top and top:IsA("TextLabel") then
		top.Text = busy and "PLAYING" or "CHALLENGE"
	end

	state.Root.Visible = true
end

local function fillSection(p, data, list)
	for k, item in list do
		fillCard(cardAt(p, data, k), item)
	end

	for i = #list + 1, #data.Cards do
		local card = data.Cards[i]
		card.Root.Visible = false

		card.UserId = 0
	end

	data.Count.Text = tostring(#list)

	data.Grid.Visible = #list > 0
	data.Empty.Visible = #list == 0
end

function PoolFriendsMenu.SetRoster(p, items, p2)
	local v = {}
	local v2 = {}

	for _, item in items do
		local userId = tonumber(item.UserId) or 0

		if not (userId ~= 0 and userId ~= LocalPlayer.UserId) then
			continue
		end

		local v3 = if p2[userId] then v else v2
		table.insert(v3, item)
	end

	local function order(p3, p4)
		local busy = p3.Busy == true
		local busy2 = p4.Busy == true

		if busy == busy2 then
			return (tonumber(p3.Level) or 1) > (tonumber(p4.Level) or 1)
		end

		return busy2
	end

	table.sort(v, order)
	table.sort(v2, order)

	fillSection(p, p.Friends, v)
	fillSection(p, p.Others, v2)
end

function PoolFriendsMenu.SetCoins(p, p2: number)
	p.CoinsLabel.Text = NumberHelper:Separate((math.round(p2)))
end

function PoolFriendsMenu.SetVisible(p, visible: boolean)
	p.Root.Visible = visible

	if visible then
		PoolFriendsMenu.Reflow(p)
	end
end

function PoolFriendsMenu.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolFriendsMenu