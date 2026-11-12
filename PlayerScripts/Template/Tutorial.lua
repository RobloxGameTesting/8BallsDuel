local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Tutorial = require(ReplicatedStorage.Libraries.GameSpecific.Tutorial)
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Libraries.Classes.Maid)
local Players = game:GetService("Players")
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local userId = tostring(Players.LocalPlayer.UserId)

RemoteSignals.OnClientEvent(RemoteEnums.TutorialStart, function(...)
	local v = ({ ... })[1]

	task.spawn(function()
		if not Profiles.GetPlayerReplica(userId) then
			Profiles.WaitForPlayerReplica(userId)
		end

		Tutorial.Play(v)
	end)
end)

script:SetAttribute("Loaded", true)