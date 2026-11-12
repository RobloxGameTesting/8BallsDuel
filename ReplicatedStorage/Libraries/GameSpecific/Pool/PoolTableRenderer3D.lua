local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolGeometry = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolGeometry)
local PoolSkins = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolSkins)
local PoolModifiers = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolModifiers)
local PoolModifierArt = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolModifierArt)

local PoolTableRenderer3D = {}

local HalfWidth = PoolGeometry.HalfWidth
local HalfHeight = PoolGeometry.HalfHeight
local BallDiameter = PoolConstants.BallDiameter

local v = HalfWidth + PoolConstants.CushionDepth
local v2 = HalfHeight + PoolConstants.CushionDepth
local v3 = PoolConstants.FrameWidth / 2 - PoolConstants.BezelDepth
local v4 = PoolConstants.FrameHeight / 2 - PoolConstants.BezelDepth

local function toWorld(vector2: Vector2, p: number) -- 27 equivalent calls inferred from this helper
	return Vector3.new(0, 5000, 0) + Vector3.new(vector2.X, p, -vector2.Y)
end

local function makePart(parent, name: string, size: Vector3, cframe: CFrame, color: Color3) -- 16 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent

	return part
end

local function makeDisc(parent, name: string, p: number, p2: number, position: Vector3, color: Color3)
	local part = makePart(parent, name, Vector3.new(p2, p, p), CFrame.new(position), color) -- inferred equivalent call
	part.Shape = Enum.PartType.Cylinder
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, 1.5707963267948966)

	return part
end

local function buildBackdrop(parent, p: number)
	local backdrop = PoolConstants.View3D.Backdrop

	local part = makePart( -- inferred equivalent call
		parent,
		"Backdrop",
		Vector3.new(PoolConstants.FrameWidth * 4, 2, PoolConstants.FrameHeight * 6),
		CFrame.new(Vector3.new(0, 5000, 0) + Vector3.new(0, p, 0)),
		backdrop.Outer
	)

	part.CastShadow = false

	local backdropSurface = Instance.new("SurfaceGui")
	backdropSurface.Name = "BackdropSurface"
	backdropSurface.Face = Enum.NormalId.Top
	backdropSurface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	backdropSurface.PixelsPerStud = backdrop.PixelsPerStud

	backdropSurface.LightInfluence = 0
	backdropSurface.AlwaysOnTop = false
	backdropSurface.ZOffset = 0
	backdropSurface.Adornee = part
	backdropSurface.Parent = part

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	fill.Parent = backdropSurface

	local tint = Instance.new("UIGradient")
	tint.Name = "Tint"
	tint.Rotation = backdrop.Rotation

	tint.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, backdrop.Outer),
		ColorSequenceKeypoint.new(math.clamp(backdrop.CentreStop, 0.01, 0.99), backdrop.Inner),
		ColorSequenceKeypoint.new(1, backdrop.Outer)
	})

	tint.Parent = fill

	return part
end

local function buildBody(stockTable, theme)
	buildBackdrop(stockTable, -20)

	makePart( -- inferred equivalent call
		stockTable,
		"Body",
		Vector3.new(PoolConstants.FrameWidth, 6, PoolConstants.FrameHeight),
		CFrame.new(Vector3.new(0, 4997, 0)),
		theme.Frame
	)

	makePart( -- inferred equivalent call
		stockTable,
		"Cloth",
		Vector3.new(PoolConstants.PlayWidth, 0.5, PoolConstants.PlayHeight),
		CFrame.new(Vector3.new(0, 4999.77, 0)),
		theme.Cloth
	)

	local v5 = v4 - v2
	local midpoint = (v4 + v2) / 2
	local v6 = v3 - v
	local midpoint2 = (v3 + v) / 2

	for _, v7 in { 1, -1 } do
		makePart( -- inferred equivalent call
			stockTable,
			v7 > 0 and "RailTop" or "RailBottom",
			Vector3.new(v3 * 2, 2.5, v5),
			CFrame.new(toWorld(Vector2.new(0, v7 * midpoint), 1.25)), -- inferred equivalent call
			theme.Rail
		)

		makePart( -- inferred equivalent call
			stockTable,
			v7 > 0 and "RailFoot" or "RailHead",
			Vector3.new(v6, 2.5, v2 * 2),
			CFrame.new(toWorld(Vector2.new(v7 * midpoint2, 0), 1.25)), -- inferred equivalent call
			theme.Rail
		)
	end
end

local function buildCushions(stockTable, theme)
	for _, v5 in PoolGeometry.GetCushions() do
		local v6 = v5.B - v5.A
		local magnitude = v6.Magnitude
		local v7 = (v5.A + v5.B) / 2 - v5.Normal * (PoolConstants.CushionDepth / 2)

		local vector3 = Vector3.new(PoolConstants.CushionDepth, 1.6, magnitude)

		if math.abs(v6.X) > math.abs(v6.Y) then
			vector3 = Vector3.new(magnitude, 1.6, PoolConstants.CushionDepth)
		end

		makePart(stockTable, "Cushion_" .. v5.Id, vector3, CFrame.new(toWorld(v7, 0.8)), theme.Cushion) -- inferred equivalent call
	end
end

local function buildPockets(stockTable, theme)
	for _, v5 in PoolGeometry.GetPockets() do
		local v6 = v5.BowlRadius * 2

		makeDisc(stockTable, "Casing_" .. v5.Id, v6 + 1.4, 0.4, toWorld(v5.BowlCentre, 0.08), theme.PocketCasing) -- inferred equivalent call

		makeDisc(stockTable, "Pocket_" .. v5.Id, v6, 5, toWorld(v5.BowlCentre, -2.38), theme.Pocket) -- inferred equivalent call
	end
end

local function buildDiamonds(stockTable, theme)
	for k, v5 in PoolGeometry.GetDiamonds() do
		makeDisc(stockTable, "Diamond" .. k, 0.9, 0.12, toWorld(v5, 2.56), theme.Diamond) -- inferred equivalent call
	end
end

