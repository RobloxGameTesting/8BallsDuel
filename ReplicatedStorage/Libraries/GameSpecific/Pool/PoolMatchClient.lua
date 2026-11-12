local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolMatchmakingConstants = require(Pool.PoolMatchmakingConstants)
local PoolAI = require(Pool.PoolAI)
local PoolActivity = require(Pool.PoolActivity)
local PoolAimOverlay = require(Pool.PoolAimOverlay)
local PoolAudio = require(Pool.PoolAudio)
local PoolConstants = require(Pool.PoolConstants)
local PoolFoulPopup = require(Pool.PoolFoulPopup)
local PoolGeometry = require(Pool.PoolGeometry)
local PoolHaptics = require(Pool.PoolHaptics)
local PoolHudRenderer = require(Pool.PoolHudRenderer)
local PoolInputController = require(Pool.PoolInputController)
local PoolMatchTypes = require(Pool.PoolMatchTypes)
local PoolPhysics = require(Pool.PoolPhysics)
local PoolPlayerData = require(Pool.PoolPlayerData)
local PoolRules = require(Pool.PoolRules)
local PoolSkins = require(Pool.PoolSkins)
local PoolStepper = require(Pool.PoolStepper)
local PoolStreakBadge = require(Pool.PoolStreakBadge)
local PoolVip = require(Pool.PoolVip)
local PoolViewController = require(Pool.PoolViewController)
local PoolVisuals = require(Pool.PoolVisuals)

local PoolMatchClient = {}

local LocalPlayer = Players.LocalPlayer
local CueBallNumber = PoolConstants.CueBallNumber

local EightBallNumber = PoolConstants.EightBallNumber

local function state(p) -- 12 equivalent calls inferred from this helper
	local data = p.Replica and p.Replica.Data

	return if data then data.poolMatch else nil
end

local function isNineBall(p): boolean -- 5 equivalent calls inferred from this helper
	return p.GameType == "NineBall"
end

local function isMyTurn(p): boolean -- 6 equivalent calls inferred from this helper
	local v = state(p) -- inferred equivalent call
	return v ~= nil and v.Phase == "Playing" and p.Seat > 0 and v.Turn == p.Seat
end

local function hideCue(p)
	PoolAimOverlay.SetVisible(p.Overlay, false)
	PoolAimOverlay.SetStickVisible(p.Overlay, false)
	PoolViewController.SetCueStickVisible(p.View, false)

	PoolAimOverlay.HidePocketCall(p.Overlay)

	PoolAimOverlay.HideHeldBall(p.Overlay)
end

local function showHeldBall(state2, vector2: Vector2) -- 3 equivalent calls inferred from this helper
	PoolAimOverlay.SetVisible(state2.Overlay, true)
	PoolAimOverlay.SetStickVisible(state2.Overlay, false)
	PoolViewController.SetCueStickVisible(state2.View, false)
	PoolAimOverlay.ShowHeldBall(state2.Overlay, vector2)
end

local function pocketEventFor(data, p: number) -- 1 equivalent call inferred from this helper
	for _, event in data.Simulation.Events do
		if event.Kind == "Pocketed" and event.Ball == p then
			return event
		end
	end

	return nil
end

local function groupOfBall(p: number): nil | string -- 2 equivalent calls inferred from this helper
	if p == CueBallNumber or p == EightBallNumber then
		return nil
	end

	return if p < EightBallNumber then "Solid" else "Stripe"
end

local function shooterSeat(p) -- 3 equivalent calls inferred from this helper
	return if p.ShotSeat > 0 then p.ShotSeat else p.Rules.Turn
end

local function isRewardablePot(state2, p: number): boolean
	local v = shooterSeat(state2) -- inferred equivalent call
	local group = state2.Rules.Groups[v]

	if p == CueBallNumber then
		return false
	end

	if isNineBall(state2) then -- inferred equivalent call
		local shotTarget = state2.ShotTarget

		if shotTarget == nil then
			return true
		end

		for _, event in state2.Simulation.Events do
			if event.Kind == "BallHit" and event.Ball == CueBallNumber and event.Other then
				return event.Other == shotTarget
			end
		end

		return false
	elseif p == EightBallNumber then
		return group ~= nil and PoolRules.CountRemaining(state2.Simulation, group) == 0
	else
		local openClaim = groupOfBall(p) -- inferred equivalent call

		if group then
			return openClaim == group
		end

		if state2.Rules.Phase ~= "Open" then
			return false
		end

		if not state2.OpenClaim then
			state2.OpenClaim = openClaim
		end

		return openClaim == state2.OpenClaim
	end
end

local function startDrop(data, p: number)
	if data.Dropped[p] then
		return
	end

	data.Dropped[p] = true

	if p ~= CueBallNumber then
		task.delay(PoolMatchmakingConstants.RackDelay, function()
			if data.Dropped[p] then
				PoolHudRenderer.SetBallPotted(data.Hud, p, true)
				PoolViewController.RackBall(data.View, p)
			end
		end)
	end

	local event = pocketEventFor(data, p) -- inferred equivalent call
	local v = nil

	if event and event.PocketId then
		for _, v2 in PoolGeometry.GetPockets() do
			if v2.Id == event.PocketId then
				v = v2
			end
		end
	end

	if v then
		PoolViewController.PocketBall(data.View, p, v, event.EntryPosition, event.EntrySpeed)

		if isRewardablePot(data, p) then
			if shooterSeat(data) == data.Seat then -- inferred equivalent call
				PoolHaptics.PotYourBall()
			end

			local v2 = state(data) -- inferred equivalent call

			if v2 then
				v2 = v2.Seats[shooterSeat(data)] -- inferred equivalent call
			end

			PoolVisuals.PlayPot(
				PoolViewController.ToWorld(v.MouthCentre, PoolConstants.VisualCues.PottedHeight),
				v2 and v2.PotEffect
			)
		end
	else
		PoolViewController.SetBallVisible(data.View, p, false)
	end
