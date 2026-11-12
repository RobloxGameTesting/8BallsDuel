local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local PoolCarousel = {}

local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function widthOf(data) -- 1 equivalent call inferred from this helper
	return data.Config.CardWidth or 0.42
end

local function stepOf(p) -- 2 equivalent calls inferred from this helper
	return p.Config.CardStep or 0.46
end

local function applyLayout(data, p: number, flag: boolean?)
	if data.Config.Virtual then
		return
	end

	local v = math.round(p)
	local v2 = widthOf(data) -- inferred equivalent call
	local cardHeight = data.Config.CardHeight or 0.62
	local shrink = data.Config.Shrink or 0.14
	local shrinkY = data.Config.ShrinkY or shrink
	local v3 = stepOf(data) -- inferred equivalent call
	local zIndex = data.Track.ZIndex

	for k, instance in data.Cards do
		local v4 = k - p
		local v5 = math.clamp(1 - math.abs(v4), 0, 1)
		local v6 = 1 - shrink + shrink * v5
		local v7 = 1 - shrinkY + shrinkY * v5

		instance.AnchorPoint = Vector2.new(0.5, 0.5)
		instance.ZIndex = zIndex + (k == v and 3 or 1)

		local v8 = {
			Position = UDim2.fromScale(v4 * v3 + 0.5, 0.5),
			Size = UDim2.fromScale(v2 * v6, cardHeight * v7)
		}

		if flag then
			instance.Position = v8.Position
			instance.Size = v8.Size
		else
			TweenService:Create(instance, tweenInfo, v8):Play()
		end
	end
end

local function pixelsToCards(p, p2: number) -- 1 equivalent call inferred from this helper
	local x = p.Track.AbsoluteSize.X

	if x <= 0 then
		return 0
	end

	return p2 / (x * stepOf(p)) -- inferred equivalent call
end

function PoolCarousel.GetKey(p)
	return p.Keys[p.Index]
end

function PoolCarousel.IsTapSuppressed(p)
	return p.SuppressTap
end

function PoolCarousel:SetIndex(p: number, flag: boolean?)
	local count = #self.Cards

	if count == 0 then
		self.Index = 1
		self.Focus = 1
	else
		local focus = math.clamp(math.round(p), 1, count)
		local v = focus ~= self.Index

		self.Index = focus
		self.Focus = focus

		applyLayout(self, focus, flag)

		if v then
			self.ChangedBindable:Fire(focus, self.Keys[focus])
		end
	end
end

function PoolCarousel.FocusKey(p, p2: string?, flag: boolean?): boolean
	if not p2 then
		return false
	end

	for k, key in p.Keys do
		if key == p2 then
			PoolCarousel.SetIndex(p, k, flag)

			return true
		end
	end

	return false
end

