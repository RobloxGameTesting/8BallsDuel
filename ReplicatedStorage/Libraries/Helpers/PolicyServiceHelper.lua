local PolicyService = game:GetService("PolicyService")

return {
	Get = function(_, p)
		assert(p, "plr argument is nil. Player object expected")
		local result

		repeat
			local success
			success, result = pcall(function()
				return PolicyService:GetPolicyInfoForPlayerAsync(p)
			end)

			task.wait()
		until success

		return result
	end
}