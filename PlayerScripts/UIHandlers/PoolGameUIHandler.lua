local v = game:GetService("Players")
local v2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local Notifications = require(v2.Libraries.Classes.Notifications)
local Profiles = require(v2.Libraries.Modules.Profiles)
local RemoteEnums = require(v2.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(v2.Libraries.Modules.RemoteSignals)

local pool = v2:WaitForChild("Libraries"):WaitForChild("GameSpecific"):WaitForChild("Pool")
local PoolMatchmakingConstants = require(pool:WaitForChild("PoolMatchmakingConstants"))
local PoolAimOverlay = require(pool:WaitForChild("PoolAimOverlay"))
local PoolAudio = require(pool:WaitForChild("PoolAudio"))
local PoolVisuals = require(pool:WaitForChild("PoolVisuals"))
local PoolAI = require(pool:WaitForChild("PoolAI"))
local PoolCoach = require(pool:WaitForChild("PoolCoach"))
local PoolFriendOpponent = require(pool:WaitForChild("PoolFriendOpponent"))
local PoolSkill = require(pool:WaitForChild("PoolSkill"))
local PoolConstants = require(pool:WaitForChild("PoolConstants"))
local PoolGeometry = require(pool:WaitForChild("PoolGeometry"))
local PoolHaptics = require(pool:WaitForChild("PoolHaptics"))

local PoolTableHaptics = require(pool:WaitForChild("PoolTableHaptics"))
local PoolHudRenderer = require(pool:WaitForChild("PoolHudRenderer"))
local PoolEmotes = require(pool:WaitForChild("PoolEmotes"))
local PoolFoulPopup = require(pool:WaitForChild("PoolFoulPopup"))
v2 = require(pool:WaitForChild("PoolQuestPanel"))
local PoolInputController = require(pool:WaitForChild("PoolInputController"))
local PoolMatchClient = require(pool:WaitForChild("PoolMatchClient"))
local PoolMatchReplica = require(pool:WaitForChild("PoolMatchReplica"))
local PoolPhysics = require(pool:WaitForChild("PoolPhysics"))
local PoolPlayerData = require(pool:WaitForChild("PoolPlayerData"))
local PoolRules = require(pool:WaitForChild("PoolRules"))
local PoolChatBox = require(pool:WaitForChild("PoolChatBox"))
local PoolResultScreen = require(pool:WaitForChild("PoolResultScreen"))
local PoolSkins = require(pool:WaitForChild("PoolSkins"))
local PoolPlayerStats = require(pool:WaitForChild("PoolPlayerStats"))
local PoolStatsPopup = require(pool:WaitForChild("PoolStatsPopup"))

local PoolStreakBadge = require(pool:WaitForChild("PoolStreakBadge"))

local PoolVip = require(pool:WaitForChild("PoolVip"))
local PoolStepper = require(pool:WaitForChild("PoolStepper"))
local PoolTutorialFlow = require(pool:WaitForChild("PoolTutorialFlow"))
local PoolTutorialScene = require(pool:WaitForChild("PoolTutorialScene"))
local PoolViewController = require(pool:WaitForChild("PoolViewController"))

local PoolTrickshotEditor = require(pool:WaitForChild("PoolTrickshotEditor"))
local PoolTrickshotMenu = require(pool:WaitForChild("PoolTrickshotMenu"))
local PoolTrickshotSaves = require(pool:WaitForChild("PoolTrickshotSaves"))
local PoolLevelResult = require(pool:WaitForChild("PoolLevelResult"))
local PoolLives = require(pool:WaitForChild("PoolLives"))
local PoolTrickshotTypes = require(pool:WaitForChild("PoolTrickshotTypes"))
local PoolLevelCatalog = require(pool:WaitForChild("PoolLevelCatalog"))
local PoolTrickshotCodes = require(pool:WaitForChild("PoolTrickshotCodes"))
local PoolModifiers = require(pool:WaitForChild("PoolModifiers"))
local PoolGoals = require(pool:WaitForChild("PoolGoals"))
local PoolCommunity = require(pool:WaitForChild("PoolCommunity"))
local PoolCommunityMenu = require(pool:WaitForChild("PoolCommunityMenu"))

local localPlayer = v.LocalPlayer
local poolGameUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("PoolGameUI")
local tbl = poolGameUI:WaitForChild("Table")

local view = PoolViewController.new(tbl)
local hud = PoolHudRenderer.new(poolGameUI)

v2.new(poolGameUI)

local v3 = PoolAimOverlay.new(view.Renderer2D.Overlay)
local v4 = PoolResultScreen.new(poolGameUI)

local v5 = PoolChatBox.new(poolGameUI, PoolMatchmakingConstants.ChatMaxLength)

local simulation = PoolPhysics.newSimulation()

local v6 = PoolStepper.new()
local v7 = PoolAudio.new()

local v8 = PoolTableHaptics.new()

local v9 = "Offline"
local v10 = nil

local v11 = nil

local v12 = nil

local v13 = 0

local v14 = nil
local v15 = false

local function solving(): boolean
	return v12 ~= nil or v14 ~= nil
end

local v16 = {}

local function firedCueBalls() -- 4 equivalent calls inferred from this helper
	local cueSet = {}

	for _, v17 in v16 do
		if v17.Cue then
			cueSet[v17.Cue] = true
		end
	end

	return cueSet
end

local function attemptDecided(flag: boolean) -- 1 equivalent call inferred from this helper
	local v17 = v11

	if not v17 then
		return false, false
	end

	local scene = PoolTrickshotEditor.GetScene(v17)
	local maxStarsFor = PoolGoals.MaxStarsFor(scene)

	if maxStarsFor <= 0 or not flag and PoolGoals.KindOf(scene) == "Bullseye" then
		return false, false
	end

	if maxStarsFor <= PoolGoals.Evaluate(scene, simulation).Stars then
		return true, true
	end

	return PoolGoals.NothingLeft(scene, simulation), false
end

local v17 = false

local v18 = { Size = tbl.Size, Position = tbl.Position }
local v19 = "Match"

local function setTableLayout(p: string)
	if v19 == p then
		return
	end

	v19 = p

	local v20 = PoolConstants.TableLayout[p]

	if v20 then
		tbl.AnchorPoint = Vector2.new(0.5, 0.5)
		tbl.Size = UDim2.new(1, -(v20.Left + v20.Right), 1, -(v20.Top + v20.Bottom))
		tbl.Position = UDim2.new(0.5, (v20.Left - v20.Right) / 2, 0.5, (v20.Top - v20.Bottom) / 2)
	else
		tbl.Size = v18.Size
		tbl.Position = v18.Position
	end
end

local refreshShotCount

local aimNextCueBall

local total = 0

local v20 = 0

local now = os.time()
v = PoolGeometry.BuildRack(Random.new(now))

PoolPhysics.Reset(simulation, v)
PoolViewController.RenderRack(view, v)

local input2 = PoolInputController.new(view, hud, v3, simulation)

local v21 = PoolCoach.new()

PoolFriendOpponent.Prefetch()

local function applyMode(viewMode: string)
	if viewMode ~= "2D" and viewMode ~= "3D" then
		return
	end

	PoolViewController.SetMode(view, viewMode)
	PoolHudRenderer.SetViewToggleLabel(hud, viewMode == "2D" and "3D" or "2D")

	PoolAimOverlay.SetStickVisible(v3, viewMode == "2D")

	PoolHudRenderer.SetPottedRackVisible(hud, viewMode == "2D")

	if poolGameUI:GetAttribute("ViewMode") ~= viewMode then
		poolGameUI:SetAttribute("ViewMode", viewMode)
	end
end

applyMode("2D")
poolGameUI:SetAttribute("ViewMode", view.Mode)

hud.ViewToggle.Activated:Connect(function()
	applyMode(view.Mode == "2D" and "3D" or "2D")
end)

local function applyAimMode() -- 1 equivalent call inferred from this helper
	local aimMode = poolGameUI:GetAttribute("AimMode")

	PoolInputController.SetAimMode(input2, aimMode == "Tap" and "Tap" or "Drag")
end

local function applyAimSensitivity() -- 1 equivalent call inferred from this helper
	PoolInputController.SetDragSensitivity(input2, (tonumber(poolGameUI:GetAttribute("AimSensitivity"))))
end

local function applySoundVolume()
	local soundVolume = poolGameUI:GetAttribute("SoundVolume")
	local v22 = typeof(soundVolume) ~= "number" and 0.7 or soundVolume

	PoolAudio.SetVolumeScale(v7, v22)

	PoolAudio.SetGlobalVolume(v22)

	if v10 then
		PoolMatchClient.SetVolumeScale(v10, v22)
	end
end

local function applyVibration() -- 1 equivalent call inferred from this helper
	PoolTableHaptics.SetEnabled(v8, PoolHaptics.IsEnabled())
end

local function applyPredictionLines() -- 1 equivalent call inferred from this helper
	PoolAimOverlay.SetGuidesVisible(v3, poolGameUI:GetAttribute("HidePredictions") ~= true)
end

poolGameUI:GetAttributeChangedSignal("SoundVolume"):Connect(applySoundVolume)
poolGameUI:GetAttributeChangedSignal("HidePredictions"):Connect(applyPredictionLines)
applySoundVolume()
applyPredictionLines() -- inferred equivalent call
poolGameUI:GetAttributeChangedSignal("AimMode"):Connect(applyAimMode)
applyAimMode() -- inferred equivalent call
local count = 0

hud.Settings:Connect(function()
	count += 1

	poolGameUI:SetAttribute("OpenSettings", count)
end)

hud.Chat:Connect(function()
	if not PoolMatchmakingConstants.ChatEnabled then
		return
	end

	PoolChatBox.Show(v5)
end)

v5.Submitted:Connect(function(p: string)
	if not PoolMatchmakingConstants.ChatEnabled then
		return
	end

	RemoteSignals.FireServer(RemoteEnums.Pool, "Chat", p)
end)

poolGameUI:GetAttributeChangedSignal("AimSensitivity"):Connect(applyAimSensitivity)
applyAimSensitivity() -- inferred equivalent call
poolGameUI:GetAttributeChangedSignal("ViewMode"):Connect(function()
	applyMode(poolGameUI:GetAttribute("ViewMode"))
end)

local displayPositionsByNumber = {}

for _, v22 in v do
	displayPositionsByNumber[v22.Number] = v22.DisplayPosition
end

local v22 = false

local function rackHasBeenStruck(): boolean -- 1 equivalent call inferred from this helper
	for _, event in simulation.Events do
		if event.Kind == "BallHit" then
			return true
		end
	end

	return false
end

local v23 = PoolRules.newMatch(1)
local v24 = PoolRules.BeginShot(v23, simulation)
local v25 = 0
local v26 = false

local v27 = { "Player 1", "Player 2" }

local v28 = { "", "" }

local v29 = nil

local v30 = nil

local v31 = 0

local flag = false

local flag2 = false

local v32 = nil

local v36 = {}

local v37 = 0

local v38 = nil

local count2 = 0

local function setEmoteSide(p: string?) -- 4 equivalent calls inferred from this helper
	v38 = p
	PoolHudRenderer.SetEmoteSide(hud, p)
end

hud.Emote:Connect(function(p: string)
	local v39 = v38

	if not (v39 and PoolEmotes.IsPlayerChoice(p)) then
		return
	end

	PoolHudRenderer.PlayEmote(hud, v39, p)

	local v40 = v10

	if not v40 then
		return
	end

	local success, result = pcall(function(): boolean
		local seat = PoolMatchClient.GetSeat(v40)
		local seatEntry = PoolMatchClient.GetSeatEntry(v40, seat == 1 and 2 or 1)

		return seatEntry ~= nil and (tonumber(seatEntry.UserId) or 0) > 0
	end)

	if success and result then
		RemoteSignals.FireServer(RemoteEnums.Pool, "Emote", p)
	end
end)

local function startBotEmoteSpam() -- 1 equivalent call inferred from this helper
	count2 += 1

	local v39 = count2
	local v40 = v29

	if not v40 or flag2 or PoolEmotes.StyleOf(v40) ~= "Spammer" then
		return
	end

	task.spawn(function()
		while count2 == v39 and v29 == v40 do
			task.wait(PoolEmotes.Between(PoolEmotes.BurstEvery))

			if count2 ~= v39 or v29 ~= v40 then
				break
			end

			if not (v23 and v23.Turn ~= 2) then
				continue
			end

			for _ = 1, math.random(PoolEmotes.BurstSize.Min, PoolEmotes.BurstSize.Max) do
				if count2 ~= v39 or v29 ~= v40 then
					return
				end

				PoolHudRenderer.PlayEmote(hud, "Right", PoolEmotes.Pick(PoolEmotes.SpammerEmotes))
				task.wait(PoolEmotes.Between(PoolEmotes.BurstGap))
			end
		end
	end)
end

local count3 = 0

local set = {}
local count4 = 0

local v39 = {}

local v40 = nil

local v41 = PoolVisuals.new()

local function sideOf(p: number): string -- 2 equivalent calls inferred from this helper
	return if p == 1 then "Left" else "Right"
end

local function turnSeconds() -- 2 equivalent calls inferred from this helper
	return PoolConstants.Rules.DefaultTurnTime + PoolSkins.GetCueEffects().Time
end

local function refreshHud()
	PoolHudRenderer.SetActiveSide(hud, sideOf(v23.Turn)) -- inferred equivalent call

	PoolHudRenderer.SetGroup(hud, "Left", v23.Groups[1])
	PoolHudRenderer.SetGroup(hud, "Right", v23.Groups[2])

	for _, v42 in simulation.Order do
		if not (simulation.Balls[v42].Pocketed and v42 ~= PoolConstants.CueBallNumber) then
			continue
		end

		PoolHudRenderer.SetBallPotted(hud, v42, true)
		PoolViewController.RackBall(view, v42)
	end

	for i = 1, 2 do
		local group = v23.Groups[i]
		local v42 = group ~= nil and PoolRules.CountRemaining(simulation, group) == 0

		PoolHudRenderer.SetOnEight(hud, sideOf(i), v42) -- inferred equivalent call
	end
end

local function returnCueBall()
	local ball = simulation.Balls[PoolConstants.CueBallNumber]

	if not ball then
		return
	end

	ball.Pocketed = false
	ball.Sinking = false
	ball.PocketId = nil
	ball.Velocity = Vector2.zero
	ball.Spin = Vector2.zero
	ball.Position = PoolRules.ClampPlacement(v23, PoolGeometry.RespotSpot)

	v39[PoolConstants.CueBallNumber] = nil

	PoolViewController.ReturnBall(view, PoolConstants.CueBallNumber, ball.Position)
end

local function botIsUp(): boolean -- 7 equivalent calls inferred from this helper
	return v29 ~= nil and v23.Turn == 2 and not v26 and v23.Phase ~= "GameOver"
end

local fn

local function highlightOwnBalls()
	local group = PoolRules.GetGroup(v23, v23.Turn)

	if not group then
		return
	end

	local ballParts = {}

	for _, v42 in simulation.Order do
		local ball = simulation.Balls[v42]

		if not ball or ball.Pocketed or v42 == PoolConstants.CueBallNumber then
			continue
		end

		local v43 = v42 == PoolConstants.EightBallNumber
		local v44 = v42 < PoolConstants.EightBallNumber and "Solid" or "Stripe"
		local v45

		if v43 then
			v45 = PoolRules.CountRemaining(simulation, group) == 0
		else
			v45 = v44 == group
		end

		if not v45 then
			continue
		end

		local ballPart = PoolViewController.GetBallPart(view, v42)

		if ballPart then
			ballParts[v42] = ballPart
		end
	end

	PoolVisuals.HighlightBalls(v41, ballParts)
end

local function pickBotSkin(p: string, list)
	local modelNames = {}

	if #list > 0 then
		for _, item in list do
			local item2 = PoolSkins.GetItem(p, item)
			local modelName = item2 and item2.modelName

			if typeof(modelName) == "string" and modelName ~= "" then
				table.insert(modelNames, modelName)
			else
				warn(string.format("[Pool] bot %s %q is not a skin with a model", p, (tostring(item))))
			end
		end
	else
		for _, v42 in PoolSkins.GetAll(p) do
			local modelName

			if typeof(v42) == "table" then
				modelName = v42.modelName
			end

			if typeof(modelName) == "string" and modelName ~= "" then
				table.insert(modelNames, modelName)
			end
		end

		table.sort(modelNames)
	end

	if #modelNames > 0 then
		return modelNames[math.random(1, #modelNames)]
	end

	return nil
end

local function pickBotCue(p) -- 2 equivalent calls inferred from this helper
	return pickBotSkin("cueSticks", p)
end

local function onlineSeatCue(p: number)
	local state = PoolMatchReplica.GetState()
	local v42 = state and state.Seats and state.Seats[p]

	if v42 and v42.UserId == localPlayer.UserId then
		return nil
	end

	local cueSkin = v42 and v42.CueSkin

	if typeof(cueSkin) == "string" and cueSkin ~= "" then
		v36[p] = cueSkin

		return cueSkin
	end

	local v43 = v36[p]

	if v43 then
		return v43
	end

	if not v42 or v42.IsBot ~= true and not (v42.UserId <= 0) then
		return nil
	end

	local botCue = pickBotCue(PoolConstants.BotCuesFor(state and state.VenueId or nil)) -- inferred equivalent call

	if botCue then
		v36[p] = botCue
	end

	return botCue
end

local function applyTableSkin(_: number?) -- 3 equivalent calls inferred from this helper
	PoolViewController.SetTableSkin(view, PoolSkins.GetTableModelName())
end

local function applyCueSkin(p: number?)
	if v29 ~= nil and v23.Turn == 2 then
		PoolViewController.SetCueStickModel(view, v32)
	elseif v9 == "Online" then
		PoolViewController.SetCueStickModel(view, onlineSeatCue(p or v23.Turn))
	else
		PoolViewController.SetCueStickModel(view, nil)
	end
end

local v42 = 0

local function beginTurn(flag3: boolean?)
	v24 = PoolRules.BeginShot(v23, simulation)
	v25 = os.clock() + turnSeconds() -- inferred equivalent call
	refreshHud()
	applyTableSkin() -- inferred equivalent call
	applyCueSkin()

	local v43 = not flag3 and v23.Turn ~= v42

	v42 = v23.Turn

	if v43 and not botIsUp() then -- inferred equivalent call
		PoolAudio.PlayCue(v23.BallInHand and "TurnStartBallInHand" or "TurnStart")
	end

	PoolVisuals.Clear(v41)

	if not botIsUp() then -- inferred equivalent call
		if v23.BallInHand then
			PoolVisuals.ShowBallInHand(v41, PoolViewController.GetBallPart(view, PoolConstants.CueBallNumber))
		end

		highlightOwnBalls()
	end

	if not botIsUp() then -- inferred equivalent call
		PoolInputController.ReleaseAim(input2)
	end

	fn()
end

local function pocketEventFor(p: number) -- 1 equivalent call inferred from this helper
	for _, event in simulation.Events do
		if event.Kind == "Pocketed" and event.Ball == p then
			return event
		end
	end

	return nil
end

local function isRewardablePot(p: number)
	if v9 == "Trickshot" then
		local v43

		if v11 then
			v43 = PoolTrickshotTypes.FindById(v11.Scene, p)
		end

		return v43 ~= nil and PoolTrickshotTypes.IsGolden(v43)
	else
		local group = PoolRules.GetGroup(v23, v23.Turn)

		if p == PoolConstants.CueBallNumber then
			return false
		end

		if p == PoolConstants.EightBallNumber then
			return group ~= nil and PoolRules.CountRemaining(simulation, group) == 0
		else
			local v43 = p < PoolConstants.EightBallNumber and "Solid" or "Stripe"

			if group then
				return v43 == group
			end

			if v23.Phase ~= "Open" then
				return false
			end

			if not v40 then
				v40 = v43
			end

			return v43 == v40
		end
	end
end

local function startDrop(p: number)
	if v39[p] then
		return
	end

	v39[p] = true

	if v9 == "Trickshot" then
		local v43 = (p ~= PoolConstants.CueBallNumber and v11 and true or false)
			and PoolTrickshotTypes.FindById(v11.Scene, p)

		if v43 then
			task.delay(PoolMatchmakingConstants.RackDelay, function()
				if v39[p] then
					PoolViewController.RackBall(view, v43.N)
				end
			end)
		end
	elseif p ~= PoolConstants.CueBallNumber then
		task.delay(PoolMatchmakingConstants.RackDelay, function()
			if v39[p] then
				PoolHudRenderer.SetBallPotted(hud, p, true)
				PoolViewController.RackBall(view, p)
			end
		end)
	end

	local event = pocketEventFor(p) -- inferred equivalent call
	local v44 = nil

	if event and event.PocketId then
		for _, v45 in PoolGeometry.GetPockets() do
			if v45.Id == event.PocketId then
				v44 = v45
			end
		end

		local holeIndex = PoolModifiers.HoleIndex(event.PocketId)

		if not v44 and holeIndex and v11 then
			local v45 = (v11.Scene.Mods or {})[holeIndex]
			local v46

			if v45 then
				v46 = PoolModifiers.Get(v45.K)
			end

			if v45 and v46 then
				v44 = PoolModifiers.HoleAsPocket(
					event.PocketId,
					Vector2.new(v45.X, v45.Y),
					PoolModifiers.RadiusOf(v46, v45.S),
					event.EntryPosition,
					event.EntryDirection
				)
			end
		end
	end

	if v44 then
		PoolViewController.PocketBall(view, p, v44, event.EntryPosition, event.EntrySpeed)

		if isRewardablePot(p) then
			if not botIsUp() then -- inferred equivalent call
				PoolHaptics.PotYourBall()
			end

			local v45

			if v29 == nil then
				v45 = false
			else
				v45 = v23.Turn == 2
			end

			local playPot = PoolVisuals.PlayPot
			local world = PoolViewController.ToWorld(v44.MouthCentre, PoolConstants.VisualCues.PottedHeight)
			local v46

			if not v45 then
				v46 = PoolSkins.GetPotEffectName()
			end

			playPot(world, v46)
		end
	else
		PoolViewController.SetBallVisible(view, p, false)
	end
end

local function syncBalls()
	if not v22 and rackHasBeenStruck() then -- inferred equivalent call
		v22 = true
	end

	for _, v43 in simulation.Order do
		local ball = simulation.Balls[v43]

		if ball.Pocketed then
			startDrop(v43)
		elseif ball.Destroyed then
			if not v39[v43] then
				v39[v43] = true
				PoolViewController.BurnBall(view, v43)
			end
		elseif not PoolViewController.IsDropping(view, v43) then
			local v44 = ball.Position

			if not v22 and displayPositionsByNumber[v43] then
				v44 = displayPositionsByNumber[v43]
			end

			PoolViewController.SetBallHeight(view, v43, ball.Height or 0)
			PoolViewController.SetBall(view, v43, v44)
		end
	end
end

local function rerack()
	local rack = PoolGeometry.BuildRack(Random.new(os.clock() * 1000 % 1000000000))

	table.clear(displayPositionsByNumber)

	for _, v43 in rack do
		displayPositionsByNumber[v43.Number] = v43.DisplayPosition
	end

	v22 = false
	table.clear(v39)
	PoolPhysics.Reset(simulation, rack)

	PoolAudio.Reset(v7)

	PoolTableHaptics.Reset(v8)
	PoolViewController.ClearRack(view)

	PoolHudRenderer.ResetRows(hud)

	for _, v43 in simulation.Order do
		PoolViewController.SetBallVisible(view, v43, true)
	end

	PoolViewController.RenderRack(view, rack)
end

local function localSeat() -- 4 equivalent calls inferred from this helper
	if v9 == "Bots" then
		return 1
	end

	if v9 ~= "Online" or not v10 then
		return nil
	end

	local seat = PoolMatchClient.GetSeat(v10)
	return if seat > 0 then seat else nil
end

local function isYou(turn: number): boolean -- 2 equivalent calls inferred from this helper
	local v43 = localSeat() -- inferred equivalent call
	return v43 == nil or v43 == turn
end

local function groupAssignedText(turn: number, groupAssigned)
	local v43 = localSeat() -- inferred equivalent call

	if v43 then
		return string.format("You're %s!", PoolRules.DescribeGroup(PoolRules.GetGroup(v23, v43)))
	end

	return string.format("%s, you're %s!", v27[turn], PoolRules.DescribeGroup(groupAssigned))
end

local function onSettled()
	if not v26 then
		return
	end

	v26 = false

	local turn = v23.Turn
	local shot = PoolRules.ResolveShot(v23, simulation, v24)

	v40 = nil

	if flag2 and turn ~= 2 and shot.Legal and not shot.Rerack then
		local v43

		if v24 == nil then
			v43 = false
		else
			v43 = v24.WasBreak == true
		end

		for _, v44 in shot.Potted do
			if v44 == PoolConstants.CueBallNumber then
				continue
			end

			set[v44] = true

			if v43 then
				count4 += 1
			end
		end
	end

	for _, event in simulation.Events do
		if not (event.Kind == "Pocketed" and event.Ball ~= PoolConstants.CueBallNumber) then
			continue
		end

		PoolHudRenderer.SetBallPotted(hud, event.Ball, true)
		PoolViewController.RackBall(view, event.Ball)
	end

	if shot.Winner and shot.Winner ~= turn and isYou(turn) then -- inferred equivalent call
		PoolHudRenderer.ShowFoul(hud, PoolFoulPopup.ForLoss(shot.LossReason))
	end

	if shot.Winner then
		local v43 = flag2

		if v9 == "Bots" and v29 and shot.Winner ~= 2 and not v43 then
			RemoteSignals.FireServer(RemoteEnums.Pool, "BotWin", v29.Level.Id)
		end

		if v9 == "Bots" and v29 then
			local v44 = PoolFriendOpponent.Get()
			local v45

			if v44 then
				v45 = v44.UserId
			end

			PoolPlayerStats.RecordBotResult(PoolPlayerStats.SeedFor(v45, v27[2]), shot.Winner == 2)
		end

		if flag2 then
			flag2 = false

			RemoteSignals.FireServer(RemoteEnums.Pool, "FirstMatch", "Finish", shot.Winner ~= 2)
			local count5 = 0

			for _ in set do
				count5 += 1
			end

			RemoteSignals.FireServer(RemoteEnums.Pool, "TutorialFirstMatchResult", shot.Winner ~= 2, count5, count4)

			if shot.Winner == 2 then
				RemoteSignals.FireServer(RemoteEnums.Pool, "TutorialConsolation")

				task.spawn(function()
					task.wait(PoolMatchmakingConstants.ResultDelay + 1.5)
					PoolTutorialFlow.ShowConsolation()
				end)
			else
				RemoteSignals.FireServer(RemoteEnums.Pool, "TutorialFirstMatchWin")
			end
		end

		PoolInputController.EndMatch(input2)
		refreshHud()

		local winner = shot.Winner
		local lossReason = shot.LossReason

		task.delay(PoolMatchmakingConstants.ResultDelay, function()
			if flag and v23.Winner == winner then
				PoolResultScreen.SetSeries(v4, nil)
				PoolResultScreen.PlayOutcome(v4, winner, localSeat()) -- inferred equivalent call
				local v44

				if v9 == "Bots" then
					v44 = v27[winner]
				end

				if v43 then
					PoolResultScreen.SetRematchEnabled(v4, false)
					PoolResultScreen.SetExitLabel(v4, "BACK TO LOBBY")
				end

				PoolResultScreen.Show(v4, winner, v31, lossReason, nil, nil, v44)

				if v43 then
					task.delay(1 + math.random() * 3, function()
						if v4.Root.Visible then
							Notifications.new("TextNotification", {
								message = "Opponent doesn't want a rematch",
								colour = Color3.fromRGB(238, 108, 108)
							})
						end
					end)
				end
			end
		end)
	elseif shot.Rerack then
		PoolHudRenderer.Notify(hud, "8-ball on the break — re-racking", 3)
		rerack()
	else
		if shot.GroupAssigned then
			PoolHudRenderer.Notify(hud, groupAssignedText(turn, shot.GroupAssigned), 3)
		elseif #shot.Fouls > 0 then
			local primaryFoul = PoolRules.PrimaryFoul(shot.Fouls)
			local v43

			if isYou(turn) then -- inferred equivalent call
				v43 = PoolFoulPopup.ForFoul(primaryFoul, v23.GameType)
			end

			if v43 then
				PoolHudRenderer.ShowFoul(hud, v43)
			else
				PoolHudRenderer.Notify(hud, PoolRules.DescribeFoul(primaryFoul), 2.5)
			end
		elseif shot.TurnPasses then
			PoolHudRenderer.Notify(hud, string.format("%s's turn", v27[v23.Turn]), 2)
		end

		local ball = simulation.Balls[PoolConstants.CueBallNumber]
		local v43 = not (ball == nil) and ball.Pocketed

		if v43 then
			returnCueBall()
		end

		beginTurn()

		local turn2 = v23.Turn

		if not (v43 and v23.BallInHand) then
			PoolInputController.Hold(input2, PoolMatchmakingConstants.TurnStartDelay, function()
				if not flag or v23.Turn ~= turn2 or v23.Phase == "GameOver" then
					return
				end

				if not v23.BallInHand then
					PoolInputController.SetState(input2, "Aiming")
				elseif botIsUp() then -- inferred equivalent call
					fn()
				else
					PoolInputController.OfferBallInHand(input2)
				end
			end)
		elseif botIsUp() then -- inferred equivalent call
			fn()
		else
			PoolInputController.GiveBallInHand(input2)
		end
	end
end

input2.Shot:Connect(function(direction: Vector2, power: number, vector2: Vector2)
	if v9 == "Online" then
		return
	end

	if v9 == "Tutorial" then
		power = math.max(power, PoolConstants.Tutorial.MinShotPower)
	else
		v26 = true
	end

	if flag2 then
		count3 += 1

		RemoteSignals.FireServer(RemoteEnums.Pool, "FirstMatch", "Shot", count3)
	end

	local shoot = PoolPhysics.Shoot(simulation, direction, power, vector2)

	PoolAudio.PlayCueStrike(power)

	PoolVisuals.Clear(v41)

	PoolAudio.Reset(v7)
	PoolTableHaptics.Reset(v8)
	v20 = 0
	PoolHudRenderer.ResetSpin(hud)

	if v9 == "Trickshot" and shoot then
		table.insert(v16, {
			Cue = PoolPhysics.CueNumber(simulation),
			Direction = direction,
			Power = power,
			Spin = vector2 or Vector2.zero,
			Delay = math.min(total, PoolStepper.MaxShotDelaySteps)
		})

		total = 0

		if v12 and #v16 == 1 then
			RemoteSignals.FireServer(RemoteEnums.Pool, "LevelShot", v12)
		end

		refreshShotCount()
		aimNextCueBall()
	end
end)

local v43 = false
local v44 = nil

local v45 = nil

local flag3 = false
local v46 = nil

local v47 = nil

local fn2 = nil

local function setCameraMode(flag4: boolean) -- 2 equivalent calls inferred from this helper
	if flag4 and PoolConstants.FreeRoamCamera ~= true or v43 == flag4 then
		return
	end

	v43 = flag4
	v44 = nil
	v45 = nil
	flag3 = false
	v46 = nil
	v47 = nil

	if flag4 then
		PoolInputController.EnterCamera(input2)
		PoolViewController.SetCameraZoom(view, (math.max(PoolViewController.GetFitZoom(view), 1.5)))
	else
		PoolViewController.ResetCamera(view)
		PoolInputController.ExitCamera(input2)
	end

	if fn2 then
		fn2(flag4)
	end

	PoolHudRenderer.SetCameraActive(hud, flag4)
end

local function bindCameraDrag()
	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if not v43 then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonA and input.UserInputType.Name:sub(1, 7) == "Gamepad" then
			local GuiService = game:GetService("GuiService")

			if GuiService.SelectedObject == nil then
				flag3 = true
				v46 = UserInputService:GetMouseLocation()
			end
		else
			if gameProcessed or v44 or v47 then
				return
			end

			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				v44 = input
				v45 = Vector2.new(input.Position.X, input.Position.Y)
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not v43 then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			PoolViewController.SetCameraZoom(
				view,
				PoolViewController.GetZoom(view) * (1 + 0.12 * input.Position.Z),
				Vector2.new(input.Position.X, input.Position.Y)
			)

			return
		end

		if v44 == nil or v47 then
			return
		end

		local v48

		if input == v44 then
			v48 = true
		elseif v44.UserInputType == Enum.UserInputType.MouseButton1 then
			v48 = input.UserInputType == Enum.UserInputType.MouseMovement
		else
			v48 = false
		end

		if v48 then
			local vector2 = Vector2.new(input.Position.X, input.Position.Y)

			if v45 then
				PoolViewController.PanCamera(view, vector2 - v45)
			end

			v45 = vector2
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if v44 and input.UserInputType == v44.UserInputType then
			v44 = nil
			v45 = nil
		end

		if input.KeyCode == Enum.KeyCode.ButtonA then
			flag3 = false
			v46 = nil
		end
	end)

	UserInputService.TouchPinch:Connect(function(list, p: number, _: number, p2)
		if not v43 then
			return
		end

		if p2 == Enum.UserInputState.Begin then
			v47 = PoolViewController.GetZoom(view)
			v44 = nil
			v45 = nil
		elseif p2 == Enum.UserInputState.End or p2 == Enum.UserInputState.Cancel then
			v47 = nil
		elseif v47 and #list >= 2 then
			local midpoint = (list[1] + list[2]) / 2

			PoolViewController.SetCameraZoom(view, v47 * p, midpoint)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not poolGameUI.Enabled then
			return
		end

		if input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.ButtonX then
			setCameraMode(not v43)
		end
	end)

	RunService.RenderStepped:Connect(function(dt: number)
		if not v43 then
			return
		end

		if flag3 then
			local mouseLocation = UserInputService:GetMouseLocation()

			if v46 then
				local v48 = mouseLocation - v46

				if v48.Magnitude > 0 then
					PoolViewController.PanCamera(view, v48)
				end
			end

			v46 = mouseLocation
		end

		local v48 = 0
		local maxValue = 0

		for _, v49 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
			local keyCode = v49.KeyCode

			if keyCode == Enum.KeyCode.Thumbstick2 or keyCode == Enum.KeyCode.Thumbstick1 and not flag3 then
				local vector2 = Vector2.new(v49.Position.X, -v49.Position.Y)

				if vector2.Magnitude > 0.15 then
					PoolViewController.PanCamera(view, -vector2 * 700 * dt)
				end
			elseif keyCode == Enum.KeyCode.ButtonR2 or keyCode == Enum.KeyCode.ButtonL2 then
				local v50 = v49.UserInputState == Enum.UserInputState.Begin
					or v49.UserInputState == Enum.UserInputState.Change
				local v51 = not (v49.Position.Z > 0.05) and (v50 and 1 or 0) or v49.Position.Z

				if keyCode == Enum.KeyCode.ButtonR2 then
					v48 = math.max(v48, v51)
				else
					maxValue = math.max(maxValue, v51)
				end
			end
		end

		if not UserInputService:GetFocusedTextBox() then
			v48 = (UserInputService:IsKeyDown(Enum.KeyCode.Equals) or UserInputService:IsKeyDown(Enum.KeyCode.KeypadPlus))
				and 1
				or v48

			if
				UserInputService:IsKeyDown(Enum.KeyCode.Minus)
				or UserInputService:IsKeyDown(Enum.KeyCode.KeypadMinus)
			then
				maxValue = 1
			end
		end

		local v49 = v48 - maxValue

		if math.abs(v49) > 0.1 then
			PoolViewController.SetCameraZoom(view, PoolViewController.GetZoom(view) * 1.6 ^ (v49 * dt))
		end
	end)
end

if PoolConstants.FreeRoamCamera == true then
	bindCameraDrag()

	hud.CameraToggle.Activated:Connect(function()
		setCameraMode(not v43)
	end)
end

PoolHudRenderer.SetCameraActive(hud, false)

function input2.IsLegalTarget(p: number)
	return PoolRules.IsLegalFirstContact(v23, simulation, p)
end

function input2.ClampPlacement(vector2: Vector2)
	return PoolRules.ClampPlacement(v23, vector2)
end

PoolHudRenderer.SetWager(hud, v31)
PoolHudRenderer.SetWagerVisible(hud, v31 > 0)

local function localRating() -- 2 equivalent calls inferred from this helper
	local success, skill = pcall(PoolPlayerData.GetSkill, localPlayer.UserId)

	if success and typeof(skill) == "table" and tonumber(skill.Rating) then
		return skill.Rating
	end

	return PoolSkill.BaseRating
end

fn = function()
	v30 = nil

	if not botIsUp() then -- inferred equivalent call
		return
	end

	local v48 = v29

	local turn = PoolAI.BuildTurn(v48)

	local thinkTime = v48.Level.ThinkTime or 0
	local thinkUntil = os.clock() + thinkTime

	local placement = nil

	if v23.BallInHand and PoolAI.StaysForBreak(v48, simulation, v23) then
		v23.BallInHand = false
	elseif v23.BallInHand then
		local placeCueBallOptions = PoolAI.PlaceCueBallOptions(v48, simulation, v23, turn.Reconsider and 2 or 1)
		local v51

		if placeCueBallOptions[1] then
			v51 = PoolRules.ClampPlacement(v23, placeCueBallOptions[1])
		else
			v51 = PoolRules.ClampPlacement(v23, PoolAI.PlaceCueBall(v48, simulation, v23))
		end

		local v52

		if placeCueBallOptions[2] then
			v52 = PoolRules.ClampPlacement(v23, placeCueBallOptions[2])
		end

		local ball = simulation.Balls[PoolConstants.CueBallNumber]

		if ball then
			local v53

			if ball.Pocketed then
				v53 = PoolRules.ClampPlacement(v23, PoolGeometry.RespotSpot)
			else
				v53 = ball.Position
			end

			ball.Position = v53
			ball.Velocity = Vector2.zero
			ball.Pocketed = false

			PoolViewController.SetBallVisible(view, PoolConstants.CueBallNumber, true)
			PoolViewController.SetBall(view, PoolConstants.CueBallNumber, v53)

			PoolVisuals.ShowBallInHand(v41, PoolViewController.GetBallPart(view, PoolConstants.CueBallNumber))

			local placementLegs = PoolAI.BuildPlacementLegs(v48, simulation, turn, v51, v52, function(vector2: Vector2)
				return PoolRules.ClampPlacement(v23, vector2)
			end)

			local leg = table.remove(placementLegs, 1)

			placement = {
				From = v53,
				To = leg.To,
				Leg = leg,
				Legs = placementLegs,
				HoldUntil = thinkUntil + turn.PlaceHold,
				StartedAt = nil,
				Until = nil
			}
		else
			v23.BallInHand = false
		end
	end

	PoolInputController.SetState(input2, "Aiming")
	PoolInputController.SetAimDirection(input2, input2.Direction)

	PoolInputController.SetBallHeld(input2, placement ~= nil)

	v30 = {
		Plan = nil,
		Turn = turn,
		Placement = placement,
		Looks = {},
		Looking = 0,
		Confidence = 0.5,
		Resolved = false,
		Resolving = false,
		NextAt = 0,
		Phase = "Planning",
		From = input2.Direction,
		To = input2.Direction,
		SweepUntil = 0,
		SweepFrom = 0,
		Charge = 0,
		EarliestChargeAt = thinkUntil + PoolConstants.Bots.MinimumTurn,
		ThinkUntil = thinkUntil,
		AimShownAt = nil,
		LineShownSince = nil,
		ShotDirection = nil,
		ShotPower = nil,
		ShowDirection = nil
	}

	local v51 = v30

	task.spawn(function()
		while v30 == v51 and v51.Placement do
			task.wait()
		end

		while v30 == v51 and os.clock() < v51.ThinkUntil do
			task.wait()
		end

		if v30 ~= v51 then
			return
		end

		local plan = PoolAI.Plan(v48, simulation, v23, 2)

		if v30 ~= v51 then
			return
		end

		v51.Plan = plan
		v51.Confidence = PoolAI.Confidence(plan.Choice)

		v51.Looks = PoolAI.BuildLookSequence(v48, plan, v51.Turn, input2.Direction)
		v51.Phase = "Looking"
		v51.Looking = 1
		v51.NextAt = 0
	end)
end

local function botShoot()
	local v48 = v30
	local v49 = v29

	if not (v48 and v49) then
		return
	end

	local v50 = v48.ShotDirection
	local v51 = v48.ShotPower
	local v52 = v48.ShotSpin

	if not (v50 and v51) then
		v50, v51, v52 = PoolAI.Commit(v49, v48.Plan, simulation)
	end

	if not (v50 and v51) then
		v50, v51 = PoolAI.FallbackShot(simulation, v23)
	end

	v30 = nil
	v26 = true

	PoolInputController.SetState(input2, "Simulating")

	PoolInputController.SetPower(input2, 0)

	PoolPhysics.Shoot(simulation, v50, v51, v52 or Vector2.zero)

	PoolAudio.PlayCueStrike(v51)
	PoolAudio.Reset(v7)
	PoolHudRenderer.ResetSpin(hud)
end

local SweepAim = PoolAI.SweepAim

local function aimSeenLongEnough(p, now2: number): boolean -- 2 equivalent calls inferred from this helper
	local lineShownSince = p.LineShownSince

	if lineShownSince and now2 - lineShownSince >= PoolConstants.Bots.MinimumTurn then
		return true
	end

	return p.EarliestChargeAt + 4 <= now2
end

local function updateBot()
	local v48 = v30
	local v49 = v29

	if not (v48 and v49) then
		return
	end

	if PoolAimOverlay.IsAimShown(input2.Overlay) then
		v48.LineShownSince = v48.LineShownSince or os.clock()
	else
		v48.LineShownSince = nil
	end

	local placement = v48.Placement

	if placement then
		local now2 = os.clock()

		if now2 < placement.HoldUntil then
			return
		end

		if not placement.StartedAt then
			local buildCarry = PoolAI.BuildCarry
			local random = Random.new()
			local from = placement.From
			local to = placement.To
			local v50

			if placement.Leg then
				v50 = placement.Leg.Seconds
			end

			local carry = buildCarry(random, from, to, v50)

			placement.Carry = carry
			placement.StartedAt = now2
			placement.Until = now2 + carry.Seconds
		end

		local ball = simulation.Balls[PoolConstants.CueBallNumber]
		local startedAt = placement.StartedAt
		local v50 = math.max(placement.Until - startedAt, 0.001)
		local v51 = math.clamp((now2 - startedAt) / v50, 0, 1)

		if ball then
			local position

			if placement.Carry then
				position = PoolAI.CarryPosition(placement.Carry, placement.From, placement.To, v51)
			else
				position = placement.From:Lerp(placement.To, PoolAI.Ease(v51))
			end

			ball.Position = position

			PoolViewController.SetBall(view, PoolConstants.CueBallNumber, ball.Position)
		end

		if v51 >= 1 then
			local leg = placement.Leg
			local leg2 = table.remove(placement.Legs, 1)

			if leg2 then
				placement.From = placement.To
				placement.To = leg2.To
				placement.Leg = leg2
				placement.StartedAt = nil
				placement.Until = nil
				placement.Carry = nil
				placement.HoldUntil = now2 + (not leg and 0 or leg.HoldAfter)
			else
				v48.Placement = nil
				v23.BallInHand = false
				PoolVisuals.HideBallInHand(v41)

				PoolInputController.SetBallHeld(input2, false)
				refreshHud()
			end
		end
	else
		local plan = v48.Plan

		if not plan then
			return
		end

		local bots = PoolConstants.Bots
		local now2 = os.clock()

		if now2 < v48.SweepUntil then
			local v50 = math.max(v48.SweepUntil - v48.SweepFrom, 0.001)
			local v51 = math.clamp((now2 - v48.SweepFrom) / v50, 0, 1)

			local v52 = v51 * v51 * (3 - v51 * 2)

			PoolInputController.SetAimDirection(input2, SweepAim(v48.From, v48.To, v52))
		elseif now2 < v48.NextAt then
			if v48.Phase == "Committing" and v48.ShotPower then
				local v50

				if v48.Charge then
					v50 = PoolAI.ChargeFraction(v48.Charge, now2 - v48.SweepUntil)
				else
					v50 = math.clamp((now2 - v48.SweepUntil) / math.max(bots.Theatre.ChargeFillSeconds, 0.001), 0, 1)
				end

				v48.PeakPower = math.max(v48.PeakPower or 0, v48.ShotPower * v50)
				PoolInputController.SetPower(input2, v48.PeakPower)

				local showDirection = v48.ShowDirection or v48.ShotDirection

				if showDirection then
					PoolInputController.SetAimDirection(input2, showDirection)
				end
			end
		else
			local function turnTo(to: Vector2, p: number, p2: number)
				if not v48.AimShownAt then
					v48.AimShownAt = now2
					v48.EarliestChargeAt = math.max(v48.EarliestChargeAt, now2 + bots.MinimumTurn)
				end

				v48.From = input2.Direction
				v48.To = to
				v48.SweepFrom = now2

				v48.SweepUntil = now2 + math.max(PoolAI.SweepSeconds(input2.Direction, to, p), 0.001)
				v48.NextAt = v48.SweepUntil + p2
			end

			if v48.Phase == "Looking" then
				local look = v48.Looks[v48.Looking]

				if look then
					turnTo(look.Direction, look.Sweep, look.Rest)
					v48.Looking += 1
				elseif v48.Resolved then
					if now2 < v48.EarliestChargeAt then
						v48.NextAt = v48.EarliestChargeAt

						return
					end

					if not aimSeenLongEnough(v48, now2) then -- inferred equivalent call
						return
					end

					if
						v48.EmoteDone
						or flag2
						or PoolEmotes.StyleOf(v49) ~= "Winner"
						or not PoolEmotes.IsGameBallShot(v23, v48.Plan)
					then
						v48.Charge = PoolAI.BuildCharge(v49, v48.Turn)

						local total2 = v48.Charge.Total

						turnTo(
							v48.ShowDirection or v48.ShotDirection or input2.Direction,
							bots.Theatre.CommitSweep,
							total2
						)

						v48.Phase = "Committing"
					else
						v48.EmoteDone = true
						PoolHudRenderer.PlayEmote(hud, "Right", PoolEmotes.Pick(PoolEmotes.WinnerEmotes))
						v48.NextAt = now2 + PoolEmotes.Between(PoolEmotes.WinnerPause)
					end
				else
					if v48.Resolving then
						return
					end

					v48.Resolving = true

					task.spawn(function()
						local shotDirection, shotPower, shotSpin = PoolAI.Commit(v49, plan, simulation, true)

						if v30 ~= v48 then
							return
						end

						if not (shotDirection and shotPower) then
							shotDirection, shotPower = PoolAI.FallbackShot(simulation, v23)
						end

						v48.ShotDirection = shotDirection
						v48.ShotPower = shotPower

						if not plan.Choice then
							shotSpin = nil
						end

						v48.ShotSpin = shotSpin

						v48.ShowDirection = plan.ShowDirection or shotDirection
						local v53

						if plan.Choice and not plan.Break then
							v53 = plan.Choice.Direction
						end

						v48.Looks = PoolAI.BuildSettleSequence(v49, v48.ShowDirection, v48.Confidence, v48.Turn, v53)
						v48.Looking = 1
						v48.Resolved = true
					end)
				end
			elseif not (now2 < v48.EarliestChargeAt) and aimSeenLongEnough(v48, now2) then -- inferred equivalent call
				botShoot()
			end
		end
	end
end

local function applyIdentities()
	local identities = PoolConstants.Identities

	if v9 == "Bots" then
		v27[1] = localPlayer.DisplayName
		v28[1] = PoolPlayerData.Thumbnail(localPlayer.UserId)

		v28[2] = identities.BotIcon

		local v48 = PoolFriendOpponent.Get()

		if v48 then
			v27[2] = v48.DisplayName
			v28[2] = PoolPlayerData.Thumbnail(v48.UserId)
		end
	elseif v9 == "Offline" then
		local v48 = identities.Offline[1]

		if v48 then
			v27[1] = v48.Name
			v28[1] = v48.Icon
		end

		local v49 = identities.Offline[2]

		if v49 then
			v27[2] = v49.Name
			v28[2] = v49.Icon
		end
	end

	local v48

	if v9 == "Bots" then
		v48 = PoolVip.Owns(localPlayer.UserId)
	else
		v48 = false
	end

	PoolHudRenderer.SetPlayer(hud, "Left", v27[1], v28[1], v48)
	PoolHudRenderer.SetPlayer(hud, "Right", v27[2], v28[2], false)
	local v49

	if v9 == "Bots" then
		v49 = PoolPlayerData.GetWinStreak(localPlayer.UserId)
	end

	PoolHudRenderer.SetWinStreak(hud, "Left", v49)
	PoolHudRenderer.SetWinStreak(hud, "Right", nil)

	for i = 1, 2 do
		PoolResultScreen.SetPlayer(v4, i, v27[i], v28[i], i == 1 and v48)

		local setWinStreak = PoolResultScreen.SetWinStreak
		local v53

		if i == 1 then
			v53 = v49
		end

		setWinStreak(v4, i, v53)
	end
end

PoolFriendOpponent.Changed:Connect(function()
	if flag and v9 == "Bots" then
		applyIdentities()
	end
end)

for _, panel in hud.Panels do
	local statsButton = panel.StatsButton
	local pressScale = panel.Icon:FindFirstChild("PressScale")

	if statsButton and pressScale and pressScale:IsA("UIScale") then
		PoolStatsPopup.PressFeedback(statsButton, pressScale)
	end
end

local function portraitsPressable(): boolean -- 2 equivalent calls inferred from this helper
	return (v9 == "Online" or v9 == "Bots") and not flag2
end

local function openPortraitStats(p: string)
	if flag and portraitsPressable() then -- inferred equivalent call
		local v48 = p == "Left" and 1 or 2

		if v9 == "Online" then
			local v49 = v10

			if not v49 then
				return
			end

			if v48 == PoolMatchClient.GetSeat(v49) then
				PoolStatsPopup.OpenSelf()

				return
			end

			local seatEntry = PoolMatchClient.GetSeatEntry(v49, v48)

			if not seatEntry then
				return
			end

			PoolStatsPopup.OpenSeat(v48, {
				UserId = seatEntry.AvatarUserId or seatEntry.UserId,
				DisplayName = seatEntry.DisplayName,
				Name = seatEntry.Name,
				Level = seatEntry.Level,
				WinStreak = PoolStreakBadge.ForSeat(seatEntry),
				Vip = PoolVip.ForSeat(seatEntry)
			})
		else
			if v48 ~= 2 then
				PoolStatsPopup.OpenSelf()

				return
			end

			local v49 = PoolFriendOpponent.Get()
			local botLevel = poolGameUI:GetAttribute("BotLevel")
			local v50

			if typeof(botLevel) == "string" then
				v50 = PoolAI.GetLevel(botLevel)
			end

			if not v50 then
				v50 = PoolAI.LevelForRating(localRating()) -- inferred equivalent call
			end

			local userId

			if v49 then
				userId = v49.UserId
			end

			local displayName = v27[2]

			PoolStatsPopup.OpenFake(
				{ UserId = userId, DisplayName = displayName, Image = v28[2] },
				PoolPlayerStats.SeedFor(userId, displayName),
				v50.Rating
			)
		end
	end
end

hud.Portrait:Connect(openPortraitStats)

local v48 = nil
local v49 = nil

local v50 = 0

local v51 = nil

local function trickshotSlots() -- 10 equivalent calls inferred from this helper
	local playerReplica = Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))
	local poolTrickshots = playerReplica and playerReplica.Data and playerReplica.Data.poolTrickshots

	if typeof(poolTrickshots) == "table" then
		return poolTrickshots
	end

	return {}
