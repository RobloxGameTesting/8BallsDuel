local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolGeometry = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolGeometry)
local PoolPhysics = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolPhysics)
local PoolRuleSets = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolRuleSets)

local PoolRules = {}

local CueBallNumber = PoolConstants.CueBallNumber
local EightBallNumber = PoolConstants.EightBallNumber

PoolRules.LossReasons = {
	NineLegal = "Pocketed the 9 legally",
	EightOnBreak = "Pocketed the 8 on the break",
	EightEarly = "Pocketed the 8 before clearing their group",
	EightScratch = "Scratched while pocketing the 8",
	EightFoul = "Fouled while pocketing the 8",
	EightLegal = "Pocketed the 8 legally",
	EightWrongPocket = "Pocketed the 8 in a pocket they had not called"
}

PoolRules.WrongPocketNotice = "Wrong pocket — turn over"

function PoolRules.LossKind(p: string?)
	if p == nil then
		return nil
	end

	for k, lossReason in PoolRules.LossReasons do
		if lossReason == p then
			return k
		end
	end

	return nil
end

local function other(turn: number): number -- 15 equivalent calls inferred from this helper
	return if turn == 1 then 2 else 1
end

local function groupOf(p: number) -- 4 equivalent calls inferred from this helper
	local group = PoolConstants.GetGroup(p)

	return if group == "Solid" or group == "Stripe" then group else nil
end

function PoolRules.CountRemaining(p, p2: string)
	local v

	if p2 == "Solid" then
		v = PoolConstants.Solids
	else
		v = PoolConstants.Stripes
	end

	local count = 0

	for _, v2 in v do
		local ball = p.Balls[v2]

		if not ball or ball.Pocketed then
			continue
		end

		count += 1
	end

	return count
end

function PoolRules.IsOnEight(p, p2: string?): boolean
	return p2 ~= nil and PoolRules.CountRemaining(p, p2) == 0
end

function PoolRules.newMatch(value: number?, p, p2: string?, callPocket: string?)
	local v = value or 1
	local v2 = p2 == "NineBall"
	local match = {
		Phase = "Break",
		Turn = v,
		Breaker = v,
		Groups = {},
		BallInHand = true,
		BehindHeadString = true,
		Winner = nil,
		LossReason = nil,
		ShotCount = 0,
		Rules = PoolRuleSets.Resolve(p),
		GameType = v2 and "NineBall" or "EightBall",
		CallPocket = 0
	}

	if v2 or callPocket ~= "Eight" and callPocket ~= "All" then
		callPocket = nil
	end

	match.CallPocket = callPocket
	return match
end

function PoolRules.NeedsCall(data, p)
	if not data or PoolRules.IsNineBall(data) then
		return false
	end

	local callPocket = data.CallPocket

	if callPocket ~= "Eight" and callPocket ~= "All" or (data.Phase == "Break" or data.Phase == "GameOver") then
		return false
	end

	if callPocket == "All" then
		return true
	end

	return PoolRules.IsOnEight(p, data.Groups[data.Turn])
end

function PoolRules.IsPocket(p, value): boolean
	if typeof(value) ~= "string" then
		return false
	end

	for _, v in PoolGeometry.GetPockets(PoolPhysics.GetTable(p)) do
		if v.Id == value then
			return true
		end
	end

	return false
end

function PoolRules.NearestPocket(p, vector2: Vector2)
	local v = 1e999
	local id = nil

	for _, v2 in PoolGeometry.GetPockets(PoolPhysics.GetTable(p)) do
		local magnitude = (v2.MouthCentre - vector2).Magnitude

		if not (magnitude < v) then
			continue
		end

		id = v2.Id
		v = magnitude
	end

	return id
end