end

local function rackHasBeenStruck(state2): boolean -- 1 equivalent call inferred from this helper
	for _, event in state2.Simulation.Events do
		if event.Kind == "BallHit" then
			return true
		end
	end

	return false
end

local function syncBalls(state2)
	if not state2.RackRevealed and rackHasBeenStruck(state2) then -- inferred equivalent call
		state2.RackRevealed = true
	end

	for _, v in state2.Simulation.Order do
		local ball = state2.Simulation.Balls[v]

		if ball.Pocketed then
			startDrop(state2, v)
		elseif not PoolViewController.IsDropping(state2.View, v) then
			local v2 = ball.Position

			if not state2.RackRevealed and state2.RackDisplay[v] then
				v2 = state2.RackDisplay[v]
			end

			PoolViewController.SetBall(state2.View, v, v2)
		end
	end
end

local function applyRack(state2, seed: number)
	local rackFor = PoolGeometry.BuildRackFor(state2.GameType, Random.new(seed))

	table.clear(state2.RackDisplay)
	table.clear(state2.Dropped)

	PoolHudRenderer.ResetRows(state2.Hud)

	for _, v in rackFor do
		state2.RackDisplay[v.Number] = v.DisplayPosition
	end

	state2.RackRevealed = false

	PoolPhysics.Reset(state2.Simulation, rackFor)
	PoolStepper.Reset(state2.Stepper)

	PoolAudio.Reset(state2.Audio)
	PoolViewController.ClearRack(state2.View)

	for _, v in state2.Simulation.Order do
		PoolViewController.SetBallVisible(state2.View, v, true)
	end

	PoolViewController.RenderRack(state2.View, rackFor)
end

local function applyBalls(data, balls)
	for k, item in balls do
		local v = tonumber(k)

		if not v then
			continue
		end

		local ball = data.Simulation.Balls[v]

		if not ball then
			continue
		end

		ball.Position = Vector2.new(item.X, item.Y)
		ball.Velocity = Vector2.zero
		ball.Spin = Vector2.zero

		if item.P then
			ball.Pocketed = true
			ball.Sinking = false

			startDrop(data, v)

			if v ~= CueBallNumber then
				PoolHudRenderer.SetBallPotted(data.Hud, v, true)
				PoolViewController.RackBall(data.View, v)
			end
		else
			ball.Pocketed = false
			ball.Sinking = false
			ball.PocketId = nil
			data.Dropped[v] = nil

			if v ~= CueBallNumber then
				PoolHudRenderer.SetBallPotted(data.Hud, v, false)
				PoolViewController.UnrackBall(data.View, v)
			end

			PoolViewController.ReturnBall(data.View, v, ball.Position)
		end
	end

	data.Simulation.Settled = true
end

local function sideOf(_, p: number): string -- 7 equivalent calls inferred from this helper
	return if p == 1 then "Left" else "Right"
end

local function applySeats(state2)
	local v = state(state2) -- inferred equivalent call

	if not v then
		return
	end

	local seatsPainted = ""

	for i = 1, 2 do
		local seat = v.Seats[i]
		local v2

		if seat then
			v2 = string.format(
				"%d:%d:%s:%d:%s:%s:%s|",
				i,
				seat.UserId,
				seat.DisplayName,
				seat.Level,
				tostring(seat.IsBot == true),
				tostring(seat.WinStreak or 0),
				(tostring(PoolVip.ForSeat(seat)))
			)
		else
			v2 = string.format("%d:empty|", i)
		end

		seatsPainted ..= v2
	end

	if seatsPainted == state2.SeatsPainted then
		return
	end

	state2.SeatsPainted = seatsPainted

	state2.Seat = PoolMatchTypes.SeatOf(v, LocalPlayer.UserId) or state2.Seat

	for k, seat in v.Seats do
		PoolHudRenderer.SetPlayer(
			state2.Hud,
			sideOf(nil, k), -- inferred equivalent call
			seat.DisplayName,
			PoolPlayerData.Thumbnail(seat.AvatarUserId or seat.UserId),
			PoolVip.ForSeat(seat)
		)

		PoolHudRenderer.SetLevel(state2.Hud, sideOf(nil, k), seat.Level) -- inferred equivalent call

		PoolHudRenderer.SetWinStreak(state2.Hud, sideOf(nil, k), PoolStreakBadge.ForSeat(seat)) -- inferred equivalent call

		PoolHudRenderer.SetBotTag(state2.Hud, sideOf(nil, k), false) -- inferred equivalent call
	end
end

