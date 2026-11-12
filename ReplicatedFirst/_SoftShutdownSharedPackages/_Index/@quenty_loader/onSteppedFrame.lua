local RunService = game:GetService("RunService")

return function(onStepped)
	assert(type(onStepped) == "function", "Bad func")

	return RunService.Stepped:Once(onStepped)
end