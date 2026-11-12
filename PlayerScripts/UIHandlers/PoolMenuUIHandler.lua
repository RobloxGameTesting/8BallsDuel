local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

require(ReplicatedStorage.Libraries.Constants.FriendConstants)
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local pool = ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("GameSpecific"):WaitForChild("Pool")
local PoolConstants = require(pool:WaitForChild("PoolConstants"))
local PoolCardRewards = require(pool:WaitForChild("PoolCardRewards"))
local PoolCardPickScreen = require(pool:WaitForChild("PoolCardPickScreen"))
local PoolFriendsMenu = require(pool:WaitForChild("PoolFriendsMenu"))

local PoolVip = require(pool:WaitForChild("PoolVip"))
local PoolGalaxyPopup = require(pool:WaitForChild("PoolGalaxyPopup"))
local PoolGalaxySet = require(pool:WaitForChild("PoolGalaxySet"))
local PoolSeasonPrompt = require(pool:WaitForChild("PoolSeasonPrompt"))
local PoolSeasonHype = require(pool:WaitForChild("PoolSeasonHype"))
local PoolInviteMenu = require(pool:WaitForChild("PoolInviteMenu"))

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage2.Libraries.Modules.Button)
local PoolHomeMenu = require(pool:WaitForChild("PoolHomeMenu"))
local PoolUpdateBubble = require(pool:WaitForChild("PoolUpdateBubble"))
local PoolNineBallPopup = require(pool:WaitForChild("PoolNineBallPopup"))
local PoolChallengeModePopup = require(pool:WaitForChild("PoolChallengeModePopup"))
local PoolLikeGoalBar = require(pool:WaitForChild("PoolLikeGoalBar"))
local PoolMenuPopups = require(pool:WaitForChild("PoolMenuPopups"))
local PoolMenuWidgets = require(pool:WaitForChild("PoolMenuWidgets"))
local PoolStarterPackPopup = require(pool:WaitForChild("PoolStarterPackPopup"))
local PoolOfferCarousel = require(pool:WaitForChild("PoolOfferCarousel"))
local PoolTutorialPopup = require(pool:WaitForChild("PoolTutorialPopup"))
local PoolInventoryMenu = require(pool:WaitForChild("PoolInventoryMenu"))
local PoolAudio = require(pool:WaitForChild("PoolAudio"))
local PoolMatchReplica = require(pool:WaitForChild("PoolMatchReplica"))
local PoolPlayerData = require(pool:WaitForChild("PoolPlayerData"))
local PoolSearchMenu = require(pool:WaitForChild("PoolSearchMenu"))
local PoolSettingsMenu = require(pool:WaitForChild("PoolSettingsMenu"))
local PoolStatsPopup = require(pool:WaitForChild("PoolStatsPopup"))
local PoolHaptics = require(pool:WaitForChild("PoolHaptics"))
local PoolShopMenu = require(pool:WaitForChild("PoolShopMenu"))
local PoolVenueMenu = require(pool:WaitForChild("PoolVenueMenu"))
local PoolWorldPass = require(pool:WaitForChild("PoolWorldPass"))
local PoolWorldPassCard = require(pool:WaitForChild("PoolWorldPassCard"))
local PoolModeMenu = require(pool:WaitForChild("PoolModeMenu"))
local PoolLevelSelectMenu = require(pool:WaitForChild("PoolLevelSelectMenu"))
local PoolCommunityMenu = require(pool:WaitForChild("PoolCommunityMenu"))
local PoolStarPacks = require(pool:WaitForChild("PoolStarPacks"))
local PoolLives = require(pool:WaitForChild("PoolLives"))
local PoolPackOpening = require(pool:WaitForChild("PoolPackOpening"))
local PoolVenueLootbox = require(pool:WaitForChild("PoolVenueLootbox"))
local PoolAchievementsMenu = require(pool:WaitForChild("PoolAchievementsMenu"))
local PoolLevelCatalog = require(pool:WaitForChild("PoolLevelCatalog"))
local PoolSkins = require(pool:WaitForChild("PoolSkins"))
local PoolTutorialFlow = require(pool:WaitForChild("PoolTutorialFlow"))
local Tutorial = require(ReplicatedStorage.Libraries.GameSpecific.Tutorial)

local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId

local success, result = pcall(function()
	return TeleportService:GetLocalPlayerTeleportData()
end)
local venueId

if success and typeof(result) == "table" and typeof(result.VenueId) == "string" then
	venueId = result.VenueId
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PoolMenuUI = PlayerGui:WaitForChild("PoolMenuUI")
local PoolGameUI = PlayerGui:WaitForChild("PoolGameUI")

local v = PoolHomeMenu.new(PoolMenuUI)

local v2 = PoolUpdateBubble.new(PoolMenuUI:WaitForChild("HomeMenu"), function()
	local seasonCard = v.SeasonCard
	local root = v.Root
	local x = root.AbsolutePosition.X
	local v2 = x + root.AbsoluteSize.X
	local absolutePosition = seasonCard.AbsolutePosition
	local absoluteSize = seasonCard.AbsoluteSize
	local v3 = absolutePosition.X + absoluteSize.X / 2

	if x <= v3 and v3 <= v2 then
		local v4 = math.max(absolutePosition.X, x)
		local v5 = math.min(absolutePosition.X + absoluteSize.X, v2)
		local v6 = v3 < x + (v2 - x) * 0.4 and 0.2 or 0.8

		return Vector2.new(v4 + (v5 - v4) * v6, absolutePosition.Y + absoluteSize.Y * 0.14), "Card"
	else
		local v4 = if v3 < x then v.Previous else v.Next

		if v4.Visible then
			return Vector2.new(v4.AbsolutePosition.X + v4.AbsoluteSize.X * 0.5, v4.AbsolutePosition.Y + 2), "Arrow"
		end

		return nil
	end
end)

local v3 = PoolLevelSelectMenu.new(PoolMenuUI)

local v4 = PoolCommunityMenu.new(PoolMenuUI)

local v5 = PoolLikeGoalBar.new(v.Root)

PoolMenuPopups.Bind(PoolTutorialPopup.new(PoolMenuUI))

PoolMenuPopups.BindStarterPack(PoolStarterPackPopup.new(PoolMenuUI))

PoolOfferCarousel.new(v.Root, function()
	PoolMenuPopups.ShowStarterPack()
end)

local v6 = PoolGalaxyPopup.new(PoolMenuUI)
PoolMenuPopups.BindGalaxySet(v6)

local v7 = PoolSeasonPrompt.new()
PoolMenuPopups.BindSeasonPrompt(v7)

local EventsMenu = PoolMenuUI:WaitForChild("EventsMenu")

local v8 = PoolFriendsMenu.new(PoolMenuUI)
local v9 = PoolShopMenu.new(PoolMenuUI)
local v10 = PoolVenueMenu.new(PoolMenuUI)
local v11 = PoolModeMenu.new(PoolMenuUI)
local v12 = PoolSearchMenu.new(PoolMenuUI)
local v13 = PoolSettingsMenu.new(PoolMenuUI)