function PoolRules.AimedPocket(p, vector2: Vector2)
	if vector2.Magnitude < 0.0001 then
		return nil
	end

	local v = PoolPhysics.CastCueBall(p, vector2)

	if v.Kind ~= "Ball" or not (v.ObjectDirection and v.Other) then
		return nil
	end

	local ball = p.Balls[v.Other]

	if not ball then
		return nil
	end

	local unit = v.ObjectDirection.Unit
	local v2 = -1e999
	local id = nil

	for _, v3 in PoolGeometry.GetPockets(PoolPhysics.GetTable(p)) do
		local v4 = v3.MouthCentre - ball.Position

		if not (v4.Magnitude > 0.001) then
			continue
		end

		local dot = unit:Dot(v4.Unit)

		if not (v2 < dot) then
			continue
		end

		id = v3.Id
		v2 = dot
	end

	return id
end

function PoolRules.IsNineBall(p): boolean
	return p ~= nil and p.GameType == "NineBall"
end

function PoolRules.MoneyBall(p)
	if PoolRules.IsNineBall(p) then
		return PoolConstants.NineBall.BallNumber
	end

	return EightBallNumber
end

local function lowestOnTable(p, p2)
	local v = nil

	for _, v2 in p.Order do
		if v2 == CueBallNumber then
			continue
		end

		local v3

		if p2 then
			v3 = p2[v2] == true
		else
			local ball = p.Balls[v2]

			if ball == nil then
				v3 = false
			else
				v3 = not (ball.Pocketed or ball.Destroyed)
			end
		end

		if v3 and (v == nil or v2 < v) then
			v = v2
		end
	end

	return v
end

function PoolRules.LowestBall(p)
	return lowestOnTable(p, nil)
end

function PoolRules.GetRules(p)
	return PoolRuleSets.Resolve(p.Rules)
end

function PoolRules.GetGroup(p, p2: number)
	return p.Groups[p2]
end

function PoolRules.BeginShot(data, p)
	local onTable = {}

	for _, v in p.Order do
		local ball = p.Balls[v]
		onTable[v] = ball ~= nil and not ball.Pocketed
	end

	return {
		WasBreak = data.Phase == "Break",
		TimedOut = false,
		Group = data.Groups[data.Turn],
		OnTable = onTable
	}
end

local function readShot(p)
	local v = 1e999
	local count = 0
	local ballSet = {}
	local balls = {}
	local other2 = nil

	for _, event in p.Events do
		if not (event.Kind == "BallHit" and event.Ball == CueBallNumber and event.Other and event.Time < v) then
			continue
		end

		v = event.Time
		other2 = event.Other
	end

	for _, event in p.Events do
		if event.Kind == "Pocketed" then
			table.insert(balls, event.Ball)
		elseif event.Kind == "CushionHit" or event.Kind == "TipHit" then
			if event.Ball ~= CueBallNumber then
				ballSet[event.Ball] = true
			end

			if v <= event.Time then
				count += 1
			end
		end
	end

	local count2 = 0

	for _ in ballSet do
		count2 += 1
	end

	return other2, balls, count, count2
end

local function finish(state, p, winner: number, lossReason: string) -- 7 equivalent calls inferred from this helper
	state.Phase = "GameOver"
	state.Winner = winner
	state.LossReason = lossReason
	state.BallInHand = false
	p.Winner = winner
	p.LossReason = lossReason
	p.Continues = false
	p.TurnPasses = false
	p.BallInHand = false
end

