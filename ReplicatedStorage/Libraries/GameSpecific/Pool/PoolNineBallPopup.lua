local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolConstants = require(Pool.PoolConstants)
local PoolTableRenderer3D = require(Pool.PoolTableRenderer3D)

local PoolNineBallPopup = {}

local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local cframe = CFrame.Angles(0, 3.141592653589793, 0)

local function expect(instance, childName: string) -- 6 equivalent calls inferred from this helper
	local child = instance:FindFirstChild(childName)

	if not child then
		error(
			string.format(
				"[PoolNineBallPopup] %s has no child named %q -- check ReplicatedStorage.UI.PoolMenuUI.NineBallPopup",
				instance:GetFullName(),
				childName
			),
			0
		)
	end

	return child
end

local function createChip(parent, layoutOrder: number, zIndex: number)
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "Ball" .. layoutOrder
	viewportFrame.LayoutOrder = layoutOrder
	viewportFrame.Size = UDim2.fromScale(0.1, 1)
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.BorderSizePixel = 0
	viewportFrame.ZIndex = zIndex
	viewportFrame.Ambient = Color3.fromRGB(220, 220, 220)
	viewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
	viewportFrame.LightDirection = Vector3.new(-0.3, -1, -0.6)

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.Parent = viewportFrame

	local pulse = Instance.new("UIScale")
	pulse.Name = "Pulse"
	pulse.Parent = viewportFrame

	viewportFrame.Parent = parent

	local createLooseBall = PoolTableRenderer3D.CreateLooseBall(viewportFrame, layoutOrder, "Ball")
	createLooseBall.CFrame = cframe

	local camera = Instance.new("Camera")
	camera.FieldOfView = 30

	local v = PoolConstants.BallDiameter / 2 * 1.12 / 0.2679491924311227

	camera.CFrame = CFrame.new(Vector3.new(0, 0, v), Vector3.new(0, 0, 0))
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	return viewportFrame
end

function PoolNineBallPopup.new(instance)
	local maid = Maid.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")

	maid:GiveTask(bindableEvent)
	maid:GiveTask(bindableEvent2)
	local root = expect(instance, "NineBallPopup") -- inferred equivalent call
	local card = expect(root, "Card") -- inferred equivalent call
	local row = expect(card, "BallRow") -- inferred equivalent call
	local arrow = expect(card, "Arrow") -- inferred equivalent call
	local play = expect(card, "Confirm") -- inferred equivalent call
	local close = expect(card, "Close") -- inferred equivalent call
	root.Visible = false

	pcall(PoolButtonSkin.ApplyExit, close)

	local chipTemplate = row:FindFirstChild("ChipTemplate")

	if chipTemplate and chipTemplate:IsA("GuiObject") then
		chipTemplate.Visible = false
	end

	local zIndex = row.ZIndex + 10
	local chips = {}

	for _, ball in PoolConstants.NineBall.Balls do
		chips[ball] = createChip(row, ball, zIndex)
	end

	local v = {
		Root = root,
		Card = card,
		Row = row,
		Arrow = arrow,
		Play = play,
		Close = close,
		Chips = chips,
		RestSize = card.Size,
		PlayRequested = bindableEvent.Event,
		Closed = bindableEvent2.Event,
		Maid = maid,
		ShowMaid = Maid.new()
	}

	maid:GiveTask(play.Activated:Connect(function()
		bindableEvent:Fire()
	end))

	maid:GiveTask(close.Activated:Connect(function()
		bindableEvent2:Fire()
	end))

	return v
end

local function walkOrder(data)
	local clone = table.clone(PoolConstants.NineBall.Balls)
	table.sort(clone)

	local chips = {}

	for _, v in clone do
		local chip = data.Chips[v]

		if chip then
			table.insert(chips, chip)
		end
	end

	return chips
end

local function pulseOf(instance) -- 2 equivalent calls inferred from this helper
	if instance then
		return (instance:FindFirstChild("Pulse"))
	end

	return nil
