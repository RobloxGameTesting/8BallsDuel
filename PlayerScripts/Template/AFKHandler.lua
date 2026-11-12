local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

Players.LocalPlayer.Idled:Connect(function(p)
	RemoteSignals.FireServer(RemoteEnums.AFK, p)
end)