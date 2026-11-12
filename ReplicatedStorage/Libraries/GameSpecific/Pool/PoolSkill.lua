local PoolSkill = {}
PoolSkill.BaseRating = 1200
PoolSkill.Spread = 400
PoolSkill.PlacementGames = 10
PoolSkill.PlacementStep = 48
PoolSkill.SettledStep = 24
PoolSkill.MinRating = 700
PoolSkill.MaxRating = 2200
PoolSkill.MinTarget = 0.4
PoolSkill.MaxTarget = 0.7
PoolSkill.NeutralTarget = 0.55
PoolSkill.LossStep = 0.05
PoolSkill.WinStep = 0.05
PoolSkill.StreakCap = 3
PoolSkill.PriorWins = 5
PoolSkill.PriorGames = 10

function PoolSkill.NewStats()
	return { Wins = 0, Losses = 0, Streak = 0, Rating = PoolSkill.BaseRating }
end

function PoolSkill.FromData(data)
	if typeof(data) == "table" then
		return {
			Wins = tonumber(data.wins) or 0,
			Losses = tonumber(data.losses) or 0,
			Streak = tonumber(data.streak) or 0,
			Rating = tonumber(data.rating) or PoolSkill.BaseRating
		}
	end

	return PoolSkill.NewStats()
end

function PoolSkill.Games(p)
	return p.Wins + p.Losses
end

function PoolSkill.WinRate(p)
	return (p.Wins + PoolSkill.PriorWins) / (PoolSkill.Games(p) + PoolSkill.PriorGames)
end

function PoolSkill.WinChance(p: number, p2: number)
	return 1 / (1 + 10 ^ ((p2 - p) / PoolSkill.Spread))
end

function PoolSkill.TargetWinChance(p)
	local v = math.clamp(p.Streak, -PoolSkill.StreakCap, PoolSkill.StreakCap)
	local neutralTarget = PoolSkill.NeutralTarget

	if v < 0 then
		neutralTarget += -v * PoolSkill.LossStep
	elseif v > 0 then
		neutralTarget -= v * PoolSkill.WinStep
	end

	return (math.clamp(neutralTarget, PoolSkill.MinTarget, PoolSkill.MaxTarget))
end

function PoolSkill.RatingForChance(p: number, value: number)
	local v = math.clamp(value, 0.01, 0.99)

	return p + PoolSkill.Spread * math.log10(1 / v - 1)
end

function PoolSkill.DesiredOpponentRating(p)
	return PoolSkill.RatingForChance(p.Rating, PoolSkill.TargetWinChance(p))
end

PoolSkill.FloorWinRate = 0.5

PoolSkill.FloorBoost = 0.25

function PoolSkill.SubstituteWinChance(p)
	local targetWinChance = PoolSkill.TargetWinChance(p)
	local winRate = PoolSkill.WinRate(p)

	if winRate < PoolSkill.FloorWinRate then
		targetWinChance += (PoolSkill.FloorWinRate - winRate) / PoolSkill.FloorWinRate * PoolSkill.FloorBoost
	end

	return (math.clamp(targetWinChance, PoolSkill.MinTarget, 0.9))
end

function PoolSkill.SubstituteOpponentRating(p)
	return PoolSkill.RatingForChance(p.Rating, PoolSkill.SubstituteWinChance(p))
end

function PoolSkill.Step(p)
	if PoolSkill.Games(p) < PoolSkill.PlacementGames then
		return PoolSkill.PlacementStep
	end

	return PoolSkill.SettledStep
end

function PoolSkill.Apply(data, p: number, flag: boolean)
	local winChance = PoolSkill.WinChance(data.Rating, p)

	local v = data.Rating + PoolSkill.Step(data) * ((flag and 1 or 0) - winChance)
	local streak

	if flag then
		streak = not (data.Streak > 0) and 1 or data.Streak + 1
	else
		streak = not (data.Streak < 0) and -1 or data.Streak - 1
	end

	return {
		Wins = data.Wins + (flag and 1 or 0),
		Losses = data.Losses + (flag and 0 or 1),
		Streak = streak,
		Rating = math.clamp(v, PoolSkill.MinRating, PoolSkill.MaxRating)
	}
end

function PoolSkill.ToData(data)
	return { wins = data.Wins, losses = data.Losses, streak = data.Streak, rating = data.Rating }
end

return PoolSkill