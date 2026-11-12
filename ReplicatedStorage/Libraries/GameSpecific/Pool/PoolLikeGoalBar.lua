local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolLikeGoals = require(Pool.PoolLikeGoals)
local PoolButtonSkin = require(script.Parent.PoolButtonSkin)

local PoolLikeGoalBar = {}

local color = Color3.fromRGB(255, 213, 79)
local color2 = Color3.fromRGB(120, 126, 136)
Color3.fromRGB(52, 56, 62)

local colorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(185, 185, 185))

local function bind(instance, value: string)
	local child = instance

	for childName in value:gmatch("[^%.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"PoolLikeGoalBar: %s.%s is missing (looking for %q)",
					instance:GetFullName(),
					value,
					childName
				),
				2
			)
		end
	end

	return child
end

local function setClaim(data, text: string, autoButtonColor: boolean) -- 1 equivalent call inferred from this helper
	data.ClaimLabel.Text = text
	local setColour = PoolButtonSkin.SetColour
	local claim = data.Claim
	local v = if autoButtonColor then data.EnabledColour else color2
	setColour(claim, v)

	data.Claim.AutoButtonColor = autoButtonColor

	if data.Gradient and data.EnabledGradient then
		local gradient = data.Gradient
		local color3

		if autoButtonColor then
			color3 = data.EnabledGradient
		else
			color3 = colorSequence
		end

		gradient.Color = color3
	end
end

local function refresh(state, flag: boolean)
	local likes = PoolLikeGoals.GetLikes()

	if not likes then
		state.Root.Visible = false

		return
	end

	warn("Set to false. Enable the like rewards in Update 6")
	state.Root.Visible = true

	local data = state.Replica and state.Replica.Data
	local progress = PoolLikeGoals.GetProgress(likes)
	local v = PoolLikeGoals.GetClaimable(data, likes)
	local milestones = PoolLikeGoals.Milestones

	local v2 = progress.Fraction

	if v then
		v2 = 1
		state.Title.Text = string.format("%s LIKES REACHED!", NumberHelper:Separate(v))
		setClaim(state, state.Pending and "CLAIMING..." or "CLAIM", not state.Pending) -- inferred equivalent call
	else
		if progress.Next then
			v = progress.Next
			state.Title.Text = string.format(
				"FREE CUE AT %s / %s LIKES",
				NumberHelper:Separate(likes),
				NumberHelper:Separate(progress.Next)
			)
			state.ClaimLabel.Text = "LOCKED"
		else
			v = milestones[#milestones]
			state.Title.Text = "EVERY LIKE REWARD CLAIMED!"
			state.ClaimLabel.Text = data and "CLAIMED" or "LOADING..."
		end

		PoolButtonSkin.SetColour(state.Claim, color2)

		state.Claim.AutoButtonColor = false

		if state.Gradient and state.EnabledGradient then
			state.Gradient.Color = colorSequence
		end
	end

	TweenService:Create(state.Fill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(v2, 1)
	}):Play()

	state.ShownItem = PoolLikeGoals.GetRewardItem(v)

	if flag and state.ShownReached ~= nil and progress.Reached > state.ShownReached then
		Notifications.new("TextNotification", {
			message = string.format(
				"%s likes reached! Claim your free cue stick!",
				NumberHelper:Separate(progress.Previous)
			),
			colour = color,
			length = 8
		})
	end

	state.ShownReached = progress.Reached
end

function PoolLikeGoalBar.new(p)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent)

	local bindableEvent2 = Instance.new("BindableEvent")
	maid:GiveTask(bindableEvent2)

	local root = bind(p, "LikeGoal")
	local folder = bind(root, "Claim")
	local inspect = bind(root, "Inspect")
	local uiGradient = folder:FindFirstChildOfClass("UIGradient")
	local colorsByUiStroke = {}

	for _, uiStroke in folder:GetDescendants() do
		if uiStroke:IsA("UIStroke") then
			colorsByUiStroke[uiStroke] = uiStroke.Color
		end
	end

	local v = {
		Root = root,
		Title = bind(root, "Title"),
		Fill = bind(root, "Track.Fill"),
		Claim = folder,
		ClaimLabel = bind(folder, "Top"),
		Inspect = inspect,
		InspectPressed = bindableEvent2.Event,
		EnabledColour = PoolButtonSkin.GetColour(folder),
		Gradient = uiGradient,
		EnabledGradient = 0,
		Outlines = 0,
		Replica = nil,
		ShownItem = nil,
		ShownReached = nil,
		Pending = false,
		PendingToken = 0,
		ClaimPressed = 0,
		Maid = 0
	}
	local enabledGradient

	if uiGradient then
		enabledGradient = uiGradient.Color
	end

	v.EnabledGradient = enabledGradient
	v.Outlines = colorsByUiStroke

	v.ClaimPressed = bindableEvent.Event
	v.Maid = maid

	root.Selectable = false
	root.AutoButtonColor = false

	maid:GiveTask(folder.Activated:Connect(function()
		local data = v.Replica and v.Replica.Data

		if v.Pending or not PoolLikeGoals.GetClaimable(data, PoolLikeGoals.GetLikes()) then
			return
		end

		v.Pending = true
		v.PendingToken += 1

		local pendingToken = v.PendingToken

		refresh(v, false)
		bindableEvent:Fire()

		task.delay(4, function()
			if v.Pending and v.PendingToken == pendingToken then
				v.Pending = false
				refresh(v, false)
			end
		end)
	end))

	maid:GiveTask(inspect.Activated:Connect(function()
		if v.ShownItem then
			bindableEvent2:Fire(PoolLikeGoals.Category, v.ShownItem)
		end
	end))

	v.Fill.Size = UDim2.fromScale(0, 1)
	root.Visible = false

	maid:GiveTask(ReplicatedStorage:GetAttributeChangedSignal(PoolLikeGoals.LikesAttribute):Connect(function()
		refresh(v, true)
	end))

	refresh(v, false)

	return v
end

function PoolLikeGoalBar:SetReplica(replica)
	self.Replica = replica

	if replica then
		local success, result = pcall(function()
			return replica:ListenToWrite("PoolOnboardingReward", function()
				self.Pending = false
				refresh(self, false)
			end)
		end)

		if success and result then
			self.Maid:GiveTask(function()
				result:Disconnect()
			end)
		end
	end

	refresh(self, false)
end

function PoolLikeGoalBar.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolLikeGoalBar