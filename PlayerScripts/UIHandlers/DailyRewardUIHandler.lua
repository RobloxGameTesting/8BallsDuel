local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local Inventories = require(ReplicatedStorage.Libraries.Classes.Inventories)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
game:GetService("RunService")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
require(ReplicatedStorage.Libraries.Modules.Menu)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
local SharedConstants = require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Types.DataTypes)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RemoteSignals = require(ReplicatedStorage2.Libraries.Modules.RemoteSignals)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local Assets = ReplicatedStorage.Assets
local content = PlayerGui:WaitForChild("DailyRewardUI").Content
local consecutive = content.Consecutive
local list = content.List
Maid.new()
local v2 = Maid.new()
local clone = Assets.UI.Battlepass.Checkmark:Clone()

UserInterfaceHelper:FitScrollingFrame(list, "Y", UDim2.new(0, 0, 0, 5))

local v3 = {}
local clone2 = Assets.UI.Daily.ClaimLabel:Clone()
local v4 = nil

local function loadAndUpdateConsecutiveRewards()
	local streakClaims = data.dailyReward.streakClaims
	local streak = data.dailyReward.streak
	local v5 = math.clamp(streakClaims, 1, 1e999)

	local v6 = streak == 0 and "255, 255, 255" or "255, 0, 0"
	consecutive.Header.Streak.Text = `<font color="rgb({v6})"> {streak}</font> DAY STREAK`

	if not v4 or v4 ~= v5 then
		v4 = v5

		for i = 0, 2 do
			local v7 = v5 + i
			local DAILY_REWARDS_CONSECUTIVE_CALCULATOR = SharedConstants.DAILY_REWARDS_CONSECUTIVE_CALCULATOR(v7)

			if DAILY_REWARDS_CONSECUTIVE_CALCULATOR then
				local child = consecutive:FindFirstChild(i + 1 .. "Reward")
				local rewards = child.Rewards
				child.Header.Text = v7 * SharedConstants.DAILY_CONSECUTIVE_INCREMENT .. " DAY STREAK"
				local v8 = {}

				for k, v9 in DAILY_REWARDS_CONSECUTIVE_CALCULATOR do
					if typeof(v9) == "number" then
						continue
					end

					local v10 = Inventories.fromList({ Key = v9 }, rewards, "misc", "v2")

					local getSlots = Inventories.GetSlots(v10)
					getSlots.Key.LayoutOrder = k

					v8[k] = v10
				end

				v2[i] = function()
					for _, v9 in v8 do
						Inventories.Destroy(v9)
					end
				end
			else
				v2[i] = nil
			end
		end
	end

	for i = 0, 2 do
		local v7 = v5 + i

		if not SharedConstants.DAILY_REWARDS_CONSECUTIVE_CALCULATOR(v7) then
			continue
		end

		local child = consecutive:FindFirstChild(i + 1 .. "Reward")

		if v7 <= streakClaims then
			child.BackgroundColor3 = Color3.fromRGB(111, 255, 0)
			clone.Parent = child
		else
			child.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		end
	end
end

function update()
	local claims = data.dailyReward.claims

	for i = math.clamp(claims - 28, 1, 1e999), claims + 28 do
		local name = i % 7 == 0 and "Row" .. i / 7 * 2 or "Row" .. math.ceil(i / 7) * 2 - 1

		if list:FindFirstChild(name) then
			continue
		end

		local clone3 = Assets.UI.Daily.Row:Clone()
		clone3.Name = name
		clone3.LayoutOrder = tonumber(string.match(name, "%d+"))
		clone3.Parent = list
	end

	math.clamp(claims % 7 == 0 and claims / 7 * 2 or math.ceil(claims / 7) * 2 - 1, 1, 1e999)
	local v5 = {}

	for i = 0, 4 do
		table.insert(v5, `Row{claims + i}`)
		table.insert(v5, `Row{claims - i}`)
	end

	for _, frame in list:GetChildren(), nil, nil do
		if not (frame:IsA("Frame") and table.find(v5, frame.Name)) then
			continue
		end

		local uiAspectRatioConstraint = frame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
		local v6 = {}

		if frame.Visible then
			continue
		end

		frame.Visible = true

		local v7 = tonumber(string.match(frame.Name, "%d+"))
		local v8, v9

		if v7 % 2 == 0 then
			v8 = v7 * 7 / 2
			v9 = v7 * 7 / 2
			uiAspectRatioConstraint.AspectRatio = 4
		else
			v8 = (v7 - 1) / 2 * 7 + 1
			v9 = v8 + 5
			uiAspectRatioConstraint.AspectRatio = 6
		end

		for i = v8, v9 do
			local DAILY_REWARD_CALCULATOR = SharedConstants.DAILY_REWARD_CALCULATOR(i)

			local v10 = Inventories.fromList({ Key = DAILY_REWARD_CALCULATOR }, frame, "misc", "v2")

			table.insert(v6, v10)

			local key = Inventories.GetSlots(v10).Key

			local clone3 = key.Content.LabelTop:Clone()
			clone3.Visible = true
			clone3.Text = "Day " .. tostring(i)
			clone3.Size = UDim2.new(1, 0, 0.2, 0)
			clone3.Position = UDim2.new(0.5, 0, 0.35, 0)
			clone3.Parent = key.Content

			if i % 7 == 0 then
				key.UIAspectRatioConstraint.AspectRatio = 4
			end

			key.Content.Size = UDim2.fromScale(0.9, 0.9)

			key.LayoutOrder = i

			v3[i] = key
		end
	end

	local lastReward = data.dailyReward.lastReward

	if os.time() - lastReward >= SharedConstants.DAILY_TIME then
		local parent = v3[claims + 1]

		if parent then
			parent.Content.LabelTop.Visible = false
			parent.Content.LabelBottom.Visible = false
			clone2.Parent = parent
		else
			clone2.Parent = ReplicatedStorage
		end

		content.Timer.Text = "READY"
	else
		clone2.Parent = ReplicatedStorage

		task.spawn(function()
			while true do
				local v6 = os.time() - lastReward

				if SharedConstants.DAILY_TIME <= v6 then
					break
				end

				local v7 = SharedConstants.DAILY_TIME - v6
				content.Timer.Text = NumberHelper.FormatTimerHMS(v7)

				task.wait(1)
			end

			if not v3[data.dailyReward.claims + 1] then
				return
			end

			update()
		end)
	end

	for i = 1, claims do
		local parent = v3[i]

		if not parent or parent:FindFirstChild("Checkmark") then
			continue
		end

		local clone = Assets.UI.Battlepass.Checkmark:Clone()
		clone.Parent = parent
	end
end

update()
loadAndUpdateConsecutiveRewards()
v:ListenToWrite("DailyClaim", function()
	update()
	loadAndUpdateConsecutiveRewards()
end)
v:ListenToWrite("DailyStreakClaim", function()
	update()
	loadAndUpdateConsecutiveRewards()
end)

Button.Create(content, function()
	local lastReward = data.dailyReward.lastReward
	local v5 = os.time() - lastReward
	local v6 = v3[data.dailyReward.claims + 1]

	if v5 < SharedConstants.DAILY_TIME then
		warn("Time hasn't elapsed")
	elseif v6 then
		RemoteSignals.FireServer("DailyReward", "DailyClaim")
	else
		warn("No label found, all dailys are collected")
	end
end)