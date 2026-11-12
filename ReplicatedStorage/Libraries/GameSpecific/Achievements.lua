game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.Profiles)
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Libraries.Helpers.TableHelper)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Types.Types)
local PlaceHelper = require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
require(ReplicatedStorage.Libraries.Helpers.StatsHelper)

RunService:IsServer()
local achievements = {
	Play = {
		title = "Thanks for playing!",
		description = function(_): string
			return "PLACE_HOLDER_DESCRIPTION"
		end,
		missionId = "Plays",
		order = -1,
		tiers = {
			{
				requirement = 1,
				rewards = {
					{ writeLib = "Currency1", value = 500 }
				}
			}
		},
		writeLib = "Plays"
	},
	Group = {
		title = "Join the group!",
		description = function(_): string
			return "Become a member of the GROUP_NAME group on Roblox"
		end,
		missionId = "JoinGroup",
		order = 0,
		tiers = {
			{
				requirement = 1,
				rewards = {
					{ writeLib = "Currency1", value = 500 }
				}
			}
		},
		writeLib = "Group"
	},
	Playtime = {
		title = "Play Time",
		description = function(p)
			if p >= 3600 then
				return `Play {PlaceHelper.GetName()} for {NumberHelper.FormatTimerHMS(p)} hours`
			end

			return `Play {PlaceHelper.GetName()} for {NumberHelper.FormatTimerMS(p)} minutes`
		end,
		missionId = "Playtime",
		order = 2,
		tiers = {
			{
				requirement = 60,
				rewards = {
					{ writeLib = "Currency1", value = 500 }
				}
			},
			{
				requirement = 900,
				rewards = {
					{ writeLib = "Currency1", value = 500 }
				}
			}
		},
		writeLib = "Playtime"
	},
	["Friend Plays"] = {
		title = "Friendly Competition",
		description = function(p)
			return `Play {PlaceHelper.GetName()} with {p} friends`
		end,
		missionId = "Friends",
		order = 3,
		tiers = {
			{
				requirement = 1,
				rewards = {
					{ writeLib = "Currency1", value = 500 }
				},
				badgeId = nil
			},
			{
				requirement = 3,
				rewards = {
					{ writeLib = "Currency1", value = 500 }
				},
				badgeId = nil
			}
		},
		writeLib = "FriendPlays"
	}
}

return {
	GetAchievements = function()
		return achievements
	end
}