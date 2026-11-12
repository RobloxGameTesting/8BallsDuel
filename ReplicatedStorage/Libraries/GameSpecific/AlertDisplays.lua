local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local SharedConstants = require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local PoolSkins = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolSkins)

local function waitForPath(value: string)
	local child = PlayerGui

	for childName in value:gmatch("[^%.]+") do
		child = child:WaitForChild(childName)
	end

	return child
end

local AlertDisplays = {
	{
		enabled = function(): number
			local lastReward = data.dailyReward.lastReward

			if os.time() - lastReward < SharedConstants.DAILY_TIME then
				return 0
			end

			return 1
		end,
		writeLibs = { "DailyClaim" },
		display = "#",
		alerts = function()
			local child = PlayerGui

			local v = { nil }

			for childName in ("MainUI.LeftPanel1.DailyReward.Content.Notification"):gmatch("[^%.]+") do
				child = child:WaitForChild(childName)
			end

			v[1] = child
			return v
		end
	},
	{
		enabled = function()
			return PoolSkins.CountAllUnseen(data)
		end,
		writeLibs = { "Inventory", "PoolSeenItems" },
		display = "!",
		alerts = function()
			local child = PlayerGui

			local v = { nil }

			for childName in ("PoolMenuUI.HomeMenu.PlayRow.InventoryCard.Notification"):gmatch("[^%.]+") do
				child = child:WaitForChild(childName)
			end

			v[1] = child
			return v
		end
	}
}

local writeLibs = {
	"EventProgress",
	"EventClaims",
	"EventQuestClaim",
	"IncrementMission",
	"EventMissions",
	"EventWeeklyMissions",
	"Purchases",
	"EventLadderScale"
}

local function seasonSignals()
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)

	return { Events.Ended, Events.Changed }
end

local function seasonCounts()
	local Events = require(ReplicatedStorage.Libraries.Modules.Events)
	local success, claimableRewardCount = pcall(Events.GetClaimableRewardCount, Events, LocalPlayer)
	local success2, claimableQuests = pcall(Events.GetClaimableQuests, Events, LocalPlayer)

	local v = (not success or typeof(claimableRewardCount) ~= "number") and 0 or claimableRewardCount

	if success2 and typeof(claimableQuests) == "table" then
		return v, #claimableQuests
	end

	return v, 0
end

table.insert(AlertDisplays, {
	enabled = function()
		local v, v2 = seasonCounts()

		return v + v2
	end,
	writeLibs = writeLibs,
	signals = seasonSignals,
	display = "!",
	alerts = function()
		local child = PlayerGui

		local v = { nil }

		for childName in ("PoolMenuUI.HomeMenu.PlayRow.SeasonCard.Notification"):gmatch("[^%.]+") do
			child = child:WaitForChild(childName)
		end

		v[1] = child
		return v
	end
})

table.insert(AlertDisplays, {
	enabled = function()
		return (seasonCounts())
	end,
	writeLibs = writeLibs,
	signals = seasonSignals,
	display = "!",
	alerts = function()
		local child = PlayerGui

		local v = { nil }

		for childName in ("PoolMenuUI.EventsMenu.Background.Header.Categories.Rewards.Notification"):gmatch("[^%.]+") do
			child = child:WaitForChild(childName)
		end

		v[1] = child
		return v
	end
})

table.insert(AlertDisplays, {
	enabled = function()
		local _, v = seasonCounts()

		return v
	end,
	writeLibs = writeLibs,
	signals = seasonSignals,
	display = "!",
	alerts = function()
		local child = PlayerGui

		local v = { nil }

		for childName in ("PoolMenuUI.EventsMenu.Background.Header.Categories.Quests.Notification"):gmatch("[^%.]+") do
			child = child:WaitForChild(childName)
		end

		v[1] = child
		return v
	end
})

table.insert(AlertDisplays, {
	enabled = function()
		local _, v = seasonCounts()

		return v
	end,
	writeLibs = writeLibs,
	signals = seasonSignals,
	display = "!",
	alerts = function()
		local child = PlayerGui

		local v = { nil }

		for childName in ("PoolGameUI.Hud.QuestsButton.Notification"):gmatch("[^%.]+") do
			child = child:WaitForChild(childName)
		end

		v[1] = child
		return v
	end
})

for _, category in PoolSkins.Categories do
	local id = category.Id

	table.insert(AlertDisplays, {
		enabled = function()
			return PoolSkins.CountUnseen(data, id)
		end,
		writeLibs = { "Inventory", "PoolSeenItems" },
		display = "!",
		alerts = function()
			local child = PlayerGui

			local v = { nil }

			for childName in ("PoolMenuUI.InventoryMenu.Tabs." .. id .. ".Notification"):gmatch("[^%.]+") do
				child = child:WaitForChild(childName)
			end

			v[1] = child
			return v
		end
	})
end

return AlertDisplays