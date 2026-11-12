local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolGifting = require(Pool.PoolGifting)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolVip = require(Pool.PoolVip)

local PoolGiftPicker = {}

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)

local color = Color3.fromRGB(176, 72, 255)
local color2 = Color3.fromRGB(118, 122, 134)
local color3 = Color3.fromRGB(126, 226, 118)
local color4 = Color3.fromRGB(176, 184, 202)
local color5 = Color3.fromRGB(255, 106, 106)

local v = { OWNED = "OWNED", MAXED = "MAXED", LOADING = "LOADING", UNGIFTABLE = "--" }

local v2 = {
	Built = false,
	Gui = nil,
	List = nil,
	Layout = nil,
	Empty = nil,
	Item = nil,
	Template = nil,
	Cards = {},
	ProductId = nil,
	Answers = nil,
	AskedAt = 0,
	Options = nil,
	Friends = {},
	Maid = Maid.new()
}

local function screen() -- 2 equivalent calls inferred from this helper
	local poolGiftUI = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PoolGiftUI")
		or ReplicatedStorage.UI:FindFirstChild("PoolGiftUI")

	if not poolGiftUI then
		error("[PoolGiftPicker] PoolGiftUI is in neither PlayerGui nor ReplicatedStorage.UI", 2)
	end

	return poolGiftUI
end

local function find(instance, value: string)
	for childName in value:gmatch("[^%.]+") do
		local child = instance:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"[PoolGiftPicker] %s has no %q (looking for %s)",
					instance:GetFullName(),
					childName,
					value
				),
				2
			)
		end

		instance = child
	end

	return instance
end

local function reflow()
	local list = v2.List
	local layout = v2.Layout

	if not (list and layout) then
		return
	end

	local v3 = list.AbsoluteSize.X - list.ScrollBarThickness

	if v3 <= 0 then
		return
	end

	local function cellWidth(p: number) -- 2 equivalent calls inferred from this helper
		return (v3 - (p - 1) * 10) / p
	end

	local v4 = math.clamp(math.round((v3 + 10) / 160), 2, 6)

	while v4 > 2 and cellWidth(v4) < 104 do -- inferred equivalent call
		v4 -= 1
	end

	local v5 = math.floor(cellWidth(v4)) -- inferred equivalent call

	layout.CellSize = UDim2.fromOffset(v5, (math.floor(v5 / 0.74)))
	layout.CellPadding = UDim2.fromOffset(10, 10)
end

local function cardAt(k: number)
	local card = v2.Cards[k]

	if card then
		return card
	end

	local card2 = v2.Template:Clone()
	card2.Name = "Card"
	card2.Visible = false
	card2.Parent = v2.List

	local gift = find(card2, "Gift")
	local top = gift:FindFirstChild("Top")

	local v3 = {
		Root = card2,
		Avatar = find(card2, "Avatar"),
		Name = find(card2, "PlayerName"),
		Status = find(card2, "Status"),
		Gift = gift,
		Top = 0,
		UserId = 0
	}

	if not (top and top:IsA("TextLabel")) then
		top = nil
	end

	v3.Top = top

	gift.Activated:Connect(function()
		PoolGiftPicker.Choose(v3.UserId)
	end)

	v2.Cards[k] = v3

	return v3
end

local function setKey(state, flag: boolean, text: string, color6: Color3) -- 3 equivalent calls inferred from this helper
	state.Gift.Active = flag
	state.Gift.AutoButtonColor = flag
	PoolButtonSkin.SetColour(state.Gift, color6)

	if state.Top then
		state.Top.Text = text
	end
end

local function fillCard(state, player)
	local userId2 = player.UserId
	local v3 = v2.Answers and v2.Answers[tostring(userId2)]

	state.UserId = userId2
	state.Avatar.Image = PoolPlayerData.Thumbnail(userId2)
	PoolVip.Apply(state.Name, player.DisplayName, v3 ~= nil and v3.Vip == true)

	if v2.Friends[userId2] then
		state.Status.Text = "Friend"
		state.Status.TextColor3 = color3
	else
		state.Status.Text = "@" .. player.Name
		state.Status.TextColor3 = color4
	end

	if v3 then
		if v3.Status == "OK" then
			setKey(state, true, "GIFT", color) -- inferred equivalent call
		else
			setKey(state, false, v[v3.Status] or v3.Status, color2) -- inferred equivalent call
		end
	else
		setKey(state, false, "...", color2) -- inferred equivalent call
	end

	state.Root.Visible = true
