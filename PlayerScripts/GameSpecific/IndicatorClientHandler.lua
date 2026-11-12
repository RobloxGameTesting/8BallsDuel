local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Indicator = require(ReplicatedStorage.Libraries.Modules.Indicator)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

RemoteSignals.OnClientEvent(RemoteEnums.Indicator, function(p, p2)
	local v = {
		risePixels = 60,
		randomJitterPixels = 5,
		travelDirection = Vector2.new((math.random() * 2 - 1) * 0.6, -1),
		size = Vector2.new(240, 60),
		finalSize = Vector2.new(240, 60)
	}

	local color = Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
	Indicator.new(p, 1, color, p2, v)
end)