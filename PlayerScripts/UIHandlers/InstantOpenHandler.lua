local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
local Players = game:GetService("Players")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local ConfigChecker = require(ReplicatedStorage.Libraries.Modules.ConfigChecker)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local instant = PlayerGui:WaitForChild("PackOpenUI").Instant

local function update()
	if data.configuration.misc.instaOpen == "On" then
		instant.Content.Label.Text = "ENABLED"
		Button.SetColours({ Instant = instant }, "Instant", "green", "white")
	else
		instant.Content.Label.Text = "DISABLED"
		Button.SetColours({ Instant = instant }, "Instant", "red", "white")
	end
end

Button.Create(instant, function()
	local v2 = {
		configurationType = "misc",
		configuration = "instaOpen",
		val = data.configuration.misc.instaOpen == "On" and "Off" or "On"
	}

	if ConfigChecker.Verify(LocalPlayer, v2) then
		RemoteSignals.FireServer("Packs", "UpdateConfiguration", v2)
	end
end)

update()
v:ListenToWrite("SetConfig", update)