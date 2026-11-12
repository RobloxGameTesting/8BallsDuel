local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolGeometry = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolGeometry)
local PoolModifiers = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolModifiers)

local PoolTableRenderer2D = {}

local tbl = PoolGeometry.Default
local frameWidth = tbl.FrameWidth
local frameHeight = tbl.FrameHeight
local vector2 = Vector2.new(0.5, 0.5)

local function isBare(): boolean -- 5 equivalent calls inferred from this helper
	return PoolConstants.BareTable == true and tbl ~= PoolGeometry.Default
end

local function isTrickshotLook(): boolean -- 2 equivalent calls inferred from this helper
	return tbl ~= PoolGeometry.Default and PoolConstants.TrickshotTable ~= nil and not isBare() -- inferred equivalent call
end

local function toScale(vector2_2: Vector2) -- 3 equivalent calls inferred from this helper
	return UDim2.fromScale(0.5 + vector2_2.X / frameWidth, 0.5 - vector2_2.Y / frameHeight)
end

local function toSize(p: number, p2: number) -- 2 equivalent calls inferred from this helper
	return UDim2.fromScale(p / frameWidth, p2 / frameHeight)
end

function PoolTableRenderer2D.TableToScale(vector2_2: Vector2)
	return toScale(vector2_2)
end

function PoolTableRenderer2D.InchesToSize(p: number, p2: number)
	return toSize(p, p2)
end

function PoolTableRenderer2D.GetTable()
	return tbl
end

function PoolTableRenderer2D.GetFrameSize()
	return Vector2.new(frameWidth, frameHeight)
end

function PoolTableRenderer2D.PixelToTable(p, vector2_2: Vector2)
	local v = p.Root.AbsolutePosition + GuiService:GetGuiInset()
	local absoluteSize = p.Root.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return Vector2.zero
	end

	local v2 = (vector2_2.X - v.X) / absoluteSize.X
	local v3 = (vector2_2.Y - v.Y) / absoluteSize.Y

	return Vector2.new((v2 - 0.5) * frameWidth, (0.5 - v3) * frameHeight)
end

function PoolTableRenderer2D.GetScreenRect(p)
	return p.Root.AbsolutePosition + GuiService:GetGuiInset(), p.Root.AbsoluteSize
end

local function rect(guiObject, name: string, vector2_2: Vector2, p: number, p2: number, backgroundColor: Color3, p3: number)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = vector2
	frame.Position = toScale(vector2_2) -- inferred equivalent call
	frame.Size = toSize(p, p2) -- inferred equivalent call
	frame.BackgroundColor3 = backgroundColor
	frame.BorderSizePixel = 0

	frame.ZIndex = (not guiObject:IsA("GuiObject") and 0 or guiObject.ZIndex) + p3
	frame.Parent = guiObject

	return frame
end

local function circle(parent, name: string, vector2_2: Vector2, p: number, backgroundColor: Color3, zIndex: number) -- 8 equivalent calls inferred from this helper
	local parent2 = rect(parent, name, vector2_2, p, p, backgroundColor, zIndex)

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = parent2

	return parent2
end

local function applyBallSize(ball)
	local baseSize = ball:GetAttribute("BaseSize")

	if typeof(baseSize) ~= "UDim2" then
		return
	end

	local v = (ball:GetAttribute("BallScale") or 1) * (ball:GetAttribute("HeightScale") or 1)

	ball.Size = UDim2.new(baseSize.X.Scale * v, baseSize.X.Offset * v, baseSize.Y.Scale * v, baseSize.Y.Offset * v)
end

local function markPiece(instance) -- 8 equivalent calls inferred from this helper
	instance:SetAttribute("TablePiece", true)

	return instance
end

local function buildCushions(parent, data)
	for _, v in PoolGeometry.GetCushions(tbl) do
		local v2 = v.B - v.A
		local magnitude = v2.Magnitude
		local v3 = (v.A + v.B) / 2 - v.Normal * (PoolConstants.CushionDepth / 2)

		local v4 = PoolConstants.CushionDepth
		local v5

		if math.abs(v2.X) > math.abs(v2.Y) then
			v5 = PoolConstants.CushionDepth
			v4 = magnitude
		else
			v5 = magnitude
		end

		markPiece(rect(parent, "Cushion_" .. v.Id, v3, v4, v5, data.Cushion, 4)) -- inferred equivalent call
	end
end

