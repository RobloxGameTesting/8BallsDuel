local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PoolGoals = require(Pool.PoolGoals)
local PoolModifiers = require(Pool.PoolModifiers)
local PoolModifierArt = require(Pool.PoolModifierArt)
local PoolConstants = require(Pool.PoolConstants)
local PoolTableRenderer3D = require(Pool.PoolTableRenderer3D)

local PoolLevelGoal = {}

local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local color = Color3.fromRGB(250, 206, 70)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(196, 208, 224)
local color4 = Color3.fromRGB(18, 22, 30)

function PoolLevelGoal.Describe(p)
	local kind = PoolGoals.KindOf(p)

	if kind == "None" then
		return nil
	end

	local count = PoolGoals.Census(p)[kind]
	local maxStars = PoolModifiers.MaxStars

	if kind == "Bullseye" then
		return {
			Kind = "Bullseye",
			Count = count,
			Title = count > 1 and "LAND ON A BULLSEYE" or "LAND ON THE BULLSEYE",
			Detail = "Stop a ball on it. The closer to the middle, the more stars"
		}
	elseif kind == "Bubble" then
		return {
			Kind = "Bubble",
			Count = count,
			Title = count > 1 and "POP THE GOLDEN BUBBLES" or "POP THE GOLDEN BUBBLE",
			Detail = not (count > 1) and "Roll a ball through it to pop it" or string.format(
				"Roll a ball through them. Pop all %d for %d stars",
				count,
				maxStars
			)
		}
	end

	return {
		Kind = kind,
		Count = count,
		Title = count > 1 and "POCKET THE GOLDEN BALLS" or "POCKET THE GOLDEN BALL",
		Detail = not (count > 1) and "Knock it into a pocket" or string.format(
			"Knock them into a pocket. Sink all %d for %d stars",
			count,
			maxStars
		)
	}
end

local function iconPart(parent, name: string, size: Vector3, cframe: CFrame, color5: Color3) -- 2 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Size = size
	part.CFrame = cframe
	part.Color = color5
	part.Parent = parent

	return part
end

local function disc(parent, name: string, p: number, p2: number, p3: number, color5: Color3)
	local part = iconPart( -- inferred equivalent call
		parent,
		name,
		Vector3.new(p2, p, p),
		CFrame.new(0, p3, 0) * CFrame.Angles(0, 0, 1.5707963267948966),
		color5
	)

	part.Shape = Enum.PartType.Cylinder

	return part
end

local function aim(p, vector3: Vector3, p2: number, p3: number)
	local currentCamera = p.Icon.CurrentCamera
	local fieldOfView = math.rad(currentCamera.FieldOfView)
	local v = p2 * 0.62 / math.tan(fieldOfView / 2)
	local v2 = math.rad(p3)
	local v3 = Vector3.new(0, math.sin(v2), (math.cos(v2))) * v

	currentCamera.CFrame = CFrame.lookAt(vector3 + v3, vector3)
end

local function buildBullseye(p, world)
	for k, bullseyeRing in PoolModifiers.BullseyeRings do
		if k > 1 then
			disc(world, "Seam", 10 * bullseyeRing.Fraction + 0.5, 0.1, (k - 0.5) * 0.02, color2)
		end

		disc(world, "Band", 10 * bullseyeRing.Fraction, 0.1, k * 0.02, bullseyeRing.Colour)
	end

	local currentCamera = p.Icon.CurrentCamera
	local v = 6.2 / math.tan(math.rad(currentCamera.FieldOfView) / 2)

	local v2 = Vector3.new(0, 0.9396926, 0.34202015) * v

	currentCamera.CFrame = CFrame.lookAt(Vector3.new(0, 0, 0) + v2, Vector3.new(0, 0, 0))
end