local root = v12.Left.Root
local statsButton = root:FindFirstChild("StatsButton")
local pressScale = root:FindFirstChild("PressScale")

if statsButton and statsButton:IsA("TextButton") then
	statsButton.Activated:Connect(function()
		PoolStatsPopup.OpenSelf()
	end)

	if pressScale and pressScale:IsA("UIScale") then
		PoolStatsPopup.PressFeedback(statsButton, pressScale)
	end
end

PoolGameUI.Enabled = false

local function waitForReplica()
	local v14 = Profiles.GetPlayerReplica((tostring(UserId)))
	local lastTime = os.clock()
	local v15 = lastTime + 15

	while not v14 do
		task.wait(0.1)
		v14 = Profiles.GetPlayerReplica((tostring(UserId)))

		if v14 or not (v15 <= os.clock()) then
			continue
		end

		v15 += 15
		warn(string.format(
			"[PoolMenuUIHandler] still waiting for player replica (%ds)",
			(math.floor(os.clock() - lastTime))
		))
	end

	return v14
end

local v14 = waitForReplica()

PoolLikeGoalBar.SetReplica(v5, v14)

PoolShopMenu.SetReplica(v9, v14)
PoolGalaxyPopup.SetReplica(v6, v14)

PoolMatchReplica.Init()

local v15 = PoolInventoryMenu.new(PoolMenuUI)

local function coins() -- 3 equivalent calls inferred from this helper
	return PoolPlayerData.GetCoins(UserId)
end

local function refreshCurrency()
	PoolHomeMenu.SetCurrency(v, coins(), PoolPlayerData.GetGems(UserId)) -- inferred equivalent call
	PoolShopMenu.Refresh(v9, coins())
	PoolVenueMenu.SetCoins(v10, coins())
	PoolFriendsMenu.SetCoins(v8, coins())
	PoolInventoryMenu.SetCoins(v15, coins())
	PoolInventoryMenu.SetGems(v15, PoolPlayerData.GetGems(UserId))

	local progress = PoolPlayerData.GetProgress(UserId)

	PoolVenueMenu.SetProgress(
		v10,
		v14.Data.poolVenueWins,
		PoolWorldPass.Owns(UserId),
		PoolPlayerData.GetLevel(UserId),
		progress,
		v14.Data.poolVenueBoxes
	)

	PoolModeMenu.SetProgress(v11, v14.Data.poolBotWins)

	local progress2, v16, v17 = PoolPlayerData.GetProgress(UserId)
	local v18 = math.max(v17 - v16, 1)

	PoolHomeMenu.SetLevel(v, PoolPlayerData.GetLevel(UserId), (progress2 - v16) / v18)

	PoolHomeMenu.SetWinStreak(v, PoolPlayerData.GetWinStreak(UserId))
end

local function venueById(p: string) -- 3 equivalent calls inferred from this helper
	return PoolConstants.GetVenue(p)
end

local v16 = PoolNineBallPopup.new(PoolMenuUI)

local v17 = PoolChallengeModePopup.new(PoolMenuUI)

local v18 = { PoolChallengePrompts = true, StarterPackPopup = true }

local function hideAllMenus(flag: boolean?)
	PoolInviteMenu.Close()

	PoolStatsPopup.Close()

	PoolNineBallPopup.Hide(v16)
	PoolHomeMenu.SetVisible(v, false)
	PoolFriendsMenu.SetVisible(v8, false)
	PoolShopMenu.SetVisible(v9, false)
	PoolInventoryMenu.SetVisible(v15, false)
	PoolVenueMenu.SetVisible(v10, false)
	PoolModeMenu.SetVisible(v11, false)

	if not flag then
		PoolSearchMenu.SetVisible(v12, false)
	end

	PoolSettingsMenu.SetVisible(v13, false)
	PoolLevelSelectMenu.SetVisible(v3, false)
	PoolCommunityMenu.SetVisible(v4, false)

	for _, guiObject in PoolMenuUI:GetChildren() do
		if not guiObject:IsA("GuiObject") or v18[guiObject.Name] or not (not flag or guiObject ~= v12.Root) then
			continue
		end

		guiObject.Visible = false
	end
end

local function showHome() -- 9 equivalent calls inferred from this helper
	if PoolGameUI:GetAttribute("MatchActive") then
		return
	end

	hideAllMenus()
	refreshCurrency()
	PoolHomeMenu.SetVisible(v, true)
	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
end

local v19 = nil
local v20 = nil

local v21 = "EightBall"

local function showVenues(p: string?)
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	refreshCurrency()

	if p then
		v21 = p
	end

	PoolVenueMenu.SetLadder(v10, v21)

	v19 = nil
	v20 = nil
	PoolVenueMenu.SetChallengeTarget(v10, nil)
	PoolVenueMenu.SetFriendButtonsVisible(v10, true)

	PoolVenueMenu.SetVisible(v10, true)
	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
end

local function showVenuesForChallenge(userId: number, displayName: string?, p: string?, vip: boolean?)
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	refreshCurrency()

	v19 = userId
	v20 = displayName

	PoolVenueMenu.SetLadder(v10, p == "NineBall" and "NineBall" or "EightBall")

	PoolVenueMenu.SetChallengeTarget(v10, displayName, vip)

	PoolVenueMenu.SetFriendButtonsVisible(v10, false)

	PoolVenueMenu.SetVisible(v10, true)
	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
end

local function showTable(matchMode: string) -- 5 equivalent calls inferred from this helper
	hideAllMenus()
	PoolGameUI:SetAttribute("MatchMode", matchMode)
	PoolGameUI.Enabled = true
	PoolGameUI:SetAttribute("MatchActive", true)
end

local function startBotMatch(botLevel: string) -- 3 equivalent calls inferred from this helper
	PoolGameUI:SetAttribute("BotLevel", botLevel)
	showTable("Bots") -- inferred equivalent call
end

local function showBots() -- 1 equivalent call inferred from this helper
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	refreshCurrency()
	PoolModeMenu.OpenBots(v11)
	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
end

local function ladderProgress()
	local poolLevels = v14.Data.poolLevels
	local poolLevels2 = {}

	if typeof(poolLevels) == "table" then
		for k, poolLevel in poolLevels do
			local v22 = tonumber(k)

			if v22 and typeof(poolLevel) == "number" and poolLevel > 0 then
				poolLevels2[v22] = poolLevel
			end
		end
	end

	local v22 = 1

	while poolLevels2[v22] do
		v22 += 1
	end

	return poolLevels2, v22
end

local function refreshPacks() -- 2 equivalent calls inferred from this helper
	PoolLevelSelectMenu.SetPacksReady(v3, PoolStarPacks.Ready(v14.Data))
end

local function currentLives()
	local now = PoolLives.Now()
	local resolved, _, v22 = PoolLives.Resolve(v14.Data, now)

	if v22 then
		return resolved, v22 - now
	end

	return resolved, nil
end

local function refreshLives() -- 2 equivalent calls inferred from this helper
	PoolLevelSelectMenu.SetLives(v3, currentLives())
