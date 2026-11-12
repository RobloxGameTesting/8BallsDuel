local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolCommunity = require(Pool.PoolCommunity)
local PoolConstants = require(Pool.PoolConstants)
local PoolTrickshotCodes = require(Pool.PoolTrickshotCodes)

local Menu = PoolConstants.Menu
local Competition = Menu.Competition
local PlayOffline = Menu.PlayOffline
local color = Color3.fromRGB(255, 92, 110)
local color2 = Color3.new(1, 1, 1)

local v = {
	Bullseye = "◎ BULLSEYE",
	Bubble = "● GOLDEN BUBBLES",
	Pocket = "◉ POCKET THE GOLD",
	None = "TRICKSHOT"
}

local v2 = nil
local PoolCommunityMenu = {}

function PoolCommunityMenu.TakePending(p: string)
	local v3 = v2

	if not v3 or v3.Code ~= p then
		return nil
	end

	v2 = nil

	return v3
end

local v3 = {}

local function pageKey(sort: string, p: number) -- 3 equivalent calls inferred from this helper
	return string.format("%s:%d", sort, p)
end

local function signature(p)
	local v4 = table.create(#p.Items + 1)
	table.insert(v4, (tostring(p.Pages)))

	for _, item in p.Items do
		table.insert(
			v4,
			string.format(
				"%s|%s|%s|%s|%s|%s|%s|%s|%s|%s",
				item.Code,
				item.Name,
				item.AuthorName,
				item.Kind,
				tostring(item.Plays),
				tostring(item.Clears),
				tostring(item.Favourites),
				item.Favourited and "1" or "0",
				tostring(item.Published),
				(tostring(item.Updated))
			)
		)
	end

	return table.concat(v4, "\n")
end

local function rememberFavourite(p: string, favourited: boolean, favourites: number?)
	local v4 = nil

	for k, v5 in v3 do
		local v6 = string.sub(k, 1, 5) == "Mine:"

		for i = #v5.Items, 1, -1 do
			local item = v5.Items[i]

			if item.Code ~= p then
				continue
			end

			item.Favourited = favourited

			if favourites then
				item.Favourites = favourites
			end

			v4 = v4 or item

			if not v6 or favourited then
				continue
			end

			table.remove(v5.Items, i)
		end
	end

	local v5 = v3[pageKey("Mine", 1)] -- inferred equivalent call

	if favourited and v4 and v5 then
		for _, item in v5.Items do
			if item.Code == p then
				return
			end
		end

		table.insert(v5.Items, 1, table.clone(v4))

		if #v5.Items > PoolCommunity.PageSize then
			table.remove(v5.Items)
		end
	end
end

local function need(communityMenu, value: string)
	local child = communityMenu

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolCommunityMenu: %s.%s is missing (looking for %q)",
					communityMenu:GetFullName(),
					value,
					childName
				),
				2
			)
		end
	end

	return child
end

local function setText(button, text: string)
	local top = button:FindFirstChild("Top")

	if top and top:IsA("TextLabel") then
		top.Text = text
	elseif button:IsA("TextButton") then
		button.Text = text
	end
end

local function paintTabs(p)
	for k, tab in p.Tabs do
		local v4 = k == p.Sort

		if PoolButtonSkin.IsSkinned(tab) then
			local setColour = PoolButtonSkin.SetColour
			local v5 = if v4 then Competition else PlayOffline
			setColour(tab, v5)
		else
			local backgroundColor

			if v4 then
				backgroundColor = Competition
			else
				backgroundColor = PlayOffline
			end

			tab.BackgroundColor3 = backgroundColor
		end
	end
end