local function buildPockets(parent, data)
	for _, v in PoolGeometry.GetPockets(tbl) do
		local v2 = v.BowlRadius * 2

		markPiece(circle(parent, "Casing_" .. v.Id, v.BowlCentre, v2 + 1.4, data.PocketCasing, 7)) -- inferred equivalent call
		markPiece(circle(parent, "Pocket_" .. v.Id, v.BowlCentre, v2, data.Pocket, 8)) -- inferred equivalent call
	end
end

local function buildDiamonds(parent, data)
	if isBare() then -- inferred equivalent call
		return
	end

	local trickshotTable = PoolConstants.TrickshotTable

	if isTrickshotLook() and trickshotTable.Rivets then -- inferred equivalent call
		local v = tbl.HalfWidth + PoolConstants.CushionDepth
		local v2 = tbl.HalfHeight + PoolConstants.CushionDepth
		local v3 = frameWidth / 2 - PoolConstants.BezelDepth
		local v4 = frameHeight / 2 - PoolConstants.BezelDepth
		local midpoint = (v3 + v) / 2
		local midpoint2 = (v4 + v2) / 2
		local v5 = {
			Vector2.new(-midpoint, -midpoint2),
			Vector2.new(midpoint, -midpoint2),
			Vector2.new(midpoint, midpoint2),
			Vector2.new(-midpoint, midpoint2)
		}
		local lerped = trickshotTable.RivetColour:Lerp(Color3.new(1, 1, 1), 0.55)
		local lerped2 = trickshotTable.RivetColour:Lerp(Color3.new(0, 0, 0), 0.35)

		for i = 1, 4 do
			local v6 = v5[i]
			local v7 = v5[i % 4 + 1]
			local v8 = math.max(1, (math.round((v7 - v6).Magnitude / trickshotTable.RivetSpacing)))

			for j = 0, v8 - 1 do
				local parent2 = circle( -- inferred equivalent call
					parent,
					string.format("Rivet%d_%d", i, j),
					v6:Lerp(v7, j / v8),
					trickshotTable.RivetDiameter,
					trickshotTable.RivetColour,
					6
				)

				local uiGradient = Instance.new("UIGradient")
				uiGradient.Color = ColorSequence.new(lerped, lerped2)
				uiGradient.Rotation = 45
				uiGradient.Parent = parent2

				local uiStroke = Instance.new("UIStroke")
				uiStroke.Color = lerped2:Lerp(Color3.new(0, 0, 0), 0.4)
				uiStroke.Thickness = 1
				uiStroke.Transparency = 0.35
				uiStroke.Parent = parent2
				markPiece(parent2) -- inferred equivalent call
			end
		end
	else
		for k, v in PoolGeometry.GetDiamonds(tbl) do
			markPiece(circle(parent, "Diamond" .. k, v, 0.9, data.Diamond, 6)) -- inferred equivalent call
		end
	end
end

local rebuildTable

local function buildTableArt(parent, theme)
	local trickshotLook = isTrickshotLook() -- inferred equivalent call
	local trickshotTable = PoolConstants.TrickshotTable
	local backgroundColor

	if trickshotLook then
		backgroundColor = trickshotTable.EdgeColour
	else
		backgroundColor = theme.Frame
	end

	parent.BackgroundColor3 = backgroundColor

	if not isBare() then -- inferred equivalent call
		local zero = Vector2.zero
		local v = frameWidth - PoolConstants.BezelDepth * 2
		local v2 = frameHeight - PoolConstants.BezelDepth * 2
		local v3

		if trickshotLook then
			v3 = trickshotTable.RimColour
		else
			v3 = theme.Rail
		end

		local parent2 = markPiece(rect(parent, "Wood", zero, v, v2, v3, 2)) -- inferred equivalent call

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0.035, 0)
		uiCorner.Parent = parent2

		if trickshotLook then
			local uiGradient = Instance.new("UIGradient")
			uiGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.92, 0.92, 0.92)),
				ColorSequenceKeypoint.new(0.18, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(0.34, Color3.new(0.88, 0.88, 0.88)),
				ColorSequenceKeypoint.new(0.52, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(0.7, Color3.new(0.9, 0.9, 0.9)),
				ColorSequenceKeypoint.new(0.86, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(0.93, 0.93, 0.93))
			})

			uiGradient.Rotation = 90
			uiGradient.Parent = parent2
		end
	end

	local zero = Vector2.zero
	local bare = isBare() -- inferred equivalent call
	local v

	if bare then
		v = frameWidth
	else
		v = tbl.HalfWidth * 2
	end

	local bare2 = isBare() -- inferred equivalent call
	local v2

	if bare2 then
		v2 = frameHeight
	else
		v2 = tbl.HalfHeight * 2
	end

	markPiece(rect(parent, "Cloth", zero, v, v2, theme.Cloth, 3)) -- inferred equivalent call

	buildCushions(parent, theme)

	if tbl.Pocketed then
		local v3 = rect(
			parent,
			"HeadString",
			Vector2.new(tbl.HeadStringX, 0),
			0.3,
			tbl.HalfHeight * 2,
			PoolConstants.HeadStringColour,
			5
		)

		v3.BackgroundTransparency = 0.82
		markPiece(v3) -- inferred equivalent call
	end

	buildDiamonds(parent, theme)
	buildPockets(parent, theme)