local function buildImageSurface(stockTable)
	local table3D = PoolConstants.Table3D
	local v5, v6

	if table3D.FitTo == "Height" then
		v5 = PoolConstants.FrameHeight
		v6 = v5 * table3D.SourceAspect
	else
		v6 = PoolConstants.FrameWidth
		v5 = v6 / table3D.SourceAspect
	end

	local v7 = v6 * table3D.Scale.X
	local v8 = v5 * table3D.Scale.Y

	local rotationDegrees = math.rad(table3D.RotationDegrees)
	local vector3

	if math.abs((math.cos(rotationDegrees))) < 0.5 then
		vector3 = Vector3.new(v8, 0.5, v7)
	else
		vector3 = Vector3.new(v7, 0.5, v8)
	end

	local part = makePart( -- inferred equivalent call
		stockTable,
		"ImageSurface",
		vector3,
		CFrame.new(toWorld(table3D.Offset, -0.25)) * CFrame.Angles(0, rotationDegrees, 0), -- inferred equivalent call
		Color3.fromRGB(12, 15, 18)
	)

	part.CastShadow = false

	local artwork = Instance.new("SurfaceGui")
	artwork.Name = "Artwork"
	artwork.Face = Enum.NormalId.Top
	artwork.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	artwork.PixelsPerStud = 50
	artwork.LightInfluence = table3D.LightInfluence
	artwork.ZOffset = 0
	artwork.Parent = part

	local tbl = Instance.new("ImageLabel")
	tbl.Name = "Table"
	tbl.Size = UDim2.fromScale(1, 1)
	tbl.BackgroundTransparency = 1
	tbl.Image = table3D.ImageId
	tbl.ScaleType = Enum.ScaleType.Stretch
	tbl.Parent = artwork
end

local function buildGeometryOverlay(_) end

local buildCueStick

local function buildTableModel(parent, p: string?): boolean
	local table3D = PoolConstants.Table3D

	local child = ReplicatedStorage

	for _, childName in table3D.ModelFolderPath do
		child = child:FindFirstChild(childName)

		if not child then
			warn(string.format("[Pool] table folder not found at %s", childName))
			return false
		end
	end

	local v5 = p or PoolSkins.GetTableModelName()
	local model

	if v5 then
		model = child:FindFirstChild(v5)
	end

	if v5 and not model then
		warn(string.format("[Pool] table model %q not found in %s", v5, child:GetFullName()))
	end

	if not (model and model:IsA("Model")) then
		model = child:FindFirstChild(table3D.ModelName)
	end

	if not (model and model:IsA("Model")) then
		warn(string.format("[Pool] table model %q not found", (tostring(table3D.ModelName))))
		return false
	end

	local _, v6 = model:GetBoundingBox()

	local v7 = 2 * (v6.X - v6.Z)
	local modelScale = table3D.ModelScale or not (v7 > 0) and 1 or PoolConstants.PlayWidth / v7

	local tableModel = model:Clone()
	tableModel.Name = "TableModel"
	local primaryPart = nil

	for _, part in tableModel:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Size *= modelScale
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		primaryPart = primaryPart or part
	end

	if not primaryPart then
		return false
	end

	tableModel.PrimaryPart = primaryPart
	tableModel.Parent = parent

	local v8 = (table3D.ModelRotationDegrees or 0) % 360

	if v8 ~= 0 then
		tableModel:PivotTo(tableModel:GetPivot() * CFrame.Angles(0, math.rad(v8), 0))
	end

	local boundingBox, v9 = tableModel:GetBoundingBox()
	local v10 = table3D.SurfaceDropFromTop * modelScale
	local world = toWorld(table3D.ModelOffset, 0 + v10 - v9.Y / 2) -- inferred equivalent call

	tableModel:PivotTo(tableModel:GetPivot() + (world - boundingBox.Position))

	return true
end

function PoolTableRenderer3D:SetTableSkin(p: string?)
	if not PoolConstants.Table3D.UseModel then
		return false
	end

	if self.BuiltTable then
		self.PendingSkin = p

		return true
	end

	local stockHolder = self.StockHolder

	if self.TableSkin == p and stockHolder:FindFirstChild("TableModel") then
		return true
	end

	local tableModel = stockHolder:FindFirstChild("TableModel")

	if tableModel then
		tableModel.Name = "TableModelOld"
	end

	local tableModel2 = buildTableModel(stockHolder, p)

	if tableModel2 then
		if tableModel then
			tableModel:Destroy()
		end

		self.TableSkin = p
	elseif tableModel then
		tableModel.Name = "TableModel"
	end

	return tableModel2
end

function PoolTableRenderer3D.new(p: string?, value: string?)
	local theme = PoolConstants.GetTheme(p)
	local maid = Maid.new()

	local name = value or "PoolScene3D"

	local folder = Instance.new("Folder")
	folder.Name = name

	for _, folder2 in workspace:GetChildren() do
		if not (folder2 ~= folder and folder2.Name == name and folder2:IsA("Folder")) then
			continue
		end

		warn(`[Pool] removing a leftover {name} -- something built a scene and did not clean it up`)
		folder2:Destroy()
	end

	maid:GiveTask(folder)

	local stockTable = Instance.new("Folder")
	stockTable.Name = "StockTable"
	stockTable.Parent = folder

	maid:GiveTask(stockTable)

	if PoolConstants.Table3D.UseModel then
		buildBackdrop(stockTable, -30)

		if not buildTableModel(stockTable) then
			buildBody(stockTable, theme)
			buildCushions(stockTable, theme)
			buildDiamonds(stockTable, theme)
			buildPockets(stockTable, theme)
		end
	elseif PoolConstants.Table3D.UseImage then
		buildBackdrop(stockTable, -20)

		buildImageSurface(stockTable)
	else
		buildBody(stockTable, theme)
		buildCushions(stockTable, theme)
		buildDiamonds(stockTable, theme)
		buildPockets(stockTable, theme)
	end

	local _showGeometryOverlay = PoolConstants.Table3D.ShowGeometryOverlay

	local part = makePart( -- inferred equivalent call
		folder,
		"LightAnchor",
		Vector3.new(1, 1, 1),
		CFrame.new(Vector3.new(0, 5045, 0)),
		Color3.new(1, 1, 1)
	)

	part.Transparency = 1
	part.CastShadow = false

	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 160
	pointLight.Shadows = false
	pointLight.Parent = part

	local balls = Instance.new("Folder")
	balls.Name = "Balls"
	balls.Parent = folder

	local shadows = Instance.new("Folder")
	shadows.Name = "Shadows"
	shadows.Parent = folder

	local modifiers = Instance.new("Folder")
	modifiers.Name = "Modifiers"
	modifiers.Parent = folder
	local tableSkin

	if PoolConstants.Table3D.UseModel then
		tableSkin = PoolSkins.GetTableModelName()
	end

	local v5 = {
		Root = folder,
		BallHolder = balls,
		ModifierHolder = modifiers,
		ModifierGroups = {},
		ModifierAnimators = {},
		ModifierClock = nil,
		ModifierBuilt = {},
		ShadowHolder = shadows,
		ShadowFloor = 0,
		Balls = {},
		Skins = {},
		Shadows = {},
		DropTokens = {},
		DropUntil = {},
		TableSkin = tableSkin,
		StockHolder = stockTable,
		BuiltTable = nil,
		CustomTable = nil,
		PendingSkin = nil,
		CueStick = nil,
		CueStickModel = nil,
		CueStickVisible = true,
		CueStickLength = 0,
		CueStickPivotOffset = Vector3.new(0, 0, 0),
		Centre = Vector3.new(0, 5000, 0),
		Theme = theme,
		Maid = maid
	}

	buildCueStick(v5)

	return v5
