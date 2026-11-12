return function(p, value: number, value2: number)
	if typeof(value) ~= "number" or typeof(value2) ~= "number" then
		return
	end

	p.Data.poolDailyRewards = {
		LastDay = math.floor(value),
		Step = math.clamp(math.floor(value2), 1, 7)
	}
end