local function resolveNineBall(state, p, data)
	local turn = state.Turn
	local ballNumber = PoolConstants.NineBall.BallNumber
	local firstContact, potted, railsAfterContact, objectBallsToRail = readShot(p)

	local nineBall = {
		Fouls = {},
		Legal = true,
		Potted = potted,
		FirstContact = firstContact,
		RailsAfterContact = railsAfterContact,
		ObjectBallsToRail = objectBallsToRail,
		GroupAssigned = nil,
		TurnPasses = true,
		BallInHand = false,
		BehindHeadString = false,
		Rerack = false,
		Winner = nil,
		LossReason = nil,
		Continues = false,
		Respot = {}
	}

	local function foul(p2: string) -- 6 equivalent calls inferred from this helper
		if not table.find(nineBall.Fouls, p2) then
			table.insert(nineBall.Fouls, p2)
		end

		nineBall.Legal = false
	end

	local rules = PoolRules.GetRules(state)

	state.ShotCount += 1

	local v = lowestOnTable(p, data.OnTable)
	local v2 = false
	local flag = false
	local v3 = false

	for _, v4 in potted do
		if v4 == CueBallNumber then
			v2 = true
		else
			flag = true

			if v4 == ballNumber then
				v3 = true
			end
		end
	end

	if data.TimedOut and rules.TimeoutIsFoul then
		foul("Timeout") -- inferred equivalent call
	end

	if v2 and rules.ScratchIsFoul then
		foul("Scratch") -- inferred equivalent call
	end

	if not data.TimedOut then
		if firstContact then
			if v ~= nil and firstContact ~= v then
				foul("WrongBallFirst") -- inferred equivalent call
			end

			if not data.WasBreak and rules.RequireRailAfterContact and not flag and railsAfterContact == 0 then
				foul("NoRailAfterContact") -- inferred equivalent call
			end
		elseif rules.RequireContact then
			foul("NoContact") -- inferred equivalent call
		end
	end

	if
		data.WasBreak
		and rules.BreakRequiresRails
		and not flag
		and objectBallsToRail < rules.BreakMinimumRailContacts
	then
		foul("IllegalBreak") -- inferred equivalent call
	end

	if v3 and (data.WasBreak or not nineBall.Legal) then
		table.insert(nineBall.Respot, ballNumber)
	end

	if v3 and nineBall.Legal and not data.WasBreak then
		finish(state, nineBall, turn, PoolRules.LossReasons.NineLegal) -- inferred equivalent call

		return nineBall
	elseif data.WasBreak then
		local v4 = not table.find(nineBall.Fouls, "IllegalBreak")

		state.Phase = "Open"

		if nineBall.Legal then
			if flag then
				state.BallInHand = false
				state.BehindHeadString = false
				nineBall.TurnPasses = false
				nineBall.Continues = true
			else
				state.Turn = other(turn) -- inferred equivalent call
				state.BallInHand = false
				state.BehindHeadString = false
			end

			return nineBall
		else
			state.Turn = other(turn) -- inferred equivalent call

			local foulGivesBallInHand = rules.BreakScratchGivesBallInHand and rules.FoulGivesBallInHand

			state.BallInHand = foulGivesBallInHand
			state.BehindHeadString = foulGivesBallInHand and not v4
			nineBall.BallInHand = state.BallInHand
			nineBall.BehindHeadString = state.BehindHeadString

			if not v4 then
				state.Phase = "Break"
				state.Breaker = state.Turn
			end

			return nineBall
		end
	else
		if nineBall.Legal then
			if flag then
				state.BallInHand = false
				state.BehindHeadString = false
				nineBall.TurnPasses = false
				nineBall.Continues = true
			else
				state.Turn = other(turn) -- inferred equivalent call
				state.BallInHand = false
				state.BehindHeadString = false
			end
		else
			state.Turn = other(turn) -- inferred equivalent call

			state.BallInHand = rules.FoulGivesBallInHand
			state.BehindHeadString = false
			nineBall.BallInHand = state.BallInHand
			nineBall.BehindHeadString = false
		end

		return nineBall
	end
end

