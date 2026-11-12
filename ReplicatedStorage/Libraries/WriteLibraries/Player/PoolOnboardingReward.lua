return function(p, value)
	if typeof(value) ~= "string" or value == "" then
		return
	end

	if typeof(p.Data.poolOnboardingRewards) ~= "table" then
		p.Data.poolOnboardingRewards = {}
	end

	p.Data.poolOnboardingRewards[value] = true
end