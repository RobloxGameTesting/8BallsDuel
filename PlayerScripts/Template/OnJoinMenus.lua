local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local Players = game:GetService("Players")
local v = require(ReplicatedStorage.Libraries.Modules.Profiles)
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Libraries.Modules.Events)
game:GetService("ExperienceNotificationService")
game:GetService("AvatarEditorService")
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
require(ReplicatedStorage.Types.DataTypes)
require(ReplicatedStorage.Libraries.Helpers.TableHelper)

local LocalPlayer = Players.LocalPlayer
LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)
v = (v.GetPlayerReplica(userId) or v.WaitForPlayerReplica(userId)).Data

task.wait(1)

Menu.PromptSequence({})