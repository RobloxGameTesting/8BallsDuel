local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolPlayerStats = require(Pool.PoolPlayerStats)
local PoolStreakBadge = require(Pool.PoolStreakBadge)
local PoolVip = require(Pool.PoolVip)

local PoolStatsPopup = {}

local LocalPlayer = Players.LocalPlayer

local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.2)
local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local v = {
	Backdrop = "Backdrop",
	Card = "Card",
	Pop = "Card.Pop",
	Close = "Card.Close",
	Avatar = "Card.Header.Avatar",
	Level = "Card.Header.Avatar.LevelBadge.Level",
	DisplayName = "Card.Header.DisplayName",
	Username = "Card.Header.Username",
	XpFill = "Card.Header.XpBar.Fill",
	MemberSince = "Card.Header.MemberSince",
	Wins = "Card.Hero.Wins.Value",
	Losses = "Card.Hero.Losses.Value",
	Games = "Card.Hero.Games.Value",
	WinRate = "Card.Hero.WinRate.Value",
	WinStreak = "Card.Grid.WinStreak.Value",
	BestStreak = "Card.Grid.BestStreak.Value",
	BallsPotted = "Card.Grid.BallsPotted.Value",
	BreakPots = "Card.Grid.BreakPots.Value",
	Venues = "Card.Grid.Venues.Value",
	Bots = "Card.Grid.Bots.Value",
	Status = "Card.Status"
}

local v2 = nil
local v3 = {}
local backgroundTransparency = 0.4

local count = 0
local selectedObject = nil