end

local buildCollisionOverlay

function PoolTableRenderer2D.new(guiObject, p: string?)
	local theme = PoolConstants.GetTheme(p)
	local maid = Maid.new()

	local poolTable = Instance.new("Frame")
	poolTable.Name = "PoolTable"
	poolTable.AnchorPoint = vector2
	poolTable.Position = UDim2.fromScale(0.5, 0.5)
	poolTable.Size = UDim2.fromScale(1, 1)
	poolTable.BackgroundColor3 = theme.Frame
	poolTable.BorderSizePixel = 0

	poolTable.ZIndex = (not guiObject:IsA("GuiObject") and 0 or guiObject.ZIndex) + 1
	poolTable.Parent = guiObject
	maid:GiveTask(poolTable)

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = frameWidth / frameHeight
	uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
	uiAspectRatioConstraint.Parent = poolTable

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.04, 0)
	uiCorner.Parent = poolTable

	buildTableArt(poolTable, theme)

	local modifiers = Instance.new("Frame")
	modifiers.Name = "Modifiers"
	modifiers.BackgroundTransparency = 1
	modifiers.BorderSizePixel = 0
	modifiers.Size = UDim2.fromScale(1, 1)
	modifiers.ZIndex = poolTable.ZIndex + 5
	modifiers.Parent = poolTable

	local balls = Instance.new("Frame")
	balls.Name = "Balls"
	balls.BackgroundTransparency = 1
	balls.BorderSizePixel = 0
	balls.Size = UDim2.fromScale(1, 1)
	balls.ZIndex = poolTable.ZIndex + 11
	balls.Parent = poolTable

	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = poolTable.ZIndex + 11 + 5
	overlay.Parent = poolTable

	local v = {
		Root = poolTable,
		Cloth = poolTable:FindFirstChild("Cloth"),
		BallHolder = balls,
		ModifierHolder = modifiers,
		ModifierPads = {},
		Overlay = overlay,
		CollisionOverlay = nil,
		Balls = {},
		Skins = {},
		Theme = theme,
		Maid = maid
	}

	buildCollisionOverlay(v)
	PoolTableRenderer2D.SetCollisionOverlayVisible(v, PoolConstants.ShowCollisionOverlay == true)

	return v
end

function PoolTableRenderer2D.SetTable(p, p2)
	local v = p2 or PoolGeometry.Default

	if v == tbl and p.Root:FindFirstChild("Cloth") then
		return
	end

	tbl = v
	frameWidth = v.FrameWidth
	frameHeight = v.FrameHeight

	rebuildTable(p)
end

function PoolTableRenderer2D:SetTheme(p)
	local theme = p or PoolConstants.GetTheme()

	if theme == self.Theme and self.Root:FindFirstChild("Cloth") then
		return
	end

	self.Theme = theme

	rebuildTable(self)
end

rebuildTable = function(state)
	local root = state.Root
	local uiAspectRatioConstraint = root:FindFirstChildOfClass("UIAspectRatioConstraint")

	if uiAspectRatioConstraint then
		uiAspectRatioConstraint.AspectRatio = frameWidth / frameHeight
	end

	for _, child in root:GetChildren() do
		if child:GetAttribute("TablePiece") then
			child:Destroy()
		end
	end

	buildTableArt(root, state.Theme)
	state.Cloth = root:FindFirstChild("Cloth")

	local visible = root.BackgroundTransparency < 1

	for _, guiObject in root:GetChildren() do
		if guiObject:GetAttribute("TablePiece") and guiObject:IsA("GuiObject") then
			guiObject.Visible = visible
		end
	end

	local v

	if state.CollisionOverlay == nil then
		v = false
	else
		v = state.CollisionOverlay.Visible
	end

	if state.CollisionOverlay then
		state.CollisionOverlay:Destroy()
		state.CollisionOverlay = nil
	end

	buildCollisionOverlay(state)
	PoolTableRenderer2D.SetCollisionOverlayVisible(state, v)

	for _, ball in state.Balls do
		ball:SetAttribute("BaseSize", toSize(PoolConstants.BallDiameter, PoolConstants.BallDiameter))
		applyBallSize(ball)
	end
