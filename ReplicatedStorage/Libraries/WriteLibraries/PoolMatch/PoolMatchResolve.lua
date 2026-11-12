return function(p, data)
	local poolMatch = p.Data.poolMatch

	if not poolMatch then
		return
	end

	if data.Phase ~= nil then
		poolMatch.Phase = data.Phase
	end

	if data.Turn ~= nil then
		poolMatch.Turn = data.Turn
	end

	if data.Seats ~= nil then
		poolMatch.Seats = data.Seats
	end

	if data.CuePlacement ~= nil then
		poolMatch.CuePlacement = data.CuePlacement
	end

	if data.Groups ~= nil then
		for k, group in data.Groups do
			local seat = poolMatch.Seats[k]

			if seat then
				seat.Group = group
			end
		end
	end

	if data.BallInHand ~= nil then
		poolMatch.BallInHand = data.BallInHand
	end

	if data.BehindHeadString ~= nil then
		poolMatch.BehindHeadString = data.BehindHeadString
	end

	if data.RulesPhase ~= nil then
		poolMatch.RulesPhase = data.RulesPhase
	end

	if data.CueRespotted ~= nil then
		poolMatch.CueRespotted = data.CueRespotted
	end

	if data.Balls ~= nil then
		poolMatch.Balls = data.Balls
	end

	if data.TurnEndsAt ~= nil then
		poolMatch.TurnEndsAt = data.TurnEndsAt
	end

	if data.StartsAt ~= nil then
		poolMatch.StartsAt = data.StartsAt
	end

	if data.Notice ~= nil then
		poolMatch.Notice = data.Notice
	end

	if data.Seed ~= nil then
		poolMatch.Seed = data.Seed
	end
end