end

local v5 = nil
local flag = false

local function getBallFolder()
	if flag then
		return v5
	end

	flag = true

	if not PoolConstants.Ball3D.UseTemplate then
		return nil
	end

	local child = ReplicatedStorage

	for _, childName in PoolConstants.Ball3D.FolderPath do
		child = child:FindFirstChild(childName)

		if not child then
			warn(string.format("[Pool] ball folder not found at %s", childName))
			return nil
		end
	end

	v5 = child

	return v5
end

local color = Color3.fromRGB(120, 128, 140)

local function getBallTemplate(p: number)
	if p == 16 then
		return nil
	end

	local ballFolder = getBallFolder()

	if not ballFolder then
		return nil
	end

	local v6

	if p == PoolConstants.CueBallNumber then
		v6 = PoolConstants.Ball3D.CueName
	elseif p == PoolConstants.GoldenBallSkin then
		v6 = PoolConstants.Ball3D.GoldenName
	else
		v6 = tostring(p)
	end

	local part = ballFolder:FindFirstChild(v6)

	if not part then
		warn(string.format("[Pool] no model named %q for ball %d", v6, p))
		return nil
	end

	return if part:IsA("BasePart") then part else nil
end

local function createBallBody(parent, name: string, p: number, color2: Color3)
	local ballTemplate = getBallTemplate(p)

	if ballTemplate then
		local clone = ballTemplate:Clone()
		clone.Name = name

		local size = ballTemplate.Size
		local v6 = math.max(size.X, size.Y, size.Z)
		local v7 = BallDiameter * PoolConstants.Ball3D.SizeMultiplier

		if v6 > 0 then
			clone.Size = size * (v7 / v6)
		end

		clone.CFrame = CFrame.new(Vector3.new(0, 5000, 0))
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false

		for _, specialMesh in clone:GetDescendants() do
			if specialMesh:IsA("SpecialMesh") then
				specialMesh.Scale = Vector3.new(v7, v7, v7)
			end
		end

		clone.Parent = parent

		return clone
	else
		local part = makePart( -- inferred equivalent call
			parent,
			name,
			Vector3.new(BallDiameter, BallDiameter, BallDiameter),
			CFrame.new(Vector3.new(0, 5000, 0)),
			color2
		)

		if p == 16 then
			part.Shape = Enum.PartType.Block
			part.Material = Enum.Material.SmoothPlastic
			part.Reflectance = 0
		else
			part.Shape = Enum.PartType.Ball
			part.Material = Enum.Material.Glass
			part.Reflectance = 0.08
		end

		return part
	end
end

local v6 = nil
local flag2 = false

local function getShadowTemplate()
	if flag2 then
		return v6
	end

	flag2 = true

	if not PoolConstants.Ball3D.ShadowEnabled then
		return nil
	end

	local part = ReplicatedStorage

	for _, childName in PoolConstants.Ball3D.ShadowPath do
		part = part:FindFirstChild(childName)

		if not part then
			warn(string.format("[Pool] ball shadow not found at %s", childName))
			return nil
		end
	end

	if part:IsA("BasePart") then
		v6 = part
	end

	return v6
end

local function shadowHeight(p) -- 3 equivalent calls inferred from this helper
	return math.max(PoolConstants.Ball3D.ShadowHeight, p.ShadowFloor or 0) + 0
end

local function createShadow(p, p2: number)
	local shadowTemplate = getShadowTemplate()
	local shadowHolder = p.ShadowHolder

	if not (shadowTemplate and shadowHolder) then
		return nil
	end

	local clone = shadowTemplate:Clone()
	local v7 = BallDiameter * PoolConstants.Ball3D.ShadowScale

	clone.Name = "Shadow" .. p2
	clone.Size = Vector3.new(v7, shadowTemplate.Size.Y, v7)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false

	clone.CastShadow = false
	clone.CFrame = CFrame.new(toWorld(Vector2.zero, shadowHeight(p))) -- inferred equivalent call
	clone.Parent = shadowHolder

	p.Shadows[p2] = clone

	return clone
end

function PoolTableRenderer3D.SetBallSkin(p, p2: number, p3: number?)
	p.Skins[p2] = p3
end

local function createBall(p, p2: number)
	local v7 = p.Skins[p2] or p2
	local v8

	if v7 == 16 then
		v8 = color
	elseif v7 == PoolConstants.GoldenBallSkin then
		v8 = PoolConstants.GoldenBallColour
	else
		v8 = PoolConstants.BallColours[v7] or PoolConstants.CueBallColour
	end

	local ballBody = createBallBody(p.BallHolder, "Ball" .. p2, v7, v8)

	ballBody:SetAttribute("BallNumber", v7)

	ballBody:SetAttribute("BaseSize", ballBody.Size)
	createShadow(p, p2)

	return ballBody
end

local function scalesOf(instance)
	local ballScale = instance:GetAttribute("BallScale")
	local heightScale = instance:GetAttribute("HeightScale")

	local selected = typeof(ballScale) ~= "number" and 1 or ballScale

	if typeof(heightScale) == "number" then
		return selected, heightScale
	end

	return selected, 1
end

local function applyBallSize(p, p2: number)
	local folder = p.Balls[p2]

	if not folder then
		return
	end

	local baseSize = folder:GetAttribute("BaseSize")

	if typeof(baseSize) ~= "Vector3" then
		return
	end

	local ballScale = folder:GetAttribute("BallScale")
	local heightScale = folder:GetAttribute("HeightScale")

	local v7 = typeof(ballScale) ~= "number" and 1 or ballScale
	local v8 = typeof(heightScale) ~= "number" and 1 or heightScale

	local v9 = v7 * v8

	folder.Size = baseSize * v9

	local v10 = BallDiameter * PoolConstants.Ball3D.SizeMultiplier * v9

	for _, specialMesh in folder:GetDescendants() do
		if specialMesh:IsA("SpecialMesh") then
			specialMesh.Scale = Vector3.new(v10, v10, v10)
		end
	end

	local folder2 = p.Shadows[p2]

	if folder2 then
		local ball3D = PoolConstants.Ball3D
		local v11 = v8 - 1
		local v12 = 1 + v11 * (ball3D.JumpShadowGrowth or 1)

		local v13 = BallDiameter * ball3D.ShadowScale * v7 * v12
		folder2.Size = Vector3.new(v13, folder2.Size.Y, v13)

		for _, decal in folder2:GetDescendants() do
			if not decal:IsA("Decal") then
				continue
			end

			local v14 = decal:GetAttribute("BaseTransparency")

			if typeof(v14) ~= "number" then
				v14 = decal.Transparency
				decal:SetAttribute("BaseTransparency", v14)
			end

			local v15 = math.clamp(v11 * (ball3D.JumpShadowFade or 0), 0, 0.85)
			decal.Transparency = v14 + (1 - v14) * v15
		end
	end