end

local function showLevelSelect()
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()

	PoolLevelSelectMenu.SetProgress(v3, ladderProgress())
	refreshPacks() -- inferred equivalent call
	refreshLives() -- inferred equivalent call
	PoolLevelSelectMenu.SetVisible(v3, true)
	PoolGameUI.Enabled = false
end

local function showCreate()
	PoolAudio.PlayCue("MenuOpen")

	PoolGameUI:SetAttribute("LevelIndex", nil)
	PoolGameUI:SetAttribute("BotLevel", nil)
	PoolGameUI:SetAttribute("CommunityCode", nil)
	showTable("Trickshot") -- inferred equivalent call
end

local function showCommunity() -- 1 equivalent call inferred from this helper
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	PoolCommunityMenu.SetVisible(v4, true)
	PoolGameUI.Enabled = false
end

v3.CommunityRequested:Connect(showCommunity)
v4.Closed:Connect(showLevelSelect)

v4.PlayRequested:Connect(function(communityCode: string)
	hideAllMenus()
	PoolGameUI:SetAttribute("BotLevel", nil)
	PoolGameUI:SetAttribute("LevelIndex", nil)
	PoolGameUI:SetAttribute("CommunityCode", communityCode)
	PoolGameUI:SetAttribute("MatchMode", "Trickshot")
	PoolGameUI.Enabled = true
	PoolGameUI:SetAttribute("MatchActive", true)
end)

v3.Closed:Connect(showHome)

v3.CreateRequested:Connect(showCreate)

v3.Chosen:Connect(function(levelIndex: number)
	local now = PoolLives.Now()
	local resolved, _, v22 = PoolLives.Resolve(v14.Data, now)

	if v22 then
		local _ = v22 - now
	end

	if resolved <= 0 then
		Notifications.new("TextNotification", {
			message = PoolLives.OutMessage(v14.Data),
			colour = Color3.fromRGB(238, 108, 108)
		})

		return
	end

	if not PoolLevelCatalog.IsAuthored(levelIndex) then
		Notifications.new("TextNotification", {
			message = string.format("Level %d is not built yet", levelIndex),
			colour = Color3.fromRGB(108, 198, 238)
		})

		return
	end

	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	PoolGameUI:SetAttribute("BotLevel", nil)
	PoolGameUI:SetAttribute("CommunityCode", nil)
	PoolGameUI:SetAttribute("LevelIndex", levelIndex)
	PoolGameUI:SetAttribute("MatchMode", "Trickshot")
	PoolGameUI.Enabled = true
	PoolGameUI:SetAttribute("MatchActive", true)
end)

v14:ListenToWrite("PoolLevelStars", function()
	if v3.Root.Visible then
		PoolLevelSelectMenu.SetProgress(v3, ladderProgress())
	end

	refreshPacks() -- inferred equivalent call
end)

v14:ListenToWrite("PoolLives", refreshLives)

PoolPackOpening.Init()

v14:ListenToWrite("PoolOnboardingReward", refreshPacks)

local v22 = false

v3.PresentPressed:Connect(function()
	if v22 or PoolPackOpening.IsBusy() then
		return
	end

	if PoolStarPacks.Ready(v14.Data) <= 0 then
		local starsToNext = PoolStarPacks.StarsToNext(v14.Data)

		Notifications.new("TextNotification", {
			message = string.format("%d more star%s to your next pack!", starsToNext, starsToNext == 1 and "" or "s"),
			colour = Color3.fromRGB(255, 216, 96)
		})
	else
		v22 = true
		PoolAudio.PlayCue("MenuOpen")
		RemoteSignals.FireServer(RemoteEnums.Pool, "ClaimStarPack")

		task.delay(8, function()
			v22 = false
		end)
	end
end)

RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
	if p == "StarPackOpened" then
		v22 = false
		task.spawn(PoolPackOpening.Play, (...))
	elseif p == "StarPackRefused" then
		v22 = false

		local v23 = ...

		Notifications.new("TextNotification", {
			message = typeof(v23) ~= "string" and "That pack could not be opened" or v23,
			colour = Color3.fromRGB(238, 108, 108)
		})
	end
end)

local function startOffline(p: string): boolean -- 2 equivalent calls inferred from this helper
	if p == "Solo" then
		PoolGameUI:SetAttribute("BotLevel", nil)
		showTable("Offline") -- inferred equivalent call
	else
		if p ~= "Trickshot" then
			return false
		end

		showLevelSelect()
	end

	return true
end

v11.Selected:Connect(function(botLevel: string)
	local flag

	if botLevel == "Solo" then
		startOffline("Solo") -- inferred equivalent call
		flag = true
	elseif botLevel == "Trickshot" then
		showLevelSelect()
		flag = true
	else
		flag = false
	end

	if flag then
		return
	end

	startBotMatch(botLevel) -- inferred equivalent call
end)

v11.Exit:Connect(function()
	showHome() -- inferred equivalent call
end)

local count = 0

local v23 = 0

local v24 = nil

local function beginSearch(p, p2: string?) -- 2 equivalent calls inferred from this helper
	count += 1
	v24 = p2

	hideAllMenus()
	PoolSearchMenu.BeginSearch(v12, p)
	PoolSearchMenu.SetVisible(v12, true)

	RemoteSignals.FireServer(RemoteEnums.Pool, "Queue", p.Id)
end

local function stopSearch() -- 3 equivalent calls inferred from this helper
	PoolSearchMenu.SetVisible(v12, false)

	if v24 ~= "Home" then
		showVenues()

		return
	end

	showHome() -- inferred equivalent call
end

local function showNineBall() -- 1 equivalent call inferred from this helper
	showVenues("NineBall")
end

local v25 = nil

local function needsNineBallHowTo(): boolean -- 1 equivalent call inferred from this helper
	return (tonumber(v14.Data.poolNineBallMatches) or 0) < PoolConstants.NineBall.HowToPlayMatches
end

v16.PlayRequested:Connect(function()
	local v26 = v25 or PoolConstants.NineBallVenues[1]

	v25 = nil
	PoolNineBallPopup.Hide(v16)

	if v26 then
		beginSearch(v26) -- inferred equivalent call
	end
end)

v16.Closed:Connect(function()
	v25 = nil
	PoolNineBallPopup.Hide(v16)
end)

v12.Cancelled:Connect(function()
	v23 = count

	RemoteSignals.FireServer(RemoteEnums.Pool, "Cancel")
	stopSearch() -- inferred equivalent call
end)

RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
	if p == "Queued" then
		local _, _, _, v26 = ...
		local v27 = tonumber(v26) or PoolPlayerData.GetLevel(UserId)

		PoolSearchMenu.SetStatus(v12, "Finding an opponent")
		PoolSearchMenu.SetRangeLevel(v12, v27)
	elseif p == "Failed" then
		local v26 = ...
		local v27 = count

		PoolSearchMenu.SetStatus(v12, (tostring(v26)))

		task.delay(2, function()
			if count ~= v27 then
				return
			end

			if not PoolGameUI.Enabled then
				stopSearch() -- inferred equivalent call
			end
		end)
	elseif p == "Cancelled" then
		if count ~= v23 or not v12.Root.Visible then
			return
		end

		stopSearch() -- inferred equivalent call
	elseif p == "Matched" then
		if v12.Root.Visible then
			PoolSearchMenu.SetJoining(v12)
		end
	elseif p == "Notice" then
		local message = ...

		if typeof(message) == "string" and message ~= "" then
			Notifications.new("TextNotification", {
				message = message,
				colour = Color3.fromRGB(238, 108, 108)
			})
		end
	elseif p == "OpponentMissing" then
		local v26, v27, _, _ = ...

		count += 1

		Notifications.new("TextNotification", {
			message = tostring(v26),
			colour = Color3.fromRGB(238, 108, 108)
		})

		local v28 = venueById(tostring(v27)) -- inferred equivalent call

		if v28 then
			hideAllMenus()
			PoolSearchMenu.BeginSearch(v12, v28)
			PoolSearchMenu.SetVisible(v12, true)
			PoolSearchMenu.SetStatus(v12, "Finding you another opponent")
			PoolGameUI.Enabled = false
			PoolGameUI:SetAttribute("MatchActive", false)
		end
	end
end)

local v26 = false

local v27 = false

local function onMatchState()
	local state = PoolMatchReplica.GetState()

	if not (state and state.Active) then
		return
	end

	if state.Phase == "Countdown" then
		hideAllMenus(v12.Root.Visible)

		PoolGameUI.Enabled = false

		PoolSearchMenu.SetVisible(v12, true)
		PoolSearchMenu.SetSeats(v12, state.Seats, state.Prize)
		PoolSearchMenu.SetStatus(v12, "Match found")

		local v28 = state.Phase == "Countdown"

		if v28 and not v26 then
			PoolAudio.PlayCue("MatchFound")
		end

		v26 = v28
	elseif state.Phase == "Playing" then
		v26 = false

		if not v27 then
			v27 = true
			showTable("Online") -- inferred equivalent call
		end
	end
end

PoolMatchReplica.OnReplica(function(object)
	v27 = false

	object:ListenToWrite("PoolMatchInit", function()
		v27 = false

		onMatchState()
	end)

	object:ListenToWrite("PoolMatchResolve", onMatchState)

	onMatchState()
end)

local v28 = {}

local lastTime = 0

local lastTime2 = 0

local function requestRoster() -- 3 equivalent calls inferred from this helper
	lastTime = os.clock()

	RemoteSignals.FireServer(RemoteEnums.Pool, "Roster")
end

local function friendIds()
	local result2 = {}

	for _, v29 in FriendHelper.GetFriendsInServer((tostring(UserId))) do
		local v30 = tonumber(v29)

		if v30 then
			result2[v30] = true
		end
	end

	return result2
end

local function refreshFriends() -- 2 equivalent calls inferred from this helper
	PoolFriendsMenu.SetCoins(v8, coins())
	PoolFriendsMenu.SetRoster(v8, v28, friendIds())
end

local v29 = nil

local function showFriends() -- 4 equivalent calls inferred from this helper
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	refreshFriends() -- inferred equivalent call
	PoolFriendsMenu.SetVisible(v8, true)
	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
	requestRoster() -- inferred equivalent call
end

v8.Closed:Connect(function()
	if v29 == "Venues" then
		v29 = nil
		showVenues()
	else
		showHome() -- inferred equivalent call
	end
end)

local v30 = nil

v8.Challenged:Connect(function(userId: number, displayName: string?, vip: boolean?)
	v30 = { UserId = userId, DisplayName = displayName, Vip = vip }
	PoolAudio.PlayCue("MenuOpen")
	PoolChallengeModePopup.Show(v17, displayName, vip)
end)

v17.Picked:Connect(function(p: string)
	local v31 = v30

	v30 = nil
	PoolChallengeModePopup.Hide(v17)

	if not v31 then
		return
	end

	showVenuesForChallenge(v31.UserId, v31.DisplayName, p, v31.Vip)
end)

v17.Closed:Connect(function()
	v30 = nil
	PoolChallengeModePopup.Hide(v17)
end)

v8.InviteRequested:Connect(function()
	PoolInviteMenu.Open(v14)
end)

RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
	if p == "Roster" then
		local v31 = ...

		v28 = typeof(v31) ~= "table" and {} or v31

		if v8.Root.Visible then
			refreshFriends() -- inferred equivalent call
		end
	elseif p == "Challenged" then
		local fromUserId, displayName, venueId2, venueName, entryFee, prize, seconds, v31 = ...

		Notifications.new("PoolChallengeNotification", {
			FromUserId = fromUserId,
			DisplayName = displayName,
			VenueId = venueId2,
			VenueName = venueName,
			EntryFee = entryFee,
			Prize = prize,
			Seconds = seconds,
			Vip = v31 == true,
			accept = function()
				RemoteSignals.FireServer(RemoteEnums.Pool, "AcceptChallenge", fromUserId)
			end,
			decline = function()
				RemoteSignals.FireServer(RemoteEnums.Pool, "DeclineChallenge", fromUserId)
			end
		})
	elseif p == "ChallengeSent" then
		local _, v31 = ...

		Notifications.new("TextNotification", {
			message = string.format("Waiting for %s to answer", (tostring(v31))),
			colour = Color3.fromRGB(255, 216, 96)
		})
	elseif p == "ChallengeDeclined" then
		local _, v31 = ...

		Notifications.new("TextNotification", {
			message = string.format("%s turned down your challenge", (tostring(v31))),
			colour = Color3.fromRGB(238, 108, 108)
		})
	elseif p == "ChallengeFailed" then
		local v31 = ...

		Notifications.new("TextNotification", {
			message = tostring(v31),
			colour = Color3.fromRGB(238, 108, 108)
		})

		if v8.Root.Visible then
			requestRoster() -- inferred equivalent call
		end
	elseif p == "SkinFailed" or p == "CueUpgradeFailed" then
		local v31 = ...

		Notifications.new("TextNotification", {
			message = tostring(v31),
			colour = Color3.fromRGB(238, 108, 108)
		})
	elseif p == "ChallengeAccepted" then
		local _, v31 = ...

		Notifications.new("TextNotification", {
			message = string.format("%s accepted!", (tostring(v31))),
			colour = Color3.fromRGB(126, 226, 118)
		})
	end
end)

local function showGalaxySet()
	PoolGalaxyPopup.Show(v6)
end

local GalaxySet = EventsMenu.Background.Header.Categories.GalaxySet

Button.Create(GalaxySet, showGalaxySet)

local ZIndex = GalaxySet.ZIndex

for _, guiObject in GalaxySet:GetDescendants() do
	if guiObject:IsA("GuiObject") then
		ZIndex = math.max(ZIndex, guiObject.ZIndex)
	end
end

PoolMenuWidgets.Sparkles(GalaxySet, Color3.fromRGB(255, 255, 255), ZIndex + 1)