end

local v52 = nil
local v53 = nil
local function deepCopy(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = deepCopy(item)
	end

	return result
end

local function copyShots()
	local clones = table.create(#v16)

	for _, v54 in v16 do
		table.insert(clones, table.clone(v54))
	end

	return clones
end

local function setPublishOffer(p) -- 1 equivalent call inferred from this helper
	v52 = p

	if v48 then
		PoolTrickshotMenu.SetPublishable(v48, p ~= nil)
	end
end

local function trickshotPlayable(p): boolean -- 1 equivalent call inferred from this helper
	return PoolTrickshotTypes.FindById(p.Scene, PoolTrickshotTypes.CueId) ~= nil
end

local function setTrickshotInput(flag4: boolean) -- 3 equivalent calls inferred from this helper
	PoolHudRenderer.SetShotControlsVisible(hud, flag4)

	PoolViewController.SetRackVisible(view, false)

	if flag4 then
		PoolInputController.SetState(input2, "Aiming")

		return
	end

	PoolInputController.SetState(input2, "GameOver")
	PoolInputController.ReleaseAim(input2)
end

local v54 = nil

local v55 = {
	Module = require(pool:WaitForChild("PoolLevelGoal")),
	Card = nil,
	ShownFor = nil
}

local buildTrickshot

local function cueBallsInScene() -- 1 equivalent call inferred from this helper
	if v11 then
		return #PoolTrickshotTypes.CueBalls(PoolTrickshotEditor.GetScene(v11))
	end

	return 0
end

refreshShotCount = function()
	local v56 = v48

	if not v56 then
		return
	end

	if not v11 or PoolTrickshotEditor.GetMode(v11) ~= "Play" then
		PoolTrickshotMenu.SetShotCount(v56, nil, nil)

		return
	end

	local v57 = PoolTrickshotTypes.SpentCueBalls(PoolTrickshotEditor.GetScene(v11), simulation, firedCueBalls()) -- inferred equivalent call

	PoolTrickshotMenu.SetShotCount(v56, v57, cueBallsInScene()) -- inferred equivalent call
end

aimNextCueBall = function(): boolean
	local v56 = v11

	if not v56 then
		return false
	end

	local v57 = PoolTrickshotTypes.NextCueBall(PoolTrickshotEditor.GetScene(v56), simulation, firedCueBalls()) -- inferred equivalent call

	if not v57 then
		PoolInputController.SetState(input2, "GameOver")

		return false
	end

	simulation.CueBall = v57.I

	input2.CanPlaceCueBall = false
	PoolInputController.SetState(input2, "Aiming")

	return true
end

local function submitLevelAttempt()
	if not v12 or v17 or #v16 == 0 then
		return
	end

	v17 = true
	RemoteSignals.FireServer(RemoteEnums.Pool, "LevelResult", v12, v16)
end

local function startLevelBody(shownFor: number)
	buildTrickshot()

	local v56 = v11
	local v57 = v48

	if not (v56 and v57) then
		return
	end

	local sceneFor = PoolLevelCatalog.SceneFor(shownFor)

	if not sceneFor then
		PoolHudRenderer.Notify(hud, "That level is not ready yet", 3)

		return
	end

	v12 = shownFor
	table.clear(v16)
	total = 0
	v17 = false
	v13 = 0

	RemoteSignals.FireServer(RemoteEnums.Pool, "LevelStart", shownFor)

	if v54 then
		PoolLevelResult.Hide(v54)
	end

	PoolTrickshotMenu.SetCampaign(v57, true)

	PoolHudRenderer.SetExitVisible(hud, true)

	PoolViewController.SetTheme(view, PoolConstants.LevelTheme(shownFor))

	PoolTrickshotEditor.SetLocked(v56, true)
	PoolTrickshotEditor.LoadScene(v56, sceneFor)
	PoolTrickshotEditor.SetMode(v56, "Play")

	PoolTrickshotMenu.SetHint(v57, nil)
	refreshShotCount()
	setTrickshotInput(true) -- inferred equivalent call
	aimNextCueBall()

	if v55.Card and v55.ShownFor ~= shownFor then
		v55.ShownFor = shownFor
		v55.Module.Show(v55.Card, sceneFor, string.format("LEVEL %d", shownFor))
	end
end

local function startCommunity()
	buildTrickshot()

	local v57 = v11
	local v58 = v48
	local v59 = v14

	if not (v57 and v58 and v59) then
		return
	end

	local sanitise = PoolTrickshotTypes.Sanitise((deepCopy(v59.Scene)))

	if not sanitise then
		PoolHudRenderer.Notify(hud, "That trickshot couldn't be loaded", 3)

		return
	end

	v12 = nil
	table.clear(v16)
	total = 0
	v17 = false
	v15 = false

	if v54 then
		PoolLevelResult.Hide(v54)
	end

	PoolTrickshotMenu.SetCampaign(v58, true)

	PoolHudRenderer.SetExitVisible(hud, true)

	PoolViewController.SetTheme(view, nil)
	PoolTrickshotEditor.SetLocked(v57, true)
	PoolTrickshotEditor.LoadScene(v57, sanitise, nil)
	PoolTrickshotEditor.SetMode(v57, "Play")
	PoolTrickshotMenu.SetHint(v58, nil)
	refreshShotCount()
	setTrickshotInput(true) -- inferred equivalent call
	aimNextCueBall()

	local card = v59.Card

	if typeof(card) == "table" then
		PoolTrickshotMenu.Toast(v58, string.format("%s  by %s", card.Name, card.AuthorName))
	end
end

local function finishCommunityAttempt()
	local v57 = v14

	if not v57 or v15 or #v16 == 0 or not v11 then
		return
	end

	v15 = true

	local scene = PoolTrickshotEditor.GetScene(v11)
	local maxStarsFor = PoolGoals.MaxStarsFor(scene)
	local v58 = not (maxStarsFor > 0) and 0 or PoolGoals.Evaluate(scene, simulation).Stars
	local v59

	if maxStarsFor > 0 then
		v59 = maxStarsFor <= v58
	else
		v59 = false
	end

	if v59 then
		RemoteSignals.FireServer(RemoteEnums.Pool, "CommunityCleared", v57.Code, copyShots())
	end

	local v60 = v54

	if not v60 then
		return
	end

	local card = v57.Card
	local v61 = typeof(card) ~= "table" and "" or string.format("%s by %s  --  ", card.Name, card.AuthorName)

	PoolLevelResult.Show(
		v60,
		true,
		v58,
		string.format("%s%d of %d stars", v61, v58, (math.max(maxStarsFor, 1))),
		false,
		nil,
		false
	)
	v60.Title.Text = v59 and "TRICKSHOT CLEARED!" or v58 >= 1 and "SO CLOSE" or "MISSED"

	local textLabel = v60.Quit:FindFirstChildWhichIsA("TextLabel", true)

	if textLabel then
		textLabel.Text = "BACK"
	end

	if v59 then
		PoolAudio.PlayCue("MatchStart")
	end
end

local function restartLevel() -- 2 equivalent calls inferred from this helper
	local shownFor = v12

	if not shownFor then
		return
	end

	startLevelBody(shownFor)
end

local function levelUnlockedThrough()
	local playerReplica = Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))
	local poolLevels = playerReplica and playerReplica.Data and playerReplica.Data.poolLevels
	local v57 = 1

	if typeof(poolLevels) ~= "table" then
		return v57
	end

	while true do
		local v58 = poolLevels[tostring(v57)] or poolLevels[v57]

		if typeof(v58) ~= "number" or v58 <= 0 then
			return v57
		end

		v57 += 1
	end
