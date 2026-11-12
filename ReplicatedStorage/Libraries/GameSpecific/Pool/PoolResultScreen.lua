local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PoolAudio = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolAudio)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)
local PoolStreakBadge = require(script.Parent.PoolStreakBadge)
local PoolVip = require(script.Parent.PoolVip)

local Hud = PoolConstants.Hud

local v = { "PayoutCoin1", "PayoutCoin2", "PayoutCoin3" }
local v2 = 0

local function pickCoinCue() -- 1 equivalent call inferred from this helper
	local count = #v
	local v3 = math.random(1, count)

	if count > 1 and v3 == v2 then
		v3 = (v3 + math.random(0, count - 2)) % count + 1
	end

	v2 = v3

	return v[v3]
end

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolResultScreen: %s.%s is missing (looking for %q)",
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

local PoolResultScreen = {}

function PoolResultScreen.new(instance, p: string?)
	local theme = PoolConstants.GetTheme(p)
	local maid = Maid.new()

	local resultScreen = instance:WaitForChild("ResultScreen")
	resultScreen.Visible = false

	local cards = {}
	local icons = {}
	local names = {}

	for i = 1, 2 do
		local v3 = bind(resultScreen, "Player" .. i)
		cards[i] = v3
		icons[i] = bind(v3, "Icon")
		names[i] = bind(v3, "PlayerName")
	end

	local pot = bind(resultScreen, "Pot")
	local experience = bind(resultScreen, "Experience")

	local series = resultScreen:FindFirstChild("Series")

	if not series then
		series = bind(resultScreen, "Reason"):Clone()
		series.Name = "Series"
		series.AnchorPoint = Vector2.new(0.5, 0.5)
		series.Position = UDim2.fromScale(0.5, 0.535)
		series.Size = UDim2.fromScale(0.2, 0.07)
		series.Text = ""
		series.Parent = resultScreen
	end

	series.Visible = false
	local rematchButton = bind(resultScreen, "Rematch")
	local exitButton = bind(resultScreen, "Exit")

	experience.Visible = false

	local title = bind(resultScreen, "Title")
	local potLabel = bind(pot, "Amount")

	title.TextColor3 = theme.Accent
	potLabel.TextColor3 = theme.Accent
	PoolButtonSkin.SetColour(rematchButton, theme.Accent)

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)

	maid:GiveTask(rematchButton.Activated:Connect(function()
		bindableEvent:Fire()
	end))

	maid:GiveTask(exitButton.Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	return {
		Root = resultScreen,
		Title = title,
		Reason = bind(resultScreen, "Reason"),
		PotLabel = potLabel,
		Pot = pot,
		Experience = experience,
		Series = series,
		SeriesWins = nil,
		Icons = icons,
		Names = names,
		Cards = cards,
		Entries = {},
		RematchButton = rematchButton,
		ExitButton = exitButton,
		Rematch = bindableEvent.Event,
		Exit = bindableEvent2.Event,
		Maid = maid,
		OutcomeSounds = {},
		OutcomeToken = 0,
		ViewerWon = false
	}
end

local function applyBotTag(data, p: number, visible: boolean)
	local icon = data.Icons[p]

	if not icon then
		return
	end

	local botTag = icon:FindFirstChild("BotTag")

	if not botTag then
		if not visible then
			return
		end

		botTag = Instance.new("Frame")
		botTag.Name = "BotTag"
		botTag.AnchorPoint = Vector2.new(0.5, 1)
		botTag.Position = UDim2.fromScale(0.5, 1)
		botTag.Size = UDim2.fromScale(1, 0.2)
		botTag.BackgroundColor3 = Color3.fromRGB(12, 14, 16)
		botTag.BackgroundTransparency = 1
		botTag.BorderSizePixel = 0
		botTag.ZIndex = icon.ZIndex + 6
		botTag.Parent = icon

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.TextScaled = true
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Text = "BOT"
		label.ZIndex = botTag.ZIndex + 1
		label.Parent = botTag

		local name = data.Names[p]

		if name then
			label.FontFace = name.FontFace
		end

		local uiSizeConstraint = Instance.new("UISizeConstraint")
		uiSizeConstraint.MinSize = Vector2.new(0, 18)
		uiSizeConstraint.Parent = botTag
	end

	botTag.Visible = visible

	local label = botTag:FindFirstChild("Label")

	if label then
		label.TextTransparency = 0
	end
end

local function stopOutcomeSounds(state)
	state.OutcomeToken += 1

	for _, outcomeSound in state.OutcomeSounds do
		if outcomeSound.maid and outcomeSound.maid.soundInstance then
			Sounds.Stop(outcomeSound, 0.2)
		end
	end

	table.clear(state.OutcomeSounds)
end

function PoolResultScreen:PlayOutcome(p: number, p2: number?)
	stopOutcomeSounds(self)

	if p <= 0 then
		self.ViewerWon = false

		return
	end

	local viewerWon = not (p2 and p2 > 0) or p == p2
	self.ViewerWon = viewerWon

	local outcomeToken = self.OutcomeToken
	local v3 = PoolAudio.PlayCue("MatchOver")

	if v3 then
		table.insert(self.OutcomeSounds, v3)
	end

	local matchVerdictDelay = PoolConstants.SoundCues.MatchVerdictDelay

	task.delay(typeof(matchVerdictDelay) ~= "number" and 1.5 or matchVerdictDelay, function()
		if self.OutcomeToken ~= outcomeToken or not self.Root.Visible then
			return
		end

		local v4 = PoolAudio.PlayCue(viewerWon and "MatchWin" or "MatchLoss")

		if v4 then
			table.insert(self.OutcomeSounds, v4)
		end
	end)
end

function PoolResultScreen.Show(data, p: number, p2: number, value: string?, p3: number?, p4: number?, value2: string?)
	data.Root.Visible = true
	local v3 = p4 == 2

	local function sideOf(p5: number) -- 3 equivalent calls inferred from this helper
		if v3 then
			return 3 - p5
		end

		return p5
	end

	for i = 1, 2 do
		local entry = data.Entries[i]

		if not entry then
			continue
		end

		local v4 = sideOf(i) -- inferred equivalent call
		local name = data.Names[v4]
		local icon = data.Icons[v4]

		if name then
			PoolVip.Apply(name, entry.Name, entry.Vip)
		end

		if not icon then
			continue
		end

		icon.Image = entry.Image

		PoolStreakBadge.Set(icon, entry.WinStreak, v4 == 1 and "BottomLeft" or "BottomRight")
	end

	if p <= 0 then
		data.Title.Text = "MATCH ENDED"
		data.Title.TextColor3 = Hud.TextMuted
	elseif p4 and p4 > 0 then
		local v4 = p == p4
		data.Title.Text = v4 and "WIN" or "LOSS"
		local title = data.Title
		local textColor

		if v4 then
			textColor = Color3.fromRGB(126, 232, 118)
		else
			textColor = Color3.fromRGB(238, 108, 108)
		end

		title.TextColor3 = textColor
	else
		local title = data.Title
		local text

		if value2 and value2 ~= "" then
			text = string.format("%s WINS", string.upper(value2))
		else
			text = string.format("PLAYER %d WINS", p)
		end

		title.Text = text

		data.Title.TextColor3 = PoolConstants.GetTheme().Accent
	end

	data.Reason.Text = value or ""
	local reason = data.Reason
	reason.Visible = value ~= nil and value ~= ""

	data.PotLabel.Text = NumberHelper:Separate((math.round(p2)))

	data.Pot.Visible = p2 > 0

	local experience = data.Experience
	experience.Visible = p3 ~= nil and p3 > 0

	if p3 and p3 > 0 then
		data.Experience.Text = string.format("+%s XP", NumberHelper:Separate((math.round(p3))))
	end

	local seriesWins = data.SeriesWins

	data.Series.Visible = seriesWins ~= nil

	if seriesWins then
		local v4 = v3 and 2 or 1
		data.Series.Text = string.format("%d-%d", seriesWins[v4] or 0, seriesWins[3 - v4] or 0)
	end

	for i = 1, 2 do
		local v4 = sideOf(i) -- inferred equivalent call
		local v5 = i == p
		local icon = data.Icons[v4]
		local ring = icon and icon:FindFirstChild("Ring")

		if ring then
			local color

			if v5 then
				color = PoolConstants.GetTheme().Accent
			else
				color = Hud.Panel
			end

			ring.Color = color
			ring.Thickness = v5 and 4 or 2
		end

		if icon then
			icon.ImageTransparency = v5 and 0 or 0.45
		end

		local name = data.Names[v4]

		if name then
			name.TextTransparency = v5 and 0 or 0.45
		end

		local entry = data.Entries[i]

		applyBotTag(data, v4, entry ~= nil and entry.Bot == true)
	end

	if p2 <= 0 then
		return
	end

	local cards = data.Cards
	p = sideOf(p) -- inferred equivalent call
	local card = cards[p]

	if not card then
		return
	end

	data.Maid:GiveTask(task.spawn(function()
		local count = 0

		for i = 1, 24 do
			if not (data.Root.Parent and data.Root.Visible) then
				break
			end

			local flyingCoin = Instance.new("ImageLabel")
			flyingCoin.Name = "FlyingCoin"
			flyingCoin.AnchorPoint = Vector2.new(0.5, 0.5)
			flyingCoin.Size = UDim2.fromScale(0.07, 0.07)
			flyingCoin.BackgroundTransparency = 1
			flyingCoin.Image = "rbxassetid://126745495335731"

			flyingCoin.ZIndex = data.Root.ZIndex + 500
			flyingCoin.Parent = data.Root

			local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uiAspectRatioConstraint.AspectRatio = 1
			uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
			uiAspectRatioConstraint.Parent = flyingCoin

			if data.ViewerWon then
				local v4 = PoolAudio.PlayCue(pickCoinCue()) -- inferred equivalent call

				if v4 then
					table.insert(data.OutcomeSounds, v4)
				end
			end

			local v4 = (i / 24 - 0.5) * 0.16
			local v5 = math.abs(v4) + 0.1

			task.spawn(function()
				local position = data.Pot.Position
				local position2 = card.Position
				local total = 0

				while total < 0.6 do
					total += RunService.PreRender:Wait()

					if not flyingCoin.Parent then
						return
					end

					local v6 = math.min(total / 0.6, 1)
					local v7 = position.X.Scale + (position2.X.Scale - position.X.Scale) * v6

					local v8 = math.sin(v6 * 3.141592653589793) * v5
					local v9 = position.Y.Scale + (position2.Y.Scale - position.Y.Scale) * v6 - v8 + v4 * v6

					flyingCoin.Position = UDim2.fromScale(v7, v9)
					flyingCoin.ImageTransparency = not (v6 > 0.8) and 0 or (v6 - 0.8) / 0.2
				end

				flyingCoin:Destroy()

				count += 1

				if data.PotLabel.Parent then
					local v6 = count >= 24 and 0 or math.floor(p2 * (1 - count / 24))

					data.PotLabel.Text = NumberHelper:Separate(v6)
				end
			end)

			task.wait(3 / 46)
		end
	end))
end

function PoolResultScreen.SetPlayer(p, p2: number, name: string, value: string?, flag: boolean?)
	p.Entries[p2] = {
		Name = name,
		Image = value or "",
		Vip = flag == true
	}
end

function PoolResultScreen.SetWinStreak(p, p2: number, winStreak: number?)
	local entry = p.Entries[p2]

	if entry then
		entry.WinStreak = winStreak
	end
end

function PoolResultScreen.SetBot(p, p2: number, bot: boolean)
	local entry = p.Entries[p2]

	if entry then
		entry.Bot = bot
	end
end

local function setButtonLabel(instance, text: string) -- 2 equivalent calls inferred from this helper
	local top = instance:FindFirstChild("Top")

	if top and top:IsA("TextLabel") then
		top.Text = text
	else
		instance.Text = text
	end
end

function PoolResultScreen.SetRematchEnabled(p, flag: boolean, value: string?)
	p.RematchButton.Visible = flag
	p.RematchButton.Active = flag
	p.RematchButton.AutoButtonColor = flag
	setButtonLabel(p.RematchButton, value or "REMATCH") -- inferred equivalent call

	p.ExitButton.Position = UDim2.fromScale(flag and 0.62 or 0.5, 0.74)
end

function PoolResultScreen.SetExitLabel(p, value: string?)
	setButtonLabel(p.ExitButton, value or "LOBBY") -- inferred equivalent call
end

function PoolResultScreen:SetSeries(seriesWins)
	self.SeriesWins = seriesWins
end

function PoolResultScreen:Hide()
	self.Root.Visible = false

	self.SeriesWins = nil
	self.Series.Visible = false

	stopOutcomeSounds(self)
	self.ViewerWon = false
end

return PoolResultScreen