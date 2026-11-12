local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("HttpService")

local isServer = RunService:IsServer()

return function(p)
	local userId = tostring(p.UserId)

	if isServer then
		if not (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data.gamepasses[script.Name] then
			return
		end
	else
		local _ = p == Players.LocalPlayer
	end
end