end

function PoolTableRenderer3D.SetBallScale(p, p2: number, p3: number)
	local ball = p.Balls[p2]

	if not ball then
		return
	end

	local v7 = math.max(p3, 0.01)

	if ball:GetAttribute("BallScale") == v7 then
		return
	end

	ball:SetAttribute("BallScale", v7)
	applyBallSize(p, p2)
end

function PoolTableRenderer3D.SetBallHeight(p, p2: number, p3: number)
	local ball = p.Balls[p2]

	if not ball then
		return
	end

	local scaleForHeight = PoolModifiers.ScaleForHeight((math.max(p3, 0)))
	local heightScale = ball:GetAttribute("HeightScale")

	if heightScale == scaleForHeight or heightScale == nil and scaleForHeight == 1 then
		return
	end

	ball:SetAttribute("HeightScale", scaleForHeight)
	applyBallSize(p, p2)
end

local v7 = BallDiameter * 2

function PoolTableRenderer3D.SetBall(p, p2: number, vector2: Vector2)
	local v8 = p.Balls[p2]

	if not v8 then
		v8 = createBall(p, p2)
		p.Balls[p2] = v8
	end

	local ballScale = v8:GetAttribute("BallScale")
	local heightScale = v8:GetAttribute("HeightScale")

	local v9 = typeof(ballScale) ~= "number" and 1 or ballScale
	local v10 = typeof(heightScale) ~= "number" and 1 or heightScale

	local world = toWorld(vector2, 0 + BallDiameter * v9 * v10 / 2) -- inferred equivalent call
	local v11 = world - v8.Position
	local magnitude = v11.Magnitude
	local rotation = v8.CFrame.Rotation

	if PoolConstants.Ball3D.RollRendering and magnitude > 0.0001 and magnitude < v7 * v9 then
		local cross = (Vector3.new(0, 1, 0)):Cross(v11)

		if cross.Magnitude > 1e-6 then
			rotation = CFrame.fromAxisAngle(cross.Unit, magnitude / (BallDiameter * v9 / 2)) * rotation
		end
	end

	v8.CFrame = CFrame.new(world) * rotation

	local shadow = p.Shadows[p2]

	if shadow then
		shadow.CFrame = CFrame.new(toWorld(vector2, shadowHeight(p))) -- inferred equivalent call
	end

	for _, part in v8:GetChildren() do
		if part:IsA("BasePart") and part.Anchored then
			part.CFrame += v11
		end
	end

	v8.Transparency = 0

	return v8
end

local function placeDropping(ball, position: Vector3, p)
	local v8 = position - ball.Position
	local magnitude = v8.Magnitude
	local rotation = ball.CFrame.Rotation

	if PoolConstants.Ball3D.RollRendering and magnitude > 0.0001 then
		local vector3 = Vector3.new(v8.X, 0, v8.Z)
		local axis = p.Axis

		if vector3.Magnitude > 0.001 then
			local cross = (Vector3.new(0, 1, 0)):Cross(vector3)

			if cross.Magnitude > 1e-6 then
				axis = cross.Unit
				p.Axis = axis
			end
		end

		if axis then
			rotation = CFrame.fromAxisAngle(axis, magnitude / (BallDiameter / 2)) * rotation
		end
	end

	ball.CFrame = CFrame.new(position) * rotation
end

function PoolTableRenderer3D.DropBall(data, p: number, data2, vector2: Vector2?, value: number?)
	local ball = data.Balls[p]
	local ball3D = PoolConstants.Ball3D

	local v8 = (data.DropTokens[p] or 0) + 1
	data.DropTokens[p] = v8

	if ball and ball3D.DropEnabled then
		local shadow = data.Shadows[p]

		if shadow then
			shadow.Parent = nil
		end

		local bowlRadius = data2.BowlRadius
		local v9 = vector2 or data2.MouthCentre
		local v10 = data2.BowlCentre + data2.Normal * (bowlRadius * ball3D.DropBackOffset)
		local v11 = data2.BowlCentre - data2.Normal * (bowlRadius * ball3D.DropFrontOffset)

		local v12 = math.clamp((value or 0) / 200, 0, 1)

		local lerped = v9:Lerp(v10, v12 * 0.75 + 0.25)

		local world = toWorld(v9, 0 + BallDiameter / 2) -- inferred equivalent call
		local world2 = toWorld(lerped, 0 - ball3D.DropBackDepth) -- inferred equivalent call
		local world3 = toWorld(v11, 0 - ball3D.DropHiddenDepth) -- inferred equivalent call

		local v13 = ball3D.DropFallSeconds * (v12 * 0.95 + 0.7)
		local v14 = ball3D.DropRollSeconds * (1.15 - v12 * 0.35)

		data.DropUntil[p] = os.clock() + v13 + v14

		task.spawn(function()
			local total = 0
			local v15 = { Axis = nil }

			while total < v13 do
				total += RunService.PreRender:Wait()

				local v16 = math.min(total / v13, 1)
				local v17 = 1 - (1 - v16) * (1 - v16)
				local v18 = v16 * v16

				local v19 = world.X + (world2.X - world.X) * v17
				local v20 = world.Z + (world2.Z - world.Z) * v17
				local v21 = world.Y + (world2.Y - world.Y) * v18

				if not ball.Parent or data.DropTokens[p] ~= v8 then
					return
				end

				placeDropping(ball, Vector3.new(v19, v21, v20), v15)
			end

			local total2 = 0

			while total2 < v14 do
				total2 += RunService.PreRender:Wait()

				local v16 = math.min(total2 / v14, 1)

				if not ball.Parent or data.DropTokens[p] ~= v8 then
					return
				end

				placeDropping(ball, world2:Lerp(world3, v16 * v16), v15)
			end

			if data.DropTokens[p] ~= v8 then
				return
			end

			PoolTableRenderer3D.SetBallVisible(data, p, false)
		end)
	else
		data.DropUntil[p] = nil
		PoolTableRenderer3D.SetBallVisible(data, p, false)
	end
