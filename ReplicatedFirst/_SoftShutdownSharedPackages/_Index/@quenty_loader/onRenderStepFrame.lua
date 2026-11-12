local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

return function(value: number, callback)
	assert(type(value) == "number", "Bad priority")
	assert(type(callback) == "function", "Bad callback")

	local v = HttpService:GenerateGUID(false) .. "_onRenderStepFrame"
	local v2 = false

	RunService:BindToRenderStep(v, value, function()
		if not v2 then
			RunService:UnbindFromRenderStep(v)
			callback()
		end
	end)

	return function()
		if not v2 then
			RunService:UnbindFromRenderStep(v)
			v2 = true
		end
	end
end