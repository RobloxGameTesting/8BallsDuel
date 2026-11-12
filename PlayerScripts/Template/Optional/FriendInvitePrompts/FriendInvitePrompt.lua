game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Device)
require(ReplicatedStorage.Libraries.Modules.Menu)
require(ReplicatedStorage.Libraries.Classes.Notifications)
require(ReplicatedStorage.Types.NotificationTypes)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Constants.FriendConstants)
local FriendHelper = require(ReplicatedStorage.Libraries.Helpers.FriendHelper)
require(ReplicatedStorage.Types.DataTypes)

local userId = tostring(Players.LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local canSendInvite = FriendHelper.CanSendInvite(userId)
local data = v.Data

if canSendInvite then
	FriendHelper.GetOnlineFriends(userId)
else
	warn("Can't send invite")
end