end

local function nextLevelAvailable(p: number, flag4: boolean) -- 1 equivalent call inferred from this helper
	local v57 = p + 1

	if PoolLevelCatalog.Count < v57 or not PoolLevelCatalog.IsAuthored(v57) then
		return false
	end

	return flag4 or v57 <= levelUnlockedThrough()
end

local function startNextLevel()
	local v57 = v12

	if not v57 then
		return
	end

	poolGameUI:SetAttribute("LevelIndex", v57 + 1)
	startLevelBody(v57 + 1)
end

buildTrickshot = function()
	if v11 then
		return
	end

	local v57 = PoolTrickshotEditor.new(view, simulation, view.Renderer2D.Overlay)
	local v58 = PoolTrickshotMenu.new(poolGameUI)
	local v59 = PoolTrickshotSaves.new(poolGameUI)
	local v60 = PoolLevelResult.new(poolGameUI)

	v54 = v60
	v55.Card = v55.Module.new(poolGameUI)

	v60.RetryRequested:Connect(function()
		if v14 then
			startCommunity()

			return
		end

		restartLevel() -- inferred equivalent call
	end)

	v60.NextRequested:Connect(function()
		local v61 = v12

		if not v61 then
			return
		end

		poolGameUI:SetAttribute("LevelIndex", v61 + 1)
		startLevelBody(v61 + 1)
	end)

	v60.QuitRequested:Connect(function()
		poolGameUI.Enabled = false
		poolGameUI:SetAttribute("MatchActive", false)
	end)

	v11 = v57
	v48 = v58
	v49 = v59

	fn2 = function(flag4: boolean)
		PoolTrickshotEditor.SetCameraMode(v57, flag4)
	end
	PoolTrickshotEditor.SetCameraMode(v57, v43)

	local function refresh()
		local spinnerArms, v61 = PoolTrickshotEditor.GetSpinnerArms(v57)

		PoolTrickshotMenu.SetSelection(
			v58,
			PoolTrickshotEditor.GetSelected(v57),
			PoolTrickshotEditor.GetSelectedModifierEntries(v57),
			PoolTrickshotEditor.GetSpinSpeed(v57),
			spinnerArms and { spinnerArms, v61 } or nil
		)

		PoolTrickshotMenu.SetMode(v58, v57.Mode, trickshotPlayable(v57)) -- inferred equivalent call
		PoolTrickshotMenu.SetHint(v58, PoolTrickshotEditor.GetHint(v57))

		PoolTrickshotMenu.SetTableSizeDisplay(v58, PoolTrickshotEditor.GetTableSize(v57))
		PoolTrickshotMenu.SetHistory(v58, PoolTrickshotEditor.CanUndo(v57), PoolTrickshotEditor.CanRedo(v57))

		setTableLayout(v57.Mode == "Edit" and ((v12 ~= nil or v14 ~= nil) and "Solve" or "Create") or "Solve")
	end

	v57.SceneChanged:Connect(refresh)
	v57.SelectionChanged:Connect(refresh)

	v57.HistoryChanged:Connect(refresh)

	v58.UndoRequested:Connect(function()
		PoolTrickshotEditor.Undo(v57)
	end)

	v58.RedoRequested:Connect(function()
		PoolTrickshotEditor.Redo(v57)
	end)

	v58.SliderGesture:Connect(function(flag4: boolean)
		if flag4 then
			PoolTrickshotEditor.BeginGesture(v57)
		else
			PoolTrickshotEditor.EndGesture(v57)
		end
	end)

	PoolTrickshotEditor.SetSnapIncrement(v57, v50)
	PoolTrickshotMenu.SetSnapDisplay(v58, v50)

	v58.SnapRequested:Connect(function()
		v50 = PoolTrickshotEditor.CycleSnap(v57)
		PoolTrickshotMenu.SetSnapDisplay(v58, v50)
	end)
	v57.ModeChanged:Connect(function(p: string)
		setTrickshotInput(p == "Play")
		v52 = nil

		if v48 then
			PoolTrickshotMenu.SetPublishable(v48, false)
		end

		if p == "Play" then
			if v12 == nil and v14 == nil then
				table.clear(v16)
			end

			total = 0
			aimNextCueBall()
		end

		refreshShotCount()
		refresh()
	end)

	v57.Message:Connect(function(p: string)
		PoolTrickshotMenu.Toast(v58, p)
	end)

	v57.Solved:Connect(function()
		PoolAudio.PlayCue("MatchStart")
		PoolHudRenderer.Notify(hud, "Trickshot solved!", 3)
	end)

	v57.Reloaded:Connect(function()
		table.clear(v39)

		v20 = 0
	end)

	v58.PaletteSelected:Connect(function(p: number, flag4: boolean?, flag5: boolean?)
		if flag5 then
			PoolTrickshotEditor.SetSelection(v57, {})
		end

		PoolTrickshotEditor.SetPalette(v57, p, flag4)
	end)

	v58.ModifierSelected:Connect(function(p: string)
		PoolTrickshotEditor.SetSelection(v57, {})
		PoolTrickshotEditor.SetModifierPalette(v57, p)
	end)

	v58.SwapRequested:Connect(function(p: number, flag4: boolean?)
		PoolTrickshotEditor.SwapType(v57, p, flag4)
	end)

	v58.ModifierSwapRequested:Connect(function(p: string)
		PoolTrickshotEditor.SwapModifierType(v57, p)
	end)

	v58.AnchorToggled:Connect(function(flag4: boolean)
		PoolTrickshotEditor.SetAnchored(v57, flag4)
	end)

	v58.TargetToggled:Connect(function(_: boolean) end)

	v58.CloneRequested:Connect(function()
		PoolTrickshotEditor.Clone(v57)
	end)

	v58.DeleteRequested:Connect(function()
		PoolTrickshotEditor.Delete(v57)
	end)

	v58.ScaleChanged:Connect(function(p: number)
		PoolTrickshotEditor.SetScale(v57, p)
	end)

	v58.SpeedChanged:Connect(function(p: number)
		PoolTrickshotEditor.SetPatrolSpeed(v57, p)
	end)

	v58.SpinChanged:Connect(function(p: number)
		PoolTrickshotEditor.SetSpinSpeed(v57, p)
	end)

	v58.LengthChanged:Connect(function(p: number)
		PoolTrickshotEditor.SetSpinnerArms(v57, p, nil)
	end)

	v58.WidthChanged:Connect(function(p: number)
		PoolTrickshotEditor.SetSpinnerArms(v57, nil, p)
	end)

	v58.RotationChanged:Connect(function(p: number)
		PoolTrickshotEditor.SetModifierRotation(v57, p)
	end)

	v58.StrengthChanged:Connect(function(p: number)
		PoolTrickshotEditor.SetModifierStrength(v57, p)
	end)

	v58.TableSizeChanged:Connect(function(p: number, p2: number)
		PoolTrickshotEditor.SetTableSize(v57, p, p2)
		PoolTrickshotMenu.SetTableSizeDisplay(v58, PoolTrickshotEditor.GetTableSize(v57))
	end)

	v58.PlayRequested:Connect(function()
		PoolTrickshotEditor.Play(v57)
	end)

	v58.EditRequested:Connect(function()
		PoolTrickshotEditor.SetMode(v57, "Edit")
	end)

	v58.ResetRequested:Connect(function()
		if v14 then
			startCommunity()
		elseif v12 then
			restartLevel() -- inferred equivalent call
		else
			v52 = nil

			if v48 then
				PoolTrickshotMenu.SetPublishable(v48, false)
			end

			table.clear(v16)
			total = 0
			PoolTrickshotEditor.Reset(v57)

			if PoolTrickshotEditor.GetMode(v57) == "Play" then
				aimNextCueBall()
			end

			refreshShotCount()
		end
	end)

	v58.SaveRequested:Connect(function()
		PoolTrickshotSaves.Open(v59, "Save", trickshotSlots()) -- inferred equivalent call
	end)

	v58.LoadRequested:Connect(function()
		PoolTrickshotSaves.Open(v59, "Load", trickshotSlots()) -- inferred equivalent call
	end)

	v58.ExitRequested:Connect(function()
		poolGameUI.Enabled = false
		poolGameUI:SetAttribute("MatchActive", false)
	end)

	local v61 = nil
	local v62 = false

	local function awaitShareCode(p: string?) -- 1 equivalent call inferred from this helper
		v61 = p
		v62 = true
	end

	local function newestSlotId(items)
		local v63 = -1
		local v64 = nil

		for k in items do
			local v65 = tonumber(k)

			if not (v65 and v63 < v65) then
				continue
			end

			v64 = k
			v63 = v65
		end

		return v64
	end

	local v63 = nil

	local function sendPublish(p: string, shots) -- 4 equivalent calls inferred from this helper
		v53 = nil
		PoolTrickshotMenu.Toast(v58, "Publishing...")
		RemoteSignals.FireServer(RemoteEnums.Pool, "CommunityPublish", p, shots)
	end

	local function freshName()
		local playerReplica = Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))
		local poolTrickshots = playerReplica and playerReplica.Data and playerReplica.Data.poolTrickshots

		local nameSet = {}

		for _, v64 in typeof(poolTrickshots) ~= "table" and {} or poolTrickshots do
			if not (typeof(v64) == "table" and typeof(v64.Name) == "string") then
				continue
			end

			nameSet[string.lower(v64.Name)] = true
		end

		local v64 = 1

		while nameSet["trickshot " .. v64] do
			v64 += 1
		end

		return "Trickshot " .. v64
	end

	v58.PublishRequested:Connect(function()
		local v64 = v52

		if not v64 then
			PoolTrickshotMenu.Toast(v58, "Win at least one star, then publish it")

			return
		end

		if v53 then
			return
		end

		local v65 = trickshotSlots() -- inferred equivalent call
		local slotId = v57.SlotId
		local v66

		if typeof(slotId) == "string" then
			v66 = v65[slotId]
		end

		if typeof(v66) == "table" and PoolCommunity.Layout(v66) == PoolCommunity.Layout(v64.Scene) then
			sendPublish(slotId, v64.Shots) -- inferred equivalent call
		else
			if typeof(v66) ~= "table" then
				local count5 = 0

				for _ in v65 do
					count5 += 1
				end

				if PoolTrickshotTypes.MaxSlots <= count5 then
					PoolTrickshotMenu.Toast(
						v58,
						string.format("All %d slots are full. Delete one first.", PoolTrickshotTypes.MaxSlots)
					)

					return
				end
			end

			local v67 = typeof(v64.Scene.Name) ~= "string" and "" or v64.Scene.Name

			if typeof(v66) == "table" then
				v67 = nil
			elseif not string.match(v67, "%S") then
				v67 = freshName()
			end

			v53 = { Shots = v64.Shots, SlotId = nil }
			local v68 = if typeof(v66) == "table" then v66.Name else v67
			v63 = v68
			local fireServer = RemoteSignals.FireServer
			local pool2 = RemoteEnums.Pool

			if typeof(v66) ~= "table" then
				slotId = nil
			end

			fireServer(pool2, "SaveTrickshot", slotId, v64.Scene, v67)

			PoolTrickshotMenu.Toast(v58, "Saving...")
		end
	end)

	v57.Maid:GiveTask(RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
		if p ~= "CommunityPublished" then
			return
		end

		local v64, v65, _, v66 = ...

		v53 = nil

		if v64 ~= true then
			PoolTrickshotMenu.Toast(v58, typeof(v65) ~= "string" and "Couldn't publish, try again" or v65)

			return
		end

		v52 = nil

		if v48 then
			PoolTrickshotMenu.SetPublishable(v48, false)
		end

		PoolAudio.PlayCue("MatchStart")

		local v67 = typeof(v65) ~= "string" and "?" or PoolTrickshotCodes.Format(v65)

		local notify = PoolHudRenderer.Notify
		local v68

		if v66 then
			v68 = string.format("Updated! Code %s now plays this version", v67)
		else
			v68 = string.format("Published! Code %s -- find it in COMMUNITY", v67)
		end

		notify(hud, v68, 5)
	end))

	v59.SaveNew:Connect(function(p: string)
		local playerReplica = Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))
		local poolTrickshots = playerReplica and playerReplica.Data and playerReplica.Data.poolTrickshots
		local count5 = 0

		for _ in typeof(poolTrickshots) ~= "table" and {} or poolTrickshots do
			count5 += 1
		end

		if PoolTrickshotTypes.MaxSlots <= count5 then
			PoolTrickshotMenu.Toast(
				v58,
				string.format("All %d slots are full. Delete one first.", PoolTrickshotTypes.MaxSlots)
			)

			return
		end

		v63 = p
		RemoteSignals.FireServer(RemoteEnums.Pool, "SaveTrickshot", nil, v57.Scene, p)
		PoolTrickshotSaves.Close(v59)
		PoolTrickshotMenu.Toast(v58, "Saving…")
	end)

	v59.SaveOver:Connect(function(p: string)
		local v64 = trickshotSlots()[p] -- inferred equivalent call
		local v65

		if typeof(v64) == "table" then
			v65 = v64.Name
		end

		v63 = v65
		RemoteSignals.FireServer(RemoteEnums.Pool, "SaveTrickshot", p, v57.Scene, nil)
		PoolTrickshotSaves.Close(v59)
		PoolTrickshotMenu.Toast(v58, "Saving…")
	end)

	v57.Maid:GiveTask(RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
		if p ~= "TrickshotSaved" then
			return
		end

		local v64, slotId = ...

		if v64 then
			if typeof(slotId) ~= "string" then
				slotId = nil
			end

			PoolTrickshotMenu.Toast(v58, not v63 and "Saved" or string.format("Saved %q", v63))

			v63 = nil

			if not slotId then
				return
			end

			v57.SlotId = slotId

			local v66 = v53

			if v66 then
				v66.SlotId = slotId
				local v67 = trickshotSlots()[slotId] -- inferred equivalent call

				if typeof(v67) ~= "table" or typeof(v67.Code) ~= "string" then
					task.delay(6, function()
						if v53 == v66 then
							sendPublish(slotId, v66.Shots) -- inferred equivalent call
						end
					end)

					return
				end

				sendPublish(slotId, v66.Shots) -- inferred equivalent call
			else
				local v67 = trickshotSlots()[slotId] -- inferred equivalent call

				if typeof(v67) == "table" and typeof(v67.Code) == "string" then
					v62 = false
					v61 = nil
					PoolTrickshotSaves.ShowShare(v59, v67.Code)
				else
					awaitShareCode(slotId) -- inferred equivalent call
				end
			end
		else
			v63 = nil
			v53 = nil
			PoolTrickshotMenu.Toast(v58, typeof(slotId) ~= "string" and "That scene couldn't be saved" or slotId)
		end
	end))

	v59.DeleteSlot:Connect(function(p: string)
		RemoteSignals.FireServer(RemoteEnums.Pool, "DeleteTrickshot", p)
	end)

	v59.CodeRequested:Connect(function(p: string)
		PoolTrickshotMenu.Toast(v58, "Looking up " .. PoolTrickshotCodes.Format(p) .. "…")
		RemoteSignals.FireServer(RemoteEnums.Pool, "LoadTrickshotCode", p)
	end)

	local function reportResizing(p) -- 2 equivalent calls inferred from this helper
		local countResized = PoolTrickshotTypes.CountResized(p)

		if countResized == 0 then
			return
		end

		task.delay(2.6, function()
			if v58.Root.Parent then
				PoolTrickshotMenu.Toast(
					v58,
					string.format(
						"%d piece%s resized to fit the current limits",
						countResized,
						countResized == 1 and "" or "s"
					)
				)
			end
		end)
	end

	v57.Maid:GiveTask(RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
		if p ~= "TrickshotCode" then
			return
		end

		local v64, v65, v66 = ...

		if not v64 then
			PoolTrickshotMenu.Toast(v58, (tostring(v65)))

			return
		end

		local sanitise = PoolTrickshotTypes.Sanitise(v66)

		if not sanitise then
			PoolTrickshotMenu.Toast(v58, "That trickshot could not be loaded")

			return
		end

		PoolTrickshotEditor.LoadScene(v57, sanitise, nil)
		PoolTrickshotSaves.Close(v59)
		PoolTrickshotMenu.Toast(v58, string.format("Loaded %q", sanitise.Name))
		reportResizing(v66) -- inferred equivalent call
	end))

	local function loadSlotIntoEditor(p: string, p2, flag4: boolean)
		local sanitise = PoolTrickshotTypes.Sanitise(p2)

		if not sanitise then
			PoolTrickshotMenu.Toast(v58, "That scene could not be loaded")

			return
		end

		PoolTrickshotEditor.LoadScene(v57, sanitise, p)
		PoolTrickshotSaves.Close(v59)
		reportResizing(p2) -- inferred equivalent call

		if not flag4 then
			PoolTrickshotMenu.Toast(v58, string.format("Loaded %q", sanitise.Name))
		elseif PoolTrickshotEditor.Play(v57) then
			PoolTrickshotMenu.Toast(v58, string.format("Playing %q", sanitise.Name))
		end
	end

	v59.LoadSlot:Connect(function(p: string, p2)
		loadSlotIntoEditor(p, p2, false)
	end)

	v59.PlaySlot:Connect(function(p: string, p2)
		loadSlotIntoEditor(p, p2, true)
	end)

	local playerReplica = Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))

	if playerReplica then
		playerReplica:ListenToWrite("PoolTrickshots", function()
			if v59.Root.Visible then
				PoolTrickshotSaves.Refresh(v59, trickshotSlots()) -- inferred equivalent call
			end
		end)

		playerReplica:ListenToWrite("PoolTrickshotCode", function()
			if v59.Root.Visible then
				PoolTrickshotSaves.Refresh(v59, trickshotSlots()) -- inferred equivalent call
			end

			local v64 = v53

			if v64 and v64.SlotId then
				local v65 = trickshotSlots()[v64.SlotId] -- inferred equivalent call

				if typeof(v65) == "table" and typeof(v65.Code) == "string" then
					sendPublish(v64.SlotId, v64.Shots) -- inferred equivalent call
				end
			else
				if not v62 then
					return
				end

				local v65 = trickshotSlots() -- inferred equivalent call
				local v66 = v61

				if not v66 then
					local v67 = -1
					v66 = nil

					for k in v65 do
						local v68 = tonumber(k)

						if not (v68 and v67 < v68) then
							continue
						end

						v66 = k
						v67 = v68
					end
				end

				local v67 = v66 and v65[v66]

				if typeof(v67) == "table" and typeof(v67.Code) == "string" then
					v62 = false
					v61 = nil
					PoolTrickshotSaves.ShowShare(v59, v67.Code)
				end
			end
		end)
	end

	refresh()