function PoolRules:ResolveShot(p, data)
	if PoolRules.IsNineBall(self) then
		return resolveNineBall(self, p, data)
	end

	local turn = self.Turn
	local firstContact, potted, railsAfterContact, objectBallsToRail = readShot(p)

	local result = {
		Fouls = {},
		Legal = true,
		Potted = potted,
		FirstContact = firstContact,
		RailsAfterContact = railsAfterContact,
		ObjectBallsToRail = objectBallsToRail,
		GroupAssigned = nil,
		TurnPasses = true,
		BallInHand = false,
		BehindHeadString = false,
		Rerack = false,
		Winner = nil,
		LossReason = nil,
		Continues = false
	}

	local function foul(p2: string) -- 10 equivalent calls inferred from this helper
		table.insert(result.Fouls, p2)
		result.Legal = false
	end

	local rules = PoolRules.GetRules(self)

	self.ShotCount += 1

	local _ = #potted > 0
	local flag = false
	local flag2 = false
	local flag3 = false

	for _, v in potted do
		if v == CueBallNumber then
			flag = true
		elseif v == EightBallNumber then
			flag2 = true
		end
	end

	if data.TimedOut and rules.TimeoutIsFoul then
		foul("Timeout") -- inferred equivalent call
	end

	if flag and rules.ScratchIsFoul then
		foul("Scratch") -- inferred equivalent call
	end

	if not data.TimedOut then
		if firstContact then
			if rules.RequireRailAfterContact then
				local v = false

				for _, v2 in potted do
					if v2 ~= CueBallNumber then
						v = true
					end
				end

				if not v and railsAfterContact == 0 then
					foul("NoRailAfterContact") -- inferred equivalent call
				end
			end
		elseif rules.RequireContact then
			foul("NoContact") -- inferred equivalent call
		end
	end

	if data.WasBreak then
		result.Fouls = {}
		result.Legal = true

		if data.TimedOut and rules.TimeoutIsFoul then
			foul("Timeout") -- inferred equivalent call
		end

		if flag and rules.ScratchIsFoul then
			foul("Scratch") -- inferred equivalent call
		end

		local flag4 = false

		for _, v in potted do
			if v ~= CueBallNumber then
				flag4 = true
			end
		end

		if rules.BreakRequiresRails and not flag4 and objectBallsToRail < rules.BreakMinimumRailContacts then
			foul("IllegalBreak") -- inferred equivalent call
		end

		if flag2 and rules.EightOnBreakRespots then
			result.Rerack = true
			self.Phase = "Break"
			self.Groups = {}
			self.Breaker = other(turn) -- inferred equivalent call
			self.Turn = self.Breaker
			self.BallInHand = true
			self.BehindHeadString = true
			result.TurnPasses = true
			result.BallInHand = true
			result.BehindHeadString = true

			return result
		elseif flag2 then
			finish(self, result, other(turn), PoolRules.LossReasons.EightOnBreak) -- inferred equivalent call

			return result
		else
			self.Phase = rules.TableOpenAfterBreak and "Open" or "Assigned"
			local v = true

			for _, foul2 in result.Fouls do
				if foul2 == "IllegalBreak" then
					v = false
				end
			end

			if result.Legal then
				if flag4 then
					self.BallInHand = false
					self.BehindHeadString = false
					result.TurnPasses = false
					result.Continues = true
				else
					self.Turn = other(turn) -- inferred equivalent call
					self.BallInHand = false
					self.BehindHeadString = false
				end

				return result
			else
				self.Turn = other(turn) -- inferred equivalent call

				local foulGivesBallInHand = rules.BreakScratchGivesBallInHand and rules.FoulGivesBallInHand

				self.BallInHand = foulGivesBallInHand
				self.BehindHeadString = foulGivesBallInHand and not v
				result.BallInHand = self.BallInHand
				result.BehindHeadString = self.BehindHeadString

				if not v then
					self.Phase = "Break"
					self.Breaker = self.Turn
				end

				return result
			end
		end
	else
		local group = data.Group

		if group ~= nil then
			local _ = PoolRules.CountRemaining(p, group) == 0
		end

		local count = 0

		if group then
			local v

			if group == "Solid" then
				v = PoolConstants.Solids
			else
				v = PoolConstants.Stripes
			end

			for _, v2 in v do
				if data.OnTable[v2] then
					count += 1
				end
			end
		end

		local v

		if group == nil then
			v = false
		else
			v = count == 0
		end

		local callPocket = self.CallPocket
		local v2

		if callPocket == "All" then
			v2 = true
		else
			v2 = callPocket == "Eight" and v
		end

		local calledPocket = data.CalledPocket
		local pocketIdsByBall = {}

		for _, event in p.Events do
			if event.Kind ~= "Pocketed" or not event.PocketId or pocketIdsByBall[event.Ball] then
				continue
			end

			pocketIdsByBall[event.Ball] = event.PocketId
		end

		local function counts(p2: number) -- 3 equivalent calls inferred from this helper
			local v3 = not v2

			if not v3 then
				if calledPocket == nil then
					return false
				end

				return pocketIdsByBall[p2] == calledPocket
			end

			return v3
		end

		if firstContact and rules.RequireOwnGroupFirst then
			if group then
				if v then
					if firstContact ~= EightBallNumber then
						foul("WrongBallFirst") -- inferred equivalent call
					end
				else
					local group2 = groupOf(firstContact) -- inferred equivalent call

					if firstContact == EightBallNumber or group2 ~= group then
						foul("WrongBallFirst") -- inferred equivalent call
					end
				end
			elseif firstContact == EightBallNumber then
				foul("WrongBallFirst") -- inferred equivalent call
			end
		end

		if flag2 then
			if v then
				if flag then
					finish(self, result, other(turn), PoolRules.LossReasons.EightScratch) -- inferred equivalent call
				elseif result.Legal then
					if counts(EightBallNumber) then -- inferred equivalent call
						finish(self, result, turn, PoolRules.LossReasons.EightLegal) -- inferred equivalent call
					else
						finish(self, result, other(turn), PoolRules.LossReasons.EightWrongPocket) -- inferred equivalent call
					end
				else
					finish(self, result, other(turn), PoolRules.LossReasons.EightFoul) -- inferred equivalent call
				end
			else
				finish(self, result, other(turn), PoolRules.LossReasons.EightEarly) -- inferred equivalent call
			end

			return result
		else
			if self.Phase == "Open" and result.Legal and rules.AssignGroupOnFirstPotted then
				for _, v3 in potted do
					local groupAssigned = groupOf(v3) -- inferred equivalent call

					if groupAssigned and counts(v3) then -- inferred equivalent call
						self.Groups[turn] = groupAssigned
						self.Groups[other(turn)] = groupAssigned == "Solid" and "Stripe" or "Solid" -- inferred equivalent call
						self.Phase = "Assigned"
						result.GroupAssigned = groupAssigned
						break
					end
				end
			end

			local group2 = self.Groups[turn]
			local flag4 = false

			for _, v3 in potted do
				if v3 == CueBallNumber or v3 == EightBallNumber or group2 ~= nil and groupOf(v3) ~= group2 then -- inferred equivalent call
					continue
				end

				if counts(v3) then -- inferred equivalent call
					flag3 = true
				else
					flag4 = true
				end
			end

			if result.Legal then
				if flag3 then
					self.BallInHand = false
					self.BehindHeadString = false
					result.TurnPasses = false
					result.Continues = true
				else
					self.Turn = other(turn) -- inferred equivalent call
					self.BallInHand = false
					self.BehindHeadString = false

					if flag4 then
						result.WrongPocket = true
					end
				end
			else
				self.Turn = other(turn) -- inferred equivalent call

				self.BallInHand = rules.FoulGivesBallInHand

				self.BehindHeadString = false
				result.BallInHand = self.BallInHand
				result.BehindHeadString = false
			end

			return result
		end
	end