local function buildBubble(p, world)
	local bubble = PoolModifiers.Get("Bubble")
	local v = if bubble then bubble.Colour else color
	local part = iconPart( -- inferred equivalent call
		world,
		"Pad",
		Vector3.new(0.08, 10, 10),
		CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966),
		v
	)

	part.Shape = Enum.PartType.Cylinder

	local bubble2 = PoolModifierArt.Build(world, "Bubble", part, 5, { X = 0, Y = 0 })
	local currentCamera = p.Icon.CurrentCamera
	local v2 = 6.82 / math.tan(math.rad(currentCamera.FieldOfView) / 2)

	local v3 = Vector3.new(0, 0.9612617, 0.27563736) * v2

	currentCamera.CFrame = CFrame.lookAt(Vector3.new(0, 0.3, 0) + v3, Vector3.new(0, 0.3, 0))

	return bubble2
end

local function buildGoldenBall(p, world)
	local looseBall = PoolTableRenderer3D.CreateLooseBall(world, PoolConstants.GoldenBallSkin, "GoldenBall")
	local v = math.max(looseBall.Size.X, looseBall.Size.Y, looseBall.Size.Z)

	looseBall.CFrame = CFrame.Angles(0, 3.141592653589793, 0)

	local v2 = v * 1.25
	local currentCamera = p.Icon.CurrentCamera
	local fieldOfView = math.rad(currentCamera.FieldOfView)
	local v3 = v2 * 0.62 / math.tan(fieldOfView / 2)

	local v4 = Vector3.new(0, 0.309017, 0.95105654) * v3

	currentCamera.CFrame = CFrame.lookAt(Vector3.new(0, 0, 0) + v4, Vector3.new(0, 0, 0))
end

local function buildIcon(state, kind)
	local icon = state.Icon
	local world = icon:FindFirstChild("World")

	if world then
		world:Destroy()
	end

	local world2 = Instance.new("WorldModel")
	world2.Name = "World"
	world2.Parent = icon

	if kind == "Bullseye" then
		buildBullseye(state, world2)
	else
		if kind == "Bubble" then
			return buildBubble(state, world2)
		end

		if kind == "Pocket" then
			buildGoldenBall(state, world2)
		end
	end

	return nil
end

local function label(levelGoal, name: string, position: UDim2, size: UDim2, color5: Color3, p)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.Position = position
	textLabel.Size = size
	textLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", p)
	textLabel.TextColor3 = color5
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = ""
	textLabel.ZIndex = 453
	textLabel.Parent = levelGoal

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = color4
	uiStroke.Parent = textLabel

	return textLabel
end