end

local function clearStrayTrickshotBalls()
	local v57 = {}

	for k in view.Renderer2D.Balls do
		if PoolTrickshotTypes.FirstId <= k then
			table.insert(v57, k)
		end
	end

	for k in view.Renderer3D.Balls do
		if not (PoolTrickshotTypes.FirstId <= k) or table.find(v57, k) then
			continue
		end

		table.insert(v57, k)
	end

	for _, v58 in v57 do
		PoolViewController.RemoveBall(view, v58)
	end

	return #v57
end

local function reportLocalGame() -- 2 equivalent calls inferred from this helper
	if v9 == "Bots" then
		local fireServer = RemoteSignals.FireServer
		local pool2 = RemoteEnums.Pool
		local v59

		if v29 then
			v59 = v29.Level.Id
		end

		fireServer(pool2, "LocalGame", "Bots", v59, flag2)
	elseif v9 == "Offline" then
		RemoteSignals.FireServer(RemoteEnums.Pool, "LocalGame", "Solo")
	end
end

local function startMatch()
	if flag then
		return
	end

	flag = true
	v9 = poolGameUI:GetAttribute("MatchMode") or "Offline"

	RemoteSignals.FireServer(RemoteEnums.Pool, "LocalMatch", true)

	if v9 == "Trickshot" then
		applyVibration() -- inferred equivalent call
	else
		setTableLayout("Match")
	end

	if v9 ~= "Trickshot" then
		clearStrayTrickshotBalls()

		PoolViewController.SetModifiers(view, nil, nil)
	end

	PoolHudRenderer.SetChatSide(hud, nil)
	PoolHudRenderer.ClearChat(hud)
	setEmoteSide(nil) -- inferred equivalent call
	count2 += 1
	local v57 = portraitsPressable() -- inferred equivalent call
	PoolHudRenderer.SetPortraitsPressable(hud, v57, v57)

	PoolAudio.PlayCue("MatchStart")

	v29 = nil
	v30 = nil

	if v9 == "Bots" then
		local botLevel = poolGameUI:GetAttribute("BotLevel")
		local v58 = botLevel and PoolAI.GetLevel(botLevel)

		if not v58 then
			v58 = PoolAI.LevelForRating(localRating()) -- inferred equivalent call
		end

		v29 = PoolAI.new(v58)
		v27[2] = v58.Name

		if not flag2 then
			setEmoteSide("Left") -- inferred equivalent call
			startBotEmoteSpam() -- inferred equivalent call
		end

		v32 = pickBotCue(PoolConstants.BotMenuCues(v58.Id)) -- inferred equivalent call
	else
		v27[2] = "Player 2"
		v32 = nil
	end

	reportLocalGame() -- inferred equivalent call
	table.clear(v36)
	v37 = 0

	if v9 == "Bots" then
		PoolFriendOpponent.Roll()
	end

	applyIdentities()

	PoolResultScreen.Hide(v4)

	PoolResultScreen.SetRematchEnabled(v4, true)

	PoolResultScreen.SetExitLabel(v4, nil)

	applyMode(PoolConstants.DefaultViewMode)

	PoolHudRenderer.SetMatchChromeVisible(hud, true)
	PoolHudRenderer.SetShotControlsVisible(hud, true)
	PoolViewController.SetRackVisible(view, true)
	setCameraMode(false) -- inferred equivalent call
	PoolHudRenderer.SetCameraActive(hud, false)

	if v9 == "Trickshot" then
		buildTrickshot()

		local v58 = v11
		local v59 = v48

		v23 = PoolRules.newMatch(1)
		v23.BallInHand = false
		v23.BehindHeadString = false
		v26 = false

		table.clear(displayPositionsByNumber)
		table.clear(v39)
		v22 = true

		PoolViewController.ClearRack(view)
		PoolViewController.ClearBalls(view)

		PoolHudRenderer.SetWagerVisible(hud, false)
		PoolHudRenderer.ResetRows(hud)
		PoolHudRenderer.SetGroup(hud, "Left", nil)
		PoolHudRenderer.SetGroup(hud, "Right", nil)
		PoolHudRenderer.SetTimer(hud, 1)

		PoolHudRenderer.SetExitVisible(hud, false)

		PoolHudRenderer.SetMatchChromeVisible(hud, false)

		PoolHudRenderer.SetCameraActive(hud, false)

		local communityCode = poolGameUI:GetAttribute("CommunityCode")

		local v60 = typeof(communityCode) == "string" and PoolCommunityMenu.TakePending(communityCode)

		if v60 then
			v14 = v60
			startCommunity()
			PoolTrickshotMenu.SetVisible(v59, true)
		else
			local levelIndex = poolGameUI:GetAttribute("LevelIndex")

			if typeof(levelIndex) == "number" then
				startLevelBody(levelIndex)
				PoolTrickshotMenu.SetVisible(v59, true)
			else
				v12 = nil
				table.clear(v16)
				PoolTrickshotMenu.SetCampaign(v59, false)

				PoolViewController.SetTheme(view, nil)

				if v11 then
					PoolTrickshotEditor.SetLocked(v11, false)
				end

				if v51 then
					PoolTrickshotEditor.LoadScene(v58, v51, nil)
					v51 = nil
				end

				PoolTrickshotEditor.SetMode(v58, "Edit")
				PoolTrickshotEditor.Render(v58)
				PoolTrickshotMenu.SetVisible(v59, true)
				setTrickshotInput(false) -- inferred equivalent call
			end
		end
	elseif v9 == "Tutorial" then
		v23 = PoolRules.newMatch(1)
		v26 = false

		v23.BallInHand = false
		v23.BehindHeadString = false

		input2.CanPlaceCueBall = false

		PoolTutorialScene.Apply(simulation)

		table.clear(displayPositionsByNumber)
		table.clear(v39)
		v22 = true

		for i = 0, 15 do
			local ball = simulation.Balls[i]

			if ball then
				PoolViewController.SetBallVisible(view, i, true)
				PoolViewController.SetBall(view, i, ball.Position)
			else
				PoolViewController.SetBallVisible(view, i, false)
			end
		end

		PoolAudio.Reset(v7)
		PoolViewController.ClearRack(view)
		PoolHudRenderer.ResetRows(hud)
		PoolHudRenderer.SetWagerVisible(hud, false)

		PoolHudRenderer.SetExitVisible(hud, false)
		PoolHudRenderer.SetGroup(hud, "Left", nil)
		PoolHudRenderer.SetGroup(hud, "Right", nil)

		PoolVisuals.Clear(v41)

		PoolInputController.SetState(input2, "GameOver")

		PoolTutorialScene.SetPowerMeterParked(hud, true)
	elseif v9 == "Online" then
		PoolHudRenderer.SetExitVisible(hud, false)

		PoolInputController.SetState(input2, "Simulating")

		local v58 = PoolMatchReplica.Wait(10)

		if v58 then
			local v59 = PoolMatchClient.new(v58, view, hud, v3, input2, simulation, v41)

			local soundVolume = poolGameUI:GetAttribute("SoundVolume")

			PoolMatchClient.SetVolumeScale(v59, typeof(soundVolume) ~= "number" and 0.7 or soundVolume)

			local seat = PoolMatchClient.GetSeat(v59)

			if seat > 0 and PoolMatchmakingConstants.ChatEnabled then
				PoolHudRenderer.SetChatSide(hud, seat == 1 and "Left" or "Right")
			end

			if seat > 0 then
				setEmoteSide(seat == 1 and "Left" or "Right") -- inferred equivalent call
			end

			function v59.OnFinished(p: number, p2: string, list)
				local seat2 = PoolMatchClient.GetSeat(v59)
				local v60 = list and list[seat2]

				local state = PoolMatchReplica.GetState()

				if state and state.Seats then
					for k, seat3 in state.Seats do
						PoolResultScreen.SetPlayer(
							v4,
							k,
							seat3.DisplayName,
							PoolPlayerData.Thumbnail(seat3.AvatarUserId or seat3.UserId),
							PoolVip.ForSeat(seat3)
						)

						local v61 = PoolStreakBadge.ForSeat(seat3)

						if v61 == nil then
							v61 = nil
						elseif not (p <= 0) then
							v61 = p ~= k and 0 or v61 + 1
						end

						PoolResultScreen.SetWinStreak(v4, k, v61)
					end
				end

				local v61 = list and list[p]

				PoolResultScreen.SetSeries(v4, {
					list and list[1] and list[1].SeriesWins or 0,
					list and list[2] and list[2].SeriesWins or 0
				})

				PoolResultScreen.PlayOutcome(v4, p, seat2)

				PoolResultScreen.Show(v4, p, not v61 and 0 or v61.Coins, p2, not v60 and 0 or v60.Xp, seat2)

				local v62 = state and state.Seats and state.Seats[seat2 == 1 and 2 or 1]

				if seat2 > 0 and v62 and v62.IsBot then
					RemoteSignals.FireServer(RemoteEnums.Pool, "ResultShown")
				end
			end

			v10 = v59
		else
			warn("[PoolGameUIHandler] no match replica arrived; returning to the lobby")

			flag = false
			poolGameUI.Enabled = false
			poolGameUI:SetAttribute("MatchActive", false)
		end
	else
		v23 = PoolRules.newMatch(1)

		PoolHudRenderer.SetExitVisible(hud, not flag2)

		applyIdentities()

		v31 = not flag2 and 0 or PoolConstants.FirstMatchPrize()

		PoolHudRenderer.SetWager(hud, v31)

		PoolHudRenderer.SetWagerVisible(hud, v31 > 0)

		PoolHudRenderer.ResetRows(hud)
		PoolHudRenderer.SetGroup(hud, "Left", nil)
		PoolHudRenderer.SetGroup(hud, "Right", nil)

		rerack()
		PoolViewController.ClearRack(view)

		beginTurn(true)
		PoolInputController.OfferBallInHand(input2)
		PoolHudRenderer.Notify(hud, string.format("%s breaks", v27[v23.Turn]), 2.5)
	end
