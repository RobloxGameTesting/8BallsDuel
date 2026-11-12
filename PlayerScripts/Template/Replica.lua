local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicaController = require(ReplicatedStorage.Libraries.Modules.Madwork.ReplicaController)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer

ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(p)
	if p.Tags.Player ~= LocalPlayer then
		local _ = p.Tags.Player.Name .. "'s"
	end

	local _data = p.Data
	local userId = tostring(p.Tags.Player.UserId)

	Profiles.SetClientPlayerData(userId, p)
end)

ReplicaController.ReplicaOfClassCreated("Game", function(p)
	Profiles.SetReplica("Game", p)
end)

ReplicaController.ReplicaOfClassCreated("Shop", function(p)
	Profiles.SetReplica("Shop", p)
end)

ReplicaController.ReplicaOfClassCreated("Leaderboard", function(p)
	Profiles.SetReplica("Leaderboard", p)
end)

ReplicaController.ReplicaOfClassCreated("AFK", function(p)
	Profiles.SetReplica("AFK", p)
end)

ReplicaController.ReplicaOfClassCreated("Reward", function(p)
	Profiles.SetReplica("Reward", p)
end)

ReplicaController.ReplicaOfClassCreated("Lobby", function(p)
	Profiles.SetReplica("Lobby", p)
end)

ReplicaController.RequestData()