end

function PoolTableRenderer3D.BurnBall(data, p: number)
	local ball = data.Balls[p]
	local lavaBurn = PoolConstants.LavaBurn

	local v8 = (data.DropTokens[p] or 0) + 1
	data.DropTokens[p] = v8

	if not (ball and ball.Parent and lavaBurn) then
		PoolTableRenderer3D.SetBallVisible(data, p, false)

		return
	end

	local v9 = math.max(lavaBurn.CharSeconds, 0.001)
	local v10 = math.max(lavaBurn.FadeSeconds, 0.001)
	local v11 = math.max(ball.Size.X, ball.Size.Y, ball.Size.Z) * 1.04

	local part = Instance.new("Part")
	part.Name = "Burn" .. p
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(v11, v11, v11)
	part.CFrame = ball.CFrame
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = lavaBurn.EmberColour
	part.Transparency = 1
	part.Parent = ball.Parent

	local folder = data.Shadows[p]
	local transparenciesByDecal = {}

	if folder then
		for _, decal in folder:GetDescendants() do
			if decal:IsA("Decal") then
				transparenciesByDecal[decal] = decal.Transparency
			end
		end
	end

	local function restoreShadow() -- 2 equivalent calls inferred from this helper
		for k, transparency in transparenciesByDecal do
			k.Transparency = transparency
		end
	end

	task.spawn(function()
		local total = 0
		local v12 = false

		while total < v9 + v10 do
			total += RunService.PreRender:Wait()

			if ball.Parent and data.DropTokens[p] == v8 then
				part.CFrame = ball.CFrame

				if total < v9 then
					local v13 = total / v9
					local v14 = 1 - (1 - v13) * (1 - v13)

					part.Transparency = 1 - v14
					part.Color = lavaBurn.EmberColour:Lerp(lavaBurn.CharColour, v14)
				else
					if not v12 then
						part.Transparency = 0
						part.Color = lavaBurn.CharColour

						ball.Transparency = 1
						v12 = true

						for _, part2 in ball:GetChildren() do
							if part2:IsA("BasePart") then
								part2.Transparency = 1
							end
						end
					end

					local transparency = math.min((total - v9) / v10, 1)

					part.Transparency = transparency

					for k, v13 in transparenciesByDecal do
						k.Transparency = v13 + (1 - v13) * transparency
					end
				end
			else
				part:Destroy()
				restoreShadow() -- inferred equivalent call
				return
			end
		end

		part:Destroy()

		if data.DropTokens[p] == v8 then
			PoolTableRenderer3D.SetBallVisible(data, p, false)
		end

		restoreShadow() -- inferred equivalent call
	end)
end

function PoolTableRenderer3D.DropRemaining(p, p2: number)
	local v8 = p.DropUntil[p2]

	if v8 then
		return (math.max(v8 - os.clock(), 0))
	end

	return 0
end

function PoolTableRenderer3D.CreateLooseBall(parent, ballNumber: number, p: string?)
	local color2 = PoolConstants.BallColours[ballNumber] or PoolConstants.CueBallColour
	local ballBody = createBallBody(parent, p or "Ball" .. ballNumber, ballNumber, color2)
	ballBody:SetAttribute("BallNumber", ballNumber)

	return ballBody
end

function PoolTableRenderer3D.ToWorld(vector2: Vector2, p: number)
	return toWorld(vector2, p) -- inferred equivalent call
end

local v8 = { Field = 0, Trigger = 1, Goal = 2 }

local v9 = { Mud = Color3.fromRGB(92, 58, 30) }

local color2 = Color3.fromRGB(255, 255, 255)

local function buildBullseye(folder, vector3: Vector3, radius: number)
	for k, bullseyeRing in PoolModifiers.BullseyeRings do
		if k > 1 then
			local disc = makeDisc(
				folder,
				"Seam" .. bullseyeRing.Stars,
				radius * 2 * bullseyeRing.Fraction + math.max(radius * 0.05, 0.25),
				0.08,
				vector3 + Vector3.new(0, (k - 0.5) * 0.004, 0),
				color2
			)

			disc.CastShadow = false
		end

		local disc = makeDisc(
			folder,
			"Band" .. bullseyeRing.Stars,
			radius * 2 * bullseyeRing.Fraction,
			0.08,
			vector3 + Vector3.new(0, k * 0.004, 0),
			bullseyeRing.Colour
		)

		disc.Transparency = 0.05
		disc.CastShadow = false
	end
end

local function ghostModifier(folder)
	if folder:GetAttribute("Popped") then
		return
	end

	folder:SetAttribute("Popped", true)

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name == "Pad" then
			part.Transparency = 0.82
		else
			part:Destroy()
		end
	end
end

local function refreshShadowFloor(state)
	local y = toWorld(Vector2.zero, 0).Y -- inferred equivalent call
	local maxValue = 0

	for _, part in state.ModifierHolder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local _, _, _, _, _, _, v10, v11, v12 = part.CFrame:GetComponents()
		local size = part.Size
		local midpoint = (math.abs(v10) * size.X + math.abs(v11) * size.Y + math.abs(v12) * size.Z) / 2

		maxValue = math.max(maxValue, part.Position.Y + midpoint - y)
	end

	state.ShadowFloor = not (maxValue > 0) and 0 or maxValue + 0.02
	local v10 = shadowHeight(state) -- inferred equivalent call

	for _, shadow in state.Shadows do
		local position = shadow.Position
		shadow.CFrame = CFrame.new(position.X, toWorld(Vector2.zero, v10).Y, position.Z) -- inferred equivalent call
	end
end

local function stopModifierClock(state) -- 3 equivalent calls inferred from this helper
	if state.ModifierClock then
		state.ModifierClock:Disconnect()
		state.ModifierClock = nil
	end

	table.clear(state.ModifierAnimators)
end

function PoolTableRenderer3D.ClearModifiers(data)
	stopModifierClock(data) -- inferred equivalent call
	data.ModifierHolder:ClearAllChildren()
	table.clear(data.ModifierGroups)
	table.clear(data.ModifierBuilt)
	refreshShadowFloor(data)
end

function PoolTableRenderer3D.PopBubble(data, p: number)
	local modifierGroup = data.ModifierGroups[p]

	if not modifierGroup or modifierGroup:GetAttribute("Popped") then
		return
	end

	local pad = modifierGroup:FindFirstChild("Pad")

	if pad then
		local pop = pad:Clone()
		pop.Name = "Pop"
		pop.Transparency = 0.1
		pop.CastShadow = false
		pop.Parent = data.ModifierHolder

		TweenService:Create(pop, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = pop.Size * Vector3.new(2.5, 1, 2.5),
			Transparency = 1
		}):Play()

		task.delay(0.5, function()
			pop:Destroy()
		end)
	end

	ghostModifier(modifierGroup)

	local v10 = data.ModifierBuilt[modifierGroup]
	local animator = v10 and v10.Animator

	local index = animator and table.find(data.ModifierAnimators, animator)

	if index then
		table.remove(data.ModifierAnimators, index)
	end
