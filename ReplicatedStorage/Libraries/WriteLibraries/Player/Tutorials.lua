game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

RunService:IsServer()

return function(p, value)
	if typeof(value) ~= "string" then
		return
	end

	p.Data.tutorials[value] = true
end