function PoolLevelGoal.new(parent)
	local maid = Maid.new()

	local levelGoal = Instance.new("CanvasGroup")
	levelGoal.Name = "LevelGoal"
	levelGoal.AnchorPoint = Vector2.new(0.5, 0.5)
	levelGoal.Position = UDim2.fromScale(0.5, 0.33)
	levelGoal.Size = UDim2.fromScale(0.6, 0.24)
	levelGoal.BackgroundColor3 = color2
	levelGoal.BackgroundTransparency = 0.06
	levelGoal.BorderSizePixel = 0
	levelGoal.GroupTransparency = 1
	levelGoal.Visible = false
	levelGoal.Active = false
	levelGoal.ZIndex = 450
	levelGoal.Parent = parent
	maid:GiveTask(levelGoal)

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = levelGoal

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new(Color3.fromRGB(37, 40, 43), Color3.fromRGB(29, 33, 40))
	uiGradient.Rotation = 90
	uiGradient.Parent = levelGoal

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 3.3
	uiAspectRatioConstraint.Parent = levelGoal

	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MinSize = Vector2.new(330, 100)
	uiSizeConstraint.Parent = levelGoal

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = levelGoal

	local border = Instance.new("Frame")
	border.Name = "Border"
	border.BackgroundTransparency = 1
	border.Size = UDim2.new(1, -6, 1, -6)
	border.Position = UDim2.fromOffset(3, 3)
	border.ZIndex = 451
	border.Parent = levelGoal

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 9)
	uiCorner2.Parent = border

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 3
	uiStroke.Color = Color3.fromRGB(30, 30, 30)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = border

	local bevel = Instance.new("Frame")
	bevel.Name = "Bevel"
	bevel.BackgroundTransparency = 1
	bevel.Size = UDim2.new(1, -10, 1, -10)
	bevel.Position = UDim2.fromOffset(5, 5)
	bevel.ZIndex = 451
	bevel.Parent = levelGoal

	local uiCorner3 = Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 7)
	uiCorner3.Parent = bevel

	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Thickness = 2
	uiStroke2.Color = Color3.fromRGB(63, 69, 74)
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke2.Parent = bevel

	local icon = Instance.new("ViewportFrame")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.Position = UDim2.fromScale(0.025, 0.5)
	icon.Size = UDim2.fromScale(0.82, 0.82)
	icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
	icon.BackgroundTransparency = 1
	icon.Ambient = Color3.fromRGB(200, 200, 205)
	icon.LightColor = Color3.fromRGB(255, 250, 240)
	icon.LightDirection = Vector3.new(-0.5, -1, -0.6)
	icon.ZIndex = 452
	icon.Parent = levelGoal

	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.Parent = icon
	icon.CurrentCamera = camera

	local function wrap(detail, maxTextSize: number) -- 1 equivalent call inferred from this helper
		detail.TextWrapped = true
		detail.TextYAlignment = Enum.TextYAlignment.Top

		local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MaxTextSize = maxTextSize
		uiTextSizeConstraint.Parent = detail
	end

	local v = {
		Root = levelGoal,
		Scale = uiScale,
		Heading = label(
			levelGoal,
			"Heading",
			UDim2.fromScale(0.31, 0.12),
			UDim2.fromScale(0.6499999999999999, 0.15),
			color,
			Enum.FontWeight.Bold
		),
		Title = label(
			levelGoal,
			"Title",
			UDim2.fromScale(0.31, 0.29),
			UDim2.fromScale(0.6499999999999999, 0.25),
			color2,
			Enum.FontWeight.Heavy
		),
		Detail = label(
			levelGoal,
			"Detail",
			UDim2.fromScale(0.31, 0.58),
			UDim2.fromScale(0.6499999999999999, 0.3),
			color3,
			Enum.FontWeight.Medium
		),
		Icon = icon,
		Token = 0,
		Showing = Maid.new(),
		Maid = maid
	}

	wrap(v.Detail, 22) -- inferred equivalent call

	maid:GiveTask(function()
		v.Showing:DoCleaning()
	end)

	return v
end

function PoolLevelGoal:Hide()
	self.Token += 1

	local token = self.Token

	self.Showing:DoCleaning()

	if not self.Root.Visible then
		return
	end

	TweenService:Create(self.Root, tweenInfo2, { GroupTransparency = 1 }):Play()
	TweenService:Create(self.Scale, tweenInfo2, { Scale = 0.92 }):Play()

	task.delay(tweenInfo2.Time, function()
		if self.Token == token and self.Root.Parent then
			self.Root.Visible = false
		end
	end)
end

function PoolLevelGoal:Show(p, text: string)
	local describe = PoolLevelGoal.Describe(p)

	if not describe then
		PoolLevelGoal.Hide(self)

		return
	end

	self.Token += 1

	local token = self.Token
	local showing = self.Showing

	showing:DoCleaning()

	self.Heading.Text = text
	self.Title.Text = describe.Title
	self.Detail.Text = describe.Detail

	local icon = buildIcon(self, describe.Kind)

	if icon then
		icon(os.clock())

		showing:GiveTask(RunService.RenderStepped:Connect(function()
			icon(os.clock())
		end))
	end

	self.Root.Visible = true
	self.Root.GroupTransparency = 1
	self.Scale.Scale = 0.82

	TweenService:Create(self.Root, tweenInfo, { GroupTransparency = 0 }):Play()
	TweenService:Create(self.Scale, tweenInfo, { Scale = 1 }):Play()

	local lastTime = os.clock()

	showing:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if os.clock() - lastTime < 0.6 then
			return
		end

		local userInputType = input.UserInputType

		if
			userInputType == Enum.UserInputType.MouseButton1
			or userInputType == Enum.UserInputType.Touch
			or input.KeyCode == Enum.KeyCode.ButtonA
		then
			PoolLevelGoal.Hide(self)
		end
	end))

	task.delay(3.6, function()
		if self.Token == token and self.Root.Parent then
			PoolLevelGoal.Hide(self)
		end
	end)
end

function PoolLevelGoal:Destroy()
	self.Token += 1
	self.Maid:DoCleaning()
end

return PoolLevelGoal