local function refreshHud(data)
	local v = state(data) -- inferred equivalent call

	if not v then
		return
	end

	PoolHudRenderer.SetActiveSide(data.Hud, sideOf(nil, v.Turn)) -- inferred equivalent call

	applySeats(data)

	data.Rules.Turn = v.Turn
	data.Rules.Phase = v.RulesPhase
	data.Rules.BallInHand = v.BallInHand
	data.Rules.BehindHeadString = v.BehindHeadString

	for k, seat in v.Seats do
		local groups = data.Rules.Groups
		local v2

		if seat.Group ~= "" then
			v2 = seat.Group
		end

		groups[k] = v2
	end

	if isNineBall(data) then -- inferred equivalent call
		PoolHudRenderer.SetNineBall(data.Hud, "Left")
		PoolHudRenderer.SetNineBall(data.Hud, "Right")

		for _, v2 in data.Simulation.Order do
			local ball = data.Simulation.Balls[v2]

			if not (v2 ~= CueBallNumber and ball) then
				continue
			end

			PoolHudRenderer.SetBallPotted(data.Hud, v2, ball.Pocketed)

			if ball.Pocketed then
				PoolViewController.RackBall(data.View, v2)
			end
		end
	else
		for k, seat in v.Seats do
			local v2

			if seat.Group ~= "" then
				v2 = seat.Group
			end

			PoolHudRenderer.SetGroup(data.Hud, sideOf(nil, k), v2) -- inferred equivalent call
		end

		for _, v2 in data.Simulation.Order do
			if not (data.Simulation.Balls[v2].Pocketed and v2 ~= CueBallNumber) then
				continue
			end

			PoolHudRenderer.SetBallPotted(data.Hud, v2, true)
			PoolViewController.RackBall(data.View, v2)
		end

		for k, seat in v.Seats do
			local group

			if seat.Group ~= "" then
				group = seat.Group
			end

			local v2 = group ~= nil and PoolRules.CountRemaining(data.Simulation, group) == 0

			PoolHudRenderer.SetOnEight(data.Hud, sideOf(nil, k), v2) -- inferred equivalent call
		end
	end
end

local function noticeText(p, p2: string)
	if p2 ~= PoolRules.GroupNotice then
		return p2
	end

	local v

	if p.Seat > 0 then
		v = p.Rules.Groups[p.Seat]
	end

	if v then
		return string.format("You're %s!", PoolRules.DescribeGroup(v))
	end

	return ""
end

local function refreshTurnEffects(data)
	PoolVisuals.Clear(data.Effects)
	local v = state(data) -- inferred equivalent call

	if v and v.Phase == "Playing" and isMyTurn(data) then -- inferred equivalent call
		if v.BallInHand then
			PoolVisuals.ShowBallInHand(data.Effects, PoolViewController.GetBallPart(data.View, CueBallNumber))
		end

		local group = PoolRules.GetGroup(data.Rules, data.Seat)

		if not group then
			return
		end

		local ballParts = {}

		for _, v2 in data.Simulation.Order do
			local ball = data.Simulation.Balls[v2]

			if not ball or ball.Pocketed or v2 == CueBallNumber then
				continue
			end

			local v3

			if v2 == EightBallNumber then
				v3 = PoolRules.CountRemaining(data.Simulation, group) == 0
			else
				v3 = groupOfBall(v2) == group -- inferred equivalent call
			end

			if not v3 then
				continue
			end

			local ballPart = PoolViewController.GetBallPart(data.View, v2)

			if ballPart then
				ballParts[v2] = ballPart
			end
		end

		PoolVisuals.HighlightBalls(data.Effects, ballParts)
	end
end

local function ownFoulMessage(data, data2) -- 1 equivalent call inferred from this helper
	local foul = data2.Foul

	if typeof(foul) ~= "string" or foul == "" then
		return nil
	end

	if data.Seat <= 0 or data2.FoulSeat ~= data.Seat or data.Covered then
		return nil
	end

	return PoolFoulPopup.ForFoul(foul, data.GameType)
end

