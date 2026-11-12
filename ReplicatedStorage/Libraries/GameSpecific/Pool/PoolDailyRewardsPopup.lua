local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolDailyRewards = require(Pool.PoolDailyRewards)
local PoolMenuWidgets = require(Pool.PoolMenuWidgets)
local PoolSkins = require(Pool.PoolSkins)

local PoolDailyRewardsPopup = {}

local LocalPlayer = Players.LocalPlayer

local color = Color3.fromRGB(255, 213, 79)
local color2 = Color3.fromRGB(120, 215, 255)
local color3 = Color3.fromRGB(114, 220, 78)
local color4 = Color3.fromRGB(118, 122, 134)
local color5 = Color3.fromRGB(255, 213, 79)
local color6 = Color3.fromRGB(20, 20, 20)

local color7 = Color3.fromRGB(150, 70, 210)
local color8 = Color3.fromRGB(60, 22, 96)

local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local v = {
	Built = false,
	Gui = nil,
	Panel = nil,
	PanelSize = nil,
	Claim = nil,
	ClaimText = nil,
	Cards = {},
	Claiming = false,
	JustClaimed = nil
}

local function find(instance, value: string)
	for childName in value:gmatch("[^%.]+") do
		local child = instance:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"[PoolDailyRewardsPopup] %s has no %q (looking for %s)",
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

local function screen() -- 1 equivalent call inferred from this helper
	local poolDailyRewardsUI = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PoolDailyRewardsUI")
		or ReplicatedStorage.UI:FindFirstChild("PoolDailyRewardsUI")

	if not poolDailyRewardsUI then
		error("[PoolDailyRewardsPopup] PoolDailyRewardsUI is in neither PlayerGui nor ReplicatedStorage.UI", 2)
	end

	return poolDailyRewardsUI
end

local function data() -- 2 equivalent calls inferred from this helper
	local playerReplica = Profiles.GetPlayerReplica((tostring(LocalPlayer.UserId)))

	return playerReplica and playerReplica.Data
end

local function rewardText(data2)
	if data2.Kind == "Coins" then
		return NumberHelper:Separate(data2.Amount or 0)
	end

	if data2.Kind == "Gems" then
		return NumberHelper:Separate(data2.Amount or 0) .. " GEMS"
	end

	local v2 = data2.Item and PoolSkins.GetItem(data2.Category or "cueSticks", data2.Item)

	return string.upper(not (v2 and v2.name) and "CUE STICK" or tostring(v2.name))
end

local function untilText(p: number) -- 1 equivalent call inferred from this helper
	local v2 = math.max(0, (math.floor(p)))

	local v3 = v2 // 3600
	local v4 = v2 % 3600 // 60

	if v3 > 0 then
		return string.format("%dH %02dM", v3, v4)
	end

	return string.format("%dM %02dS", v4, v2 % 60)
end

local function fillCard(card, k: number)
	local rewardFor = PoolDailyRewards.RewardFor(k, LocalPlayer.UserId)

	card.Day.Text = "DAY " .. k
	card.Amount.Text = rewardText(rewardFor)

	if rewardFor.Kind == "Cue" and rewardFor.Item then
		card.Icon.Visible = false
		card.Preview.Visible = true
		card.Preview.Position = card.PreviewPosition
		card.Preview.Size = card.PreviewSize
		card.Amount.TextColor3 = Color3.new(1, 1, 1)

		if card.PreviewItem ~= rewardFor.Item then
			card.PreviewItem = rewardFor.Item

			pcall(function()
				local item = PoolSkins.GetItem(rewardFor.Category or "cueSticks", rewardFor.Item)

				PoolMenuWidgets.CuePreview(card.Preview, PoolMenuWidgets.FindSkinModel(item))
			end)
		end
	else
		card.Preview.Visible = false
		card.Preview.Position = card.PreviewPosition
		card.Preview.Size = card.PreviewSize
		card.PreviewItem = nil
		card.Icon.Visible = true
		card.Icon.Image = rewardFor.Kind == "Gems" and "rbxassetid://91068843812037" or "rbxassetid://140250576355900"
		local amount = card.Amount
		local textColor

		if rewardFor.Kind == "Gems" then
			textColor = color2
		else
			textColor = color
		end

		amount.TextColor3 = textColor
	end
end

local function build()
	if v.Built then
		return
	end

	local gui = screen() -- inferred equivalent call
	gui.Enabled = false

	local panel = find(gui, "Panel")
	local parent = find(panel, "Row")
	local v2 = find(gui, "Templates.DayCard")

	v.Gui = gui
	v.Panel = panel
	v.PanelSize = panel.Size
	v.Claim = find(panel, "Claim")
	v.ClaimText = find(panel, "Claim.Top")

	for i = 1, #PoolDailyRewards.Days do
		local clone = v2:Clone()
		clone.Name = "Day" .. i
		clone.LayoutOrder = i
		clone.Visible = true

		local v3 = i == #PoolDailyRewards.Days

		clone.Size = UDim2.fromScale(v3 and 0.2 or 0.118, clone.Size.Y.Scale)

		local uiGradient = v3 and clone:FindFirstChildOfClass("UIGradient")

		if uiGradient then
			uiGradient.Color = ColorSequence.new(color7, color8)
		end

		local uiScale = Instance.new("UIScale")
		uiScale.Parent = clone
		clone.Parent = parent

		local preview = find(clone, "Preview")

		table.insert(v.Cards, {
			Root = clone,
			Day = find(clone, "Day"),
			Icon = find(clone, "Icon"),
			Preview = preview,
			Amount = find(clone, "Amount"),
			Claimed = find(clone, "Claimed"),
			Stroke = clone:FindFirstChildOfClass("UIStroke"),
			Scale = uiScale,
			PreviewPosition = preview.Position,
			PreviewSize = preview.Size
		})
	end

	find(panel, "Exit").Activated:Connect(function()
		PoolDailyRewardsPopup.Hide()
	end)

	v.Claim.Activated:Connect(function()
		PoolDailyRewardsPopup.ClaimToday()
	end)

	local playerReplica = Profiles.GetPlayerReplica((tostring(LocalPlayer.UserId)))

	if playerReplica then
		pcall(function()
			playerReplica:ListenToWrite("PoolDailyReward", function()
				v.JustClaimed = nil

				if PoolDailyRewardsPopup.IsVisible() then
					PoolDailyRewardsPopup.Refresh()
				end
			end)
		end)
	end

	task.spawn(function()
		while true do
			task.wait(1)

			if not PoolDailyRewardsPopup.IsVisible() or v.Claiming then
				continue
			end

			PoolDailyRewardsPopup.Refresh()
		end
	end)

	v.Built = true