end

local function easeInOut(p: number)
	return TweenService:GetValue(p, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
end

function PoolNineBallPopup.Show(data)
	PoolNineBallPopup.Hide(data)

	local restSize = data.RestSize

	data.Root.Visible = true
	data.Root.BackgroundTransparency = 1
	data.Card.Size = UDim2.new(
		restSize.X.Scale * 0.88,
		math.round(restSize.X.Offset * 0.88),
		restSize.Y.Scale * 0.88,
		(math.round(restSize.Y.Offset * 0.88))
	)

	TweenService:Create(data.Root, tweenInfo, { BackgroundTransparency = 0.45 }):Play()
	TweenService:Create(data.Card, tweenInfo, { Size = restSize }):Play()

	local v = walkOrder(data)
	local count = #v
	local v2 = count * 0.8 + math.max(count - 1, 0) * 0.18 + 0.4
	local lastTime = os.clock()
	local v3 = nil

	local function spotOver(p, absolutePosition: Vector2) -- 3 equivalent calls inferred from this helper
		return Vector2.new(
			p.AbsolutePosition.X + p.AbsoluteSize.X / 2 - absolutePosition.X,
			p.AbsolutePosition.Y - absolutePosition.Y
		)
	end

	local function setPulse(instance, scale: number) -- 1 equivalent call inferred from this helper
		local v4 = pulseOf(instance) -- inferred equivalent call

		if v3 and v3 ~= v4 then
			v3.Scale = 1
		end

		if v4 then
			v4.Scale = scale
		end

		v3 = v4
	end

	data.ShowMaid:GiveTask(RunService.RenderStepped:Connect(function()
		if not data.Root.Visible or count == 0 then
			return
		end

		local absolutePosition = data.Card.AbsolutePosition
		local v4 = (os.clock() - lastTime) % v2

		for i = 1, count do
			local v5 = v[i]

			if v4 < 0.8 then
				local v6 = 0.5 - math.cos(v4 * 3.141592653589793 * 2 / 0.8) * 0.5
				local v7 = spotOver(v5, absolutePosition) -- inferred equivalent call
				data.Arrow.Position = UDim2.fromOffset(math.round(v7.X), (math.round(v7.Y - 4 - v6 * 7)))

				setPulse(v5, v6 * 0.1 + 1) -- inferred equivalent call
				break
			else
				local v6 = v4 - 0.8

				local v7 = i == count and 0.4 or 0.18

				if v6 < v7 then
					local v8 = v[i % count + 1]

					local lerped = spotOver(v5, absolutePosition):Lerp( -- inferred equivalent call
						spotOver(v8, absolutePosition), -- inferred equivalent call
						easeInOut(v6 / v7)
					)

					data.Arrow.Position = UDim2.fromOffset(math.round(lerped.X), (math.round(lerped.Y - 4)))
					local v9 = nil

					if v3 and v3 ~= v9 then
						v3.Scale = 1
					end

					if v9 then
						v9.Scale = 1
					end

					v3 = v9
					break
				end

				v4 = v6 - v7
			end
		end
	end))

	data.ShowMaid:GiveTask(function()
		local v4 = nil

		if v3 and v3 ~= v4 then
			v3.Scale = 1
		end

		if v4 then
			v4.Scale = 1
		end

		v3 = v4

		for _, v5 in v do
			local v6 = pulseOf(v5) -- inferred equivalent call

			if v6 then
				v6.Scale = 1
			end
		end
	end)
end

function PoolNineBallPopup.Hide(p)
	p.ShowMaid:DoCleaning()
	p.Root.Visible = false
end

function PoolNineBallPopup.IsVisible(p)
	return p.Root.Visible
end

function PoolNineBallPopup.Destroy(p)
	PoolNineBallPopup.Hide(p)
	p.Maid:DoCleaning()
end

return PoolNineBallPopup