local function refreshGalaxyButton() -- 1 equivalent call inferred from this helper
	GalaxySet.Visible = PoolGalaxySet.HasStock()
end

for _, tier in PoolGalaxySet.Tiers do
	ReplicatedStorage:GetAttributeChangedSignal(PoolGalaxySet.SoldAttribute(tier.Id)):Connect(refreshGalaxyButton)
end

refreshGalaxyButton() -- inferred equivalent call

local function showShop()
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	PoolShopMenu.Refresh(v9, coins())
	PoolShopMenu.SetVisible(v9, true)
	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
end

local function showBattlepass() -- 1 equivalent call inferred from this helper
	PoolUpdateBubble.Dismiss(v2)
	v2 = nil

	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	EventsMenu.Visible = true
	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
end

local v31 = PoolSeasonHype.new(showBattlepass)
PoolMenuPopups.BindSeasonHype(v31)

v9.Closed:Connect(showHome)

v5.ClaimPressed:Connect(function()
	RemoteSignals.FireServer(RemoteEnums.Pool, "ClaimLikeReward")
end)

v14:ListenToWrite("Inventory", function()
	if v9.Root.Visible then
		PoolShopMenu.Refresh(v9, coins())
	end
end)

v14:ListenToWrite("Purchases", function()
	if v9.Root.Visible then
		PoolShopMenu.Refresh(v9, coins())
	end
end)

local function showInventory()
	PoolAudio.PlayCue("MenuOpen")
	hideAllMenus()
	PoolInventoryMenu.SetCoins(v15, coins())
	PoolInventoryMenu.SetGems(v15, PoolPlayerData.GetGems(UserId))
	PoolInventoryMenu.SetVisible(v15, true)

	PoolInventoryMenu.RefreshEquipped(v15)
	PoolInventoryMenu.DressSlots(v15, "cueSticks")

	PoolGameUI.Enabled = false
	PoolGameUI:SetAttribute("MatchActive", false)
end

v15.Closed:Connect(showHome)

v5.InspectPressed:Connect(function(p: string, p2: string)
	showInventory()
	PoolInventoryMenu.Focus(v15, p, p2)
end)

local function viewGalaxyCue(p: string, p2: string)
	PoolGalaxyPopup.Hide(v6)
	showInventory()
	PoolInventoryMenu.Focus(v15, p, p2)
end

v6.Panel.Viewed:Connect(viewGalaxyCue)
v9.Galaxy.Viewed:Connect(viewGalaxyCue)

local function markCategorySeen(p: string) -- 1 equivalent call inferred from this helper
	if PoolSkins.CountUnseen(v14.Data, p) > 0 then
		RemoteSignals.FireServer(RemoteEnums.Pool, "SeenItems", p)
	end
end

v15.CategoryViewed:Connect(markCategorySeen)

v14:ListenToWrite("Inventory", function(p)
	if v15.Root.Visible and p == v15.Category then
		markCategorySeen(p) -- inferred equivalent call
	end
end)

v15.EquipRequested:Connect(function(p: string, p2: string)
	PoolAudio.PlayCue("MenuOpen")
	RemoteSignals.FireServer(RemoteEnums.Pool, "Equip", p, p2)
end)

v15.BuyRequested:Connect(function(p: string, p2: string)
	PoolAudio.PlayCue("MenuOpen")
	RemoteSignals.FireServer(RemoteEnums.Pool, "BuySkin", p, p2)
end)

v15.UpgradeRequested:Connect(function(p: string)
	PoolAudio.PlayCue("MenuOpen")
	RemoteSignals.FireServer(RemoteEnums.Pool, "UpgradeCue", p)
end)

v14:ListenToWrite("PoolCueUpgrades", function()
	if v15.Root.Visible then
		PoolInventoryMenu.RefreshEquipped(v15)
		PoolInventoryMenu.DressSlots(v15, "cueSticks")
	end
end)

v14:ListenToWrite("Equipped", function()
	if v15.Root.Visible then
		PoolInventoryMenu.RefreshEquipped(v15)
	end
end)

local ResultScreen = PoolGameUI:WaitForChild("ResultScreen")
local v32 = nil
local v33 = false

local function cardPicksPending() -- 7 equivalent calls inferred from this helper
	return PoolCardRewards.HasPending(v14.Data)
end

local function resultScreenUp() -- 8 equivalent calls inferred from this helper
	return PoolGameUI.Enabled and ResultScreen.Visible
end

local function popupsClear(): boolean
	for _, childName in { "TutorialPopup", "StarterPackPopup" } do
		local guiObject = PoolMenuUI:FindFirstChild(childName)

		if guiObject and guiObject:IsA("GuiObject") and guiObject.Visible and PoolMenuUI.Enabled then
			return false
		end
	end

	local poolTutorialUI = PlayerGui:FindFirstChild("PoolTutorialUI")
	local tutorialPopup = poolTutorialUI and poolTutorialUI:FindFirstChild("TutorialPopup")

	return not (poolTutorialUI and poolTutorialUI.Enabled and tutorialPopup and tutorialPopup.Visible)
end

local function resultScreenReady() -- 5 equivalent calls inferred from this helper
	local v34 = resultScreenUp() -- inferred equivalent call

	if v34 then
		if v32 == nil then
			return false
		end

		return os.clock() - v32 >= 2.5
	end

	return v34
end

local function lobbyReady() -- 1 equivalent call inferred from this helper
	return PoolMenuUI.Enabled
		and v.Root.Visible
		and not (resultScreenUp() or PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId)))) -- inferred equivalent call
end

local function cardPickPlace(): nil | string -- 4 equivalent calls inferred from this helper
	if not popupsClear() then
		return nil
	end

	if resultScreenReady() then -- inferred equivalent call
		return "Result"
	end

	if lobbyReady() then -- inferred equivalent call
		return "Lobby"
	end

	return nil
end

local function watchCardPicks()
	if v33 or PoolCardPickScreen.IsOpen() or not cardPicksPending() then -- inferred equivalent call
		return
	end

	v33 = true

	task.spawn(function()
		while cardPicksPending() do -- inferred equivalent call
			local v34 = cardPickPlace() -- inferred equivalent call

			if v34 then
				task.wait(v34 == "Result" and 0.2 or 0.6)

				local pending = PoolCardRewards.NextPending(v14.Data)

				if pending then
					local v35

					if popupsClear() then
						if resultScreenReady() then -- inferred equivalent call
							v35 = "Result"
						else
							v35 = PoolMenuUI.Enabled
								and v.Root.Visible
								and not resultScreenUp() -- inferred equivalent call
								and not (PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId))))
								and "Lobby"
								or nil
						end
					end

					if v35 == v34 then
						local play = PoolCardPickScreen.Play
						local v36 = {
							Tier = pending.Tier,
							First = PoolCardRewards.IsFirstOpening(v14.Data),
							KeepOpen = 0
						}
						local keepOpen

						if v34 == "Result" then
							keepOpen = resultScreenUp
						end

						v36.KeepOpen = keepOpen
						local v38, v39 = play(v36)

						if v38 then
							task.wait(0.4)
						elseif not v39 then
							break
						end
					end
				end
			end

			task.wait(0.25)
		end

		v33 = false
	end)