end

function PoolRules.ClampPlacement(p, vector2: Vector2)
	local clampToPlayArea = PoolGeometry.ClampToPlayArea(vector2)

	if not p.BehindHeadString then
		return clampToPlayArea
	end

	local v = PoolGeometry.HeadStringX - PoolConstants.BallRadius

	return Vector2.new(math.min(clampToPlayArea.X, v), clampToPlayArea.Y)
end

function PoolRules.IsLegalFirstContact(data, p, p2: number): boolean
	if p2 == CueBallNumber then
		return false
	end

	if PoolRules.IsNineBall(data) then
		return data.Phase ~= "GameOver" and p2 == PoolRules.LowestBall(p)
	else
		if data.Phase == "Break" then
			return true
		end

		local group = data.Groups[data.Turn]

		if not group then
			return p2 ~= EightBallNumber
		end

		if PoolRules.CountRemaining(p, group) == 0 then
			return p2 == EightBallNumber
		end

		return groupOf(p2) == group -- inferred equivalent call
	end
end

PoolRules.GroupNotice = "@GroupAssigned"

function PoolRules.DescribeGroup(p: string?): string
	if p == "Solid" then
		return "Solids"
	elseif p == "Stripe" then
		return "Stripes"
	end

	return "Open table"
end

local function respotIsFree(p, vector2: Vector2, p2: number): boolean
	if not PoolGeometry.IsInsidePlayArea(vector2, PoolConstants.BallRadius) then
		return false
	end

	for _, v in PoolPhysics.GetActiveBalls(p) do
		if v.Number ~= p2 and (v.Position - vector2).Magnitude < PoolConstants.BallDiameter + 0.02 then
			return false
		end
	end

	return true