end

local function stopMatch()
	flag = false

	v32 = nil
	PoolViewController.SetCueStickModel(view, nil)

	RemoteSignals.FireServer(RemoteEnums.Pool, "LocalMatch", false)
	setCameraMode(false) -- inferred equivalent call
	fn2 = nil

	PoolHudRenderer.SetChatSide(hud, nil)
	PoolHudRenderer.ClearChat(hud)
	PoolChatBox.Hide(v5)
	setEmoteSide(nil) -- inferred equivalent call
	count2 += 1

	PoolHudRenderer.SetPortraitsPressable(hud, false, false)
	PoolStatsPopup.Close()

	PoolHudRenderer.SetWinStreak(hud, "Left", nil)
	PoolHudRenderer.SetWinStreak(hud, "Right", nil)

	PoolTutorialScene.SetPowerMeterParked(hud, false)

	input2.ChargeLocked = false

	v42 = 0

	PoolVisuals.Clear(v41)

	v29 = nil
	v30 = nil
	PoolInputController.ReleaseAim(input2)

	PoolHudRenderer.SetExitVisible(hud, false)

	if v10 then
		PoolMatchClient.Destroy(v10)
		v10 = nil
	end

	v9 = "Offline"

	setTableLayout("Match")

	if v11 then
		if v12 == nil and v14 == nil then
			local scene = PoolTrickshotEditor.GetScene(v11)

			if not (scene and #scene.Balls > 0) then
				scene = nil
			end

			v51 = scene
		end

		PoolTrickshotEditor.Destroy(v11)
		v11 = nil
	end

	v12 = nil
	v17 = false
	table.clear(v16)
	total = 0

	v14 = nil
	v15 = false
	v52 = nil
	v53 = nil

	if v48 then
		PoolTrickshotMenu.Destroy(v48)
		v48 = nil
	end

	if v49 then
		PoolTrickshotSaves.Destroy(v49)
		v49 = nil
	end

	if v54 then
		PoolLevelResult.Destroy(v54)
		v54 = nil
	end

	if v55.Card then
		v55.Module.Destroy(v55.Card)
		v55.Card = nil
	end

	v55.ShownFor = nil

	clearStrayTrickshotBalls()
	PoolViewController.SetModifiers(view, nil, nil)

	PoolViewController.SetRackVisible(view, true)

	PoolResultScreen.Hide(v4)
	PoolInputController.SetState(input2, "Simulating")
	applyMode("2D")
end

poolGameUI:GetAttributeChangedSignal("MatchActive"):Connect(function()
	if poolGameUI:GetAttribute("MatchActive") then
		startMatch()
	else
		stopMatch()
	end
end)

PoolTutorialFlow.Register({
	UI = poolGameUI,
	View = view,
	Input = input2,
	Hud = hud,
	Simulation = simulation,
	BeginScene = function()
		PoolFriendOpponent.Prefetch()
		poolGameUI:SetAttribute("MatchMode", "Tutorial")
		poolGameUI.Enabled = true
		poolGameUI:SetAttribute("MatchActive", true)

		while not flag do
			task.wait()
		end
	end,
	EndScene = function()
		poolGameUI:SetAttribute("MatchActive", false)
	end,
	SetTableIdle = function(flag4: boolean)
		PoolInputController.SetState(input2, flag4 and "GameOver" or "Aiming")
	end,
	StartFirstMatch = function()
		flag2 = true
		count3 = 0
		set = {}
		count4 = 0

		RemoteSignals.FireServer(RemoteEnums.Pool, "FirstMatch", "Start")
		poolGameUI:SetAttribute("TutorialFirstMatch", (poolGameUI:GetAttribute("TutorialFirstMatch") or 0) + 1)
	end
})

v4.Rematch:Connect(function()
	if v9 == "Online" then
		PoolResultScreen.SetRematchEnabled(v4, true, "WAITING...")
		RemoteSignals.FireServer(RemoteEnums.Pool, "Rematch")
	else
		PoolResultScreen.Hide(v4)

		PoolHudRenderer.SetExitVisible(hud, not flag2)

		local v57 = v23.Winner == 1 and 2 or 1

		v23 = PoolRules.newMatch(v57)
		reportLocalGame() -- inferred equivalent call
		rerack()
		PoolViewController.ClearRack(view)

		beginTurn(true)
		PoolInputController.OfferBallInHand(input2)
		PoolHudRenderer.Notify(hud, string.format("%s breaks", v27[v23.Turn]), 2.5)
	end
end)

v4.Exit:Connect(function()
	PoolResultScreen.Hide(v4)

	if v9 == "Online" then
		RemoteSignals.FireServer(RemoteEnums.Pool, "DeclineRematch")
	end

	stopMatch()
	poolGameUI.Enabled = false
	poolGameUI:SetAttribute("MatchActive", false)
end)

hud.Exit:Connect(function()
	local v57 = v12

	if v57 and not v17 and #v16 > 0 then
		local now2 = os.clock()

		if v13 < now2 then
			v13 = os.clock() + 2.5

			if v48 then
				PoolTrickshotMenu.Toast(v48, "Leaving now costs a life. Tap ← again to leave")
			end

			return
		end

		Notifications.new("TextNotification", {
			message = "You left the level and lost a life",
			colour = Color3.fromRGB(238, 108, 108)
		})
	end

	if v57 then
		RemoteSignals.FireServer(RemoteEnums.Pool, "LevelLeave", v57)
	end

	PoolResultScreen.Hide(v4)
	stopMatch()
	poolGameUI.Enabled = false
	poolGameUI:SetAttribute("MatchActive", false)
end)

RemoteSignals.OnClientEvent(RemoteEnums.Pool, function(p: string, ...)
	if p == "LevelStartRefused" then
		local v57 = ...

		if v12 ~= nil and v12 == v57 then
			local playerReplica = Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))

			Notifications.new("TextNotification", {
				message = PoolLives.OutMessage(playerReplica and playerReplica.Data),
				colour = Color3.fromRGB(238, 108, 108)
			})

			PoolResultScreen.Hide(v4)
			poolGameUI.Enabled = false
			poolGameUI:SetAttribute("MatchActive", false)
		end
	elseif p == "LevelResult" then
		local v57, v58, v59, v60, v61, v62 = ...

		if v54 and v12 == v58 then
			local show = PoolLevelResult.Show
			show(
				v54,
				v57 == true,
				tonumber(v59) or 0,
				v60,
				v61 == true,
				tonumber(v62),
				nextLevelAvailable(v58, v57 == true and (tonumber(v59) or 0) >= 1), -- inferred equivalent call
				string.format("LEVEL %d", v58)
			)
		end
	elseif p == "Emote" then
		local v57, v58 = ...

		if typeof(v57) == "number" and PoolEmotes.IsEmote(v58) then
			PoolHudRenderer.PlayEmote(hud, v57 == 1 and "Left" or "Right", v58)
		end
	elseif p == "Chat" then
		local v57, v58 = ...

		if not PoolMatchmakingConstants.ChatEnabled then
			return
		end

		if typeof(v57) == "number" and typeof(v58) == "string" then
			PoolHudRenderer.SayChat(hud, v57 == 1 and "Left" or "Right", v58)
		end
	elseif p == "RematchWanted" then
		if ... ~= localPlayer.UserId then
			Notifications.new("TextNotification", {
				message = "Your opponent wants a rematch!",
				colour = Color3.fromRGB(126, 232, 118)
			})
		end
	elseif p == "RematchDeclined" then
		Notifications.new("TextNotification", {
			message = "Opponent doesn't want a rematch",
			colour = Color3.fromRGB(238, 108, 108)
		})

		PoolResultScreen.SetRematchEnabled(v4, false)
	elseif p == "RematchStarting" then
		PoolResultScreen.Hide(v4)
		PoolResultScreen.SetRematchEnabled(v4, true)
	elseif p == "BotCovering" then
		PoolInputController.TakeAim(input2)
		PoolHudRenderer.SetSpin(hud, Vector2.zero)

		if v10 then
			PoolMatchClient.SetCovered(v10, true)
		end
	elseif p == "BotReleased" then
		PoolInputController.ReleaseAim(input2)
		PoolHudRenderer.SetSpin(hud, Vector2.zero)

		if v10 then
			PoolMatchClient.SetCovered(v10, false)
		end
	end