local function need(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolStatsPopup: %s.%s is missing (looking for %q)",
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

local function onStatsReply(p, p2)
	if p ~= count or not (v2 and v2.Visible) then
		return
	end

	local v4 = PoolPlayerStats.Sanitize(p2)

	if v4 then
		v3.Status.Visible = false

		PoolStatsPopup._Fill(v4, count)
	else
		v3.Status.Text = "Stats unavailable right now"
		v3.Status.Visible = true
	end
end

local function bind()
	if v2 then
		return v2
	end

	local v4 = need(LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PoolStatsUI"), "Root")

	for k, v5 in v do
		v3[k] = need(v4, v5)
	end

	v4.Visible = false
	backgroundTransparency = v4.BackgroundTransparency
	v2 = v4

	local close = v3.Close
	local backdrop = v3.Backdrop

	close.Activated:Connect(function()
		PoolStatsPopup.Close()
	end)

	backdrop.Activated:Connect(function()
		PoolStatsPopup.Close()
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.ButtonB and v4.Visible then
			PoolStatsPopup.Close()
		end
	end)

	RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
		if p == "Stats" then
			local v5, v6 = ...

			if v5 == count and v2 then
				if not v2.Visible then
					return
				end

				local v7 = PoolPlayerStats.Sanitize(v6)

				if v7 then
					v3.Status.Visible = false

					PoolStatsPopup._Fill(v7, count)
				else
					v3.Status.Text = "Stats unavailable right now"
					v3.Status.Visible = true
				end
			end
		end
	end)

	return v4
end

local function separate(p: number) -- 7 equivalent calls inferred from this helper
	return NumberHelper:Separate((math.floor(p)))
end

local function memberSince(memberSince2: number) -- 1 equivalent call inferred from this helper
	if memberSince2 <= 0 then
		return ""
	end

	return "Member since " .. os.date("%b %Y", memberSince2)
end

local function writeNumbers(data, p: number)
	local function at(p2: number) -- 7 equivalent calls inferred from this helper
		return (math.floor(p2 * p + 0.5))
	end

	local games = PoolPlayerStats.Games(data)
	local winRate = PoolPlayerStats.WinRate(data)

	v3.Wins.Text = separate(at(data.Wins)) -- inferred equivalent call
	v3.Losses.Text = separate(at(data.Losses)) -- inferred equivalent call
	v3.Games.Text = separate(at(games)) -- inferred equivalent call
	v3.WinRate.Text = not winRate and "—" or string.format("%d%%", (math.floor(winRate * 100 * p + 0.5)))

	v3.WinStreak.Text = separate(at(data.WinStreak)) -- inferred equivalent call
	v3.BestStreak.Text = separate(at(data.BestStreak)) -- inferred equivalent call
	v3.BallsPotted.Text = separate(at(data.BallsPotted)) -- inferred equivalent call
	v3.BreakPots.Text = separate(at(data.BreakPots)) -- inferred equivalent call
	v3.Venues.Text = string.format("%d/%d", data.VenuesUnlocked, data.VenuesTotal)
	v3.Bots.Text = string.format("%d/%d", data.BotsBeaten, data.BotsTotal)
end

local function writePending()
	for _, v4 in {
		"Wins",
		"Losses",
		"Games",
		"WinRate",
		"WinStreak",
		"BestStreak",
		"BallsPotted",
		"BreakPots",
		"Venues",
		"Bots"
	} do
		v3[v4].Text = "—"
	end

	v3.MemberSince.Text = ""
	v3.XpFill.Size = UDim2.fromScale(0, 1)
end

function PoolStatsPopup._Fill(data, p: number)
	v3.Level.Text = tostring(data.Level)
	v3.MemberSince.Text = memberSince(data.MemberSince) -- inferred equivalent call

	TweenService:Create(v3.XpFill, tweenInfo3, {
		Size = UDim2.fromScale(data.LevelProgress, 1)
	}):Play()

	writeNumbers(data, 0)

	task.spawn(function()
		local lastTime = os.clock()

		repeat
			task.wait()

			if p ~= count or not (v2 and v2.Visible) then
				break
			end

			local v4 = math.clamp((os.clock() - lastTime) / 0.45, 0, 1)

			writeNumbers(data, 1 - (1 - v4) ^ 3)
		until v4 >= 1
	end)
end

local function setIdentity(player)
	local userId = player.UserId

	local avatar = v3.Avatar
	local image

	if userId and userId > 0 then
		image = PoolPlayerData.Thumbnail(userId)
	else
		image = player.Image or ""
	end

	avatar.Image = image

	PoolStreakBadge.Set(v3.Avatar, player.WinStreak, "BottomLeft")
	PoolVip.Apply(v3.DisplayName, player.DisplayName, player.Vip)
	v3.Level.Text = tostring((math.max(math.floor(player.Level or 1), 1)))

	local name = player.Name

	if not name or name == "" then
		v3.Username.Visible = false

		return
	end

	v3.Username.Text = "@" .. name
	v3.Username.Visible = true
end

local function present(p)
	local v4 = bind()

	count += 1

	setIdentity(p)
	writePending()
	v3.Status.Visible = false

	if v4.Visible then
		return count
	end

	selectedObject = GuiService.SelectedObject
	v4.Visible = true
	v4.BackgroundTransparency = 1

	TweenService:Create(v4, tweenInfo2, { BackgroundTransparency = backgroundTransparency }):Play()

	v3.Pop.Scale = 0.85
	TweenService:Create(v3.Pop, tweenInfo, { Scale = 1 }):Play()

	PoolAudio.PlayCue("MenuOpen")

	if UserInputService.GamepadEnabled then
		GuiService.SelectedObject = v3.Close
	end

	return count
end

function PoolStatsPopup.OpenSelf()
	local v4 = PoolPlayerStats.ForLocal(LocalPlayer.UserId)

	local v5 = {
		UserId = LocalPlayer.UserId,
		DisplayName = LocalPlayer.DisplayName,
		Name = LocalPlayer.Name,
		Level = 0,
		WinStreak = 0,
		Vip = 0
	}
	local level

	if v4 then
		level = v4.Level
	else
		level = PoolPlayerData.GetLevel(LocalPlayer.UserId)
	end

	v5.Level = level
	v5.WinStreak = PoolPlayerData.GetWinStreak(LocalPlayer.UserId)
	v5.Vip = PoolVip.Owns(LocalPlayer.UserId)
	local v6 = present(v5)

	if v4 then
		PoolStatsPopup._Fill(v4, v6)
		return
	end

	v3.Status.Text = "Still loading your stats..."
	v3.Status.Visible = true
end

function PoolStatsPopup.OpenSeat(p: number, p2)
	local v4 = present(p2)

	v3.Status.Text = "Loading stats..."
	v3.Status.Visible = true

	RemoteSignals.FireServer(RemoteEnums.Pool, "Stats", v4, p)

	task.delay(6, function()
		if v4 == count and v2 and v2.Visible and v3.Status.Visible then
			v3.Status.Text = "Stats unavailable right now"
		end
	end)
end

function PoolStatsPopup.OpenFake(p, p2: number, p3: number?)
	local level = p.Level or not p3 and 1 or PoolPlayerStats.LevelForRating(p3, p2)
	local clone = table.clone(p)

	clone.Level = level

	clone.WinStreak = nil
	clone.Vip = nil

	local v4 = present(clone)

	PoolStatsPopup._Fill(PoolPlayerStats.Fake(p2, level, p3), v4)
end

function PoolStatsPopup.IsOpen()
	return v2 ~= nil and v2.Visible
end

local tweenInfo4 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function PoolStatsPopup.PressFeedback(data, instance)
	local v4 = false
	local connections = {}

	local function to(scale: number) -- 2 equivalent calls inferred from this helper
		TweenService:Create(instance, tweenInfo4, { Scale = scale }):Play()
	end

	local function rest() -- 3 equivalent calls inferred from this helper
		to(v4 and 1.04 or 1) -- inferred equivalent call
	end

	table.insert(connections, data.MouseEnter:Connect(function()
		v4 = true
		rest() -- inferred equivalent call
	end))

	table.insert(connections, data.MouseLeave:Connect(function()
		v4 = false
		rest() -- inferred equivalent call
	end))

	table.insert(connections, data.MouseButton1Down:Connect(function()
		to(0.96) -- inferred equivalent call
	end))

	table.insert(connections, data.MouseButton1Up:Connect(rest))

	table.insert(connections, data.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			v4 = false
			rest() -- inferred equivalent call
		end
	end))

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
		instance.Scale = 1
	end
end

function PoolStatsPopup.Close()
	local v4 = v2

	if not (v4 and v4.Visible) then
		return
	end

	count += 1
	v4.Visible = false

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(v4) then
		GuiService.SelectedObject = nil
	end

	local selectedObject2 = selectedObject
	selectedObject = nil

	if selectedObject2 and selectedObject2.Parent and selectedObject2.Visible then
		GuiService.SelectedObject = selectedObject2
	end
end

return PoolStatsPopup