local function setStat(guiObject, image: string, p: string, text: string, color3: Color3?)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local icon = guiObject:FindFirstChild("Icon")
	local count = guiObject:FindFirstChild("Count")
	local visible = image ~= ""

	if icon then
		icon.Image = image
		icon.Visible = visible
	end

	if count then
		guiObject = count
	elseif not (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
		guiObject = nil
	end

	if guiObject then
		if not (visible and icon) then
			text = p .. " " .. text
		end

		guiObject.Text = text
		guiObject.TextColor3 = color3 or Color3.new(1, 1, 1)
	end

	if count then
		local position

		if visible and icon then
			position = UDim2.new(0.94, 0, 0.53, 0)
		else
			position = UDim2.new(0.5, 0, 0.53, 0)
		end

		count.Position = position
		local anchorPoint

		if visible and icon then
			anchorPoint = Vector2.new(1, 0.5)
		else
			anchorPoint = Vector2.new(0.5, 0.5)
		end

		count.AnchorPoint = anchorPoint
		local size

		if visible and icon then
			size = UDim2.fromScale(0.52, 0.8)
		else
			size = UDim2.fromScale(0.9, 0.8)
		end

		count.Size = size
	end
end

local function paintHeart(instance, flag: boolean, count: number)
	local favourite = instance:FindFirstChild("Favourite", true)

	if favourite and favourite:IsA("GuiButton") then
		local icons = PoolCommunity.Icons
		local v4

		if flag then
			v4 = icons.Heart
		elseif icons.HeartOff == "" then
			v4 = icons.Heart
		else
			v4 = icons.HeartOff
		end

		local short = PoolCommunity.Short(count)
		local v5 = if flag then color else color2
		setStat(favourite, v4, "♥", short, v5)
		favourite:SetAttribute("Count", count)

		local icon = favourite:FindFirstChild("Icon")

		if icon then
			icon.ImageTransparency = (flag or icons.HeartOff ~= "") and 0 or 0.5
		end
	end
end

local function clearCards(p) -- 3 equivalent calls inferred from this helper
	p.CardMaid:DoCleaning()

	for _, card in p.CardsByCode do
		card:Destroy()
	end

	table.clear(p.CardsByCode)
end

local function notice(p, text: string)
	local now = os.clock()

	p.Status.Text = text
	p.Status.Visible = true
	p.Status:SetAttribute("NoticeToken", now)

	task.delay(2.5, function()
		if p.Status:GetAttribute("NoticeToken") == now and next(p.CardsByCode) ~= nil then
			p.Status.Visible = false
		end
	end)
end

local function requestPlay(p, awaiting: string, p2: string?)
	if p.Awaiting then
		return
	end

	p.Awaiting = awaiting
	PoolAudio.PlayCue("MenuOpen")
	local v4

	if p2 then
		v4 = string.format("Loading %s...", p2)
	else
		v4 = "Loading " .. PoolTrickshotCodes.Format(awaiting) .. "..."
	end

	notice(p, v4)
	RemoteSignals.FireServer(RemoteEnums.Pool, "CommunityPlay", awaiting)

	task.delay(8, function()
		if p.Awaiting == awaiting then
			p.Awaiting = nil
			notice(p, "Couldn't reach the trickshot list, try again")
		end
	end)
end

local function request(state) -- 5 equivalent calls inferred from this helper
	state.Request += 1
	RemoteSignals.FireServer(RemoteEnums.Pool, "CommunityBrowse", state.Page, state.Sort)
end

local function drawCard(data, data2, layoutOrder: number)
	local clone = data.Template:Clone()
	clone.Name = "Card_" .. data2.Code
	clone.LayoutOrder = layoutOrder
	clone.Visible = true

	local trickName = clone:FindFirstChild("TrickName", true)
	local author = clone:FindFirstChild("Author", true)
	local kind = clone:FindFirstChild("Kind", true)
	local plays = clone:FindFirstChild("Plays", true)
	local clears = clone:FindFirstChild("Clears", true)
	local favourite = clone:FindFirstChild("Favourite", true)
	local play = clone:FindFirstChild("Play")

	if trickName then
		trickName.Text = data2.Name
	end

	if author then
		author.Text = "by " .. data2.AuthorName
	end

	if kind then
		kind.Text = v[data2.Kind] or "TRICKSHOT"
	end

	setStat(plays, PoolCommunity.Icons.Play, "▶", PoolCommunity.Short(data2.Plays))
	setStat(clears, PoolCommunity.Icons.Check, "✓", PoolCommunity.Short(data2.Clears))

	local date = clone:FindFirstChild("Date")

	if date and date.Visible then
		local date2 = PoolCommunity.Date(data2.Published)
		local date3 = PoolCommunity.Date(data2.Updated)
		local text

		if data2.Updated > data2.Published + 60 and date3 ~= date2 then
			text = string.format("CREATED %s  •  UPDATED %s", date2, date3)
		else
			text = "CREATED " .. date2
		end

		date.Text = text
	end

	data.Favourited[data2.Code] = data2.Favourited
	paintHeart(clone, data2.Favourited, data2.Favourites)
	clone.Parent = data.Cards
	data.CardsByCode[data2.Code] = clone

	if favourite then
		data.CardMaid:GiveTask(favourite.Activated:Connect(function()
			local favourited = not data.Favourited[data2.Code]
			local favourites = math.max((favourite:GetAttribute("Count") or 0) + (favourited and 1 or -1), 0)
			data.Favourited[data2.Code] = favourited
			paintHeart(clone, favourited, favourites)
			rememberFavourite(data2.Code, favourited, favourites)
			PoolAudio.PlayCue("MenuOpen")

			local uiScale = favourite:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
			uiScale.Parent = favourite
			uiScale.Scale = 1.25
			TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = 1 }):Play()

			RemoteSignals.FireServer(RemoteEnums.Pool, "CommunityFavourite", data2.Code, favourited)
		end))
	end

	if play then
		data.CardMaid:GiveTask(play.Activated:Connect(function()
			requestPlay(data, data2.Code, data2.Name)
		end))
	end