end)

if poolGameUI:GetAttribute("MatchActive") then
	startMatch()
end

RunService.RenderStepped:Connect(function(dt: number)
	if not flag then
		return
	end

	PoolViewController.UpdateRack(view, dt)

	PoolHudRenderer.UpdateChips(hud, dt)

	updateBot()
	local v57 = localSeat() -- inferred equivalent call
	PoolCoach.Update(v21, input2, hud, dt, v57 ~= nil and v23.Turn == v57)

	if v10 then
		PoolMatchClient.Update(v10, dt)

		local state = PoolMatchReplica.GetState()
		local turn = state and state.Turn

		if turn and turn ~= v37 and v10.Simulation.Settled then
			v37 = turn
			applyTableSkin() -- inferred equivalent call
			applyCueSkin(turn)
		end
	else
		local settled = simulation.Settled
		local hasPatrol = PoolPhysics.HasPatrol(simulation)

		if settled and not (hasPatrol and total < PoolStepper.MaxShotDelaySteps) then
			if v9 == "Tutorial" or v9 == "Trickshot" then
				PoolHudRenderer.SetTimer(hud, 1)
			elseif v23.Phase ~= "GameOver" then
				local v59 = turnSeconds() -- inferred equivalent call
				local v60 = v25 - os.clock()

				PoolHudRenderer.SetTimer(hud, (math.clamp(v60 / v59, 0, 1)))

				PoolAudio.TurnClock(v60)

				if v60 <= 0 then
					simulation.Events = {}
					PoolAudio.Reset(v7)
					PoolTableHaptics.Reset(v8)
					v24.TimedOut = true
					v26 = true
					onSettled()
				end
			end
		else
			local v59

			if settled then
				v59 = PoolStepper.MaxShotDelaySteps - total
			end

			total += PoolStepper.Advance(v6, simulation, dt, v59)
			syncBalls()

			if v9 == "Trickshot" then
				local events = simulation.Events

				if v20 > #events then
					v20 = 0
				end

				for i = v20 + 1, #events do
					local event = events[i]

					if event.Kind == "Popped" and event.Modifier then
						PoolViewController.PopBubble(view, event.Modifier)
					end
				end

				v20 = #events
			end

			if v9 == "Trickshot" and v11 and PoolTrickshotEditor.GetMode(v11) == "Play" then
				if input2.State ~= "GameOver" and attemptDecided(false) then
					PoolInputController.SetState(input2, "GameOver")
				end

				local ball = simulation.Balls[PoolPhysics.CueNumber(simulation)]

				if
					(ball == nil or ball.Pocketed or ball.Destroyed == true)
					and input2.State ~= "GameOver"
					and not firedCueBalls()[PoolPhysics.CueNumber(simulation)] -- inferred equivalent call
				then
					aimNextCueBall()
					refreshShotCount()
				end
			end

			PoolAudio.Update(v7, simulation)

			if v9 == "Trickshot" then
				PoolTableHaptics.Update(v8, simulation)
			end

			if simulation.Settled and not settled then
				if v9 == "Trickshot" then
					if v11 then
						PoolTrickshotEditor.OnSettled(v11)
					end

					local v60

					if v11 == nil then
						v60 = false
					elseif PoolTrickshotTypes.NextCueBall(
						PoolTrickshotEditor.GetScene(v11),
						simulation,
						firedCueBalls() -- inferred equivalent call
					) == nil then
						v60 = true
					else
						v60 = false
					end

					local v61, v62 = attemptDecided(true) -- inferred equivalent call
					local v63

					if v11 and v12 == nil and v14 == nil and PoolTrickshotEditor.GetMode(v11) == "Play" then
						v63 = PoolGoals.Evaluate(PoolTrickshotEditor.GetScene(v11), simulation).Stars
						setPublishOffer(v63 >= 1 and #v16 > 0 and { -- inferred equivalent call
							Shots = copyShots(),
							Scene = deepCopy(PoolTrickshotEditor.GetScene(v11))
						} or nil)
					else
						v63 = 0
					end

					if v60 or v61 then
						PoolInputController.SetState(input2, "GameOver")
						submitLevelAttempt()

						finishCommunityAttempt()

						if v12 == nil and v14 == nil and v48 then
							PoolTrickshotMenu.Toast(
								v48,
								v62 and "Every star won — PUBLISH it for everyone, or RESET to play again" or not (v63 >= 1) and (v60 and "Out of cue balls — RESET to play it again" or "Nothing left to score — RESET to play it again") or string.format(
									"%d★ — PUBLISH it for everyone, or RESET to try for more",
									v63
								)
							)
						end
					end

					refreshShotCount()
				else
					onSettled()
				end
			end
		end

		PoolInputController.Update(input2, dt)
	end
end)

v = Profiles.GetPlayerReplica((tostring(localPlayer.UserId)))

if v then
	local function onSkinWrite()
		if not flag then
			return
		end

		local turn

		if v9 == "Online" then
			local state = PoolMatchReplica.GetState()

			turn = state and state.Turn

			local v57 = state and state.Seats and turn and state.Seats[turn]

			if not v57 or v57.UserId ~= localPlayer.UserId then
				return
			end
		end

		applyTableSkin() -- inferred equivalent call
		applyCueSkin(turn)
	end

	v:ListenToWrite("Equipped", onSkinWrite)
	v:ListenToWrite("Inventory", onSkinWrite)
end