end

function PoolTableRenderer2D.SetBallSkin(p, p2: number, p3: number?)
	p.Skins[p2] = p3
end

local function createBall(p, p2: number)
	local v = p.Skins[p2] or p2

	if v == 16 then
		local parent = circle( -- inferred equivalent call
			p.BallHolder,
			"Ball" .. p2,
			Vector2.zero,
			PoolConstants.BallDiameter,
			Color3.fromRGB(120, 128, 140),
			1
		)
		parent:SetAttribute("BallNumber", 16)
		parent:SetAttribute("BaseSize", parent.Size)

		local uiCorner = parent:FindFirstChildOfClass("UICorner")

		if uiCorner then
			uiCorner.CornerRadius = UDim.new(0, 3)
		end

		return parent
	else
		local v2 = v == PoolConstants.GoldenBallSkin
		local backgroundColor

		if v2 then
			backgroundColor = PoolConstants.GoldenBallColour
		else
			backgroundColor = PoolConstants.BallColours[v] or PoolConstants.CueBallColour
		end

		local v3 = v2 and "Eight" or PoolConstants.GetGroup(v)
		local v4

		if v3 == "Stripe" then
			v4 = PoolConstants.CueBallColour
		else
			v4 = backgroundColor
		end

		local parent = circle(p.BallHolder, "Ball" .. p2, Vector2.zero, PoolConstants.BallDiameter, v4, 1) -- inferred equivalent call

		parent.ClipsDescendants = true
		parent:SetAttribute("BallNumber", v)

		parent:SetAttribute("BaseSize", parent.Size)

		if v3 == "Stripe" then
			local stripe = Instance.new("Frame")
			stripe.Name = "Stripe"
			stripe.AnchorPoint = vector2
			stripe.Position = UDim2.fromScale(0.5, 0.5)
			stripe.Size = UDim2.fromScale(1, 0.46)
			stripe.BackgroundColor3 = backgroundColor
			stripe.BorderSizePixel = 0
			stripe.ZIndex = parent.ZIndex + 1
			stripe.Parent = parent
			return parent
		else
			if v3 ~= "Eight" then
				return parent
			end

			local dot = Instance.new("Frame")
			dot.Name = "Dot"
			dot.AnchorPoint = vector2
			dot.Position = UDim2.fromScale(0.5, 0.5)
			dot.Size = UDim2.fromScale(0.4, 0.4)
			dot.BackgroundColor3 = PoolConstants.CueBallColour
			dot.BorderSizePixel = 0
			dot.ZIndex = parent.ZIndex + 1
			dot.Parent = parent

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(1, 0)
			uiCorner.Parent = dot

			return parent
		end
	end
end

function PoolTableRenderer2D.SetBall(p, p2: number, vector2_2: Vector2)
	local selected = p.Balls[p2]

	if not selected then
		selected = createBall(p, p2)
		p.Balls[p2] = selected
	end

	selected.Position = toScale(vector2_2) -- inferred equivalent call
	selected.Visible = true

	return selected
end

function PoolTableRenderer2D.SetBallScale(p, p2: number, p3: number)
	local ball = p.Balls[p2]

	if not ball then
		return
	end

	local v = math.max(p3, 0.01)

	if ball:GetAttribute("BallScale") == v then
		return
	end

	ball:SetAttribute("BallScale", v)
	applyBallSize(ball)
end

function PoolTableRenderer2D.SetBallHeight(p, p2: number, p3: number)
	local ball = p.Balls[p2]

	if not ball then
		return
	end

	local scaleForHeight = PoolModifiers.ScaleForHeight((math.max(p3, 0)))

	if ball:GetAttribute("HeightScale") == scaleForHeight then
		return
	end

	ball:SetAttribute("HeightScale", scaleForHeight)
	applyBallSize(ball)

	local zIndex = ball:GetAttribute("BaseZIndex")

	if typeof(zIndex) ~= "number" then
		zIndex = ball.ZIndex
		ball:SetAttribute("BaseZIndex", zIndex)
	end

	if scaleForHeight > 1 then
		zIndex += 2
	end

	ball.ZIndex = zIndex