end

function PoolTableRenderer3D:SetModifiers(options, p)
	stopModifierClock(self) -- inferred equivalent call
	local modifierBuilt = self.ModifierBuilt
	local v10 = {}

	for _, modifierGroup in self.ModifierGroups do
		local v11 = modifierBuilt[modifierGroup]

		if v11 then
			v10[v11.Key] = modifierGroup
		end
	end

	local v11 = {}

	for _, modifierGroup in self.ModifierGroups do
		v11[modifierGroup] = true
	end

	self.ModifierBuilt = {}
	table.clear(self.ModifierGroups)

	local v12 = {}

	for k, v13 in options or {} do
		local v14 = PoolModifiers.Get(v13.K)

		if not v14 then
			continue
		end

		local radius = PoolModifiers.RadiusOf(v14, v13.S)
		local v15 = v8[v14.Kind] or 1
		local v16 = (v12[v15] or 0) + 1
		v12[v15] = v16
		local v17

		if p == nil then
			v17 = false
		else
			v17 = p[k] == true
		end

		local v18 = string.format(
			"%d|%s|%.4f|%.4f|%s|%s|%d|%d",
			k,
			v14.Id,
			v13.X,
			v13.Y,
			tostring(v13.S),
			tostring(v13.R),
			v15,
			v16
		)

		local v19 = v10[v18]

		if v19 and (v19:GetAttribute("Popped") == true) == v17 then
			v10[v18] = nil
			v11[v19] = nil

			local v20 = modifierBuilt[v19]
			self.ModifierBuilt[v19] = v20
			self.ModifierGroups[k] = v19

			local reach = v19:FindFirstChild("Reach")

			if reach then
				reach:Destroy()
			end

			if v20.Animator and not v17 then
				table.insert(self.ModifierAnimators, v20.Animator)
			end
		else
			local v20 = 0.05 + v15 * 0.22 + v16 * 0.004
			local world = toWorld(Vector2.new(v13.X, v13.Y), v20) -- inferred equivalent call

			local folder = Instance.new("Folder")
			folder.Name = v14.Id .. k
			folder.Parent = self.ModifierHolder

			local disc = makeDisc(folder, "Pad", radius * 2, 0.08, world, v14.Colour)

			disc.Transparency = v14.Kind == "Field" and 0.42 or 0.1

			disc.CastShadow = false
			disc:SetAttribute("ModifierKind", v14.Id)

			if v14.Id == "Pocket" then
				disc.Transparency = 0
			end

			local animator = nil

			if v14.Id == "Bullseye" then
				disc.Transparency = 1
				buildBullseye(folder, world, radius)
			else
				animator = PoolModifierArt.Build(folder, v14.Id, disc, radius, v13)
			end

			self.ModifierGroups[k] = folder
			self.ModifierBuilt[folder] = { Key = v18, Animator = animator }

			if v17 then
				ghostModifier(folder)
			elseif animator then
				table.insert(self.ModifierAnimators, animator)
			end
		end
	end

	for k in v11 do
		k:Destroy()
	end

	for k, v13 in options or {} do
		local v14 = PoolModifiers.Get(v13.K)
		local modifierGroup = self.ModifierGroups[k]

		local color3 = v14 and v9[v14.Id]

		if not (v14 and v14.Kind == "Field" and modifierGroup and color3) then
			continue
		end

		local radius = PoolModifiers.RadiusOf(v14, v13.S)
		local vector2 = Vector2.new(v13.X, v13.Y)
		local flag3 = false

		for k2, v15 in options or {} do
			local v16 = PoolModifiers.Get(v15.K)

			if
				k2 ~= k
				and v16
				and v16.Kind ~= "Field"
				and radius + PoolModifiers.RadiusOf(v16, v15.S) > (Vector2.new(v15.X, v15.Y) - vector2).Magnitude
			then
				flag3 = true
				break
			end
		end

		if not flag3 then
			continue
		end

		local disc = makeDisc(
			modifierGroup,
			"Reach",
			radius * 2,
			0.008,
			toWorld(vector2, 0.6100000000000001 + k * 0.004 * 0.1), -- inferred equivalent call
			color3
		)

		disc.Transparency = 0.72
		disc.CastShadow = false
	end

	local modifierAnimators = self.ModifierAnimators

	if #modifierAnimators > 0 then
		local now = os.clock()

		for _, modifierAnimator in modifierAnimators do
			modifierAnimator(now)
		end

		if RunService:IsClient() and RunService:IsRunning() then
			self.ModifierClock = RunService.RenderStepped:Connect(function()
				local now2 = os.clock()

				for _, modifierAnimator in modifierAnimators do
					modifierAnimator(now2)
				end
			end)
		end
	end

	refreshShadowFloor(self)
end

function PoolTableRenderer3D.SetBallVisible(data, p: number, flag3: boolean)
	local ball = data.Balls[p]
	local shadow = data.Shadows[p]

	if flag3 then
		data.DropTokens[p] = (data.DropTokens[p] or 0) + 1

		data.DropUntil[p] = nil
	end

	if shadow then
		local parent

		if flag3 then
			parent = data.ShadowHolder
		end

		shadow.Parent = parent
	end

	if not ball then
		return
	end

	ball.Transparency = flag3 and 0 or 1

	for _, part in ball:GetChildren() do
		if part:IsA("BasePart") then
			part.Transparency = flag3 and 0 or 1
		end
	end
end

function PoolTableRenderer3D.RemoveBall(p, p2: number)
	local ball = p.Balls[p2]

	if ball then
		ball:Destroy()
		p.Balls[p2] = nil
	end

	local shadow = p.Shadows[p2]

	if shadow then
		shadow:Destroy()
		p.Shadows[p2] = nil
	end
end

function PoolTableRenderer3D.ClearBalls(data)
	for k, ball in data.Balls do
		ball:Destroy()
		data.Balls[k] = nil
	end

	for k, shadow in data.Shadows do
		shadow:Destroy()
		data.Shadows[k] = nil
	end

	table.clear(data.Skins)
end

local function fallbackModelName()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local skins = assets and assets:FindFirstChild("Skins")
	local cueSticks = skins and skins:FindFirstChild("CueSticks")

	local cueStick1 = cueSticks and cueSticks:FindFirstChild("CueStick1")

	if not (cueStick1 and cueStick1:IsA("ModuleScript")) then
		return nil
	end

	local success, result = pcall(require, cueStick1)

	if success and typeof(result) == "table" then
		return result.modelName
	end

	return nil
