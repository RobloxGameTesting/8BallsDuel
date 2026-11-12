local current = {}
local ROBLOXHumanoidList = {
	GetCurrent = function(_)
		return current
	end
}
local function findHumanoids(humanoid, humanoids)
	if humanoid then
		if humanoid:IsA("Humanoid") then
			table.insert(humanoids, humanoid)
		end

		for _, child in pairs(humanoid:GetChildren()) do
			findHumanoids(child, humanoids)
		end
	end
end

local thread = coroutine.create(function()
	while true do
		current = {}
		findHumanoids(game.Workspace, current)
		wait(3)
	end
end)

coroutine.resume(thread)

return ROBLOXHumanoidList