end

local function decorate(parent, id: string, colour: Color3)
	local zIndex = parent.ZIndex + 1
	local function ring(p: number, thickness: number, transparency: number)
		local ring2 = Instance.new("Frame")
		ring2.Name = "Ring"
		ring2.AnchorPoint = vector2
		ring2.Position = UDim2.fromScale(0.5, 0.5)
		ring2.Size = UDim2.fromScale(p, p)
		ring2.BackgroundTransparency = 1
		ring2.ZIndex = zIndex
		ring2.Parent = parent

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = ring2

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = thickness
		uiStroke.Color = colour
		uiStroke.Transparency = transparency
		uiStroke.Parent = ring2

		return ring2
	end

	local function disc(p: number, backgroundColor: Color3, backgroundTransparency: number, value: number?) -- 1 equivalent call inferred from this helper
		local mark = Instance.new("Frame")
		mark.Name = "Mark"
		mark.AnchorPoint = vector2
		mark.Position = UDim2.fromScale(0.5, 0.5)
		mark.Size = UDim2.fromScale(p, p)
		mark.BackgroundColor3 = backgroundColor
		mark.BackgroundTransparency = backgroundTransparency
		mark.BorderSizePixel = 0
		mark.Rotation = value or 0
		mark.ZIndex = zIndex
		mark.Parent = parent

		if not value then
			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(1, 0)
			uiCorner.Parent = mark
		end

		return mark
	end

	if id == "Lava" then
		disc(0.55, Color3.fromRGB(255, 196, 92), 0.1)
	elseif id == "Boost" then
		disc(0.42, Color3.fromRGB(255, 255, 255), 0.15, 45) -- inferred equivalent call
	elseif id == "Mud" then
		for _, v in { Vector2.new(0.32, 0.38), Vector2.new(0.62, 0.55), Vector2.new(0.45, 0.7) } do
			local disc_2 = disc(0.2, Color3.fromRGB(74, 54, 36), 0.25)
			disc_2.Position = UDim2.fromScale(v.X, v.Y)
		end
	elseif id == "BlackHole" then
		ring(0.72, 2, 0.35)
		ring(0.46, 2, 0.2)
		disc(0.24, Color3.fromRGB(14, 8, 28), 0)
	elseif id == "Bubble" then
		local disc_2 = disc(0.3, Color3.fromRGB(255, 255, 255), 0.25)
		disc_2.Position = UDim2.fromScale(0.34, 0.32)
	elseif id == "Trampoline" then
		ring(0.66, 3, 0.2)
		ring(0.38, 3, 0.35)
	elseif id == "Pocket" then
		disc(0.62, Color3.fromRGB(0, 0, 0), 0)
	end
end

local function buildFanArrow(parent, r: number)
	local zIndex = parent.ZIndex + 1
	local facing = Instance.new("Frame")
	facing.Name = "Facing"
	facing.AnchorPoint = vector2
	facing.Position = UDim2.fromScale(0.5, 0.5)
	facing.Size = UDim2.fromScale(1, 1)
	facing.BackgroundTransparency = 1
	facing.Rotation = -r
	facing.ZIndex = zIndex
	facing.Parent = parent

	local shaft = Instance.new("Frame")
	shaft.Name = "Shaft"
	shaft.AnchorPoint = vector2
	shaft.Position = UDim2.fromScale(0.44, 0.5)
	shaft.Size = UDim2.fromScale(0.46, 0.1)
	shaft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shaft.BackgroundTransparency = 0.15
	shaft.BorderSizePixel = 0
	shaft.ZIndex = zIndex
	shaft.Parent = facing

	local head = Instance.new("Frame")
	head.Name = "Head"
	head.AnchorPoint = vector2
	head.Position = UDim2.fromScale(0.72, 0.5)
	head.Size = UDim2.fromScale(0.26, 0.26)
	head.Rotation = 45
	head.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	head.BackgroundTransparency = 0.15
	head.BorderSizePixel = 0
	head.ZIndex = zIndex
	head.Parent = facing
end