end

local function recipients()
	local result = {}

	for _, v3 in Players:GetPlayers() do
		if v3 ~= LocalPlayer then
			table.insert(result, v3)
		end
	end

	table.sort(result, function(a, b)
		local v3 = v2.Friends[a.UserId] == true

		if v3 == (v2.Friends[b.UserId] == true) then
			return string.lower(a.DisplayName) < string.lower(b.DisplayName)
		end

		return v3
	end)

	return result
end

local function refresh()
	if not (v2.Built and v2.ProductId) then
		return
	end

	local v3 = recipients()

	for k, v4 in v3 do
		local v5 = cardAt(k)

		v5.Root.LayoutOrder = k
		fillCard(v5, v4)
	end

	for i = #v3 + 1, #v2.Cards do
		local card = v2.Cards[i]

		card.Root.Visible = false

		card.UserId = 0
	end

	v2.List.Visible = #v3 > 0
	v2.Empty.Visible = #v3 == 0
end

local function learnFriend(player) -- 1 equivalent call inferred from this helper
	if v2.Friends[player.UserId] ~= nil or player == LocalPlayer then
		return
	end

	v2.Friends[player.UserId] = false

	task.spawn(function()
		local success, result = pcall(function()
			return LocalPlayer:IsFriendsWith(player.UserId)
		end)

		if success and result then
			v2.Friends[player.UserId] = true

			if PoolGiftPicker.IsOpen() then
				refresh()
			end
		end
	end)
end

local function ask()
	local productId = v2.ProductId

	if not productId then
		return
	end

	v2.AskedAt = os.clock()
	RemoteSignals.FireServer("Gifts", "Eligibility", productId)

	task.delay(3, function()
		if PoolGiftPicker.IsOpen() and v2.ProductId == productId and v2.Answers == nil then
			ask()
		end
	end)
end

local function build()
	if v2.Built then
		return
	end

	local gui = screen() -- inferred equivalent call
	gui.Enabled = false

	v2.Gui = gui
	v2.List = find(gui, "Panel.List")
	v2.Layout = find(gui, "Panel.List.UIGridLayout")
	v2.Empty = find(gui, "Panel.Empty")
	v2.Item = find(gui, "Panel.Item")
	v2.Template = find(gui, "Templates.PlayerCard")

	local v3 = find(gui, "Panel.Exit")
	local v4 = find(gui, "Panel.Empty.Invite")

	v2.Maid:GiveTask(v3.Activated:Connect(function()
		PoolGiftPicker.Close()
	end))

	v2.Maid:GiveTask(v4.Activated:Connect(function()
		pcall(function()
			SocialService:PromptGameInvite(LocalPlayer)
		end)
	end))

	v2.Maid:GiveTask(v2.List:GetPropertyChangedSignal("AbsoluteSize"):Connect(reflow))

	v2.Maid:GiveTask(RemoteSignals.OnClientEvent("Gifts", function(p: string, p2: number, answers)
		if p ~= "Eligibility" or p2 ~= v2.ProductId or typeof(answers) ~= "table" then
			return
		end

		v2.Answers = answers
		refresh()
	end))

	v2.Maid:GiveTask(Players.PlayerAdded:Connect(function(player)
		learnFriend(player) -- inferred equivalent call

		if PoolGiftPicker.IsOpen() then
			refresh()
			ask()
		end
	end))

	v2.Maid:GiveTask(Players.PlayerRemoving:Connect(function()
		if PoolGiftPicker.IsOpen() then
			task.defer(refresh)
		end
	end))

	for _, v5 in Players:GetPlayers() do
		if not (v2.Friends[v5.UserId] == nil and v5 ~= LocalPlayer) then
			continue
		end

		v2.Friends[v5.UserId] = false

		task.spawn(function()
			local success, result = pcall(function()
				return LocalPlayer:IsFriendsWith(v5.UserId)
			end)

			if success and result then
				v2.Friends[v5.UserId] = true

				if PoolGiftPicker.IsOpen() then
					refresh()
				end
			end
		end)
	end

	v2.Built = true