end

local function drawPage(state, items, pages: number, flag: boolean)
	clearCards(state) -- inferred equivalent call
	state.Pages = pages
	state.PageLabel.Text = string.format("PAGE %d / %d", state.Page, state.Pages)
	state.Prev.Visible = state.Page > 1
	state.Next.Visible = state.Page < state.Pages

	for k, item in items do
		drawCard(state, item, k)
	end

	if state.Awaiting then
		return
	end

	if #items > 0 then
		state.Status.Visible = false
		return
	end

	if flag then
		state.Status.Text = "Loading..."
	else
		state.Status.Text = state.Sort == "Mine" and "Tap the ♥ on a trickshot to keep it here"
			or "No trickshots yet — clear one of yours and publish it!"
	end

	state.Status.Visible = true
end

local function showCurrent(data) -- 4 equivalent calls inferred from this helper
	local v4 = v3[pageKey(data.Sort, data.Page)] -- inferred equivalent call

	if v4 then
		drawPage(data, v4.Items, v4.Pages, false)
		return
	end

	clearCards(data) -- inferred equivalent call
	data.Status.Text = "Loading..."
	data.Status.Visible = true
end

local function onPage(data, data2)
	if typeof(data2) ~= "table" or not table.find(PoolCommunity.Sorts, data2.Sort) then
		return
	end

	local v4 = math.max(1, (math.floor(tonumber(data2.Page) or 1)))
	local v5 = pageKey(data2.Sort, v4) -- inferred equivalent call
	local v6

	if data2.Sort == data.Sort then
		v6 = v4 == data.Page
	else
		v6 = false
	end

	local items = {}

	for _, v7 in typeof(data2.Items) ~= "table" and {} or data2.Items do
		local v8 = PoolCommunity.SanitizeCard(v7)

		if v8 then
			table.insert(items, v8)
		end
	end

	local v7 = {
		Items = items,
		Pages = math.max(1, (math.floor(tonumber(data2.Pages) or 1)))
	}
	local v8 = v3[v5]

	if data2.Busy then
		if v6 and not v8 then
			drawPage(data, v7.Items, v7.Pages, true)
		end
	else
		v3[v5] = v7

		if v6 and (not v8 or signature(v8) ~= signature(v7)) then
			drawPage(data, v7.Items, v7.Pages, false)
		end
	end

	if data2.Busy and v6 then
		local request2 = data.Request

		task.delay(2.5, function()
			if data.Root.Visible and data.Request == request2 then
				request(data) -- inferred equivalent call
			end
		end)
	end
end