end

local function trackResultScreen()
	if resultScreenUp() then -- inferred equivalent call
		v32 = v32 or os.clock()

		if not (v33 or PoolCardPickScreen.IsOpen()) then
			if not cardPicksPending() then -- inferred equivalent call
				return
			end

			v33 = true

			task.spawn(function()
				while cardPicksPending() do -- inferred equivalent call
					local v34 = cardPickPlace() -- inferred equivalent call

					if v34 then
						task.wait(v34 == "Result" and 0.2 or 0.6)

						local pending = PoolCardRewards.NextPending(v14.Data)

						if pending then
							local v35

							if popupsClear() then
								if resultScreenReady() then -- inferred equivalent call
									v35 = "Result"
								else
									v35 = PoolMenuUI.Enabled
										and v.Root.Visible
										and not resultScreenUp() -- inferred equivalent call
										and not (PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId))))
										and "Lobby"
										or nil
								end
							end

							if v35 == v34 then
								local play = PoolCardPickScreen.Play
								local v36 = {
									Tier = pending.Tier,
									First = PoolCardRewards.IsFirstOpening(v14.Data),
									KeepOpen = 0
								}
								local keepOpen

								if v34 == "Result" then
									keepOpen = resultScreenUp
								end

								v36.KeepOpen = keepOpen
								local v38, v39 = play(v36)

								if v38 then
									task.wait(0.4)
								elseif not v39 then
									break
								end
							end
						end
					end

					task.wait(0.25)
				end

				v33 = false
			end)
		end
	else
		v32 = nil
	end
end

ResultScreen:GetPropertyChangedSignal("Visible"):Connect(trackResultScreen)
PoolGameUI:GetPropertyChangedSignal("Enabled"):Connect(trackResultScreen)

if resultScreenUp() then
	v32 = v32 or os.clock()

	if not v33 and not PoolCardPickScreen.IsOpen() and cardPicksPending() then
		v33 = true

		task.spawn(function()
			while cardPicksPending() do -- inferred equivalent call
				local v34 = cardPickPlace() -- inferred equivalent call

				if v34 then
					task.wait(v34 == "Result" and 0.2 or 0.6)

					local pending = PoolCardRewards.NextPending(v14.Data)

					if pending then
						local v35

						if popupsClear() then
							if resultScreenReady() then -- inferred equivalent call
								v35 = "Result"
							else
								v35 = PoolMenuUI.Enabled
									and v.Root.Visible
									and not resultScreenUp() -- inferred equivalent call
									and not (PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId))))
									and "Lobby"
									or nil
							end
						end

						if v35 == v34 then
							local play = PoolCardPickScreen.Play
							local v36 = {
								Tier = pending.Tier,
								First = PoolCardRewards.IsFirstOpening(v14.Data),
								KeepOpen = 0
							}
							local keepOpen

							if v34 == "Result" then
								keepOpen = resultScreenUp
							end

							v36.KeepOpen = keepOpen
							local v38, v39 = play(v36)

							if v38 then
								task.wait(0.4)
							elseif not v39 then
								break
							end
						end
					end
				end

				task.wait(0.25)
			end

			v33 = false
		end)
	end
else
	v32 = nil
end

v14:ListenToWrite("PoolCardPicks", watchCardPicks)

if not v33 and not PoolCardPickScreen.IsOpen() and cardPicksPending() then
	v33 = true

	task.spawn(function()
		while cardPicksPending() do -- inferred equivalent call
			local v34 = cardPickPlace() -- inferred equivalent call

			if v34 then
				task.wait(v34 == "Result" and 0.2 or 0.6)

				local pending = PoolCardRewards.NextPending(v14.Data)

				if pending then
					local v35

					if popupsClear() then
						if resultScreenReady() then -- inferred equivalent call
							v35 = "Result"
						else
							v35 = PoolMenuUI.Enabled
								and v.Root.Visible
								and not resultScreenUp() -- inferred equivalent call
								and not (PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId))))
								and "Lobby"
								or nil
						end
					end

					if v35 == v34 then
						local play = PoolCardPickScreen.Play
						local v36 = {
							Tier = pending.Tier,
							First = PoolCardRewards.IsFirstOpening(v14.Data),
							KeepOpen = 0
						}
						local keepOpen

						if v34 == "Result" then
							keepOpen = resultScreenUp
						end

						v36.KeepOpen = keepOpen
						local v38, v39 = play(v36)

						if v38 then
							task.wait(0.4)
						elseif not v39 then
							break
						end
					end
				end
			end

			task.wait(0.25)
		end

		v33 = false
	end)
end

local v34 = false
local v35 = false
local v36 = false

local function venueBoxesWaiting(): boolean -- 6 equivalent calls inferred from this helper
	return PoolVenueLootbox.TotalWaiting(v14.Data) > 0
end

local function venueBoxPlaceClear()
	return PoolMenuUI.Enabled
		and (v.Root.Visible or v10.Root.Visible)
		and not resultScreenUp() -- inferred equivalent call
		and not (PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId))))
		and popupsClear()
		and not PoolMenuPopups.AnyShowing()
		and not (PoolCardPickScreen.IsOpen() or PoolCardRewards.HasPending(v14.Data) or PoolPackOpening.IsBusy() or PoolAchievementsMenu.IsVisible())
end

RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
	if p == "VenueBoxOpened" then
		v34 = false
		task.spawn(PoolPackOpening.Play, (...))
	elseif p == "VenueBoxRefused" then
		v34 = false
		v36 = true

		local v37 = ...

		Notifications.new("TextNotification", {
			message = typeof(v37) ~= "string" and "That lootbox could not be opened" or v37,
			colour = Color3.fromRGB(238, 108, 108)
		})
	end
end)

local function watchVenueBoxes()
	v36 = false

	if v35 or not venueBoxesWaiting() then -- inferred equivalent call
		return
	end

	v35 = true

	task.spawn(function()
		while venueBoxesWaiting() and not v36 do -- inferred equivalent call
			if venueBoxPlaceClear() then
				task.wait(0.8)

				if venueBoxPlaceClear() and venueBoxesWaiting() then -- inferred equivalent call
					v34 = true
					RemoteSignals.FireServer(RemoteEnums.Pool, "ClaimVenueBox")

					local lastTime3 = os.clock()

					while v34 and os.clock() - lastTime3 < 8 do
						task.wait(0.1)
					end

					v34 = false

					task.wait(0.2)

					while PoolPackOpening.IsBusy() do
						task.wait(0.2)
					end

					task.wait(0.5)
				end
			end

			task.wait(0.25)
		end

		v35 = false
	end)
end