local function buildBullseye(parent, _: number)
	for k, bullseyeRing in PoolModifiers.BullseyeRings do
		if k == 1 then
			parent.BackgroundColor3 = bullseyeRing.Colour
			parent.BackgroundTransparency = 0.08
		else
			local frame = Instance.new("Frame")
			frame.Name = "Band" .. bullseyeRing.Stars
			frame.AnchorPoint = vector2
			frame.Position = UDim2.fromScale(0.5, 0.5)
			frame.Size = UDim2.fromScale(bullseyeRing.Fraction, bullseyeRing.Fraction)
			frame.BackgroundColor3 = bullseyeRing.Colour
			frame.BackgroundTransparency = 0.08
			frame.BorderSizePixel = 0

			frame.ZIndex = parent.ZIndex + k
			frame.Parent = parent

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(1, 0)
			uiCorner.Parent = frame
		end
	end
end

local function ghostModifier(parent)
	if parent:GetAttribute("Popped") then
		return
	end

	local backgroundColor3 = parent.BackgroundColor3

	parent:SetAttribute("Popped", true)
	parent.BackgroundTransparency = 1

	for _, guiObject in parent:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local ghost = parent:FindFirstChildWhichIsA("UIStroke")

	if not ghost then
		ghost = Instance.new("UIStroke")
		ghost.Parent = parent
	end

	ghost.Name = "Ghost"
	ghost.Color = backgroundColor3
	ghost.Thickness = 2
	ghost.Transparency = 0.5
end

local TweenService = game:GetService("TweenService")

local function burstAt(modifierHolder, position: UDim2, size: UDim2, backgroundColor3: Color3, zIndex: number)
	local pop = Instance.new("Frame")
	pop.Name = "Pop"
	pop.AnchorPoint = vector2
	pop.Position = position
	pop.Size = size
	pop.BackgroundTransparency = 1
	pop.BorderSizePixel = 0
	pop.ZIndex = zIndex
	pop.Parent = modifierHolder

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = pop

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = backgroundColor3
	uiStroke.Thickness = 4
	uiStroke.Transparency = 0.05
	uiStroke.Parent = pop

	local tweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	TweenService:Create(pop, tweenInfo, {
		Size = UDim2.fromScale(size.X.Scale * 2.5, size.Y.Scale * 2.5)
	}):Play()
	TweenService:Create(uiStroke, tweenInfo, { Transparency = 1, Thickness = 0 }):Play()

	for i = 1, 6 do
		local v = i / 6 * 3.141592653589793 * 2
		local shard = Instance.new("Frame")
		shard.Name = "Shard"
		shard.AnchorPoint = vector2
		shard.Position = position
		shard.Size = UDim2.fromScale(size.X.Scale * 0.22, size.Y.Scale * 0.22)
		shard.BackgroundColor3 = backgroundColor3
		shard.BackgroundTransparency = 0.05
		shard.BorderSizePixel = 0
		shard.ZIndex = zIndex
		shard.Parent = modifierHolder

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(1, 0)
		uiCorner2.Parent = shard

		TweenService:Create(shard, tweenInfo, {
			Position = UDim2.fromScale(
				position.X.Scale + math.cos(v) * size.X.Scale * 1.1,
				position.Y.Scale + math.sin(v) * size.Y.Scale * 1.1
			),
			Size = UDim2.fromScale(0, 0),
			BackgroundTransparency = 1
		}):Play()

		task.delay(0.5, function()
			shard:Destroy()
		end)
	end

	task.delay(0.5, function()
		pop:Destroy()
	end)
end