function PoolCommunityMenu.new(instance)
	local maid = Maid.new()
	local cardMaid = Maid.new()
	maid:GiveTask(cardMaid)

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)

	local communityMenu = instance:WaitForChild("CommunityMenu")
	communityMenu.Visible = false

	local template = need(communityMenu, "CardTemplate")
	template.Visible = false

	local tabs = {}

	for _, sort in PoolCommunity.Sorts do
		tabs[sort] = need(communityMenu, "Tabs.Tab_" .. sort)
	end

	local v4 = {
		Root = communityMenu,
		Cards = need(communityMenu, "Cards"),
		Template = template,
		Status = need(communityMenu, "Status"),
		PageLabel = need(communityMenu, "Pager.Page"),
		Prev = need(communityMenu, "Pager.Prev"),
		Next = need(communityMenu, "Pager.Next"),
		Tabs = tabs,
		Sort = "Favourites",
		Page = 1,
		Pages = 1,
		Request = 0,
		CardsByCode = {},
		Favourited = {},
		PlayRequested = bindableEvent.Event,
		PlayBindable = bindableEvent,
		Closed = bindableEvent2.Event,
		CloseBindable = bindableEvent2,
		CardMaid = cardMaid,
		Maid = maid,
		CodeBox = communityMenu:FindFirstChild("Input", true),
		Awaiting = nil
	}

	local playCode = communityMenu:FindFirstChild("PlayCode")

	local function playTyped() -- 1 equivalent call inferred from this helper
		local codeBox = v4.CodeBox

		if not codeBox then
			return
		end

		local normalise = PoolTrickshotCodes.Normalise(codeBox.Text)

		if normalise then
			requestPlay(v4, normalise, nil)
		else
			notice(v4, codeBox.Text == "" and "Type a trickshot's code first" or "That code isn't valid")
		end
	end

	if playCode then
		maid:GiveTask(playCode.Activated:Connect(playTyped))
	end

	if v4.CodeBox then
		maid:GiveTask(v4.CodeBox.FocusLost:Connect(function(flag: boolean)
			if flag then
				playTyped() -- inferred equivalent call
			end
		end))
	end

	maid:GiveTask(need(communityMenu, "Back").Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	for k, v5 in tabs do
		maid:GiveTask(v5.Activated:Connect(function()
			if v4.Sort == k then
				return
			end

			v4.Sort = k
			v4.Page = 1
			paintTabs(v4)
			showCurrent(v4) -- inferred equivalent call
			request(v4) -- inferred equivalent call
		end))
	end

	maid:GiveTask(v4.Prev.Activated:Connect(function()
		if v4.Page > 1 then
			v4.Page -= 1
			showCurrent(v4) -- inferred equivalent call
			request(v4) -- inferred equivalent call
		end
	end))

	maid:GiveTask(v4.Next.Activated:Connect(function()
		if v4.Page < v4.Pages then
			v4.Page += 1
			showCurrent(v4) -- inferred equivalent call
			request(v4) -- inferred equivalent call
		end
	end))

	maid:GiveTask(RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
		if p == "CommunityPage" then
			onPage(v4, ...)
		elseif p == "CommunityFavourited" then
			local v5, v6, v7 = ...
			local v8

			if typeof(v5) == "string" then
				v8 = v4.CardsByCode[v5]
			end

			if typeof(v5) == "string" then
				rememberFavourite(v5, v6 == true, tonumber(v7))
			end

			if v8 then
				local favourite = v8:FindFirstChild("Favourite", true)

				local count = favourite and favourite:GetAttribute("Count") or 0

				v4.Favourited[v5] = v6 == true
				paintHeart(v8, v6 == true, tonumber(v7) or count)
			end
		elseif p == "CommunityScene" then
			local v5, code, scene, v6 = ...

			if not v4.Awaiting then
				return
			end

			if v5 == true then
				if code ~= v4.Awaiting or typeof(scene) ~= "table" then
					return
				end

				v4.Awaiting = nil
				v2 = { Code = code, Scene = scene, Card = PoolCommunity.SanitizeCard(v6) }

				if v4.CodeBox then
					v4.CodeBox.Text = ""
				end

				v4.PlayBindable:Fire(
					code,
					(typeof(v6) ~= "table" or typeof(v6.Name) ~= "string") and "Trickshot" or v6.Name
				)
			else
				v4.Awaiting = nil
				notice(v4, typeof(code) ~= "string" and "That trickshot couldn't be loaded" or code)
			end
		elseif p == "CommunityNotice" then
			local text = ...

			if typeof(text) == "string" then
				v4.Status.Text = text
				v4.Status.Visible = true

				task.delay(2.5, function()
					if next(v4.CardsByCode) ~= nil then
						v4.Status.Visible = false
					end
				end)
			end
		end
	end))

	paintTabs(v4)

	return v4
end

function PoolCommunityMenu:SetVisible(visible: boolean)
	self.Root.Visible = visible

	if visible then
		paintTabs(self)
		showCurrent(self) -- inferred equivalent call
		request(self) -- inferred equivalent call
	else
		self.Request += 1

		self.Awaiting = nil
	end
end

function PoolCommunityMenu:Destroy()
	clearCards(self) -- inferred equivalent call
	self.Maid:DoCleaning()
end

return PoolCommunityMenu