v14:ListenToWrite("PoolVenueWins", watchVenueBoxes)
v14:ListenToWrite("PoolVenueBoxes", function()
	refreshCurrency()
	v36 = false

	if not v35 and venueBoxesWaiting() then -- inferred equivalent call
		v35 = true

		task.spawn(function()
			while venueBoxesWaiting() and not v36 do -- inferred equivalent call
				if venueBoxPlaceClear() then
					task.wait(0.8)

					if venueBoxPlaceClear() and venueBoxesWaiting() then -- inferred equivalent call
						v34 = true
						RemoteSignals.FireServer(RemoteEnums.Pool, "ClaimVenueBox")

						local lastTime3 = os.clock()

						while v34 and os.clock() - lastTime3 < 8 do
							task.wait(0.1)
						end

						v34 = false

						task.wait(0.2)

						while PoolPackOpening.IsBusy() do
							task.wait(0.2)
						end

						task.wait(0.5)
					end
				end

				task.wait(0.25)
			end

			v35 = false
		end)
	end
end)

v14:ListenToWrite("PoolCardPicks", watchVenueBoxes)
watchVenueBoxes()

local achievements = PoolMenuUI:WaitForChild("HomeMenu"):FindFirstChild("Achievements")

if achievements then
	PoolMenuWidgets.SetButtonColour(achievements, Color3.fromRGB(255, 176, 40))

	local achievementsBadge = PoolMenuWidgets.Badge(achievements.Parent, "", achievements.ZIndex + 3400)
	local v37 = achievements.Position + UDim2.fromScale(
		achievements.Size.X.Scale * (1 - achievements.AnchorPoint.X),
		-achievements.Size.Y.Scale * achievements.AnchorPoint.Y
	)

	achievementsBadge.Name = "AchievementsBadge"
	achievementsBadge.Position = v37 - UDim2.fromScale(0.006, -0.006)
	achievementsBadge.Size = UDim2.fromScale(0.05, 0.055)
	achievementsBadge.Visible = false

	achievements.Activated:Connect(function()
		if PoolPackOpening.IsBusy() then
			return
		end

		PoolAchievementsMenu.Show()
	end)

	PoolAchievementsMenu.Watch(function(p: number)
		achievementsBadge.Text = p > 9 and "9+" or tostring(p)
		achievementsBadge.Visible = p > 0
	end)
else
	warn("[PoolMenuUIHandler] HomeMenu has no Achievements key")
end

local function configValue(p: string, p2: string) -- 12 equivalent calls inferred from this helper
	local configuration = v14.Data.configuration
	local misc = configuration and configuration.misc
	local selected = misc and misc[p]

	return if typeof(selected) == "string" then selected else p2
end

local function applyAimMode()
	PoolGameUI:SetAttribute("AimMode", configValue("poolAimMode", "Drag")) -- inferred equivalent call

	local v37 = tonumber(configValue("poolAimSensitivity", "5")) or 5 -- inferred equivalent call

	PoolGameUI:SetAttribute("AimSensitivity", (math.clamp(v37, 1, 5)))

	local v38 = tonumber(configValue("poolSoundVolume", "7")) or 7 -- inferred equivalent call

	PoolGameUI:SetAttribute("SoundVolume", math.clamp(v38, 1, 10) / 10)

	PoolGameUI:SetAttribute("HidePredictions", configValue("poolHidePredictions", "Off") == "On") -- inferred equivalent call
	PoolGameUI:SetAttribute("ShowSkins", configValue("poolShowSkins", "On") == "On") -- inferred equivalent call

	PoolHaptics.SetEnabled(configValue("poolHaptics", "On") == "On") -- inferred equivalent call
end

local function refreshSettings()
	PoolSettingsMenu.SetValue(v13, "poolAimMode", configValue("poolAimMode", "Drag")) -- inferred equivalent call
	PoolSettingsMenu.SetValue(v13, "poolAimSensitivity", configValue("poolAimSensitivity", "5")) -- inferred equivalent call
	PoolSettingsMenu.SetValue(v13, "poolSoundVolume", configValue("poolSoundVolume", "7")) -- inferred equivalent call
	PoolSettingsMenu.SetValue(v13, "poolHidePredictions", configValue("poolHidePredictions", "Off")) -- inferred equivalent call
	PoolSettingsMenu.SetValue(v13, "poolShowSkins", configValue("poolShowSkins", "On")) -- inferred equivalent call
	PoolSettingsMenu.SetValue(v13, "poolHaptics", configValue("poolHaptics", "On")) -- inferred equivalent call
end

local flag = false

local function showSettings() -- 1 equivalent call inferred from this helper
	PoolAudio.PlayCue("MenuOpen")
	flag = false
	hideAllMenus()
	refreshSettings()
	PoolSettingsMenu.SetVisible(v13, true)
	PoolGameUI.Enabled = false
end

local function showSettingsOverTable() -- 1 equivalent call inferred from this helper
	PoolAudio.PlayCue("MenuOpen")
	flag = true
	hideAllMenus()
	refreshSettings()
	PoolSettingsMenu.SetVisible(v13, true)
end

PoolGameUI:GetAttributeChangedSignal("OpenSettings"):Connect(function()
	if not PoolGameUI:GetAttribute("MatchActive") then
		return
	end

	showSettingsOverTable() -- inferred equivalent call
end)

v13.Changed:Connect(function(p: string, p2: string)
	PoolSettingsMenu.SetValue(v13, p, p2)

	RemoteSignals.FireServer(RemoteEnums.Pool, "SetSetting", p, p2)
end)

v13.Closed:Connect(function()
	if flag then
		flag = false

		PoolSettingsMenu.SetVisible(v13, false)
	else
		showHome() -- inferred equivalent call
	end
end)

v14:ListenToWrite("SetConfig", function()
	refreshSettings()
	applyAimMode()
end)

Button.Create(EventsMenu.Background.Header.Exit, function()
	PoolAudio.PlayCue("MenuClose")
	showHome() -- inferred equivalent call
end)

v.Selected:Connect(function(p: string)
	RemoteSignals.FireServer(RemoteEnums.Pool, "MenuOpened", p)

	if p == "Bots" then
		showBots() -- inferred equivalent call
	elseif p == "Solo" or p == "Trickshot" then
		if p == "Solo" then
			startOffline("Solo") -- inferred equivalent call
		elseif p == "Trickshot" then
			showLevelSelect()
		end
	elseif p == "OneOnOne" then
		showVenues("EightBall")
	elseif p == "NineBall" then
		showNineBall() -- inferred equivalent call
	elseif p == "Settings" then
		showSettings() -- inferred equivalent call
	elseif p == "WithFriends" then
		v29 = nil
		showFriends() -- inferred equivalent call
	elseif p == "Inventory" then
		showInventory()
	elseif p == "Shop" then
		showShop()
	elseif p == "Battlepass" or p == "Season" then
		showBattlepass() -- inferred equivalent call
	elseif p == "Profile" then
		PoolStatsPopup.OpenSelf()
	else
		warn(string.format("[Pool] %q is not wired up yet", p))
	end
end)