end

local function setStickPartVisible(part, cueStickVisible: boolean) -- 1 equivalent call inferred from this helper
	part.Transparency = cueStickVisible and (tonumber(part:GetAttribute("PoolBaseTransparency")) or 0) or 1
end

buildCueStick = function(state, p: string?, flag3: boolean?)
	local cueStick3D = PoolConstants.CueStick3D

	if not cueStick3D.UseModel then
		return
	end

	local child = ReplicatedStorage

	for _, childName in cueStick3D.FolderPath do
		child = child:FindFirstChild(childName)

		if not child then
			warn(string.format("[Pool] cue stick folder not found at %s", childName))
			return
		end
	end

	local children = child:GetChildren()

	local cueStickModel = p or PoolSkins.GetCueStickModelName()
	local model

	if cueStickModel then
		model = child:FindFirstChild(cueStickModel)
	end

	if cueStickModel and not model then
		warn(string.format("[Pool] cue stick model %q not found in %s", cueStickModel, child:GetFullName()))
	end

	if not (model and model:IsA("Model")) then
		model = child:FindFirstChild(cueStick3D.ModelName)
	end

	if not (model and model:IsA("Model")) then
		model = children[1]
	end

	if not (model and model:IsA("Model")) then
		warn(string.format("[Pool] cue stick model %q not found", (tostring(cueStick3D.ModelName))))
		return
	end

	print(string.format(
		"[Pool] cue stick  equipped=%s  drawn=%s  cue=%s",
		cueStickModel or "default",
		model.Name,
		(tostring(PoolSkins.GetCueName()))
	))

	local cueStick = model:Clone()
	cueStick.Name = "CueStick"

	if cueStick.PrimaryPart then
		for _, part in cueStick:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part:SetAttribute("PoolBaseTransparency", part.Transparency)

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
		end

		if not state.CueStickVisible then
			for _, part in cueStick:GetDescendants() do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end
		end

		cueStick.Parent = state.Root

		local boundingBox, v10 = cueStick:GetBoundingBox()

		state.CueStick = cueStick

		state.CueStickModel = cueStickModel

		state.CueStickLength = math.max(v10.X, v10.Y, v10.Z)

		state.CueStickPivotOffset = cueStick:GetPivot():PointToObjectSpace(boundingBox.Position)

		if v10.X < math.max(v10.Y, v10.Z) then
			warn(string.format(
				"[Pool] the PrimaryPart of %s (%s) is not square to the cue: in its frame the cue measures %.1f x %.1f x %.1f, so the long axis is not X. The stick will point off-angle until a part aligned with the shaft is used instead.",
				model.Name,
				cueStick.PrimaryPart.Name,
				v10.X,
				v10.Y,
				v10.Z
			))
		end
	else
		cueStick:Destroy()

		warn(string.format("PrimaryPart not found for %s", model.Name))

		if flag3 then
			warn(string.format(
				"[Pool] the fallback cue (%s) has no PrimaryPart either; no stick will be drawn",
				"CueStick1"
			))

			return
		end

		local v10 = fallbackModelName()

		if v10 then
			buildCueStick(state, v10, true)
		else
			warn(string.format("[Pool] could not read a fallback model from %s", "CueStick1"))
		end
	end
end

function PoolTableRenderer3D.SetCueStick(data, vector2: Vector2, vector2_2: Vector2, value: number)
	local cueStick = data.CueStick

	if not cueStick or not cueStick.PrimaryPart or vector2_2.Magnitude < 0.0001 then
		return
	end

	local cueStick3D = PoolConstants.CueStick3D
	local unit = vector2_2.Unit
	local v10 = cueStick3D.TipGap + cueStick3D.Pullback * math.clamp(value, 0, 1)

	local v11 = vector2 - unit * (PoolConstants.BallRadius + v10)
	local v12 = cueStick3D.Flip and 1 or -1
	local world = toWorld(v11 + unit * (v12 * data.CueStickLength / 2), 0 + cueStick3D.Height) -- inferred equivalent call
	local vector3 = Vector3.new(unit.X, 0, -unit.Y)

	cueStick:PivotTo(CFrame.fromMatrix(world, vector3 * v12, Vector3.new(0, 1, 0)) * CFrame.new(-data.CueStickPivotOffset))
end

function PoolTableRenderer3D.SetCueStickModel(p, p2: string?)
	local v10 = p2 or PoolSkins.GetCueStickModelName()

	if p.CueStick and v10 ~= nil and p.CueStickModel == v10 then
		return
	end

	local cueStick = p.CueStick

	buildCueStick(p, v10)

	if cueStick and p.CueStick ~= cueStick then
		cueStick:Destroy()
	end
end

function PoolTableRenderer3D:SetCueStickVisible(cueStickVisible: boolean)
	self.CueStickVisible = cueStickVisible

	local cueStick = self.CueStick

	if not cueStick then
		return
	end

	for _, part in cueStick:GetDescendants() do
		if part:IsA("BasePart") then
			setStickPartVisible(part, cueStickVisible) -- inferred equivalent call
		end
	end
end

function PoolTableRenderer3D.SetVisible(p, flag3: boolean)
	local root = p.Root
	local parent

	if flag3 then
		parent = workspace
	end

	root.Parent = parent
end

local function studRail(builtTable, vector2: Vector2, vector2_2: Vector2, trickshotTable, p: string)
	local v10 = math.max(1, (math.round((vector2_2 - vector2).Magnitude / trickshotTable.RivetSpacing)))
	local rivetDiameter = trickshotTable.RivetDiameter

	for i = 0, v10 - 1 do
		local lerped = vector2:Lerp(vector2_2, i / v10)

		local halfRivetDiameter = rivetDiameter / 2

		local part = makePart( -- inferred equivalent call
			builtTable,
			string.format("%s%d", p, i),
			Vector3.new(rivetDiameter, rivetDiameter, rivetDiameter),
			CFrame.new(toWorld(lerped, 2.5 + trickshotTable.RivetRise - halfRivetDiameter)), -- inferred equivalent call
			trickshotTable.RivetColour
		)

		part.Shape = Enum.PartType.Ball
		part.Material = trickshotTable.RivetMaterial
		part.Reflectance = 0.08
	end
end

