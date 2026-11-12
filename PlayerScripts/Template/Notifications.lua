local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
LocalPlayer:WaitForChild("PlayerGui")

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

local v = { "Notification" }

RemoteSignals.OnClientEvent("Notification", function(p, p2, ...)
	if not table.find(v, p) then
		return
	end

	Notifications.new(p2, ...)
end)