local function starburst(p, modifierPad)
	local overlay = p.Overlay

	if not (overlay and overlay.Parent) then
		return
	end

	local success, userInterfaceHelper = pcall(require, ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
	local v = success and userInterfaceHelper and userInterfaceHelper.Effect("Burst")

	if not v then
		return
	end

	local bubbleBurst = Instance.new("Frame")
	bubbleBurst.Name = "BubbleBurst"
	bubbleBurst.AnchorPoint = modifierPad.AnchorPoint
	bubbleBurst.Position = modifierPad.Position
	bubbleBurst.Size = modifierPad.Size
	bubbleBurst.BackgroundTransparency = 1
	bubbleBurst.ZIndex = overlay.ZIndex + 2
	bubbleBurst.Parent = overlay

	pcall(v.new, bubbleBurst)

	for _, image in bubbleBurst:GetChildren() do
		if image:IsA("ImageLabel") then
			image.ImageColor3 = Color3.fromRGB(255, 214, 90)
		end
	end

	task.delay(1.1, function()
		bubbleBurst:Destroy()
	end)
end

function PoolTableRenderer2D.PopBubble(p, p2: number)
	local modifierPad = p.ModifierPads[p2]

	if not modifierPad or modifierPad:GetAttribute("Popped") then
		return
	end

	burstAt(
		p.ModifierHolder,
		modifierPad.Position,
		modifierPad.Size,
		modifierPad.BackgroundColor3,
		modifierPad.ZIndex + 2
	)
	ghostModifier(modifierPad)
	starburst(p, modifierPad)
end

function PoolTableRenderer2D.ClearModifiers(p)
	p.ModifierHolder:ClearAllChildren()
	table.clear(p.ModifierPads)
end

function PoolTableRenderer2D.SetModifiers(p, options, p2)
	PoolTableRenderer2D.ClearModifiers(p)

	for k, v in options or {} do
		local v2 = PoolModifiers.Get(v.K)

		if not v2 then
			continue
		end

		local radius = PoolModifiers.RadiusOf(v2, v.S)

		local parent = circle(p.ModifierHolder, v2.Id, Vector2.new(v.X, v.Y), radius * 2, v2.Colour, 1) -- inferred equivalent call

		parent.BackgroundTransparency = v2.Kind == "Field" and 0.45 or 0.12

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 2
		uiStroke.Color = v2.Colour
		uiStroke.Transparency = 0.1
		uiStroke.Parent = parent

		if v2.Id == "Pocket" then
			parent.BackgroundTransparency = 0
			uiStroke.Thickness = 3
			uiStroke.Color = Color3.fromRGB(150, 150, 158)
			uiStroke.Transparency = 0
		end

		if v2.Id == "Bullseye" then
			buildBullseye(parent, radius)
		elseif v2.Id == "Fan" then
			buildFanArrow(parent, v.R or 0)
		else
			decorate(parent, v2.Id, v2.Colour)
		end

		parent:SetAttribute("ModifierKind", v2.Id)
		p.ModifierPads[k] = parent

		if p2 and p2[k] then
			ghostModifier(parent)
		end
	end
end

local object = setmetatable({}, { __mode = "k" })

local function cancelBurn(folder) -- 1 equivalent call inferred from this helper
	local v = object[folder]

	if v then
		object[folder] = nil
		v()
	end
end

function PoolTableRenderer2D.SetBallVisible(p, p2: number, visible: boolean)
	local ball = p.Balls[p2]

	if ball then
		local v = visible and object[ball]

		if v then
			object[ball] = nil
			v()
		end

		ball.Visible = visible
	end
end

function PoolTableRenderer2D.BurnBall(p, p2: number)
	local folder = p.Balls[p2]
	local lavaBurn = PoolConstants.LavaBurn

	if not folder then
		return
	end

	cancelBurn(folder) -- inferred equivalent call

	if not lavaBurn then
		folder.Visible = false

		return
	end

	local v = {}
	local v2 = {}

	for _, instance in { folder, unpack(folder:GetDescendants()) } do
		if instance:IsA("GuiObject") then
			table.insert(v, {
				Frame = instance,
				Colour = instance.BackgroundColor3,
				Transparency = instance.BackgroundTransparency
			})
		elseif instance:IsA("UIStroke") then
			table.insert(v2, { Stroke = instance, Transparency = instance.Transparency })
		end
	end

	local function restore()
		for _, v3 in v do
			v3.Frame.BackgroundColor3 = v3.Colour
			v3.Frame.BackgroundTransparency = v3.Transparency
		end

		for _, v3 in v2 do
			v3.Stroke.Transparency = v3.Transparency
		end
	end

	object[folder] = restore

	local v3 = math.max(lavaBurn.CharSeconds, 0.001)
	local v4 = math.max(lavaBurn.FadeSeconds, 0.001)

	task.spawn(function()
		local total = 0

		while total < v3 + v4 do
			total += RunService.Heartbeat:Wait()

			if object[folder] ~= restore or not folder.Parent then
				return
			end

			if total < v3 then
				local v5 = total / v3
				local v6 = 1 - (1 - v5) * (1 - v5)
				local lerped = lavaBurn.EmberColour:Lerp(lavaBurn.CharColour, v6)

				for _, v7 in v do
					v7.Frame.BackgroundColor3 = v7.Colour:Lerp(lerped, v6)
				end
			else
				local v5 = math.min((total - v3) / v4, 1)

				for _, v6 in v do
					v6.Frame.BackgroundColor3 = lavaBurn.CharColour
					v6.Frame.BackgroundTransparency = v6.Transparency + (1 - v6.Transparency) * v5
				end

				for _, v6 in v2 do
					v6.Stroke.Transparency = v6.Transparency + (1 - v6.Transparency) * v5
				end
			end
		end

		if object[folder] ~= restore then
			return
		end

		object[folder] = nil
		folder.Visible = false
		restore()
	end)
end

function PoolTableRenderer2D.RemoveBall(p, p2: number)
	local ball = p.Balls[p2]

	if ball then
		ball:Destroy()
		p.Balls[p2] = nil
	end
end

function PoolTableRenderer2D.ClearBalls(p)
	for k, ball in p.Balls do
		ball:Destroy()
		p.Balls[k] = nil
	end

	table.clear(p.Skins)
end

function PoolTableRenderer2D.RenderRack(p, p2)
	for _, v in p2 or PoolGeometry.BuildRack() do
		PoolTableRenderer2D.SetBall(p, v.Number, v.Position)
	end

	PoolTableRenderer2D.SetBall(p, PoolConstants.CueBallNumber, PoolGeometry.BreakSpot)
end

buildCollisionOverlay = function(p)
	local collisionOverlay = Instance.new("Frame")
	collisionOverlay.Name = "CollisionOverlay"
	collisionOverlay.BackgroundTransparency = 1
	collisionOverlay.BorderSizePixel = 0
	collisionOverlay.Size = UDim2.fromScale(1, 1)
	collisionOverlay.ZIndex = p.Root.ZIndex + 40
	collisionOverlay.Parent = p.Root

	local color = Color3.fromRGB(61, 220, 132)
	local color2 = Color3.fromRGB(242, 128, 43)
	local color3 = Color3.fromRGB(226, 64, 47)
	local color4 = Color3.fromRGB(255, 255, 255)
	local color5 = Color3.fromRGB(120, 180, 255)

	local function line(name: string, vector2_2: Vector2, vector2_3: Vector2, p2: number, backgroundColor: Color3, p3: number)
		local v = vector2_3 - vector2_2
		local magnitude = v.Magnitude

		if magnitude < 0.0001 then
			return
		end

		local midpoint = (vector2_2 + vector2_3) / 2
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.AnchorPoint = vector2
		frame.Position = toScale(midpoint) -- inferred equivalent call
		frame.Size = toSize(magnitude, p2) -- inferred equivalent call
		frame.Rotation = math.deg((math.atan2(-v.Y, v.X)))
		frame.BackgroundColor3 = backgroundColor
		frame.BorderSizePixel = 0
		frame.ZIndex = collisionOverlay.ZIndex + p3
		frame.Parent = collisionOverlay
	end

	local function dot(name: string, vector2_2: Vector2, p2: number, color6: Color3, zIndex: number) -- 3 equivalent calls inferred from this helper
		local parent = circle(collisionOverlay, name, vector2_2, p2, color6, zIndex) -- inferred equivalent call
		parent.ZIndex = zIndex
	end

	for _, v in PoolGeometry.GetCushions(tbl) do
		local v2 = v.Kind == "Facing"

		local name = "Seg_" .. v.Id
		local a = v.A
		local b = v.B
		local v3 = if v2 then color2 else color
		line(name, a, b, 0.45, v3, v2 and 42 or 41)
	end

	for _, v in PoolGeometry.GetPockets(tbl) do
		local v2 = v.Normal * v.CommitDepth

		line("Mouth_" .. v.Id, v.MouthA + v2, v.MouthB + v2, 0.3, color3, 43)

		for i = 0, 21 do
			local v3 = i / 22 * 3.141592653589793 * 2
			local v4 = v.BowlCentre + Vector2.new(math.cos(v3), (math.sin(v3))) * v.BowlRadius
			dot(string.format("Hole_%s_%d", v.Id, i), v4, 0.36, color5, 44) -- inferred equivalent call
		end

		dot("JawA_" .. v.Id, v.MouthA, 0.75, color4, 45) -- inferred equivalent call
		dot("JawB_" .. v.Id, v.MouthB, 0.75, color4, 45) -- inferred equivalent call
	end

	p.CollisionOverlay = collisionOverlay
end

function PoolTableRenderer2D.SetCollisionOverlayVisible(p, visible: boolean)
	if p.CollisionOverlay then
		p.CollisionOverlay.Visible = visible
	end
end

function PoolTableRenderer2D:Destroy()
	self.Balls = {}
	self.Maid:DoCleaning()
end

return PoolTableRenderer2D