end

function PoolGiftPicker.IsOpen()
	return v2.Gui ~= nil and v2.Gui.Enabled
end

function PoolGiftPicker.Open(productId: number, options): boolean
	if not PoolGifting.IsGiftable(productId) then
		warn("[PoolGiftPicker] product " .. tostring(productId) .. " cannot be gifted")

		return false
	end

	local v3 = false

	pcall(function()
		local Events = require(ReplicatedStorage.Libraries.Modules.Events)

		v3 = Events:IsSeasonProduct(productId) and not Events:IsActive()
	end)

	if v3 then
		Notifications.new("TextNotification", {
			message = "The season has ended, so season items can't be gifted.",
			colour = color5
		})

		return false
	end

	build()

	v2.ProductId = productId
	v2.Answers = nil
	v2.Options = options
	v2.Item.Text = PoolGifting.Title(productId)
	v2.List.CanvasPosition = Vector2.zero
	v2.Gui.Enabled = true

	reflow()
	refresh()
	ask()

	return true
end

function PoolGiftPicker.Close()
	if v2.Gui then
		v2.Gui.Enabled = false
	end

	v2.ProductId = nil
	v2.Answers = nil
	v2.Options = nil
end

function PoolGiftPicker.Choose(p: number)
	local productId = v2.ProductId
	local v3 = v2.Answers and v2.Answers[tostring(p)]

	if not productId or p == 0 or not v3 or v3.Status ~= "OK" then
		return
	end

	if not Players:GetPlayerByUserId(p) then
		refresh()

		return
	end

	local options = v2.Options

	PoolGiftPicker.Close()

	if options and options.OnChosen then
		pcall(options.OnChosen)
	end

	Sales.PromptGift(userId, productId, (tostring(p)))
end

local function hostFor(folder, clone)
	local parent = folder.Parent

	if not folder.ClipsDescendants or not parent or not parent:IsA("GuiObject") or parent:IsA("ScrollingFrame") then
		return folder
	end

	local frame = Instance.new("Frame")
	frame.Name = folder.Name .. "GiftHolder"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = false
	frame.ZIndex = folder.ZIndex

	local function sync() -- 1 equivalent call inferred from this helper
		local v3 = folder.AbsolutePosition - parent.AbsolutePosition

		frame.Position = UDim2.fromOffset(v3.X, v3.Y)
		frame.Size = UDim2.fromOffset(folder.AbsoluteSize.X, folder.AbsoluteSize.Y)
		frame.Visible = folder.Visible
	end

	local connections = {}

	for _, v3 in {
		folder:GetPropertyChangedSignal("AbsolutePosition"),
		folder:GetPropertyChangedSignal("AbsoluteSize"),
		folder:GetPropertyChangedSignal("Visible"),
		parent:GetPropertyChangedSignal("AbsolutePosition")
	} do
		table.insert(connections, v3:Connect(sync))
	end

	local function cleanup()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		if frame.Parent then
			frame:Destroy()
		end
	end

	table.insert(connections, folder.Destroying:Connect(cleanup))
	table.insert(connections, clone.Destroying:Connect(cleanup))
	sync() -- inferred equivalent call
	frame.Parent = parent

	return frame
end

function PoolGiftPicker.Badge(folder, callback, p)
	local clone = find(screen(), "Templates.GiftBadge"):Clone() -- inferred equivalent call

	local zIndex = folder.ZIndex

	for _, guiObject in folder:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			zIndex = math.max(zIndex, guiObject.ZIndex)
		end
	end

	local v3 = zIndex + 1 - clone.ZIndex

	clone.ZIndex += v3

	for _, guiObject in clone:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += v3
		end
	end

	clone.Visible = true
	clone.Parent = hostFor(folder, clone)

	clone.Activated:Connect(function()
		local v4

		if typeof(callback) == "function" then
			v4 = callback()
		else
			v4 = callback
		end

		if typeof(v4) == "number" then
			PoolGiftPicker.Open(v4, p)
		end
	end)

	return clone
end

return PoolGiftPicker