end

function PoolRules.FindRespotPosition(p, p2: number, vector2: Vector2?)
	local selected = vector2 or PoolGeometry.NineBallSpot

	if respotIsFree(p, selected, p2) then
		return selected
	end

	local v = PoolConstants.BallDiameter * 0.25

	for _, v2 in { Vector2.new(1, 0), Vector2.new(-1, 0) } do
		for i = 1, 400 do
			local v3 = selected + v2 * (i * v)

			if not PoolGeometry.IsInsidePlayArea(v3, PoolConstants.BallRadius) then
				break
			end

			if respotIsFree(p, v3, p2) then
				return v3
			end
		end
	end

	for i = 1, 80 do
		local v2 = i * v * 2
		local v3 = math.max(8, (math.floor(6.283185307179586 * v2 / v)))

		for j = 0, v3 - 1 do
			local v4 = j / v3 * 3.141592653589793 * 2
			local v5 = selected + Vector2.new(math.cos(v4), (math.sin(v4))) * v2

			if respotIsFree(p, v5, p2) then
				return v5
			end
		end
	end

	return PoolGeometry.ClampToPlayArea(selected)
end

function PoolRules.RespotBall(p, p2: number, vector2: Vector2?)
	local ball = p.Balls[p2]

	if not ball then
		return nil
	end

	ball.Pocketed = false
	ball.Sinking = false
	ball.PocketId = nil
	ball.Velocity = Vector2.zero
	ball.Spin = Vector2.zero

	ball.Height = 0
	ball.VerticalSpeed = 0
	ball.TeeterAt = nil
	ball.TeeterFor = 0
	ball.Destroyed = nil

	ball.Position = PoolRules.FindRespotPosition(p, p2, vector2)

	return ball.Position
end

local v = {
	"Timeout",
	"Scratch",
	"NoContact",
	"WrongBallFirst",
	"NoRailAfterContact",
	"IllegalBreak",
	"BallOffTable",
	"EightOutOfTurn"
}

function PoolRules.PrimaryFoul(list)
	if not list or #list == 0 then
		return nil
	end

	for _, v2 in v do
		if table.find(list, v2) then
			return v2
		end
	end

	return list[1]
end

function PoolRules.DescribeFoul(p: string, p2: string?): string
	if p == "WrongBallFirst" and p2 == "NineBall" then
		return "Lowest ball not hit first"
	end

	if p == "Scratch" then
		return "Cue ball pocketed"
	elseif p == "NoContact" then
		return "No ball was hit"
	elseif p == "WrongBallFirst" then
		return "Wrong ball hit first"
	elseif p == "NoRailAfterContact" then
		return "No ball reached a rail"
	elseif p == "Timeout" then
		return "Ran out of time"
	elseif p == "IllegalBreak" then
		return "Illegal break"
	elseif p == "BallOffTable" then
		return "Ball driven off the table"
	end

	return "Foul"
end

return PoolRules