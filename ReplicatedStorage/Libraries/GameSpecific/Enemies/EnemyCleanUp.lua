local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)

return {
	Init = function()
		print("Init the enemy clean up")
		local map = workspace.Regions:FindFirstChild("Map")

		assert(map, "Region not found in the workspace. Enemy clean up handler not running")

		Scheduler.BindHeartbeat(function()
			for _, v in Enemies._getEnemies(), nil, nil do
				local model = v.model
				local primaryPart = model and model.PrimaryPart

				if primaryPart then
					if not VectorHelper.IsPointInsidePart(primaryPart.Position, map) then
						Enemies.Destroy(v)
					end
				else
					Enemies.Destroy(v)
				end
			end
		end)
	end
}