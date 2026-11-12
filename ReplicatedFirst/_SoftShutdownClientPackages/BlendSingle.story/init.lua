local function waitForValue(bounceTarget)
	local value = bounceTarget.Value

	if value then
		return value
	end

	return bounceTarget.Changed:Wait()
end

return require(waitForValue(script:WaitForChild("BounceTarget")))