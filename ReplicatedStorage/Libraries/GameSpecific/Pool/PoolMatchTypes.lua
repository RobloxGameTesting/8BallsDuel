local PoolMatchTypes = {}
PoolMatchTypes.CueBallKey = "0"

function PoolMatchTypes.EmptyAim()
	return {
		Seat = 0,
		DirX = 1,
		DirY = 0,
		Power = 0,
		SpinX = 0,
		SpinY = 0,
		CueX = 0,
		CueY = 0,
		Placing = false
	}
end

function PoolMatchTypes.EmptyShot()
	return {
		Index = 0,
		Seat = 0,
		DirX = 1,
		DirY = 0,
		Power = 0,
		SpinX = 0,
		SpinY = 0,
		CueX = 0,
		CueY = 0
	}
end

function PoolMatchTypes.Empty()
	return {
		Active = false,
		Phase = "Idle",
		VenueId = "",
		GameType = "EightBall",
		Wager = 0,
		Prize = 0,
		Seed = 0,
		Turn = 1,
		Seats = {},
		BallInHand = false,
		BehindHeadString = false,
		RulesPhase = "Break",
		CueRespotted = false,
		ShotIndex = 0,
		Shot = PoolMatchTypes.EmptyShot(),
		Aim = PoolMatchTypes.EmptyAim(),
		Balls = {},
		StartsAt = 0,
		TurnEndsAt = 0,
		Notice = "",
		Winner = 0,
		LossReason = "",
		Rewards = {}
	}
end

function PoolMatchTypes.SeatOf(p, p2: number)
	for k, seat in p.Seats do
		if seat.UserId == p2 then
			return k
		end
	end

	return nil
end

function PoolMatchTypes.Opponent(p: number): number
	return if p == 1 then 2 else 1
end

function PoolMatchTypes.GameTypeOf(p)
	if not p then
		return "EightBall"
	end

	local gameType = p.GameType

	if gameType == "NineBall" or gameType == "EightBall" then
		return gameType
	end

	return if p.VenueId == "NineBall" then "NineBall" else "EightBall"
end

return PoolMatchTypes