local function buildSizedTable(root, data, customTable)
	local builtTable = Instance.new("Folder")
	builtTable.Name = "BuiltTable"

	local trickshotTable = PoolConstants.TrickshotTable
	local bareTable = PoolConstants.BareTable

	local halfWidth = customTable.HalfWidth
	local halfHeight = customTable.HalfHeight
	local v10 = customTable.FrameWidth
	local v11 = customTable.FrameHeight

	local v12 = halfWidth + PoolConstants.CushionDepth
	local v13 = halfHeight + PoolConstants.CushionDepth
	local v14 = v10 / 2 - PoolConstants.BezelDepth
	local v15 = v11 / 2 - PoolConstants.BezelDepth

	local v16 = math.max(v10, v11)
	local backdrop = buildBackdrop(builtTable, -30)

	backdrop.Size = Vector3.new(v16 * 6, 2, v16 * 6)

	if not bareTable then
		local part = makePart( -- inferred equivalent call
			builtTable,
			"Body",
			Vector3.new(v10, 6, v11),
			CFrame.new(Vector3.new(0, 4997, 0)),
			trickshotTable.EdgeColour
		)

		part.Material = trickshotTable.RimMaterial
	end

	if not bareTable then
		v10 = halfWidth * 2
	end

	if not bareTable then
		v11 = halfHeight * 2
	end

	local part = makePart( -- inferred equivalent call
		builtTable,
		"Cloth",
		Vector3.new(v10, 0.5, v11),
		CFrame.new(Vector3.new(0, 4999.77, 0)),
		data.Cloth
	)

	part.Material = trickshotTable.ClothMaterial

	local v17 = v15 - v13
	local midpoint = (v15 + v13) / 2
	local v18 = v14 - v12
	local midpoint2 = (v14 + v12) / 2

	for _, v19 in { 1, -1 } do
		if bareTable then
			break
		end

		local part2 = makePart( -- inferred equivalent call
			builtTable,
			v19 > 0 and "RailTop" or "RailBottom",
			Vector3.new(v14 * 2, 2.5, v17),
			CFrame.new(toWorld(Vector2.new(0, v19 * midpoint), 1.25)), -- inferred equivalent call
			trickshotTable.RimColour
		)

		part2.Material = trickshotTable.RimMaterial

		local part3 = makePart( -- inferred equivalent call
			builtTable,
			v19 > 0 and "RailFoot" or "RailHead",
			Vector3.new(v13 * 2, 2.5, v18),
			CFrame.new(toWorld(Vector2.new(v19 * midpoint2, 0), 1.25)) * CFrame.Angles(0, 1.5707963267948966, 0), -- inferred equivalent call
			trickshotTable.RimColour
		)

		part3.Material = trickshotTable.RimMaterial
	end

	for _, v19 in PoolGeometry.GetCushions(customTable) do
		local v20 = v19.B - v19.A
		local magnitude = v20.Magnitude
		local v21 = (v19.A + v19.B) / 2 - v19.Normal * (PoolConstants.CushionDepth / 2)
		local v22 = math.abs(v20.X) > math.abs(v20.Y)

		if not (customTable.Pocketed or v22) then
			magnitude += PoolConstants.CushionDepth * 2
		end

		local v23

		if v22 then
			v23 = Vector3.new(magnitude, 1.6, PoolConstants.CushionDepth)
		else
			v23 = Vector3.new(PoolConstants.CushionDepth, 1.6, magnitude)
		end

		local part2 = makePart(builtTable, "Cushion_" .. v19.Id, v23, CFrame.new(toWorld(v21, 0.8)), data.Cushion) -- inferred equivalent call

		part2.Material = trickshotTable.CushionMaterial
	end

	if bareTable or not trickshotTable.Rivets then
		if not bareTable then
			for k, v19 in PoolGeometry.GetDiamonds(customTable) do
				makeDisc(builtTable, "Diamond" .. k, 0.9, 0.12, toWorld(v19, 2.56), data.Diamond) -- inferred equivalent call
			end
		end
	else
		local v19 = {
			Vector2.new(-midpoint2, -midpoint),
			Vector2.new(midpoint2, -midpoint),
			Vector2.new(midpoint2, midpoint),
			Vector2.new(-midpoint2, midpoint)
		}

		studRail(builtTable, v19[1], v19[2], trickshotTable, "Rivet" .. 1 .. "_")
		studRail(builtTable, v19[2], v19[3], trickshotTable, "Rivet" .. 2 .. "_")
		studRail(builtTable, v19[3], v19[4], trickshotTable, "Rivet" .. 3 .. "_")
		studRail(builtTable, v19[4], v19[1], trickshotTable, "Rivet" .. 4 .. "_")
	end

	for _, v19 in PoolGeometry.GetPockets(customTable) do
		local v20 = v19.BowlRadius * 2

		makeDisc(builtTable, "Casing_" .. v19.Id, v20 + 1.4, 0.4, toWorld(v19.BowlCentre, 0.08), data.PocketCasing) -- inferred equivalent call
		makeDisc(builtTable, "Pocket_" .. v19.Id, v20, 5, toWorld(v19.BowlCentre, -2.38), data.Pocket) -- inferred equivalent call
	end

	builtTable.Parent = root

	for _, part2 in builtTable:GetDescendants() do
		if part2:IsA("BasePart") then
			part2.CastShadow = false
		end
	end

	return builtTable
end

function PoolTableRenderer3D:SetTable(customTable)
	if customTable == nil or customTable == PoolGeometry.Default then
		if self.BuiltTable then
			self.BuiltTable:Destroy()
			self.BuiltTable = nil
		end

		self.CustomTable = nil
		self.StockHolder.Parent = self.Root

		local pendingSkin = self.PendingSkin
		self.PendingSkin = nil

		if pendingSkin and pendingSkin ~= self.TableSkin then
			PoolTableRenderer3D.SetTableSkin(self, pendingSkin)
		end
	else
		if self.CustomTable == customTable and self.BuiltTable then
			return
		end

		if self.BuiltTable then
			self.BuiltTable:Destroy()
		end

		self.StockHolder.Parent = nil
		self.CustomTable = customTable
		self.BuiltTable = buildSizedTable(self.Root, self.Theme, customTable)
	end
end

function PoolTableRenderer3D:SetTheme(p)
	local theme = p or PoolConstants.GetTheme()

	if theme == self.Theme then
		return
	end

	self.Theme = theme

	local customTable = self.CustomTable

	if not customTable then
		return
	end

	if self.BuiltTable then
		self.BuiltTable:Destroy()
	end

	self.BuiltTable = buildSizedTable(self.Root, theme, customTable)
end

function PoolTableRenderer3D:Destroy()
	stopModifierClock(self) -- inferred equivalent call
	self.Balls = {}
	self.Shadows = {}
	self.Maid:DoCleaning()
end

return PoolTableRenderer3D