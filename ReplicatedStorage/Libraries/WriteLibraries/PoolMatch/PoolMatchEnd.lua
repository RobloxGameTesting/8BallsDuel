local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolMatchTypes = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolMatchTypes)

return function(p, winner: number, lossReason: string, rewards)
	local poolMatch = p.Data.poolMatch

	if not poolMatch then
		return
	end

	poolMatch.Phase = "Finished"
	poolMatch.Winner = winner
	poolMatch.LossReason = lossReason
	poolMatch.Rewards = rewards
	poolMatch.BallInHand = false
	poolMatch.TurnEndsAt = 0
	poolMatch.Aim = PoolMatchTypes.EmptyAim()
end