function PoolCarousel:SetCards(cards, keys)
	local key = PoolCarousel.GetKey(self)

	self.Drag = nil
	self.Cards = cards
	self.Keys = keys

	for _, card in cards do
		if self.Bound[card] then
			continue
		end

		self.Bound[card] = true

		self.Maid:GiveTask(card.InputBegan:Connect(function(input)
			PoolCarousel.BeginDrag(self, input)
		end))
	end

	if not PoolCarousel.FocusKey(self, key, true) then
		PoolCarousel.SetIndex(self, math.min(self.Index, (math.max(#cards, 1))), true)
	end
end

function PoolCarousel:BeginDrag(input)
	if
		self.Config.Gestures == false
		or (not self.Track.Visible or self.Drag)
		or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	self.Drag = { Input = input, StartX = input.Position.X, StartFocus = self.Focus, Furthest = 0 }
end

function PoolCarousel.new(track, options)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")

	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)

	local v = {
		Track = track,
		Cards = {},
		Keys = {},
		Index = 1,
		Focus = 1,
		Drag = nil,
		SuppressTap = false,
		Config = options or {},
		Changed = bindableEvent.Event,
		Accepted = bindableEvent2.Event,
		ChangedBindable = bindableEvent,
		AcceptedBindable = bindableEvent2,
		Maid = maid,
		Bound = {}
	}

	local function awake()
		local instance = track

		while instance do
			if instance:IsA("GuiObject") and not instance.Visible then
				return false
			end

			if instance:IsA("LayerCollector") then
				return instance.Enabled and instance:IsDescendantOf(game)
			end

			instance = instance.Parent
		end

		return false
	end

	local function finishDrag()
		local drag = v.Drag

		if not drag then
			return
		end

		v.Drag = nil

		local v2 = v.Focus - drag.StartFocus
		local v3 = math.round(v.Focus)

		if v3 == drag.StartFocus and math.abs(v2) >= 0.2 then
			v3 = drag.StartFocus + (v2 > 0 and 1 or -1)
		end

		PoolCarousel.SetIndex(v, v3)

		task.defer(function()
			v.SuppressTap = false
		end)
	end

	maid:GiveTask(track.InputBegan:Connect(function(input)
		PoolCarousel.BeginDrag(v, input)
	end))

	local function isDragMovement(drag, input): boolean -- 1 equivalent call inferred from this helper
		if drag.Input.UserInputType == Enum.UserInputType.Touch then
			return input == drag.Input
		end

		return input.UserInputType == Enum.UserInputType.MouseMovement
	end

	local function isDragRelease(drag, input): boolean -- 1 equivalent call inferred from this helper
		if drag.Input.UserInputType == Enum.UserInputType.Touch then
			return input == drag.Input
		end

		return input.UserInputType == Enum.UserInputType.MouseButton1
	end

	maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
		local drag = v.Drag

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if awake() and not drag and v.Config.Gestures ~= false then
				PoolCarousel.SetIndex(v, v.Index - math.sign(input.Position.Z))
			end
		elseif drag and isDragMovement(drag, input) then -- inferred equivalent call
			local v2 = input.Position.X - drag.StartX
			drag.Furthest = math.max(drag.Furthest, (math.abs(v2)))

			if drag.Furthest > 12 then
				v.SuppressTap = true
			end

			local v3 = drag.StartFocus - pixelsToCards(v, v2) -- inferred equivalent call

			v.Focus = math.clamp(v3, 1, (math.max(#v.Cards, 1)))

			applyLayout(v, v.Focus, true)
		end
	end))

	maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		local drag = v.Drag

		if drag and isDragRelease(drag, input) then -- inferred equivalent call
			finishDrag()
		end
	end))

	maid:GiveTask(UserInputService.WindowFocusReleased:Connect(finishDrag))

	local v2 = 0

	local function step(x: number) -- 3 equivalent calls inferred from this helper
		local now = os.clock()

		if now - v2 < 0.26 then
			return
		end

		v2 = now

		PoolCarousel.SetIndex(v, v.Index + x)
	end

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not awake() or gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.DPadLeft or input.KeyCode == Enum.KeyCode.Left then
			step(-1) -- inferred equivalent call
		elseif input.KeyCode == Enum.KeyCode.DPadRight or input.KeyCode == Enum.KeyCode.Right then
			step(1) -- inferred equivalent call
		elseif input.KeyCode == Enum.KeyCode.ButtonA then
			local card = v.Cards[v.Index]

			if card and card.Active then
				bindableEvent2:Fire(v.Index, v.Keys[v.Index])
			end
		end
	end))

	maid:GiveTask(UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if not awake() or gameProcessed or input.KeyCode ~= Enum.KeyCode.Thumbstick1 then
			return
		end

		if math.abs(input.Position.X) < 0.6 then
			v2 = 0

			return
		end

		step(math.sign(input.Position.X)) -- inferred equivalent call
	end))

	return v
end

function PoolCarousel.Step(p, p2: number)
	PoolCarousel.SetIndex(p, p.Index + p2)
end

function PoolCarousel.Relayout(p)
	applyLayout(p, p.Focus, true)
end

function PoolCarousel:Destroy()
	self.Maid:DoCleaning()
	self.Cards = {}
	self.Keys = {}
	self.Bound = {}
end

return PoolCarousel