local function applyResolve(state2, data)
	if data.Seed then
		applyRack(state2, data.Seed)
	end

	if data.Balls then
		applyBalls(state2, data.Balls)
	end

	local v = data.CuePickup and state2.Simulation.Balls[CueBallNumber]

	if v then
		local vector2 = Vector2.new(data.CuePickup.X, data.CuePickup.Y)

		v.Position = vector2
		v.Velocity = Vector2.zero
		v.Pocketed = false
		v.Sinking = false
		v.PocketId = nil
		state2.Dropped[CueBallNumber] = nil

		PoolViewController.SetBallVisible(state2.View, CueBallNumber, true)
		PoolViewController.SetBall(state2.View, CueBallNumber, vector2)

		state2.Carry = nil
		state2.BotHeld = vector2
	end

	local v2 = data.CuePlacement and state2.Simulation.Balls[CueBallNumber]

	if v2 then
		local vector2 = Vector2.new(data.CuePlacement.X, data.CuePlacement.Y)
		local v3

		if v2.Pocketed then
			v3 = PoolGeometry.RespotSpot
		else
			v3 = v2.Position
		end

		v2.Position = v3
		v2.Velocity = Vector2.zero
		v2.Pocketed = false
		v2.Sinking = false
		v2.PocketId = nil
		state2.Dropped[CueBallNumber] = nil

		PoolViewController.SetBallVisible(state2.View, CueBallNumber, true)
		PoolViewController.SetBall(state2.View, CueBallNumber, v3)

		local cuePlacement = data.CuePlacement
		local v4

		if typeof(cuePlacement.Seconds) == "number" then
			v4 = cuePlacement.Seconds
		else
			v4 = PoolConstants.Bots.PlaceSeconds
		end

		local seed

		if typeof(cuePlacement.Seed) == "number" then
			seed = cuePlacement.Seed
		end

		local buildCarry = PoolAI.BuildCarry
		local v5

		if seed then
			v5 = Random.new(seed)
		else
			v5 = Random.new()
		end

		local carry = buildCarry(v5, v3, vector2, v4)

		state2.Carry = {
			From = v3,
			To = vector2,
			StartedAt = os.clock(),
			Until = os.clock() + carry.Seconds,
			Shape = carry,
			Held = cuePlacement.Held == true
		}

		state2.BotHeld = nil
	end

	refreshHud(state2)

	state2.OpenClaim = nil

	refreshTurnEffects(state2)

	if isNineBall(state2) then -- inferred equivalent call
		state2.NextHighlightAt = 0
		state2.HighlightDark = false
	end

	local v3 = ownFoulMessage(state2, data) -- inferred equivalent call
	local v4 = data.Notice

	if v3 then
		PoolHudRenderer.ShowFoul(state2.Hud, v3)
		v4 = not data.Respotted and "" or PoolConstants.NineBall.RespotNotice
	end

	if v4 and v4 ~= "" then
		if v4 == PoolRules.GroupNotice then
			local v5

			if state2.Seat > 0 then
				v5 = state2.Rules.Groups[state2.Seat]
			end

			v4 = not v5 and "" or string.format("You're %s!", PoolRules.DescribeGroup(v5))
		end

		if v4 ~= "" then
			PoolHudRenderer.Notify(state2.Hud, v4, 2.5)
		end
	end

	local v5 = state(state2) -- inferred equivalent call

	if not v5 or v5.Phase ~= "Playing" or state2.Input.State == "GameOver" then
		return
	end

	if isMyTurn(state2) then -- inferred equivalent call
		local turn = v5.Turn
		local ballInHand = v5.BallInHand
		local cueRespotted = v5.CueRespotted

		if ballInHand and cueRespotted then
			PoolInputController.GiveBallInHand(state2.Input)
		else
			PoolInputController.Hold(state2.Input, PoolMatchmakingConstants.TurnStartDelay, function()
				local v6 = state(state2) -- inferred equivalent call

				if not v6 or v6.Phase ~= "Playing" or v6.Turn ~= turn then
					return
				end

				if ballInHand then
					PoolInputController.OfferBallInHand(state2.Input)
				else
					PoolInputController.SetState(state2.Input, "Aiming")
				end
			end)
		end
	else
		PoolInputController.SetState(state2.Input, "Simulating")
		hideCue(state2)

		state2.AwaitingShot = true

		state2.AwaitingUntil = os.clock() + 3
	end

	if v5.Turn ~= state2.AnnouncedTurn then
		local v6 = state2.AnnouncedTurn == 0

		state2.AnnouncedTurn = v5.Turn

		local seat = v5.Seats[v5.Turn]

		if seat then
			PoolHudRenderer.Notify(
				state2.Hud,
				v5.Turn == state2.Seat and "Your turn" or string.format("%s's turn", seat.DisplayName),
				2
			)
		end

		if not v6 and v5.Turn == state2.Seat then
			PoolAudio.PlayCue(v5.BallInHand and "TurnStartBallInHand" or "TurnStart")
		end
	end
end

local function matchesPrediction(predictedShot, data)
	local function near(p: number, p2: number): boolean -- 7 equivalent calls inferred from this helper
		return math.abs(p - p2) <= 1e-9
	end
	return near(predictedShot.DirX, data.DirX) -- inferred equivalent call
		and near(predictedShot.DirY, data.DirY) -- inferred equivalent call
		and near(predictedShot.Power, data.Power) -- inferred equivalent call
		and near(predictedShot.SpinX, data.SpinX) -- inferred equivalent call
		and near(predictedShot.SpinY, data.SpinY) -- inferred equivalent call
		and near(predictedShot.CueX, data.CueX) -- inferred equivalent call
		and near(predictedShot.CueY, data.CueY) -- inferred equivalent call
end

local function isBotSeat(p, p2: number)
	local v = state(p) -- inferred equivalent call
	local v2 = v and v.Seats and v.Seats[p2]

	if p2 == p.Seat then
		local covered = p.Covered

		if not covered then
			if v2 == nil then
				return false
			end

			return v2.IsBot == true
		end

		return covered
	end

	return v2 ~= nil and (v2.IsBot == true or (tonumber(v2.UserId) or 0) <= 0)
end

local function holdsShot(state2, data): boolean -- 1 equivalent call inferred from this helper
	if not isBotSeat(state2, data.Seat) then
		return false
	end

	local botLineShownSince = state2.BotLineShownSince

	return not (state2.Simulation.Settled and botLineShownSince and os.clock() - botLineShownSince >= PoolConstants.Bots.MinimumTurn)
end

local onAim

local function drawHeldAim(state2, shot)
	state2.DrawingHeld = true

	onAim(state2, {
		Seat = shot.Seat,
		DirX = shot.DirX,
		DirY = shot.DirY,
		Power = shot.Power,
		SpinX = shot.SpinX,
		SpinY = shot.SpinY,
		CueX = shot.CueX,
		CueY = shot.CueY,
		Placing = false,
		Call = shot.Call
	})

	state2.DrawingHeld = false
end

local function onShot(state2, shot, flag: boolean?)
	if shot.Index <= state2.AppliedShot then
		return
	end

	local predictedShot, shotTarget, v

	if flag then
		state2.AppliedShot = shot.Index
		state2.BotLineShownSince = nil

		predictedShot = state2.PredictedShot
		state2.PredictedShot = nil

		if predictedShot and shot.Seat == state2.Seat and matchesPrediction(predictedShot, shot) then
			state2.AwaitingShot = false

			return
		end

		if predictedShot then
			warn("[PoolMatchClient] predicted shot did not match the server's; replaying the server's")
		end

		state2.Carry = nil
		state2.BotHeld = nil

		state2.ShotSeat = state2.Rules.Turn

		if state2.GameType == "NineBall" then
			shotTarget = PoolRules.LowestBall(state2.Simulation)
		end

		state2.ShotTarget = shotTarget

		state2.OpenClaim = nil

		state2.AwaitingShot = false

		v = state2.Simulation.Balls[CueBallNumber]

		if not v then
			return
		end

		v.Position = Vector2.new(shot.CueX, shot.CueY)
		v.Pocketed = false
		v.Sinking = false
		v.PocketId = nil
		state2.Dropped[CueBallNumber] = nil

		PoolViewController.SetBallVisible(state2.View, CueBallNumber, true)
		PoolStepper.Reset(state2.Stepper)
		PoolInputController.SetState(state2.Input, "Simulating")

		hideCue(state2)

		PoolVisuals.Clear(state2.Effects)

		PoolHudRenderer.SetPower(state2.Hud, 0)

		PoolPhysics.Shoot(
			state2.Simulation,
			Vector2.new(shot.DirX, shot.DirY),
			shot.Power,
			Vector2.new(shot.SpinX, shot.SpinY)
		)

		PoolAudio.PlayCueStrike(shot.Power)

		PoolAudio.Reset(state2.Audio)
	else
		for _, v2 in state2.ShotQueue do
			if v2.Shot.Index == shot.Index then
				return
			end
		end

		state2.LatestShot = math.max(state2.LatestShot, shot.Index)

		if not (#state2.ShotQueue > 0) and not holdsShot(state2, shot) then -- inferred equivalent call
			state2.AppliedShot = shot.Index
			state2.BotLineShownSince = nil

			predictedShot = state2.PredictedShot
			state2.PredictedShot = nil

			if predictedShot and shot.Seat == state2.Seat and matchesPrediction(predictedShot, shot) then
				state2.AwaitingShot = false

				return
			end

			if predictedShot then
				warn("[PoolMatchClient] predicted shot did not match the server's; replaying the server's")
			end

			state2.Carry = nil
			state2.BotHeld = nil

			state2.ShotSeat = state2.Rules.Turn

			if state2.GameType == "NineBall" then
				shotTarget = PoolRules.LowestBall(state2.Simulation)
			end

			state2.ShotTarget = shotTarget

			state2.OpenClaim = nil

			state2.AwaitingShot = false

			v = state2.Simulation.Balls[CueBallNumber]

			if not v then
				return
			end

			v.Position = Vector2.new(shot.CueX, shot.CueY)
			v.Pocketed = false
			v.Sinking = false
			v.PocketId = nil
			state2.Dropped[CueBallNumber] = nil

			PoolViewController.SetBallVisible(state2.View, CueBallNumber, true)
			PoolStepper.Reset(state2.Stepper)
			PoolInputController.SetState(state2.Input, "Simulating")

			hideCue(state2)

			PoolVisuals.Clear(state2.Effects)

			PoolHudRenderer.SetPower(state2.Hud, 0)

			PoolPhysics.Shoot(
				state2.Simulation,
				Vector2.new(shot.DirX, shot.DirY),
				shot.Power,
				Vector2.new(shot.SpinX, shot.SpinY)
			)

			PoolAudio.PlayCueStrike(shot.Power)

			PoolAudio.Reset(state2.Audio)
			return
		end

		table.insert(state2.ShotQueue, { Shot = shot, Bot = isBotSeat(state2, shot.Seat) })
	end
end

onAim = function(state2, data)
	if
		data.Seat == 0
		or #state2.ShotQueue > 0 and not state2.DrawingHeld
		or data.Seat == state2.Seat and not isBotSeat(state2, data.Seat)
	then
		return
	end

	local ball = state2.Simulation.Balls[CueBallNumber]

	if not (ball and state2.Simulation.Settled) then
		return
	end

	local v = state(state2) -- inferred equivalent call

	if v and v.BallInHand then
		ball.Position = Vector2.new(data.CueX, data.CueY)
		PoolViewController.SetBall(state2.View, CueBallNumber, ball.Position)
	end

	if data.Placing then
		showHeldBall(state2, ball.Position) -- inferred equivalent call

		PoolHudRenderer.SetPower(state2.Hud, 0)
	else
		PoolAimOverlay.HideHeldBall(state2.Overlay)

		state2.BotHeld = nil

		local vector2 = Vector2.new(data.DirX, data.DirY)

		if vector2.Magnitude < 0.0001 then
			return
		end

		local unit = vector2.Unit

		local vector2_2 = Vector2.new(data.SpinX, data.SpinY)

		local predictShot = PoolPhysics.PredictShot(state2.Simulation, unit, data.Power, vector2_2, 1 / 60)

		local v2 = predictShot.Kind ~= "Ball"
			or not predictShot.Other
			or PoolRules.IsLegalFirstContact(state2.Rules, state2.Simulation, predictShot.Other)

		PoolAimOverlay.SetVisible(state2.Overlay, true)
		PoolAimOverlay.SetStickVisible(state2.Overlay, state2.View.Mode == "2D")
		PoolAimOverlay.Update(
			state2.Overlay,
			ball.Position,
			unit,
			predictShot,
			data.Power,
			PoolConstants.BasePredictionLength * PoolSkins.GetCueEffects().Aim,
			v2
		)

		PoolViewController.SetCueStickVisible(state2.View, true)
		PoolViewController.SetCueStick(state2.View, ball.Position, unit, data.Power)

		if data.Call then
			PoolAimOverlay.SetPockets(state2.Overlay, PoolGeometry.GetPockets(PoolPhysics.GetTable(state2.Simulation)))
			PoolAimOverlay.ShowPocketCall(state2.Overlay, data.Call, false)
		else
			PoolAimOverlay.HidePocketCall(state2.Overlay)
		end

		PoolHudRenderer.SetPower(state2.Hud, data.Power)
	end
end

local function onInit(state2)
	local v = state(state2) -- inferred equivalent call

	if not (v and v.Active) then
		return
	end

	state2.GameType = PoolMatchTypes.GameTypeOf(v)
	state2.Rules.GameType = state2.GameType

	local rules = state2.Rules
	local callPocket

	if state2.GameType ~= "NineBall" then
		callPocket = PoolConstants.CallPocketFor(v.VenueId)
	end

	rules.CallPocket = callPocket
	state2.Call = nil
	state2.CallLocked = false
	state2.CallKey = ""
	state2.CallPrompted = false
	state2.ShotTarget = nil
	state2.NextHighlightAt = 0
	state2.HighlightDark = false

	state2.Seat = PoolMatchTypes.SeatOf(v, LocalPlayer.UserId) or 0
	state2.AppliedShot = v.ShotIndex
	state2.Pending = nil
	state2.PendingEnd = nil

	state2.ShotQueue = {}
	state2.PatchQueue = {}
	state2.LatestShot = v.ShotIndex
	state2.HeadSince = nil

	state2.PredictedShot = nil

	state2.AnnouncedTurn = 0

	state2.SeatsPainted = ""

	if state2.Input.State == "GameOver" then
		PoolInputController.SetState(state2.Input, "Simulating")
	end

	if v.Seed ~= 0 then
		applyRack(state2, v.Seed)

		if v.ShotIndex > 0 then
			state2.RackRevealed = true

			if v.Balls then
				applyBalls(state2, v.Balls)
			end
		end
	end

	PoolHudRenderer.SetWager(state2.Hud, v.Prize)

	PoolHudRenderer.SetWagerVisible(state2.Hud, (v.Prize or 0) > 0)
	refreshHud(state2)

	refreshTurnEffects(state2)
end

local function sendAim(state2)
	local now = os.clock()

	if now - state2.LastAimSent < 1 / PoolMatchmakingConstants.AimRate then
		return
	end

	state2.LastAimSent = now

	local ball = state2.Simulation.Balls[CueBallNumber]

	if not ball then
		return
	end

	local fireServer = RemoteSignals.FireServer
	local pool = RemoteEnums.Pool

	local x = state2.Input.Direction.X
	local y = state2.Input.Direction.Y
	local power = state2.Input.Power
	local x2 = state2.Hud.Spin.X
	local y2 = state2.Hud.Spin.Y
	local x3 = ball.Position.X
	local y3 = ball.Position.Y

	local v = state2.Input.State == "BallInHand"

	local isActive = PoolActivity.IsActive(PoolMatchmakingConstants.AfkActiveWindow)
	local v2

	if PoolRules.NeedsCall(state2.Rules, state2.Simulation) then
		v2 = state2.Call
	end

	fireServer(pool, "Aim", x, y, power, x2, y2, x3, y3, v, isActive, v2)
end

local function updateCall(state2, p)
	local callKey = string.format("%d:%d", p.ShotIndex or 0, p.Turn or 0)

	if callKey ~= state2.CallKey then
		state2.CallKey = callKey
		state2.Call = nil
		state2.CallLocked = false
	end

	if
		state2.Input.State ~= "Aiming" and state2.Input.State ~= "Charging"
		or not PoolRules.NeedsCall(state2.Rules, state2.Simulation)
	then
		PoolAimOverlay.HidePocketCall(state2.Overlay)

		return
	end

	local call = not state2.CallLocked and PoolRules.AimedPocket(state2.Simulation, state2.Input.Direction)

	if call then
		state2.Call = call
	end

	if not state2.Call then
		local ball = state2.Simulation.Balls[CueBallNumber]
		local call2

		if ball then
			call2 = PoolRules.NearestPocket(state2.Simulation, ball.Position)
		end

		state2.Call = call2
	end

	PoolAimOverlay.SetPockets(state2.Overlay, PoolGeometry.GetPockets(PoolPhysics.GetTable(state2.Simulation)))
	PoolAimOverlay.ShowPocketCall(state2.Overlay, state2.Call, true)

	if not state2.CallPrompted then
		state2.CallPrompted = true

		local v = state2.Rules.CallPocket == "All" and "Call your pocket every shot — tap a pocket to change it"
			or "Call your pocket for the 8 — tap a pocket to change it"

		task.delay(1.4, function()
			if isMyTurn(state2) then -- inferred equivalent call
				PoolHudRenderer.Notify(state2.Hud, v, 3.5)
			end
		end)
	end
end

local function listenToWrite(maid, object, p: string, callback)
	local connection = object:ListenToWrite(p, callback)

	maid:GiveTask(function()
		connection:Disconnect()
	end)
end

function PoolMatchClient.new(replica, view, hud, overlay, state2, simulation, effects)
	local maid = Maid.new()

	local v = {
		Replica = replica,
		View = view,
		Hud = hud,
		Overlay = overlay,
		Input = state2,
		Simulation = simulation,
		Rules = PoolRules.newMatch(1),
		Stepper = PoolStepper.new(),
		Audio = PoolAudio.new(),
		Effects = effects,
		Seat = 0,
		AppliedShot = 0,
		Pending = nil,
		RackDisplay = {},
		RackRevealed = false,
		Dropped = {},
		ShotSeat = 0,
		OpenClaim = nil,
		Carry = nil,
		BotHeld = nil,
		LastAimSent = 0,
		AwaitingShot = false,
		Covered = false,
		PredictedShot = nil,
		AwaitingUntil = 0,
		PreviousIsLegalTarget = nil,
		PreviousClampPlacement = nil,
		AnnouncedTurn = 0,
		Call = nil,
		CallLocked = false,
		CallKey = "",
		CallPrompted = false,
		SeatsPainted = "",
		PendingEnd = nil,
		ShotQueue = {},
		PatchQueue = {},
		LatestShot = 0,
		HeadSince = nil,
		DrawingHeld = false,
		BotLineShownSince = nil,
		GameType = "EightBall",
		ShotTarget = nil,
		NextHighlightAt = 0,
		HighlightDark = false,
		OnFinished = nil,
		Maid = maid
	}
	local connection = replica:ListenToWrite("PoolMatchInit", function()
		onInit(v)
	end)
	maid:GiveTask(function()
		connection:Disconnect()
	end)

	maid:GiveTask(overlay.PocketPicked:Connect(function(call: string)
		if not (isMyTurn(v) and PoolRules.NeedsCall(v.Rules, v.Simulation)) then -- inferred equivalent call
			return
		end

		if v.CallLocked and v.Call == call then
			v.CallLocked = false
		else
			v.Call = call
			v.CallLocked = true
		end

		PoolAimOverlay.ShowPocketCall(v.Overlay, v.Call, true)
	end))
	local connection2 = replica:ListenToWrite("PoolMatchShot", function(p)
		onShot(v, p)
	end)
	maid:GiveTask(function()
		connection2:Disconnect()
	end)
	local connection3 = replica:ListenToWrite("PoolMatchAim", function(p)
		onAim(v, p)
	end)
	maid:GiveTask(function()
		connection3:Disconnect()
	end)
	local connection4 = replica:ListenToWrite("PoolMatchResolve", function(pending)
		if #v.ShotQueue > 0 then
			table.insert(v.PatchQueue, { After = v.LatestShot, Patch = pending })
		elseif v.Simulation.Settled then
			applyResolve(v, pending)
		elseif v.Pending then
			table.insert(v.PatchQueue, { After = v.LatestShot, Patch = pending })
		else
			v.Pending = pending
		end
	end)
	maid:GiveTask(function()
		connection4:Disconnect()
	end)
	local connection5 = replica:ListenToWrite("PoolMatchEnd", function(winner, reason, rewards)
		PoolInputController.EndMatch(v.Input)
		hideCue(v)

		v.PendingEnd = { Winner = winner, Reason = reason, Rewards = rewards }
	end)
	maid:GiveTask(function()
		connection5:Disconnect()
	end)

	maid:GiveTask(state2.Shot:Connect(function(vector2: Vector2, power: number, vector2_2: Vector2)
		if not isMyTurn(v) then -- inferred equivalent call
			return
		end

		local ball = v.Simulation.Balls[CueBallNumber]
		local v2 = if ball then ball.Position else Vector2.zero

		PoolInputController.SetState(v.Input, "Simulating")
		hideCue(v)

		v.AwaitingShot = true
		v.AwaitingUntil = os.clock() + 3

		local fireServer = RemoteSignals.FireServer
		local pool = RemoteEnums.Pool

		local x = vector2.X
		local y = vector2.Y

		local x2 = vector2_2.X
		local y2 = vector2_2.Y
		local x3 = v2.X
		local y3 = v2.Y
		local v3

		if PoolRules.NeedsCall(v.Rules, v.Simulation) then
			v3 = v.Call
		end

		fireServer(pool, "Shot", x, y, power, x2, y2, x3, y3, v3)

		v.PredictedShot = {
			DirX = vector2.X,
			DirY = vector2.Y,
			Power = power,
			SpinX = vector2_2.X,
			SpinY = vector2_2.Y,
			CueX = v2.X,
			CueY = v2.Y
		}

		v.ShotSeat = v.Rules.Turn
		local shotTarget

		if isNineBall(v) then -- inferred equivalent call
			shotTarget = PoolRules.LowestBall(v.Simulation)
		end

		v.ShotTarget = shotTarget
		v.Carry = nil
		v.OpenClaim = nil

		PoolVisuals.Clear(v.Effects)
		PoolHudRenderer.SetPower(v.Hud, 0)

		PoolStepper.Reset(v.Stepper)
		PoolPhysics.Shoot(v.Simulation, vector2, power, vector2_2)

		PoolAudio.PlayCueStrike(power)

		PoolAudio.Reset(v.Audio)

		PoolHudRenderer.ResetSpin(v.Hud)
	end))

	v.PreviousIsLegalTarget = state2.IsLegalTarget
	v.PreviousClampPlacement = state2.ClampPlacement

	function state2.IsLegalTarget(p: number)
		return PoolRules.IsLegalFirstContact(v.Rules, v.Simulation, p)
	end

	function state2.ClampPlacement(vector2: Vector2)
		return PoolRules.ClampPlacement(v.Rules, vector2)
	end

	onInit(v)

	return v
end

function PoolMatchClient:Update(p: number)
	local v = state(self) -- inferred equivalent call

	if not (v and v.Active) then
		return
	end

	if self.Carry and self.Simulation.Settled then
		local carry = self.Carry
		local ball = self.Simulation.Balls[CueBallNumber]
		local v2 = math.max(carry.Until - carry.StartedAt, 0.001)
		local v3 = math.clamp((os.clock() - carry.StartedAt) / v2, 0, 1)

		if ball then
			local position

			if carry.Shape then
				position = PoolAI.CarryPosition(carry.Shape, carry.From, carry.To, v3)
			else
				position = carry.From:Lerp(carry.To, PoolAI.Ease(v3))
			end

			ball.Position = position

			PoolViewController.SetBall(self.View, CueBallNumber, ball.Position)

			showHeldBall(self, ball.Position) -- inferred equivalent call
		else
			v3 = 1
		end

		if v3 >= 1 then
			self.Carry = nil

			if carry.Held then
				self.BotHeld = carry.To
			else
				PoolAimOverlay.HideHeldBall(self.Overlay)
			end
		end
	elseif self.Carry then
		self.Carry = nil
	end

	if self.BotHeld and not self.Carry then
		if self.Simulation.Settled and isBotSeat(self, v.Turn) then
			showHeldBall(self, self.BotHeld) -- inferred equivalent call
		else
			self.BotHeld = nil
			PoolAimOverlay.HideHeldBall(self.Overlay)
		end
	end

	if
		self.Simulation.Settled
		and (#self.ShotQueue > 0 or isBotSeat(self, v.Turn))
		and PoolAimOverlay.IsAimShown(self.Overlay)
	then
		self.BotLineShownSince = self.BotLineShownSince or os.clock()
	else
		self.BotLineShownSince = nil
	end

	if not self.Simulation.Settled then
		PoolStepper.Advance(self.Stepper, self.Simulation, p)
		syncBalls(self)

		PoolAudio.Update(self.Audio, self.Simulation)

		hideCue(self)

		if self.Simulation.Settled and self.Pending then
			local pending = self.Pending
			self.Pending = nil

			applyResolve(self, pending)
		end
	end

	if self.Simulation.Settled and not self.Pending then
		local v2 = self.ShotQueue[1]
		local v3

		if v2 then
			v3 = v2.Shot.Index - 1
		else
			v3 = 1e999
		end

		while self.PatchQueue[1] and self.PatchQueue[1].After <= v3 do
			applyResolve(self, table.remove(self.PatchQueue, 1).Patch)
		end

		if v2 then
			local now = os.clock()
			local v4 = not v2.Bot

			if v2.Bot then
				self.HeadSince = self.HeadSince or now

				if not PoolAimOverlay.IsAimShown(self.Overlay) then
					drawHeldAim(self, v2.Shot)
				end

				local botLineShownSince = self.BotLineShownSince
				v4 = botLineShownSince ~= nil and now - botLineShownSince >= PoolConstants.Bots.MinimumTurn
					or now - self.HeadSince >= 4
			end

			if v4 then
				table.remove(self.ShotQueue, 1)
				self.HeadSince = nil

				onShot(self, v2.Shot, true)
			end
		end
	end

	if self.PendingEnd and self.Simulation.Settled and #self.ShotQueue == 0 and #self.PatchQueue == 0 then
		local pendingEnd = self.PendingEnd
		self.PendingEnd = nil

		if self.Seat > 0 and pendingEnd.Winner > 0 and pendingEnd.Winner ~= self.Seat and not self.Covered then
			PoolHudRenderer.ShowFoul(self.Hud, PoolFoulPopup.ForLoss(pendingEnd.Reason))
		end

		task.delay(PoolMatchmakingConstants.ResultDelay, function()
			if self.OnFinished then
				self.OnFinished(pendingEnd.Winner, pendingEnd.Reason, pendingEnd.Rewards)
			end
		end)
	end

	if v.Phase == "Playing" and v.TurnEndsAt > 0 then
		local defaultTurnTime = PoolConstants.Rules.DefaultTurnTime
		local v2 = v.TurnEndsAt - workspace:GetServerTimeNow()

		PoolHudRenderer.SetTimer(self.Hud, (math.clamp(v2 / defaultTurnTime, 0, 1)))

		PoolAudio.TurnClock(v2)
	end

	if self.AwaitingShot and os.clock() > self.AwaitingUntil then
		self.AwaitingShot = false
	end

	if
		isNineBall(self) -- inferred equivalent call
		and (v.Phase == "Playing" or v.Phase == "Countdown")
		and self.Input.State ~= "GameOver"
		and self.Simulation.Settled
		and #self.ShotQueue == 0
	then
		local now = os.clock()

		if self.NextHighlightAt <= now then
			self.NextHighlightAt = now + PoolConstants.NineBall.HighlightInterval

			local lowestBall = PoolRules.LowestBall(self.Simulation)
			local v2

			if lowestBall then
				v2 = PoolViewController.GetBallPart(self.View, lowestBall)
			end

			if lowestBall and v2 and not PoolViewController.IsDropping(self.View, lowestBall) then
				local v3

				if self.HighlightDark then
					v3 = PoolConstants.VisualCues.YourBallsDark
				else
					v3 = PoolConstants.VisualCues.YourBalls
				end

				PoolVisuals.HighlightBalls(self.Effects, { [lowestBall] = v2 }, v3)
				self.HighlightDark = not self.HighlightDark
			end
		end
	end

	if isMyTurn(self) and self.Simulation.Settled and not self.AwaitingShot and #self.ShotQueue == 0 then -- inferred equivalent call
		PoolInputController.Update(self.Input, p)

		updateCall(self, v)

		if self.Input.State ~= "Simulating" then
			sendAim(self)
		end
	end
end

function PoolMatchClient.SetVolumeScale(p, p2: number)
	PoolAudio.SetVolumeScale(p.Audio, p2)
end

function PoolMatchClient.GetSeat(p)
	return p.Seat
end

function PoolMatchClient.GetSeatEntry(p, p2: number)
	local v = state(p) -- inferred equivalent call
	local v2 = v and v.Seats[p2]

	if v2 then
		return (table.clone(v2))
	end

	return nil
end

function PoolMatchClient:SetCovered(covered: boolean)
	self.Covered = covered
end

function PoolMatchClient.Destroy(data)
	data.Input.IsLegalTarget = data.PreviousIsLegalTarget
	data.Input.ClampPlacement = data.PreviousClampPlacement

	hideCue(data)

	PoolVisuals.ClearHighlights(data.Effects)

	data.Maid:DoCleaning()
end

return PoolMatchClient