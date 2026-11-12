local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Types.NotificationTypes)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolVip = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolVip)

local poolChallengeNotification = ReplicatedStorage.Assets.Notifications.PoolChallengeNotification
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local PoolChallengeNotification = {
	notification = poolChallengeNotification,
	canOverrideSelf = false,
	parent = "PoolChallengePrompts"
}

local function values(p) -- 3 equivalent calls inferred from this helper
	return p.values
end

function PoolChallengeNotification.new(notificationInstance)
	local values2 = values(notificationInstance) -- inferred equivalent call
	local clone = poolChallengeNotification:Clone()

	local v = {
		notificationLabel = clone,
		notificationInstance = notificationInstance,
		parent = values2.parent or PoolChallengeNotification.parent,
		maid = Maid.new(),
		resolved = false
	}

	clone.LayoutOrder = notificationInstance.layoutOrder
	clone.Parent = PlayerGui:FindFirstChild(v.parent, true)

	local entryFee = tonumber(values2.EntryFee) or 0
	local prize = tonumber(values2.Prize) or 0

	PoolVip.Apply(clone.PlayerName, tostring(values2.DisplayName), values2.Vip == true)
	clone.Message.Text = "challenged you to a game"

	local v2 = tostring(values2.VenueName)

	if PoolConstants.IsNineBallVenue(values2.VenueId) then
		v2 = "9 BALL  ·  " .. v2
	end

	if math.round(entryFee) > 0 then
		clone.Venue.Text = string.format(
			"%s  ·  %s to play  ·  %s to win",
			v2,
			PoolConstants.DescribeFee(entryFee),
			NumberHelper:Separate(prize)
		)
	elseif math.round(prize) > 0 then
		clone.Venue.Text = string.format("%s  ·  %s to win", v2, NumberHelper:Separate(prize))
	else
		clone.Venue.Text = string.format("%s  ·  Friendly match", v2)
	end

	clone.Avatar.Image = string.format(
		"rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150",
		tonumber(values2.FromUserId) or 0
	)

	return v
end

local function resolve(state, flag: boolean)
	if state.resolved then
		return
	end

	state.resolved = true

	local values2 = values(state.notificationInstance) -- inferred equivalent call
	local v = if flag then values2.accept else values2.decline

	if v then
		local success, result = pcall(v)

		if not success then
			warn("[PoolChallengeNotification] callback failed: " .. tostring(result))
		end
	end

	if state.maid.yield then
		state.maid.yield:Fire()
	end
end

function PoolChallengeNotification.Show(data)
	local notificationLabel = data.notificationLabel
	local values2 = values(data.notificationInstance) -- inferred equivalent call

	notificationLabel.Position = UDim2.fromScale(0, 1.6)
	TweenService:Create(notificationLabel, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, 0)
	}):Play()

	data.maid.yield = Instance.new("BindableEvent")

	data.maid:GiveTask(notificationLabel.Accept.Activated:Connect(function()
		resolve(data, true)
	end))

	data.maid:GiveTask(notificationLabel.Decline.Activated:Connect(function()
		resolve(data, false)
	end))

	local v = math.max(tonumber(values2.Seconds) or 20, 1)
	local v2 = os.clock() + v

	task.spawn(function()
		while not data.resolved do
			local v3 = v2 - os.clock()

			if v3 <= 0 then
				break
			end

			notificationLabel.Timer.Text = tostring((math.ceil(v3)))
			task.wait(0.2)
		end

		resolve(data, false)
	end)

	data.maid.yield.Event:Wait()
	data.maid.yield = nil
end

function PoolChallengeNotification.Hide(p)
	TweenService:Create(p.notificationLabel, TweenInfo.new(0.2), {
		Position = UDim2.fromScale(0, 1.6)
	}):Play()

	task.wait(0.2)
end

function PoolChallengeNotification:Destroy()
	self.maid:Destroy()
	self.notificationLabel:Destroy()
end

function PoolChallengeNotification.Cancel(p)
	resolve(p, false)
end

return PoolChallengeNotification