end

function PoolDailyRewardsPopup.CanClaim()
	return PoolDailyRewards.CanClaim(data()) -- inferred equivalent call
end

function PoolDailyRewardsPopup.IsVisible()
	return v.Gui ~= nil and v.Gui.Enabled
end

function PoolDailyRewardsPopup.Refresh()
	build()

	local state = PoolDailyRewards.GetState(data()) -- inferred equivalent call
	local v2 = state.Claimed
	local v3 = state.Claimable

	if v.JustClaimed then
		v2 = v.JustClaimed
		v3 = false
	end

	for k, card in v.Cards do
		fillCard(card, k)

		local visible = k <= v2
		local v4 = v3 and k == state.Step

		card.Claimed.Visible = visible

		if card.Stroke then
			local stroke = card.Stroke
			local color9 = if v4 then color5 else color6
			stroke.Color = color9
			card.Stroke.Thickness = v4 and 4 or 2.5
		end

		card.Scale.Scale = v4 and 1.06 or 1
	end

	local claim = v.Claim
	local claimText = v.ClaimText

	if v3 and not v.Claiming then
		claim.Active = true
		claim.AutoButtonColor = true
		PoolButtonSkin.SetColour(claim, color3)
		claimText.Text = "CLAIM DAY " .. state.Step
	else
		claim.Active = false
		claim.AutoButtonColor = false
		PoolButtonSkin.SetColour(claim, color4)
		local text

		if v.Claiming then
			text = "CLAIMING..."
		else
			text = "NEXT REWARD IN " .. untilText(state.NextAt - PoolDailyRewards.Now()) -- inferred equivalent call
		end

		claimText.Text = text
	end
end

function PoolDailyRewardsPopup.Show()
	build()
	PoolDailyRewardsPopup.Refresh()

	local gui = v.Gui
	local panel = v.Panel
	local panelSize = v.PanelSize

	gui.Enabled = true
	panel.Size = UDim2.new(panelSize.X.Scale * 0.6, 0, panelSize.Y.Scale * 0.6, 0)
	TweenService:Create(panel, tweenInfo, { Size = panelSize }):Play()

	pcall(function()
		PoolAudio.PlayCue("MenuOpen")
	end)
end

function PoolDailyRewardsPopup.Hide()
	if v.Gui then
		v.Gui.Enabled = false
	end
end

function PoolDailyRewardsPopup.ClaimToday()
	if v.Claiming or not PoolDailyRewardsPopup.CanClaim() then
		return
	end

	v.Claiming = true
	PoolDailyRewardsPopup.Refresh()

	local v2 = nil
	local connection = RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
		if p == "DailyClaimed" or p == "DailyClaimFailed" then
			v2 = { p, ... }
		end
	end)

	RemoteSignals.FireServer(RemoteEnums.Pool, "ClaimDaily")

	local lastTime = os.clock()

	while not v2 and os.clock() - lastTime < 8 do
		task.wait()
	end

	connection:Disconnect()
	v.Claiming = false

	if v2 and v2[1] == "DailyClaimed" then
		local justClaimed = tonumber(v2[2]) or 1
		local v3 = v2[3]
		local card = v.Cards[justClaimed]

		v.JustClaimed = justClaimed
		PoolDailyRewardsPopup.Refresh()

		if card then
			card.Scale.Scale = 1.25
			TweenService:Create(card.Scale, tweenInfo, { Scale = 1 }):Play()
		end

		pcall(function()
			PoolAudio.PlayCue(typeof(v3) == "table" and v3.Kind == "Cue" and "MatchWin" or "PayoutCoin1")
		end)

		if typeof(v3) == "table" then
			local new = Notifications.new
			local message

			if v3.Kind == "Cue" then
				message = "Day " .. justClaimed .. ": unlocked " .. rewardText(v3) .. "!"
			else
				message = "Day " .. justClaimed .. ": +" .. rewardText(v3) .. (v3.Kind == "Coins" and " coins!" or "!")
			end

			local colour

			if v3.Kind == "Gems" then
				colour = color2
			elseif v3.Kind == "Coins" then
				colour = color
			else
				colour = Color3.fromRGB(214, 138, 255)
			end

			new("TextNotification", { message = message, colour = colour, length = 4 })
		end
	else
		Notifications.new("TextNotification", {
			message = not v2 and "The server didn't answer. Try again in a moment." or tostring(v2[2]),
			colour = Color3.fromRGB(238, 108, 108)
		})

		PoolDailyRewardsPopup.Refresh()
	end
end

return PoolDailyRewardsPopup