v10.Chosen:Connect(function(data)
	if coins() < data.EntryFee then -- inferred equivalent call
		Notifications.new("TextNotification", {
			message = string.format(
				"You need $%s more to play %s",
				NumberHelper:Separate(data.EntryFee - coins()), -- inferred equivalent call
				(tostring(data.Name))
			),
			colour = Color3.fromRGB(238, 108, 108)
		})

		return
	end

	local v37 = v19

	if v37 then
		v19 = nil
		v20 = nil
		PoolVenueMenu.SetChallengeTarget(v10, nil)

		RemoteSignals.FireServer(RemoteEnums.Pool, "Challenge", v37, data.Id)
		showFriends() -- inferred equivalent call
	elseif PoolConstants.IsNineBallVenue(data.Id) and needsNineBallHowTo() then -- inferred equivalent call
		v25 = data
		PoolAudio.PlayCue("MenuOpen")
		PoolNineBallPopup.Show(v16)
	else
		beginSearch(data) -- inferred equivalent call
	end
end)

v10.Exit:Connect(function()
	if v19 then
		v19 = nil
		v20 = nil
		PoolVenueMenu.SetChallengeTarget(v10, nil)
		showFriends() -- inferred equivalent call
	else
		showHome() -- inferred equivalent call
	end
end)

v10.FriendsRequested:Connect(function()
	v29 = "Venues"
	showFriends() -- inferred equivalent call
end)

v10.InviteRequested:Connect(function()
	task.spawn(function()
		if FriendHelper.CanSendInvite((tostring(UserId))) == false then
			Notifications.new("TextNotification", {
				message = "Invites aren't available on your account",
				colour = Color3.fromRGB(238, 108, 108)
			})

			return
		end

		PoolAudio.PlayCue("MenuOpen")
		PoolInviteMenu.PromptAnyone()
	end)
end)

v14:ListenToWrite("Currency1", refreshCurrency)
v14:ListenToWrite("Currency2", refreshCurrency)
v14:ListenToWrite("Experience", refreshCurrency)

v14:ListenToWrite("PoolVenueWins", refreshCurrency)

v14:ListenToWrite("PoolBotWins", refreshCurrency)

v10.PassRequested:Connect(function()
	PoolWorldPassCard.Prompt()
end)

v14:ListenToWrite("Gamepasses", refreshCurrency)

v14:ListenToWrite("WinStreak", refreshCurrency)

local function refreshHomePlayer()
	PoolHomeMenu.SetPlayer(
		v,
		LocalPlayer.DisplayName,
		PoolPlayerData.Thumbnail(UserId),
		PoolVip.Owns(LocalPlayer.UserId)
	)
end

v14:ListenToWrite("Gamepasses", refreshHomePlayer)

refreshHomePlayer()
refreshCurrency()
refreshSettings()
applyAimMode()

PoolGameUI:GetAttributeChangedSignal("MatchActive"):Connect(function()
	if not (PoolGameUI:GetAttribute("MatchActive") or PoolGameUI.Enabled) then
		if PoolGameUI:GetAttribute("MatchMode") == "Trickshot" then
			if PoolGameUI:GetAttribute("CommunityCode") == nil then
				showLevelSelect()

				return
			end

			PoolGameUI:SetAttribute("CommunityCode", nil)
			showCommunity() -- inferred equivalent call
		else
			showHome() -- inferred equivalent call
		end
	end
end)

RunService.RenderStepped:Connect(function(dt: number)
	PoolSearchMenu.Update(v12, dt)

	if v8.Root.Visible and os.clock() - lastTime >= 3 then
		requestRoster() -- inferred equivalent call
	end

	if v3.Root.Visible and os.clock() - lastTime2 >= 0.25 then
		lastTime2 = os.clock()
		refreshLives() -- inferred equivalent call
	end

	if v26 then
		local state = PoolMatchReplica.GetState()

		if state and state.StartsAt > 0 then
			local v37 = state.StartsAt - workspace:GetServerTimeNow()

			PoolSearchMenu.SetCountdown(v12, v37)

			if v37 < -3 and not v27 then
				v27 = true
				v26 = false
				showTable("Online") -- inferred equivalent call
			end
		end
	end
end)

local function needsIntroduction(): boolean -- 1 equivalent call inferred from this helper
	local tutorials = v14.Data.tutorials

	return typeof(tutorials) ~= "table" or not tutorials.Introduction
end

local v37 = false

local function runFirstMatch()
	v37 = true

	local v38 = venueById(PoolConstants.Tutorial.FirstMatchVenueId) or PoolConstants.Venues[1] -- inferred equivalent call

	if v38 then
		hideAllMenus()
		PoolMenuUI.Enabled = true
		PoolSearchMenu.BeginSearch(v12, v38)
		PoolSearchMenu.SetStatus(v12, "Finding an opponent")

		PoolSearchMenu.SetCancelable(v12, false)
		PoolSearchMenu.SetVisible(v12, true)

		task.delay(PoolConstants.Tutorial.FakeSearchSeconds, function()
			PoolSearchMenu.SetVisible(v12, false)
			startBotMatch(PoolConstants.Tutorial.FirstMatchBotLevel) -- inferred equivalent call
		end)
	else
		startBotMatch(PoolConstants.Tutorial.FirstMatchBotLevel) -- inferred equivalent call
	end
end

PoolGameUI:GetAttributeChangedSignal("TutorialFirstMatch"):Connect(runFirstMatch)

Tutorial.Finished:Connect(function()
	v37 = true
	task.spawn(PoolTutorialFlow.OfferFirstMatch)
end)

local function showArrival(venueId2: string): boolean
	local v38 = venueById(venueId2) -- inferred equivalent call

	if not v38 then
		return false
	end

	hideAllMenus()

	PoolSearchMenu.BeginSearch(v12, v38, false)

	PoolSearchMenu.SetJoining(v12)
	PoolSearchMenu.SetVisible(v12, true)
	PoolGameUI.Enabled = false

	task.delay(25, function()
		if v27 or PoolGameUI:GetAttribute("MatchActive") or PoolMatchReplica.GetState() then
			return
		end

		showHome() -- inferred equivalent call
	end)

	return true
end

local state = PoolMatchReplica.GetState()

if not (v27 or PoolGameUI:GetAttribute("MatchActive")) then
	if state and state.Active then
		onMatchState()
	elseif not (venueId and showArrival(venueId)) then
		if needsIntroduction() then
			hideAllMenus()
			PoolMenuUI.Enabled = false
			PoolGameUI.Enabled = false

			task.delay(20, function()
				if
					not v37
					and needsIntroduction() -- inferred equivalent call
					and not (PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId))))
				then
					warn("[PoolMenuUIHandler] no tutorial arrived; opening the lobby")

					PoolMenuUI.Enabled = true
					showHome() -- inferred equivalent call
				end
			end)
		else
			showHome()

			PoolMenuPopups.OnJoin(function()
				return PoolMenuUI.Enabled
					and v.Root.Visible
					and not (PoolGameUI:GetAttribute("MatchActive") or Tutorial.IsPlaying((tostring(UserId))) or PoolCardPickScreen.IsOpen() or cardPicksPending()) -- inferred equivalent call
			end)
		end
	end
end

PoolMenuUI:SetAttribute("Ready", true)