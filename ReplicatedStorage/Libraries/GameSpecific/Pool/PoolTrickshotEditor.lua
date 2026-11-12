local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Mouses = require(ReplicatedStorage.Libraries.Classes.Mouses)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolGeometry = require(Pool.PoolGeometry)
local PoolPhysics = require(Pool.PoolPhysics)
local PoolTableRenderer2D = require(Pool.PoolTableRenderer2D)
local PoolModifiers = require(Pool.PoolModifiers)
local PoolGoals = require(Pool.PoolGoals)
local PoolTrickshotTypes = require(Pool.PoolTrickshotTypes)
local PoolTrickshotStyle = require(Pool.PoolTrickshotStyle)
local PoolViewController = require(Pool.PoolViewController)

local PoolTrickshotEditor = {}

local color = Color3.fromRGB(120, 220, 255)
local color2 = Color3.fromRGB(255, 205, 80)
local color3 = Color3.fromRGB(255, 120, 120)

local function modifierIndexAt(state, dragFrom: Vector2)
	local mods = state.Scene.Mods or {}

	for i = #mods, 1, -1 do
		local mod = mods[i]
		local v = PoolModifiers.Get(mod.K)

		if v and PoolModifiers.RadiusOf(v, mod.S) >= (dragFrom - Vector2.new(mod.X, mod.Y)).Magnitude then
			return i
		end
	end

	return nil
end

local function modifierList(p) -- 2 equivalent calls inferred from this helper
	if not p.Scene.Mods then
		p.Scene.Mods = {}
	end

	return p.Scene.Mods
end

local function radiusOf(p) -- 7 equivalent calls inferred from this helper
	return PoolConstants.BallRadius * (p.S or 1)
end

local function tableOf(p) -- 2 equivalent calls inferred from this helper
	return PoolTrickshotTypes.TableOf(p.Scene)
end

local function applyTable(p) -- 4 equivalent calls inferred from this helper
	PoolViewController.SetTable(p.View, tableOf(p))
end

PoolTrickshotEditor.SnapSteps = { 0, 0.25, 0.5, 1, 2 }

local function snapSpacing(p) -- 4 equivalent calls inferred from this helper
	return p.SnapIncrement * PoolConstants.BallDiameter
end

local function snapValue(p: number, p2: number) -- 4 equivalent calls inferred from this helper
	if p2 > 0 then
		return math.round(p / p2) * p2
	end

	return p
end

local function snapPoint(p, vector2: Vector2) -- 5 equivalent calls inferred from this helper
	local v = snapSpacing(p) -- inferred equivalent call

	if v <= 0 then
		return vector2
	end

	return Vector2.new(snapValue(vector2.X, v), snapValue(vector2.Y, v)) -- inferred equivalent call
end

function PoolTrickshotEditor.GetSnapIncrement(p)
	return p.SnapIncrement
end

function PoolTrickshotEditor:SetSnapIncrement(snapIncrement: number)
	if table.find(PoolTrickshotEditor.SnapSteps, snapIncrement) then
		self.SnapIncrement = snapIncrement
	end
end

function PoolTrickshotEditor:CycleSnap()
	local snapSteps = PoolTrickshotEditor.SnapSteps
	self.SnapIncrement = snapSteps[(table.find(snapSteps, self.SnapIncrement) or 1) % #snapSteps + 1]

	return self.SnapIncrement
end

local function positionOf(p) -- 17 equivalent calls inferred from this helper
	return Vector2.new(p.X, p.Y)
end

local function ballAt(state, dragFrom: Vector2)
	local balls = state.Scene.Balls

	for i = #balls, 1, -1 do
		local ball = balls[i]

		if (positionOf(ball) - dragFrom).Magnitude <= radiusOf(ball) then -- inferred equivalent call
			return ball
		end
	end

	return nil
end

local function hasRoom(p, vector2: Vector2, p2: number, p3: number?): boolean
	for _, ball in p.Scene.Balls do
		if ball.I ~= p3 and (positionOf(ball) - vector2).Magnitude < p2 + radiusOf(ball) - 0.001 then -- inferred equivalent call
			return false
		end
	end

	return true
end

local function selectionCount(p) -- 2 equivalent calls inferred from this helper
	local count = 0

	for _ in p.Selection do
		count += 1
	end

	return count
end

local function ringFor(data, p: number)
	local ring = data.Rings[p]

	if ring then
		return ring
	end

	local clone = data.RingTemplate:Clone()
	clone.Name = "Ring" .. p
	clone.Visible = false
	clone.Parent = data.Layer
	data.Rings[p] = clone

	return clone
end

Color3.fromRGB(120, 235, 150)
Color3.fromRGB(210, 70, 70)

local function buildPocketMarkers(data)
	for _, v in PoolGeometry.GetPockets() do
		local clone = data.PocketTemplate:Clone()
		clone.Name = "Pocket" .. v.Id
		clone.Visible = false
		clone.Position = PoolTableRenderer2D.TableToScale(v.MouthCentre)
		clone.Size = PoolTableRenderer2D.InchesToSize(v.Mouth, v.Mouth)
		clone.Parent = data.Layer

		data.Pockets[v.Id] = clone
	end
end

local function pocketAt(vector2: Vector2)
	for _, v in PoolGeometry.GetPockets() do
		if (v.MouthCentre - vector2).Magnitude <= v.Mouth then
			return v.Id
		end
	end

	return nil
end

local function renderPockets(state) -- 1 equivalent call inferred from this helper
	for _, pocket in state.Pockets do
		pocket.Visible = false
	end
end

local function renderModifierSelection(data)
	local mods = data.Scene.Mods or {}

	local v = data.Mode == "Edit"

	for k, modRing in data.ModRings do
		if mods[k] then
			continue
		end

		modRing:Destroy()
		data.ModRings[k] = nil
	end

	for k, mod in mods do
		local visible = v and data.ModSelection[k] == true
		local v2 = data.ModRings[k]

		if visible and not v2 then
			v2 = data.RingTemplate:Clone()
			v2.Name = "ModRing" .. k
			v2.Parent = data.Layer
			data.ModRings[k] = v2
		end

		if not v2 then
			continue
		end

		v2.Visible = visible

		if not visible then
			continue
		end

		local v3 = PoolModifiers.Get(mod.K)
		local v4 = (not v3 and 6 or PoolModifiers.RadiusOf(v3, mod.S)) * 2 * 1.15

		v2.Position = PoolTableRenderer2D.TableToScale(Vector2.new(mod.X, mod.Y))
		v2.Size = PoolTableRenderer2D.InchesToSize(v4, v4)

		local edge = v2:FindFirstChild("Edge")
		edge.Color = color
		edge.Thickness = data.RingThickness * 2
		edge.Transparency = 0.5

		local pip = v2:FindFirstChild("Pip")
		pip.Visible = false
	end
end

local function soleMovingBall(p) -- 2 equivalent calls inferred from this helper
	local selected = PoolTrickshotEditor.GetSelected(p)

	if #selected ~= 1 then
		return nil
	end

	local v = selected[1]

	return if v.RX and v.RY then v else nil
end

local function renderPatrolHandle(state)
	local v = soleMovingBall(state) -- inferred equivalent call

	if v then
		local v2 = positionOf(v) -- inferred equivalent call
		local vector2 = Vector2.new(v.RX, v.RY)
		local v3 = vector2 - v2
		local v4 = PoolConstants.BallDiameter * (v.S or 1)

		if not state.PatrolLine then
			local patrolLine = Instance.new("Frame")
			patrolLine.Name = "PatrolLine"
			patrolLine.AnchorPoint = Vector2.new(0.5, 0.5)
			patrolLine.BackgroundColor3 = color
			patrolLine.BackgroundTransparency = 0.35
			patrolLine.BorderSizePixel = 0
			patrolLine.ZIndex = state.Layer.ZIndex + 1
			patrolLine.Parent = state.Layer
			state.PatrolLine = patrolLine
		end

		if not state.PatrolGhost then
			local patrolGhost = Instance.new("Frame")
			patrolGhost.Name = "PatrolGhost"
			patrolGhost.AnchorPoint = Vector2.new(0.5, 0.5)
			patrolGhost.BackgroundColor3 = PoolConstants.BallColours[PoolTrickshotTypes.MovingBallNumber]
				or Color3.fromRGB(240, 140, 60)

			patrolGhost.BackgroundTransparency = 0.45
			patrolGhost.BorderSizePixel = 0
			patrolGhost.ZIndex = state.Layer.ZIndex + 2
			patrolGhost.Parent = state.Layer

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(1, 0)
			uiCorner.Parent = patrolGhost

			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 2
			uiStroke.Color = color
			uiStroke.Transparency = 0.2
			uiStroke.Parent = patrolGhost

			state.PatrolGhost = patrolGhost
		end

		local patrolLine = state.PatrolLine
		local patrolGhost = state.PatrolGhost

		patrolLine.Visible = true
		patrolLine.Position = PoolTableRenderer2D.TableToScale(v2 + v3 * 0.5)

		patrolLine.Size = PoolTableRenderer2D.InchesToSize(v3.Magnitude, 0.9)

		patrolLine.Rotation = -math.deg((math.atan2(v3.Y, v3.X)))

		patrolGhost.Visible = true
		patrolGhost.Position = PoolTableRenderer2D.TableToScale(vector2)
		patrolGhost.Size = PoolTableRenderer2D.InchesToSize(v4, v4)
	else
		if state.PatrolGhost then
			state.PatrolGhost.Visible = false
		end

		if state.PatrolLine then
			state.PatrolLine.Visible = false
		end
	end
end

local function renderCueOrder(data)
	local cueBalls = PoolTrickshotTypes.CueBalls(data.Scene)
	local set = {}
	local v

	if data.Mode == "Edit" then
		v = #cueBalls > 1
	else
		v = false
	end

	if v then
		for k, cueBall in cueBalls do
			set[cueBall.I] = true

			local parent = data.CueLabels[cueBall.I]

			if not parent then
				parent = Instance.new("TextLabel")
				parent.Name = "CueOrder" .. cueBall.I
				parent.AnchorPoint = Vector2.new(0.5, 0.5)
				parent.BackgroundTransparency = 1
				parent.FontFace = Font.new("rbxasset://fonts/families/Teko.json", Enum.FontWeight.Bold)
				parent.TextScaled = true
				parent.TextColor3 = Color3.fromRGB(28, 34, 44)

				parent.ZIndex = data.Layer.ZIndex + 3
				parent.Parent = data.Layer

				local uiStroke = Instance.new("UIStroke")
				uiStroke.Thickness = 2
				uiStroke.Color = Color3.fromRGB(255, 255, 255)
				uiStroke.Transparency = 0.15
				uiStroke.Parent = parent

				data.CueLabels[cueBall.I] = parent
			end

			local v2 = PoolConstants.BallDiameter * (cueBall.S or 1)

			parent.Visible = true
			parent.Text = tostring(k)
			parent.Position = PoolTableRenderer2D.TableToScale(positionOf(cueBall))
			parent.Size = PoolTableRenderer2D.InchesToSize(v2 * 0.8, v2 * 0.8)
		end
	end

	for k, cueLabel in data.CueLabels do
		if set[k] then
			continue
		end

		cueLabel:Destroy()
		data.CueLabels[k] = nil
	end
end

function PoolTrickshotEditor:Render()
	local set = {}

	for _, ball in self.Scene.Balls do
		set[ball.I] = true

		PoolViewController.SetBallSkin(self.View, ball.I, PoolTrickshotTypes.SkinForBall(ball))
		PoolViewController.SetBall(self.View, ball.I, positionOf(ball))
		PoolViewController.SetBallScale(self.View, ball.I, ball.S or 1)

		local i = ball.I
		local v = self.Rings[i]

		if not v then
			v = self.RingTemplate:Clone()
			v.Name = "Ring" .. i
			v.Visible = false
			v.Parent = self.Layer
			self.Rings[i] = v
		end

		local v2 = self.Selection[ball.I] == true
		local v3 = radiusOf(ball) * 2 -- inferred equivalent call

		v.Position = PoolTableRenderer2D.TableToScale(positionOf(ball))
		v.Size = PoolTableRenderer2D.InchesToSize(v3 * 1.35, v3 * 1.35)
		local visible

		if v2 then
			visible = v2
		elseif ball.A == true and self.Mode == "Edit" then
			visible = not self.Locked
		else
			visible = false
		end

		v.Visible = visible

		local edge = v:FindFirstChild("Edge")
		local color4

		if v2 then
			color4 = color
		else
			color4 = if ball.A then color3 else color2
		end

		edge.Color = color4
		local thickness

		if v2 then
			thickness = self.RingThickness * 2
		else
			thickness = self.RingThickness
		end

		edge.Thickness = thickness

		edge.Transparency = v2 and 0.5 or 0

		local pip = v:FindFirstChild("Pip")

		pip.Visible = false
	end

	for k in self.Drawn do
		if set[k] then
			continue
		end

		PoolViewController.RemoveBall(self.View, k)

		local ring = self.Rings[k]

		if not ring then
			continue
		end

		ring:Destroy()
		self.Rings[k] = nil
	end

	self.Drawn = set

	PoolViewController.SetModifiers(self.View, self.Scene.Mods, self.Simulation.Popped)
	renderModifierSelection(self)
	renderPatrolHandle(self)
	renderCueOrder(self)
	renderPockets(self) -- inferred equivalent call
end

local function copyList(list)
	if not list then
		return nil
	end

	local clones = table.create(#list)

	for k, item in list do
		clones[k] = table.clone(item)
	end

	return clones
end

local function field(p) -- 18 equivalent calls inferred from this helper
	if p == nil then
		return "-"
	end

	return (tostring(p))
end

local function takeSnapshot(state)
	local scene = state.Scene
	local v = field(scene.TL) -- inferred equivalent call
	local v2 = { v, field(scene.TH) } -- inferred equivalent call

	for _, ball in scene.Balls do
		local v3 = field(ball.I) -- inferred equivalent call
		local v4 = field(ball.N) -- inferred equivalent call
		local v5 = field(ball.X) -- inferred equivalent call
		local v6 = field(ball.Y) -- inferred equivalent call
		local v7 = field(ball.S) -- inferred equivalent call
		local v8 = field(ball.A) -- inferred equivalent call
		local v9 = field(ball.RX) -- inferred equivalent call
		local v10 = field(ball.RY) -- inferred equivalent call
		local v11 = field(ball.RS) -- inferred equivalent call
		local o = ball.O
		table.insert(v2, table.concat({
			v3,
			v4,
			v5,
			v6,
			v7,
			v8,
			v9,
			v10,
			v11,
			field(o) -- inferred equivalent call
		}, ","))
	end

	table.insert(v2, "|")

	for _, v3 in scene.Mods or {} do
		local v4 = field(v3.K) -- inferred equivalent call
		local v5 = field(v3.X) -- inferred equivalent call
		local v6 = field(v3.Y) -- inferred equivalent call
		local v7 = field(v3.S) -- inferred equivalent call
		local v8 = field(v3.R) -- inferred equivalent call
		local p = v3.P
		table.insert(v2, table.concat({ v4, v5, v6, v7, v8, field(p) }, ",")) -- inferred equivalent call
	end

	return {
		Key = table.concat(v2, ";"),
		Balls = copyList(scene.Balls),
		Mods = copyList(scene.Mods),
		TL = scene.TL,
		TH = scene.TH
	}
end

local function historyChanged(state) -- 5 equivalent calls inferred from this helper
	local historyEvent = state.historyEvent

	if historyEvent then
		historyEvent:Fire()
	end
end

local function commitHistory(state)
	state.HistoryPendingAt = nil

	if not state.HistoryCommitted then
		return
	end

	local historyCommitted = takeSnapshot(state)

	if historyCommitted.Key ~= state.HistoryCommitted.Key then
		table.insert(state.HistoryUndo, state.HistoryCommitted)

		if #state.HistoryUndo > 100 then
			table.remove(state.HistoryUndo, 1)
		end

		state.HistoryCommitted = historyCommitted

		table.clear(state.HistoryRedo)
	end

	historyChanged(state) -- inferred equivalent call
end

local function flushHistory(p) -- 4 equivalent calls inferred from this helper
	if p.HistoryPendingAt then
		commitHistory(p)
	end
end

local function resetHistory(state) -- 2 equivalent calls inferred from this helper
	table.clear(state.HistoryUndo)
	table.clear(state.HistoryRedo)
	state.HistoryPendingAt = nil
	state.HistoryCommitted = takeSnapshot(state)
	historyChanged(state) -- inferred equivalent call
end

local function changed(state)
	PoolTrickshotEditor.Render(state)

	if state.HistoryContinuous > 0 then
		state.HistoryPendingAt = os.clock()
		historyChanged(state) -- inferred equivalent call
	else
		commitHistory(state)
	end

	state.sceneEvent:Fire()
end

local function selectionChanged(p) -- 4 equivalent calls inferred from this helper
	PoolTrickshotEditor.Render(p)
	p.selectionEvent:Fire()
end

local function say(p, p2: string) -- 23 equivalent calls inferred from this helper
	p.messageEvent:Fire(p2)
end

local function ballName(p: number, flag: boolean?) -- 2 equivalent calls inferred from this helper
	if p == PoolConstants.CueBallNumber then
		return "Cue Ball"
	end

	if flag then
		return p .. " Ball"
	end

	if p == PoolTrickshotTypes.MovingBallNumber then
		return "Moving Ball"
	end

	if p == PoolTrickshotTypes.SpinnerHubNumber then
		return "Spinner"
	end

	if p == PoolTrickshotTypes.GoldenBallNumber then
		return "Golden Ball"
	end

	return p .. " Ball"
end

local function describeSelection(data)
	local selected = PoolTrickshotEditor.GetSelected(data)
	local selectedModifiers = PoolTrickshotEditor.GetSelectedModifiers(data)
	local v = #selected + #selectedModifiers

	if v == 0 then
		return nil
	end

	if #selectedModifiers == 0 and #selected > 0 then
		local g = nil
		local v2 = true

		for _, v3 in selected do
			if v3.G and (not g or v3.G == g) then
				g = v3.G
			else
				v2 = false
				break
			end
		end

		if v2 and g then
			for _, v3 in selected do
				if v3.W then
					return string.format("Spinner -- %d long, %d wide, %d°/s", v3.L or 1, v3.D or 1, v3.W)
				end
			end
		end
	end

	if v > 1 then
		return v .. " selected"
	end

	if #selected == 1 then
		local v2 = selected[1]
		local v3 = ballName(v2.N, v2.O) -- inferred equivalent call

		if v2.RX and v2.RY then
			if v2.N == PoolTrickshotTypes.MovingBallNumber then
				return v3 .. " -- drag the far marker"
			end

			return v3 .. " (moving -- drag the far marker)"
		elseif v2.G then
			if v2.W then
				return string.format("Spinner -- %d long, %d wide, %d°/s", v2.L or 1, v2.D or 1, v2.W)
			end

			return "Spinner blade"
		else
			if v2.A then
				return v3 .. " (anchored)"
			end

			if v2.N == PoolTrickshotTypes.GoldenBallNumber then
				return v3 .. " -- pocket this one"
			end

			return v3
		end
	else
		local v2 = (data.Scene.Mods or {})[selectedModifiers[1]]
		local v3

		if v2 then
			v3 = PoolModifiers.Get(v2.K)
		end

		return if v3 then v3.Name else nil
	end
end

function PoolTrickshotEditor.GetHint(data)
	if data.Mode ~= "Edit" then
		return nil
	end

	if data.CameraMode then
		local lastInputType = UserInputService:GetLastInputType()

		if lastInputType.Name:sub(1, 7) == "Gamepad" then
			return "Look around with a stick or hold A • RT / LT to zoom"
		end

		if lastInputType == Enum.UserInputType.Touch then
			return "Drag to look around • pinch to zoom"
		end

		return "Drag to look around • scroll or +/- to zoom"
	else
		local v = describeSelection(data)

		if v then
			return v
		end

		if #PoolTrickshotTypes.CueBalls(data.Scene) == 0 then
			return "Tap to pick a spot for the cue ball"
		end

		local v2 = data.ModifierPalette and PoolModifiers.Get(data.ModifierPalette)

		if v2 then
			return "Tap to place: " .. v2.Name
		end

		local v3 = ballName(data.Palette, data.PaletteOrdinary) -- inferred equivalent call

		if data.Palette ~= PoolConstants.CueBallNumber then
			return "Tap to place: " .. v3
		end

		local count = #PoolTrickshotTypes.CueBalls(data.Scene)

		if PoolTrickshotTypes.MaxCueBalls <= count then
			return string.format("%d cue balls -- that is the limit", count)
		end

		return string.format("Tap to place: %s (%d of %d shots)", v3, count, PoolTrickshotTypes.MaxCueBalls)
	end
end

function PoolTrickshotEditor:SetPalette(palette: number, flag: boolean?)
	self.Palette = palette

	self.PaletteOrdinary = flag == true

	self.ModifierPalette = nil

	self.sceneEvent:Fire()
end

function PoolTrickshotEditor:SetModifierPalette(modifierPalette: string?)
	if modifierPalette ~= nil and not PoolModifiers.IsPlaceable(modifierPalette) then
		return
	end

	self.ModifierPalette = modifierPalette
	self.sceneEvent:Fire()
end

function PoolTrickshotEditor.SetSelection(data, items)
	table.clear(data.Selection)

	table.clear(data.ModSelection)

	for _, item in items do
		data.Selection[item] = true
	end

	local gSet = {}

	for _, ball in data.Scene.Balls do
		if ball.G and data.Selection[ball.I] then
			gSet[ball.G] = true
		end
	end

	if next(gSet) then
		for _, ball in data.Scene.Balls do
			if ball.G and gSet[ball.G] then
				data.Selection[ball.I] = true
			end
		end
	end

	selectionChanged(data) -- inferred equivalent call
end

function PoolTrickshotEditor.SetModifierSelection(p, items)
	table.clear(p.Selection)
	table.clear(p.ModSelection)

	for _, item in items do
		p.ModSelection[item] = true
	end

	selectionChanged(p) -- inferred equivalent call
end

function PoolTrickshotEditor.GetSelectedModifiers(p)
	local selectedModifiers = {}

	for k in p.Scene.Mods or {} do
		if p.ModSelection[k] then
			table.insert(selectedModifiers, k)
		end
	end

	table.sort(selectedModifiers)

	return selectedModifiers
end

function PoolTrickshotEditor.GetSelected(p)
	local balls = {}

	for _, ball in p.Scene.Balls do
		if p.Selection[ball.I] then
			table.insert(balls, ball)
		end
	end

	return balls
end

local function placeGoldenBall(p, vector2: Vector2, p2: number): boolean
	if #p.Scene.Balls >= PoolTrickshotTypes.MaxBalls then
		say(p, string.format("Scene is full (%d balls) -- no room for a golden ball", PoolTrickshotTypes.MaxBalls)) -- inferred equivalent call

		return false
	else
		local v = tableOf(p) -- inferred equivalent call
		local ballRadius = PoolConstants.BallRadius
		local v2 = p2 + ballRadius + 3
		local v3 = -vector2
		local v4 = not (v3.Magnitude > 0.001) and 3.141592653589793 or math.atan2(v3.Y, v3.X)

		for i = 0, 11 do
			local v5 = v4 + math.ceil(i / 2) * (i % 2 == 0 and 1 or -1) * 3.141592653589793 / 6
			local clampPosition = PoolTrickshotTypes.ClampPosition(
				vector2 + Vector2.new(math.cos(v5), (math.sin(v5))) * v2,
				1,
				v
			)

			local magnitude = (clampPosition - vector2).Magnitude

			if p2 + ballRadius < magnitude and hasRoom(p, clampPosition, ballRadius) then
				table.insert(p.Scene.Balls, {
					I = PoolTrickshotTypes.NextId(p.Scene),
					N = PoolTrickshotTypes.GoldenBallNumber,
					X = clampPosition.X,
					Y = clampPosition.Y
				})

				return true
			end
		end

		say(p, "No room beside that pocket for its golden ball") -- inferred equivalent call
		return false
	end
end

local function placeModifier(data, modifierPalette: string, vector2: Vector2)
	local v = modifierList(data) -- inferred equivalent call

	if #v >= PoolModifiers.MaxModifiers then
		say(data, string.format("Scene is full (%d modifiers)", PoolModifiers.MaxModifiers)) -- inferred equivalent call
	else
		local v2 = PoolModifiers.Get(modifierPalette)

		if not v2 then
			return
		end

		local clampModifierPosition = PoolTrickshotTypes.ClampModifierPosition
		vector2 = snapPoint(data, vector2) -- inferred equivalent call
		local v3 = clampModifierPosition(vector2, tableOf(data))

		table.insert(v, {
			K = v2.Id,
			X = v3.X,
			Y = v3.Y,
			R = v2.Rotatable and 0 or nil
		})

		if v2.Id == "Pocket" then
			placeGoldenBall(data, v3, PoolModifiers.RadiusOf(v2, 1))
		end

		changed(data)
	end
end

local function seedPatrol(data, vector2: Vector2)
	local v = tableOf(data) -- inferred equivalent call
	local clampPosition = PoolTrickshotTypes.ClampPosition(vector2 + Vector2.new(18, 0), 0, v)

	if (clampPosition - vector2).Magnitude >= PoolModifiers.MinPatrolDistance then
		return clampPosition
	end

	return PoolTrickshotTypes.ClampPosition(vector2 - Vector2.new(18, 0), 0, v)
end

local function rebuildSpinners(p)
	local balls = p.Scene.Balls

	for i = #balls, 1, -1 do
		local ball = balls[i]

		if not ball.G or ball.W then
			continue
		end

		table.remove(balls, i)

		p.Selection[ball.I] = nil
	end

	local balls2 = {}

	for _, ball in balls do
		if ball.G and ball.W then
			table.insert(balls2, ball)
		end
	end

	for _, v in balls2 do
		local v2 = p.Selection[v.I] == true

		for _, v3 in PoolTrickshotTypes.SpinnerOffsets(v.L or 1, v.D or 1, v.S) do
			if #balls >= PoolTrickshotTypes.MaxBalls then
				break
			end

			local v4 = {
				I = PoolTrickshotTypes.NextId(p.Scene),
				N = PoolTrickshotTypes.MovingBallNumber,
				X = math.round((v.X + v3.X) * 100) / 100,
				Y = math.round((v.Y + v3.Y) * 100) / 100,
				S = v.S,
				G = v.G
			}

			table.insert(balls, v4)

			if v2 then
				p.Selection[v4.I] = true
			end
		end
	end
end

local function nextSpinnerGroup(p)
	local gSet = {}
	local maxG = 0

	for _, ball in p.Scene.Balls do
		if not ball.G then
			continue
		end

		gSet[ball.G] = true
		maxG = math.max(maxG, ball.G)
	end

	local count = 0

	for _ in gSet do
		count += 1
	end

	if PoolModifiers.MaxSpinners <= count or maxG + 1 > PoolModifiers.MaxSpinners then
		return nil
	end

	return maxG + 1
end

local function placeSpinner(data, vector2: Vector2)
	local v = nextSpinnerGroup(data)

	if v then
		local defaultSpinnerLength = PoolModifiers.DefaultSpinnerLength
		local defaultSpinnerWidth = PoolModifiers.DefaultSpinnerWidth
		local clampPosition = PoolTrickshotTypes.ClampPosition
		vector2 = snapPoint(data, vector2) -- inferred equivalent call
		local v2 = clampPosition(vector2, 1, tableOf(data))

		if not hasRoom(data, v2, PoolConstants.BallRadius) then
			say(data, "No room there") -- inferred equivalent call
			return
		end

		table.insert(data.Scene.Balls, {
			I = PoolTrickshotTypes.NextId(data.Scene),
			N = PoolTrickshotTypes.SpinnerHubNumber,
			X = v2.X,
			Y = v2.Y,
			A = true,
			G = v,
			W = PoolModifiers.DefaultSpinSpeed,
			L = defaultSpinnerLength,
			D = defaultSpinnerWidth
		})

		rebuildSpinners(data)
		changed(data)
	else
		say(data, string.format("Scene is full (%d spinners)", PoolModifiers.MaxSpinners)) -- inferred equivalent call
	end
end

function PoolTrickshotEditor.Place(data, vector2: Vector2)
	if data.ModifierPalette then
		placeModifier(data, data.ModifierPalette, vector2)

		return nil
	end

	if #data.Scene.Balls >= PoolTrickshotTypes.MaxBalls then
		say(data, string.format("Scene is full (%d balls)", PoolTrickshotTypes.MaxBalls)) -- inferred equivalent call

		return nil
	else
		local palette = data.Palette
		local v = palette == PoolConstants.CueBallNumber

		local paletteOrdinary = data.PaletteOrdinary == true

		if palette == PoolTrickshotTypes.SpinnerHubNumber and not paletteOrdinary then
			placeSpinner(data, vector2)

			return nil
		end

		if v and #PoolTrickshotTypes.CueBalls(data.Scene) >= PoolTrickshotTypes.MaxCueBalls then
			say(data, string.format("%d cue balls is the limit", PoolTrickshotTypes.MaxCueBalls)) -- inferred equivalent call

			return nil
		else
			local clampPosition = PoolTrickshotTypes.ClampPosition
			vector2 = snapPoint(data, vector2) -- inferred equivalent call
			local v2 = clampPosition(vector2, 1, tableOf(data))

			if not hasRoom(data, v2, PoolConstants.BallRadius) then
				say(data, "No room there") -- inferred equivalent call
				return nil
			end

			local v4

			if v and #PoolTrickshotTypes.CueBalls(data.Scene) == 0 then
				v4 = PoolTrickshotTypes.CueId
			else
				v4 = PoolTrickshotTypes.NextId(data.Scene)
			end

			local v3 = {
				I = v4,
				N = palette,
				X = v2.X,
				Y = v2.Y,
				A = v and not paletteOrdinary and true or nil,
				O = paletteOrdinary and true or nil
			}

			if palette == PoolTrickshotTypes.MovingBallNumber and not paletteOrdinary then
				local v5 = seedPatrol(data, v2)

				local x = v5.X
				local y = v5.Y
				v3.RX = x
				v3.RY = y
				v3.RS = PoolModifiers.DefaultPatrolSpeed
			end

			table.insert(data.Scene.Balls, v3)
			changed(data)

			return v3
		end
	end
end

function PoolTrickshotEditor.Delete(data)
	local balls = data.Scene.Balls

	local gSet = {}

	for _, ball in balls do
		if data.Selection[ball.I] and ball.G and ball.W then
			gSet[ball.G] = true
		end
	end

	for i = #balls, 1, -1 do
		local ball = balls[i]

		if data.Selection[ball.I] or ball.G and gSet[ball.G] then
			table.remove(balls, i)
		end
	end

	local mods = data.Scene.Mods

	if mods then
		for i = #mods, 1, -1 do
			if data.ModSelection[i] then
				table.remove(mods, i)
			end
		end
	end

	table.clear(data.Selection)
	table.clear(data.ModSelection)

	for k, modRing in data.ModRings do
		modRing:Destroy()
		data.ModRings[k] = nil
	end

	selectionChanged(data) -- inferred equivalent call
	changed(data)
end

function PoolTrickshotEditor.Clone(p)
	local selectedModifierEntries = PoolTrickshotEditor.GetSelectedModifierEntries(p)

	if #selectedModifierEntries > 0 then
		local v = modifierList(p) -- inferred equivalent call
		local v2 = PoolModifiers.MaxModifiers - #v
		local v3 = {}

		for _, selectedModifierEntry in selectedModifierEntries do
			if v2 <= #v3 then
				say(p, string.format("Scene is full (%d modifiers)", PoolModifiers.MaxModifiers)) -- inferred equivalent call
				break
			else
				local v4 = PoolModifiers.Get(selectedModifierEntry.K)
				local v5 = not v4 and 4 or PoolModifiers.RadiusOf(v4, selectedModifierEntry.S) * 0.5

				local clampModifierPosition = PoolTrickshotTypes.ClampModifierPosition(
					Vector2.new(selectedModifierEntry.X + v5, selectedModifierEntry.Y + v5),
					tableOf(p)
				)

				table.insert(v, {
					K = selectedModifierEntry.K,
					X = clampModifierPosition.X,
					Y = clampModifierPosition.Y,
					S = selectedModifierEntry.S,
					R = selectedModifierEntry.R,
					P = selectedModifierEntry.P
				})

				table.insert(v3, #v)
			end
		end

		if #v3 == 0 then
			return
		end

		PoolTrickshotEditor.SetModifierSelection(p, v3)
		changed(p)
	else
		local selected = PoolTrickshotEditor.GetSelected(p)
		local v = PoolTrickshotTypes.MaxBalls - #p.Scene.Balls
		local v2 = {}
		local flag = false
		local flag2 = false

		for _, v3 in selected do
			if v3.N == PoolTrickshotTypes.GoldenBallNumber then
				flag = true
			elseif v3.G then
				flag2 = true
			elseif v3.N ~= PoolConstants.CueBallNumber then
				if v <= #v2 then
					say(p, string.format("Scene is full (%d balls)", PoolTrickshotTypes.MaxBalls)) -- inferred equivalent call
					break
				else
					local v4 = {
						I = PoolTrickshotTypes.NextId(p.Scene),
						N = v3.N,
						X = v3.X,
						Y = v3.Y,
						S = v3.S,
						A = v3.A,
						RX = v3.RX,
						RY = v3.RY,
						RS = v3.RS,
						O = v3.O
					}

					table.insert(p.Scene.Balls, v4)
					table.insert(v2, v4.I)
				end
			end
		end

		if flag then
			say(p, "Golden balls come with a pocket -- place a pocket for another") -- inferred equivalent call
		end

		if flag2 then
			say(p, "Spinners are placed whole -- tap to place another") -- inferred equivalent call
		end

		if #v2 == 0 then
			return
		end

		PoolTrickshotEditor.SetSelection(p, v2)
		changed(p)
	end
end

function PoolTrickshotEditor.SetAnchored(p, flag: boolean)
	for _, v in PoolTrickshotEditor.GetSelected(p) do
		if v.G ~= nil then
			continue
		end

		local v2 = v.N == PoolConstants.CueBallNumber
		local v3

		if flag then
			v3 = true
		elseif v2 and not v.O then
			v3 = false
		end

		v.A = v3

		if not (flag and v.RX) then
			continue
		end

		v.RX = nil
		v.RY = nil
		v.RS = nil
	end

	changed(p)
end

function PoolTrickshotEditor.GetSelectedModifierEntries(p)
	local mods = p.Scene.Mods or {}
	local selectedModifierEntries = {}

	for _, v in PoolTrickshotEditor.GetSelectedModifiers(p) do
		if mods[v] then
			table.insert(selectedModifierEntries, mods[v])
		end
	end

	return selectedModifierEntries
end

function PoolTrickshotEditor.SetPatrolSpeed(p, value: number)
	local rs = math.clamp(value, PoolModifiers.MinPatrolSpeed, PoolModifiers.MaxPatrolSpeed)
	local flag = false

	for _, v in PoolTrickshotEditor.GetSelected(p) do
		if not (v.RX and v.RY) then
			continue
		end

		v.RS = rs
		flag = true
	end

	if flag then
		changed(p)
	end
end

function PoolTrickshotEditor.SetSpinnerArms(p, p2: number?, p3: number?)
	local gSet = {}
	local balls = {}

	for _, v in PoolTrickshotEditor.GetSelected(p) do
		if v.G then
			gSet[v.G] = true
		end
	end

	for _, ball in p.Scene.Balls do
		if ball.G and ball.W and gSet[ball.G] then
			table.insert(balls, ball)
		end
	end

	if #balls == 0 then
		return
	end

	local v = {}

	for _, ball in p.Scene.Balls do
		if ball.G and ball.W and gSet[ball.G] then
			v[ball] = {
				PoolTrickshotTypes.CleanSpinnerArm(p2 or ball.L or 1, ball.L or 1),
				PoolTrickshotTypes.CleanSpinnerArm(p3 or ball.D or 1, ball.D or 1)
			}
		end
	end

	local v2 = false

	for k, v3 in v do
		if not (k.L ~= v3[1] or k.D ~= v3[2]) then
			continue
		end

		local v4 = v3[1]
		local v5 = v3[2]
		k.L = v4
		k.D = v5
		v2 = true
	end

	if not v2 then
		return
	end

	rebuildSpinners(p)
	changed(p)
end

function PoolTrickshotEditor.GetSpinnerArms(p)
	local selected = PoolTrickshotEditor.GetSelected(p)

	if #selected == 0 then
		return nil, nil
	end

	local v = nil

	for _, v2 in selected do
		if not v2.G then
			return nil, nil
		end

		v = v or v2.G
	end

	for _, ball in p.Scene.Balls do
		if ball.G == v and ball.W then
			return ball.L or 1, ball.D or 1
		end
	end

	return nil, nil
end

function PoolTrickshotEditor.SetSpinSpeed(p, value: number)
	local v = math.round((math.clamp(value, PoolModifiers.MinSpinSpeed, PoolModifiers.MaxSpinSpeed)))
	local gSet = {}

	for _, v2 in PoolTrickshotEditor.GetSelected(p) do
		if v2.G then
			gSet[v2.G] = true
		end
	end

	local flag = false

	for _, ball in p.Scene.Balls do
		if not (ball.G and ball.W and gSet[ball.G]) then
			continue
		end

		ball.W = v
		flag = true
	end

	if flag then
		changed(p)
	end
end

function PoolTrickshotEditor.GetSpinSpeed(p)
	local selected = PoolTrickshotEditor.GetSelected(p)

	if #selected == 0 then
		return nil
	end

	local v = nil

	for _, v2 in selected do
		if not v2.G then
			return nil
		end

		v = v or v2.G
	end

	for _, ball in p.Scene.Balls do
		if ball.G == v and ball.W then
			return ball.W
		end
	end

	return nil
end

function PoolTrickshotEditor.SetModifierRotation(p, p2: number)
	local flag = false

	for _, v in PoolTrickshotEditor.GetSelectedModifierEntries(p) do
		local v2 = PoolModifiers.Get(v.K)

		if not (v2 and v2.Rotatable) then
			continue
		end

		v.R = math.round(p2) % 360
		flag = true
	end

	if flag then
		changed(p)
	end
end

function PoolTrickshotEditor.SetModifierStrength(p, p2: number)
	local flag = false

	for _, v in PoolTrickshotEditor.GetSelectedModifierEntries(p) do
		local v2 = PoolModifiers.Get(v.K)

		if not PoolModifiers.HasStrength(v2) then
			continue
		end

		local dialToStrength = PoolModifiers.DialToStrength(v2, p2)

		if dialToStrength == v2.Strength.Default then
			dialToStrength = nil
		end

		v.P = dialToStrength
		flag = true
	end

	if flag then
		changed(p)
	end
end

function PoolTrickshotEditor.SetScale(p, value: number)
	local selectedModifierEntries = PoolTrickshotEditor.GetSelectedModifierEntries(p)

	if #selectedModifierEntries > 0 then
		for _, selectedModifierEntry in selectedModifierEntries do
			local scaleRange, v = PoolModifiers.ScaleRange(PoolModifiers.Get(selectedModifierEntry.K))
			local v2 = math.clamp(value, scaleRange, v)

			if v2 == 1 then
				v2 = nil
			end

			selectedModifierEntry.S = v2
		end

		changed(p)
	else
		local v = math.clamp(value, PoolTrickshotTypes.MinScale, PoolTrickshotTypes.MaxScale)
		local flag = false
		local flag2 = false

		for _, v2 in PoolTrickshotEditor.GetSelected(p) do
			if not (v2.G and v2.W) then
				continue
			end

			local v3

			if v ~= 1 then
				v3 = v
			end

			v2.S = v3
			flag = true
		end

		if flag then
			rebuildSpinners(p)
		else
			for _, v2 in PoolTrickshotEditor.GetSelected(p) do
				local v3 = PoolConstants.BallRadius * v
				local clampPosition = PoolTrickshotTypes.ClampPosition(positionOf(v2), v, tableOf(p)) -- inferred equivalent call

				if hasRoom(p, clampPosition, v3, v2.I) then
					local v4

					if v ~= 1 then
						v4 = v
					end

					v2.S = v4
					local x = clampPosition.X
					local y = clampPosition.Y
					v2.X = x
					v2.Y = y
				else
					flag2 = true
				end
			end

			if flag2 then
				say(p, "Not enough room to resize") -- inferred equivalent call
			end
		end

		changed(p)
	end
end

function PoolTrickshotEditor.SwapModifierType(p, p2: string)
	local v = PoolModifiers.Get(p2)

	if not v then
		return
	end

	for _, v2 in PoolTrickshotEditor.GetSelectedModifierEntries(p) do
		if v.Id == "Pocket" and v2.K ~= "Pocket" then
			placeGoldenBall(p, Vector2.new(v2.X, v2.Y), PoolModifiers.RadiusOf(v, v2.S))
		end

		v2.K = v.Id
		v2.R = v.Rotatable and (v2.R or 0) or nil

		v2.P = nil
	end

	changed(p)
end

function PoolTrickshotEditor.SwapType(p, p2: number, flag: boolean?)
	if not PoolTrickshotTypes.IsPlaceable(p2) then
		return
	end

	if p2 == PoolConstants.CueBallNumber then
		local flag2 = false

		for _, v in PoolTrickshotEditor.GetSelected(p) do
			if not (v.N == PoolConstants.CueBallNumber and (v.O == true) ~= (flag == true)) then
				continue
			end

			v.O = flag and true or nil
			v.A = not flag or nil
			flag2 = true
		end

		if flag2 then
			changed(p)
		else
			say(p, "Move the cue ball instead of swapping to it") -- inferred equivalent call
		end
	else
		for _, v in PoolTrickshotEditor.GetSelected(p) do
			if v.N == PoolConstants.CueBallNumber or v.G then
				continue
			end

			v.N = p2

			v.O = flag and true or nil

			if flag then
				v.RX = nil
				v.RY = nil
				v.RS = nil
			end

			PoolViewController.SetBallSkin(p.View, v.I, PoolTrickshotTypes.SkinForBall(v))
			PoolViewController.RemoveBall(p.View, v.I)
		end

		changed(p)
	end
end

function PoolTrickshotEditor.MoveSelection(data, vector2: Vector2)
	if data.SnapIncrement > 0 then
		local selected = PoolTrickshotEditor.GetSelected(data)
		local selectedModifiers = PoolTrickshotEditor.GetSelectedModifiers(data)

		if #selected + #selectedModifiers == 1 then
			local v

			if #selected == 1 then
				local v2 = selected[1]
				v = data.DragOrigin[v2.I] or positionOf(v2) -- inferred equivalent call
			else
				local selectedModifier = selectedModifiers[1]
				local mod = data.Scene.Mods[selectedModifier]
				v = data.DragOrigin[-selectedModifier] or Vector2.new(mod.X, mod.Y)
			end

			vector2 = snapPoint(data, v + vector2) - v -- inferred equivalent call
		else
			vector2 = Vector2.new(snapValue(vector2.X, snapSpacing(data)), snapValue(vector2.Y, snapSpacing(data))) -- inferred equivalent call
		end
	end

	local selectedModifiers = PoolTrickshotEditor.GetSelectedModifiers(data)

	if #selectedModifiers > 0 then
		local mods = data.Scene.Mods or {}

		for _, selectedModifier in selectedModifiers do
			local mod = mods[selectedModifier]

			if not mod then
				continue
			end

			local v = -selectedModifier
			local v2 = data.DragOrigin[v] or Vector2.new(mod.X, mod.Y)

			local clampModifierPosition = PoolTrickshotTypes.ClampModifierPosition(v2 + vector2, tableOf(data))

			local x = clampModifierPosition.X
			local y = clampModifierPosition.Y
			mod.X = x
			mod.Y = y
		end

		changed(data)
	else
		local selected = PoolTrickshotEditor.GetSelected(data)
		local v = {}

		local v2 = {}

		for _, v3 in selected do
			if not (v3.G and v3.W) then
				continue
			end

			local origin = data.DragOrigin[v3.I] or positionOf(v3) -- inferred equivalent call

			v[v3.I] = PoolTrickshotTypes.ClampPosition(origin + vector2, v3.S or 1, tableOf(data))
			v2[v3.G] = { Origin = origin, Target = v[v3.I] }
		end

		for _, v3 in selected do
			if v[v3.I] then
				continue
			end

			local v4 = v3.G and v2[v3.G]

			if v4 then
				local v5 = data.DragOrigin[v3.I] or positionOf(v3) -- inferred equivalent call

				v[v3.I] = v4.Target + (v5 - v4.Origin)
			else
				local v5 = data.DragOrigin[v3.I] or positionOf(v3) -- inferred equivalent call

				v[v3.I] = PoolTrickshotTypes.ClampPosition(v5 + vector2, v3.S or 1, tableOf(data))
			end
		end

		for _, v3 in selected do
			local v4 = v[v3.I]

			for _, ball in data.Scene.Balls do
				if ball.I == v3.I or data.Selection[ball.I] then
					continue
				end

				local v5 = radiusOf(v3) + radiusOf(ball) -- inferred equivalent call

				local magnitude = (positionOf(ball) - v4).Magnitude -- inferred equivalent call

				if not (magnitude < v5 - 0.001) then
					continue
				end

				local magnitude2 = (positionOf(ball) - positionOf(v3)).Magnitude -- inferred equivalent call

				if v5 <= magnitude2 or magnitude <= magnitude2 then
					return
				end
			end
		end

		for _, v3 in selected do
			local v4 = v[v3.I]
			local x = v4.X
			local y = v4.Y
			v3.X = x
			v3.Y = y
		end

		changed(data)
	end
end

function PoolTrickshotEditor.GetTableSize(p)
	return PoolTrickshotTypes.CleanTableScale(p.Scene.TL), PoolTrickshotTypes.CleanTableScale(p.Scene.TH)
end

function PoolTrickshotEditor.SetTableSize(data, p: number, p2: number): boolean
	if data.Mode ~= "Edit" or data.Locked then
		return false
	end

	local tl = PoolTrickshotTypes.CleanTableScale(p)
	local th = PoolTrickshotTypes.CleanTableScale(p2)
	local tableSize, v = PoolTrickshotEditor.GetTableSize(data)

	if tl == tableSize and th == v then
		return false
	end

	local tbl = PoolTrickshotTypes.TableOf({ TL = tl, TH = th })
	local balls = data.Scene.Balls
	local v2 = {}

	for _, ball in balls do
		v2[ball.I] = PoolTrickshotTypes.ClampPosition(positionOf(ball), ball.S or 1, tbl) -- inferred equivalent call
	end

	for i = 1, #balls - 1 do
		local ball = balls[i]

		for j = i + 1, #balls do
			local ball2 = balls[j]
			local v3 = radiusOf(ball) + radiusOf(ball2) -- inferred equivalent call

			local magnitude = (v2[ball.I] - v2[ball2.I]).Magnitude

			if magnitude < v3 - 0.001 and magnitude < (positionOf(ball) - positionOf(ball2)).Magnitude - 0.001 then -- inferred equivalent call
				say(data, "Move balls inward to shrink the table further") -- inferred equivalent call
				return false
			end
		end
	end

	for _, ball in balls do
		local v3 = v2[ball.I]
		local x = v3.X
		local y = v3.Y
		ball.X = x
		ball.Y = y

		if not (ball.RX and ball.RY) then
			continue
		end

		local v4 = PoolTrickshotTypes.ClampPosition(Vector2.new(ball.RX, ball.RY), ball.S or 1, tbl)

		if (v4 - v3).Magnitude < PoolModifiers.MinPatrolDistance then
			v4 = PoolTrickshotTypes.ClampPosition(v3 + Vector2.new(18, 0), 0, tbl)

			if not ((v4 - v3).Magnitude >= PoolModifiers.MinPatrolDistance) then
				v4 = PoolTrickshotTypes.ClampPosition(v3 - Vector2.new(18, 0), 0, tbl)
			end
		end

		local x2 = v4.X
		local y2 = v4.Y
		ball.RX = x2
		ball.RY = y2
	end

	for _, v3 in data.Scene.Mods or {} do
		local clampModifierPosition = PoolTrickshotTypes.ClampModifierPosition(Vector2.new(v3.X, v3.Y), tbl)
		local x = clampModifierPosition.X
		local y = clampModifierPosition.Y
		v3.X = x
		v3.Y = y
	end

	local scene = data.Scene

	if tl == 1 then
		tl = nil
	end

	scene.TL = tl
	local scene2 = data.Scene

	if th == 1 then
		th = nil
	end

	scene2.TH = th
	applyTable(data) -- inferred equivalent call
	changed(data)

	return true
end

local function loadIntoSimulation(data)
	local simulation = data.Simulation

	table.clear(simulation.Balls)
	table.clear(simulation.Order)
	table.clear(simulation.Events)
	simulation.Elapsed = 0
	simulation.Settled = true

	simulation.RestlessFor = 0
	simulation.IsBreakShot = false

	PoolPhysics.SetTable(simulation, tableOf(data))

	PoolPhysics.SetModifiers(simulation, data.Scene.Mods)

	for _, ball in data.Scene.Balls do
		local addBall = PoolPhysics.AddBall

		local i = ball.I
		local v = positionOf(ball) -- inferred equivalent call
		local v2

		if ball.S then
			v2 = PoolConstants.BallRadius * ball.S
		end

		addBall(simulation, i, v, v2, ball.A)

		PoolViewController.SetBallVisible(data.View, ball.I, true)
	end

	for _, ball in data.Scene.Balls do
		if ball.RX and ball.RY then
			PoolPhysics.SetPatrol(simulation, ball.I, Vector2.new(ball.RX, ball.RY), ball.RS)
		end
	end

	PoolPhysics.SetRotors(simulation, data.Scene.Balls)

	data.reloadedEvent:Fire()
end

local function clearSimulation(p) -- 5 equivalent calls inferred from this helper
	local simulation = p.Simulation

	table.clear(simulation.Balls)
	table.clear(simulation.Order)
	table.clear(simulation.Events)

	table.clear(simulation.Popped)
	simulation.Settled = true
	simulation.IsBreakShot = false
end

function PoolTrickshotEditor.GetMode(p)
	return p.Mode
end

function PoolTrickshotEditor:Play()
	if self.Mode == "Play" then
		return true
	end

	if not PoolTrickshotTypes.FindById(self.Scene, PoolTrickshotTypes.CueId) then
		say(self, "Place a cue ball first") -- inferred equivalent call
		return false, "Place a cue ball first"
	end

	local _ = PoolTrickshotTypes.CountTargets(self.Scene) == 0

	table.clear(self.Selection)
	table.clear(self.ModSelection)
	self.Mode = "Play"
	loadIntoSimulation(self)
	PoolTrickshotEditor.Render(self)
	self.modeEvent:Fire("Play")

	return true
end

function PoolTrickshotEditor.Reset(p)
	if p.Mode == "Play" then
		loadIntoSimulation(p)
	else
		clearSimulation(p) -- inferred equivalent call
	end

	PoolTrickshotEditor.Render(p)
end

function PoolTrickshotEditor:SetMode(p: string)
	if self.Mode == p then
		return
	end

	if p == "Play" then
		PoolTrickshotEditor.Play(self)

		return
	end

	self.Mode = "Edit"
	clearSimulation(self) -- inferred equivalent call
	PoolTrickshotEditor.Render(self)
	self.modeEvent:Fire("Edit")
end

function PoolTrickshotEditor.Evaluate(p)
	return PoolGoals.Evaluate(p.Scene, p.Simulation)
end

function PoolTrickshotEditor.IsSolved(p)
	return PoolGoals.IsPassed(PoolTrickshotEditor.Evaluate(p))
end

function PoolTrickshotEditor.OnSettled(data)
	if data.Mode ~= "Play" then
		return
	end

	local evaluate = PoolTrickshotEditor.Evaluate(data)

	if PoolGoals.IsPassed(evaluate) then
		data.solvedEvent:Fire(evaluate)
		say(data, string.format("%s -- %d★", evaluate.Summary, evaluate.Stars)) -- inferred equivalent call
	else
		local ball = data.Simulation.Balls[data.Simulation.CueBall]

		if ball and ball.Pocketed then
			say(data, "Potted the cue ball") -- inferred equivalent call
		end
	end
end

local function clearOverlayExtras(state)
	table.clear(state.ModSelection)

	for k, modRing in state.ModRings do
		modRing:Destroy()
		state.ModRings[k] = nil
	end

	for k, cueLabel in state.CueLabels do
		cueLabel:Destroy()
		state.CueLabels[k] = nil
	end

	if state.PatrolGhost then
		state.PatrolGhost.Visible = false
	end

	if state.PatrolLine then
		state.PatrolLine.Visible = false
	end

	state.PatrolDragId = nil
	state.DragMode = nil
	state.DragFrom = nil
	state.Dragging = false
	state.Marquee.Visible = false
end

function PoolTrickshotEditor.GetScene(p)
	return p.Scene
end

function PoolTrickshotEditor:LoadScene(p, slotId: string?)
	for k in self.Drawn do
		PoolViewController.RemoveBall(self.View, k)
	end

	for k, ring in self.Rings do
		ring:Destroy()
		self.Rings[k] = nil
	end

	clearOverlayExtras(self)

	table.clear(self.Drawn)
	table.clear(self.Selection)

	self.Scene = p or PoolTrickshotTypes.NewScene()
	self.SlotId = slotId
	self.Mode = "Edit"
	applyTable(self) -- inferred equivalent call
	clearSimulation(self) -- inferred equivalent call
	PoolTrickshotEditor.Render(self)
	self.modeEvent:Fire("Edit")
	self.selectionEvent:Fire()
	self.sceneEvent:Fire()
	resetHistory(self) -- inferred equivalent call
end

local function restoreSnapshot(state, data)
	for k in state.Drawn do
		PoolViewController.RemoveBall(state.View, k)
	end

	for k, ring in state.Rings do
		ring:Destroy()
		state.Rings[k] = nil
	end

	clearOverlayExtras(state)
	table.clear(state.Drawn)

	state.Scene.Balls = copyList(data.Balls) or {}
	state.Scene.Mods = copyList(data.Mods)
	state.Scene.TL = data.TL
	state.Scene.TH = data.TH

	local set = {}

	for k in state.Selection do
		if PoolTrickshotTypes.FindById(state.Scene, k) then
			set[k] = true
		end
	end

	state.Selection = set
	applyTable(state) -- inferred equivalent call
	PoolTrickshotEditor.Render(state)
	state.selectionEvent:Fire()
	state.sceneEvent:Fire()
end

local function canEditHistory(data): boolean -- 2 equivalent calls inferred from this helper
	return data.Mode == "Edit" and not (data.Locked or data.CameraMode)
end

function PoolTrickshotEditor.CanUndo(p): boolean
	return #p.HistoryUndo > 0 or p.HistoryPendingAt ~= nil
end

function PoolTrickshotEditor:BeginGesture()
	self.HistoryHold += 1
end

function PoolTrickshotEditor:EndGesture()
	self.HistoryHold = math.max(self.HistoryHold - 1, 0)

	if self.HistoryHold == 0 then
		flushHistory(self) -- inferred equivalent call
	end
end

function PoolTrickshotEditor.CanRedo(p): boolean
	return #p.HistoryRedo > 0 and p.HistoryPendingAt == nil
end

function PoolTrickshotEditor:Undo(): boolean
	if not canEditHistory(self) then -- inferred equivalent call
		return false
	end

	flushHistory(self) -- inferred equivalent call
	local historyCommitted = table.remove(self.HistoryUndo)

	if not historyCommitted then
		return false
	end

	table.insert(self.HistoryRedo, self.HistoryCommitted)
	self.HistoryCommitted = historyCommitted
	restoreSnapshot(self, historyCommitted)
	historyChanged(self) -- inferred equivalent call
	return true
end

function PoolTrickshotEditor:Redo(): boolean
	if not canEditHistory(self) then -- inferred equivalent call
		return false
	end

	flushHistory(self) -- inferred equivalent call
	local historyCommitted = table.remove(self.HistoryRedo)

	if not historyCommitted then
		return false
	end

	table.insert(self.HistoryUndo, self.HistoryCommitted)
	self.HistoryCommitted = historyCommitted
	restoreSnapshot(self, historyCommitted)
	historyChanged(self) -- inferred equivalent call
	return true
end

local function pointerPixel(p) -- 4 equivalent calls inferred from this helper
	Mouses.SetPosition(p.Mouse)

	return p.Mouse.mouseViewport
end

local function pointerTable(state) -- 3 equivalent calls inferred from this helper
	return PoolTableRenderer2D.PixelToTable(state.View.Renderer2D, pointerPixel(state)) -- inferred equivalent call
end

local function overTable(state, vector2: Vector2): boolean
	local screenRect, v = PoolTableRenderer2D.GetScreenRect(state.View.Renderer2D)

	local v2 = v * ((PoolTrickshotTypes.ModifierRegion - 1) / 2)
	local v3 = screenRect - v2
	local v4 = screenRect + v + v2

	return vector2.X >= v3.X and vector2.X <= v4.X and vector2.Y >= v3.Y and vector2.Y <= v4.Y
end

local function selectWithin(data, dragFrom: Vector2, vector2: Vector2, flag: boolean?)
	local vector2_2 = Vector2.new(math.min(dragFrom.X, vector2.X), (math.min(dragFrom.Y, vector2.Y)))
	local vector2_3 = Vector2.new(math.max(dragFrom.X, vector2.X), (math.max(dragFrom.Y, vector2.Y)))

	local function inside(x: number, y: number): boolean -- 2 equivalent calls inferred from this helper
		return vector2_2.X <= x and x <= vector2_3.X and vector2_2.Y <= y and y <= vector2_3.Y
	end

	local v = {}

	for _, ball in data.Scene.Balls do
		if inside(ball.X, ball.Y) then -- inferred equivalent call
			table.insert(v, ball.I)
		end
	end

	if #v > 0 then
		if flag and next(data.ModSelection) == nil then
			for k in data.Selection do
				if not table.find(v, k) then
					table.insert(v, k)
				end
			end
		end

		PoolTrickshotEditor.SetSelection(data, v)
	else
		local v2 = {}

		for k, v3 in data.Scene.Mods or {} do
			if inside(v3.X, v3.Y) then -- inferred equivalent call
				table.insert(v2, k)
			end
		end

		if flag then
			if #v2 == 0 then
				return
			end

			if next(data.Selection) == nil then
				for k in data.ModSelection do
					if not table.find(v2, k) then
						table.insert(v2, k)
					end
				end
			end
		end

		PoolTrickshotEditor.SetModifierSelection(data, v2)
	end
end

function PoolTrickshotEditor.MovePatrolTarget(p, vector2: Vector2)
	local v

	if p.PatrolDragId then
		v = PoolTrickshotTypes.FindById(p.Scene, p.PatrolDragId)
	end

	if not v then
		return
	end

	local clampPosition = PoolTrickshotTypes.ClampPosition
	vector2 = snapPoint(p, vector2) -- inferred equivalent call
	local v2 = clampPosition(vector2, v.S or 1, tableOf(p))

	if (v2 - positionOf(v)).Magnitude < PoolModifiers.MinPatrolDistance then -- inferred equivalent call
		return
	end

	local x = v2.X
	local y = v2.Y
	v.RX = x
	v.RY = y
	changed(p)
end

local function patrolHandleAt(state, dragFrom: Vector2) -- 2 equivalent calls inferred from this helper
	local v = soleMovingBall(state) -- inferred equivalent call

	if not v then
		return nil
	end

	if (dragFrom - Vector2.new(v.RX, v.RY)).Magnitude <= PoolConstants.BallRadius * (v.S or 1) then
		return v
	end

	return nil
end

local function beginDrag(p)
	table.clear(p.DragOrigin)

	for _, v in PoolTrickshotEditor.GetSelected(p) do
		p.DragOrigin[v.I] = positionOf(v) -- inferred equivalent call
	end

	local mods = p.Scene.Mods or {}

	for _, v in PoolTrickshotEditor.GetSelectedModifiers(p) do
		local mod = mods[v]

		if mod then
			p.DragOrigin[-v] = Vector2.new(mod.X, mod.Y)
		end
	end
end

local vector2s = {
	[Enum.KeyCode.Left] = Vector2.new(-1, 0),
	[Enum.KeyCode.Right] = Vector2.new(1, 0),
	[Enum.KeyCode.Up] = Vector2.new(0, 1),
	[Enum.KeyCode.Down] = Vector2.new(0, -1),
	[Enum.KeyCode.DPadLeft] = Vector2.new(-1, 0),
	[Enum.KeyCode.DPadRight] = Vector2.new(1, 0),
	[Enum.KeyCode.DPadUp] = Vector2.new(0, 1),
	[Enum.KeyCode.DPadDown] = Vector2.new(0, -1)
}

local function hasSelection(data): boolean -- 4 equivalent calls inferred from this helper
	return next(data.Selection) ~= nil or next(data.ModSelection) ~= nil
end

function PoolTrickshotEditor.Nudge(data, vector2: Vector2)
	if data.Mode ~= "Edit" or data.Locked or next(data.Selection) == nil and next(data.ModSelection) == nil then
		return
	end

	beginDrag(data)
	PoolTrickshotEditor.MoveSelection(data, vector2)
	table.clear(data.DragOrigin)
end

function PoolTrickshotEditor.StepScale(p, p2: number)
	if p.Mode ~= "Edit" or p.Locked then
		return
	end

	local selectedModifierEntries = PoolTrickshotEditor.GetSelectedModifierEntries(p)
	local s

	if #selectedModifierEntries > 0 then
		s = selectedModifierEntries[1].S or 1
	else
		local selected = PoolTrickshotEditor.GetSelected(p)

		if #selected == 0 then
			return
		end

		s = selected[1].S or 1
	end

	local v = math.round((s + p2 * 0.1) * 100) / 100

	PoolTrickshotEditor.SetScale(p, v)
end

function PoolTrickshotEditor.RotateModifiers(p, p2: number)
	if p.Mode ~= "Edit" or p.Locked then
		return
	end

	local flag = false

	for _, v in PoolTrickshotEditor.GetSelectedModifierEntries(p) do
		local v2 = PoolModifiers.Get(v.K)

		if not (v2 and v2.Rotatable) then
			continue
		end

		v.R = math.round((v.R or 0) + p2) % 360
		flag = true
	end

	if flag then
		changed(p)
	end
end

local function bindShortcuts(data)
	local v = nil
	local v2 = 0

	local function nudgeFor(p)
		local v3 = vector2s[p]
		local v4 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		local v5 = snapSpacing(data) -- inferred equivalent call

		if v5 > 0 then
			if v4 then
				v5 *= 5
			end

			return v3 * v5
		end

		return v3 * (v4 and 2.5 or 0.5)
	end

	data.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or data.Mode ~= "Edit" or data.Locked or data.CameraMode or not data.Layer.Parent then
			return
		end

		local keyCode = input.KeyCode

		local v3 = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightMeta)

		if v3 and keyCode == Enum.KeyCode.Z then
			if
				UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			then
				PoolTrickshotEditor.Redo(data)
			else
				PoolTrickshotEditor.Undo(data)
			end
		elseif v3 and keyCode == Enum.KeyCode.Y then
			PoolTrickshotEditor.Redo(data)
		elseif vector2s[keyCode] then
			if not hasSelection(data) then -- inferred equivalent call
				return
			end

			if not v then
				PoolTrickshotEditor.BeginGesture(data)
			end

			v = keyCode
			v2 = os.clock() + 0.35
			PoolTrickshotEditor.Nudge(data, nudgeFor(keyCode))
		else
			local v4 = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
				or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

			if
				keyCode == Enum.KeyCode.Delete
				or keyCode == Enum.KeyCode.Backspace
				or keyCode == Enum.KeyCode.ButtonB
			then
				if hasSelection(data) then -- inferred equivalent call
					PoolTrickshotEditor.Delete(data)
				end
			elseif keyCode == Enum.KeyCode.D and v4 or keyCode == Enum.KeyCode.ButtonY then
				if hasSelection(data) then -- inferred equivalent call
					PoolTrickshotEditor.Clone(data)
				end
			elseif keyCode == Enum.KeyCode.LeftBracket or keyCode == Enum.KeyCode.ButtonL1 then
				PoolTrickshotEditor.StepScale(data, -1)
			elseif keyCode == Enum.KeyCode.RightBracket or keyCode == Enum.KeyCode.ButtonR1 then
				PoolTrickshotEditor.StepScale(data, 1)
			elseif keyCode == Enum.KeyCode.Q or keyCode == Enum.KeyCode.ButtonL2 then
				PoolTrickshotEditor.RotateModifiers(data, -15)
			elseif keyCode == Enum.KeyCode.E or keyCode == Enum.KeyCode.ButtonR2 then
				PoolTrickshotEditor.RotateModifiers(data, 15)
			end
		end
	end))

	data.Maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == v then
			v = nil
			PoolTrickshotEditor.EndGesture(data)
		end
	end))

	data.Maid:GiveTask(RunService.Heartbeat:Connect(function()
		if not v then
			return
		end

		if data.Mode == "Edit" and not (data.Locked or data.CameraMode) and hasSelection(data) then -- inferred equivalent call
			local now = os.clock()

			if v2 <= now then
				v2 = now + 0.05
				PoolTrickshotEditor.Nudge(data, nudgeFor(v))
			end

			return
		end

		v = nil
		PoolTrickshotEditor.EndGesture(data)
	end))
end

function PoolTrickshotEditor:SetCameraMode(cameraMode: boolean)
	if self.CameraMode == cameraMode then
		return
	end

	self.CameraMode = cameraMode

	if cameraMode then
		self.DragFrom = nil
		self.DragMode = nil
		self.PatrolDragId = nil
		self.Dragging = false
		self.Marquee.Visible = false
	end

	if self.Layer.Parent then
		self.sceneEvent:Fire()
	end
end

function PoolTrickshotEditor:SetLocked(locked: boolean)
	self.Locked = locked

	if locked then
		table.clear(self.Selection)
		table.clear(self.ModSelection)
		selectionChanged(self) -- inferred equivalent call
	end
end

local function shiftHeld() -- 2 equivalent calls inferred from this helper
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

local function modifierSelectionCount(p) -- 1 equivalent call inferred from this helper
	local count = 0

	for _ in p.ModSelection do
		count += 1
	end

	return count
end

local function toggleBall(state, i: number)
	if next(state.ModSelection) == nil then
		local v = {}

		for k in state.Selection do
			if k ~= i then
				table.insert(v, k)
			end
		end

		if not state.Selection[i] then
			table.insert(v, i)
		end

		PoolTrickshotEditor.SetSelection(state, v)
	else
		PoolTrickshotEditor.SetSelection(state, { i })
		say(state, "Balls and pads are selected separately") -- inferred equivalent call
	end
end

local function toggleModifier(state, p: number)
	if next(state.Selection) == nil then
		local v = {}

		for k in state.ModSelection do
			if k ~= p then
				table.insert(v, k)
			end
		end

		if not state.ModSelection[p] then
			table.insert(v, p)
		end

		PoolTrickshotEditor.SetModifierSelection(state, v)
	else
		PoolTrickshotEditor.SetModifierSelection(state, { p })
		say(state, "Balls and pads are selected separately") -- inferred equivalent call
	end
end

local function announceSelection(state, flag: boolean)
	local v = selectionCount(state) + modifierSelectionCount(state) -- inferred equivalent call

	if flag then
		say(state, string.format("Added to selection (%d)", v)) -- inferred equivalent call
	else
		say(state, string.format("Removed from selection (%d)", v)) -- inferred equivalent call
	end
end

local function bindInput(state)
	local mouse = state.Mouse
	local v = nil

	local lastTime = 0
	local v2 = nil
	local v3 = false
	local v4 = false
	local v5 = false

	state.Maid:GiveTask(mouse.Activated:Connect(function(flag: boolean)
		if not Mouses.PressReachedWorld(flag) or (state.Mode ~= "Edit" or state.Locked or state.CameraMode) then
			return
		end

		local mouseViewport = pointerPixel(state) -- inferred equivalent call

		if not overTable(state, mouseViewport) then
			return
		end

		v = mouseViewport
		state.Dragging = false
		state.DragFrom = pointerTable(state) -- inferred equivalent call

		lastTime = os.clock()
		v2 = nil
		v3 = false
		v4 = false
		v5 = false
		local v6 = shiftHeld() -- inferred equivalent call
		local v7 = patrolHandleAt(state, state.DragFrom) -- inferred equivalent call

		if v7 then
			state.PatrolDragId = v7.I
			state.DragMode = "Patrol"
		else
			local v8 = ballAt(state, state.DragFrom)

			if v8 then
				if not state.Selection[v8.I] then
					if v6 then
						toggleBall(state, v8.I)
						v3 = true
					else
						v2 = { Kind = "Ball", Key = v8.I }
					end
				end

				state.DragMode = "Move"
				beginDrag(state)
			else
				local v9 = modifierIndexAt(state, state.DragFrom)

				if v9 then
					if not state.ModSelection[v9] then
						if v6 then
							toggleModifier(state, v9)
							v3 = true
						else
							v2 = { Kind = "Pad", Key = v9 }
						end
					end

					state.DragMode = "Move"
					beginDrag(state)
				else
					state.DragMode = "Marquee"
					v5 = v6
				end
			end
		end
	end))

	state.Maid:GiveTask(mouse.Moved:Connect(function()
		if state.Mode ~= "Edit" or not (v and state.DragFrom) then
			return
		end

		local mouseViewport = pointerPixel(state) -- inferred equivalent call

		if not state.Dragging then
			if (mouseViewport - v).Magnitude < 6 then
				return
			end

			state.Dragging = true

			if v2 and state.DragMode == "Move" then
				if v2.Kind == "Ball" then
					PoolTrickshotEditor.SetSelection(state, { v2.Key })
				else
					PoolTrickshotEditor.SetModifierSelection(state, { v2.Key })
				end

				v2 = nil
				beginDrag(state)
			end
		end

		if state.DragMode == "LongPressed" then
			return
		end

		local v6 = pointerTable(state) -- inferred equivalent call

		if state.DragMode == "Patrol" then
			PoolTrickshotEditor.MovePatrolTarget(state, v6)

			return
		end

		if state.DragMode == "Move" then
			PoolTrickshotEditor.MoveSelection(state, v6 - state.DragFrom)

			return
		end

		local dragFrom = state.DragFrom
		local midpoint = (dragFrom + v6) / 2

		state.Marquee.Visible = true
		state.Marquee.Position = PoolTableRenderer2D.TableToScale(midpoint)
		state.Marquee.Size = PoolTableRenderer2D.InchesToSize(
			math.abs(v6.X - dragFrom.X),
			(math.abs(v6.Y - dragFrom.Y))
		)
	end))

	state.Maid:GiveTask(mouse.Deactivated:Connect(function()
		if state.Mode ~= "Edit" or not (v and state.DragFrom) then
			return
		end

		local dragFrom = state.DragFrom
		local dragging = state.Dragging
		local dragMode = state.DragMode
		local v6 = shiftHeld() -- inferred equivalent call
		local v7 = v4
		local v8 = v3
		local v9 = v5

		v = nil
		v2 = nil
		v3 = false
		v4 = false
		v5 = false
		state.DragFrom = nil
		state.DragMode = nil
		state.PatrolDragId = nil
		state.Dragging = false
		state.Marquee.Visible = false
		flushHistory(state) -- inferred equivalent call

		if dragging then
			if dragMode == "Marquee" then
				selectWithin(state, dragFrom, pointerTable(state), v9 or v6) -- inferred equivalent call
			end
		else
			if v7 then
				return
			end

			if dragMode ~= "Patrol" and not patrolHandleAt(state, dragFrom) then -- inferred equivalent call
				if v6 then
					if v8 then
						return
					end

					local v10 = ballAt(state, dragFrom)

					if v10 then
						toggleBall(state, v10.I)

						return
					end

					local v11 = modifierIndexAt(state, dragFrom)

					if v11 then
						toggleModifier(state, v11)
					end
				else
					local v10 = ballAt(state, dragFrom)

					if v10 then
						PoolTrickshotEditor.SetSelection(state, { v10.I })

						return
					end

					local v11 = modifierIndexAt(state, dragFrom)

					if v11 then
						PoolTrickshotEditor.SetModifierSelection(state, { v11 })
					elseif selectionCount(state) > 0 or next(state.ModSelection) ~= nil then -- inferred equivalent call
						PoolTrickshotEditor.SetSelection(state, {})
					else
						PoolTrickshotEditor.Place(state, dragFrom)
					end
				end
			end
		end
	end))

	state.Maid:GiveTask(RunService.Heartbeat:Connect(function()
		if not v or v4 or state.Dragging or not state.DragFrom then
			return
		end

		if state.Mode ~= "Edit" or state.Locked or state.CameraMode then
			return
		end

		if os.clock() - lastTime < 0.45 or state.DragMode == "Patrol" or (pointerPixel(state) - v).Magnitude >= 6 then -- inferred equivalent call
			return
		end

		v4 = true
		v2 = nil

		local dragFrom = state.DragFrom
		local v6 = ballAt(state, dragFrom)
		local v7

		if not v6 then
			v7 = modifierIndexAt(state, dragFrom)
		end

		if v6 or v7 then
			if not v3 then
				if v6 then
					toggleBall(state, v6.I)
				else
					toggleModifier(state, v7)
				end
			end

			local v8

			if v6 then
				v8 = state.Selection[v6.I] == true
			else
				v8 = state.ModSelection[v7] == true
			end

			if v8 then
				state.DragMode = "Move"
				beginDrag(state)
			else
				state.DragMode = "LongPressed"
			end

			announceSelection(state, v8)
		else
			v5 = true
			say(state, "Drag to add to the selection") -- inferred equivalent call
		end
	end))
end

local function getAuthoredLayer() -- 1 equivalent call inferred from this helper
	local frame = PoolTrickshotStyle.Authored("PoolTrickshotUI", "Overlay", "Layer")

	assert(frame:IsA("Frame"), "[Trickshot] PoolTrickshotUI.Overlay.Layer must be a Frame")

	return frame
end

function PoolTrickshotEditor.new(view, simulation, parent)
	local maid = Maid.new()

	local trickshotLayer = getAuthoredLayer():Clone() -- inferred equivalent call
	trickshotLayer.Name = "TrickshotLayer"
	trickshotLayer.Visible = true
	trickshotLayer.Parent = parent
	maid:GiveTask(trickshotLayer)

	local marquee = trickshotLayer:FindFirstChild("Marquee")
	local edge = marquee:FindFirstChild("Edge")
	marquee.Visible = false

	local ringTemplate = trickshotLayer:FindFirstChild("RingTemplate")
	local pocketTemplate = trickshotLayer:FindFirstChild("PocketTemplate")

	assert(ringTemplate, "[Trickshot] the authored Layer has no RingTemplate")
	assert(pocketTemplate, "[Trickshot] the authored Layer has no PocketTemplate")

	ringTemplate.Parent = nil
	pocketTemplate.Parent = nil
	maid:GiveTask(ringTemplate)
	maid:GiveTask(pocketTemplate)

	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local bindableEvent4 = Instance.new("BindableEvent")
	local bindableEvent5 = Instance.new("BindableEvent")
	local bindableEvent6 = Instance.new("BindableEvent")
	local bindableEvent7 = Instance.new("BindableEvent")

	for _, v in {
		bindableEvent,
		bindableEvent2,
		bindableEvent3,
		bindableEvent4,
		bindableEvent5,
		bindableEvent6,
		bindableEvent7
	} do
		maid:GiveTask(v)
	end

	local mouse = Mouses.new()
	maid:GiveTask(function()
		if mouse.maid then
			mouse.maid:DoCleaning()
		end
	end)

	local v = {
		View = view,
		Simulation = simulation,
		Scene = PoolTrickshotTypes.NewScene(),
		Mode = "Edit",
		Locked = false,
		CameraMode = false,
		Palette = PoolConstants.CueBallNumber,
		PaletteOrdinary = false,
		Selection = {},
		SlotId = nil,
		Layer = trickshotLayer,
		Marquee = marquee,
		RingTemplate = ringTemplate,
		PocketTemplate = pocketTemplate,
		RingThickness = ringTemplate:FindFirstChild("Edge") and ringTemplate:FindFirstChild("Edge").Thickness or 2,
		Rings = {},
		ModRings = {},
		CueLabels = {},
		ModSelection = {},
		ModifierPalette = nil,
		Pockets = {},
		Mouse = mouse,
		Dragging = false,
		PatrolGhost = nil,
		PatrolLine = nil,
		PatrolDragId = nil,
		DragMode = nil,
		DragFrom = nil,
		DragOrigin = {},
		Drawn = {},
		SceneChanged = bindableEvent.Event,
		SelectionChanged = bindableEvent2.Event,
		ModeChanged = bindableEvent3.Event,
		Solved = bindableEvent4.Event,
		Reloaded = bindableEvent6.Event,
		Message = bindableEvent5.Event,
		HistoryChanged = bindableEvent7.Event,
		HistoryUndo = {},
		HistoryRedo = {},
		HistoryCommitted = nil,
		HistoryPendingAt = nil,
		HistoryContinuous = 0,
		HistoryHold = 0,
		SnapIncrement = 0,
		Maid = maid,
		sceneEvent = bindableEvent,
		selectionEvent = bindableEvent2,
		modeEvent = bindableEvent3,
		solvedEvent = bindableEvent4,
		reloadedEvent = bindableEvent6,
		messageEvent = bindableEvent5,
		historyEvent = bindableEvent7
	}

	bindInput(v)
	bindShortcuts(v)
	buildPocketMarkers(v)
	applyTable(v) -- inferred equivalent call
	resetHistory(v) -- inferred equivalent call
	maid:GiveTask(RunService.Heartbeat:Connect(function()
		local historyPendingAt = v.HistoryPendingAt

		if historyPendingAt and v.HistoryHold == 0 and not v.DragFrom and os.clock() - historyPendingAt >= 0.35 then
			commitHistory(v)
		end
	end))

	maid:GiveTask(RunService.RenderStepped:Connect(function(_: number)
		local v2 = os.clock() % 5 / 5
		local v3

		if v2 < 0.5 then
			v3 = v2 * 2
		else
			v3 = (1 - v2) * 2
		end

		local color4 = Color3.new(v3, v3, v3)

		if marquee.Visible then
			edge.Color = color4
			marquee.BackgroundColor3 = color4
		end

		for k, ring in v.Rings do
			if not (ring.Visible and v.Selection[k]) then
				continue
			end

			local edge2 = ring:FindFirstChild("Edge")

			if edge2 then
				edge2.Color = color4
			end
		end
	end))

	return v
end

local function clearModifiers(data) -- 2 equivalent calls inferred from this helper
	PoolViewController.SetModifiers(data.View, nil, nil)
	PoolPhysics.SetModifiers(data.Simulation, nil)
end

function PoolTrickshotEditor.Unrender(data)
	for k in data.Drawn do
		PoolViewController.RemoveBall(data.View, k)
	end

	for k, ring in data.Rings do
		ring:Destroy()
		data.Rings[k] = nil
	end

	table.clear(data.Drawn)

	for _, pocket in data.Pockets do
		pocket.Visible = false
	end

	clearOverlayExtras(data)
	clearSimulation(data) -- inferred equivalent call
	clearModifiers(data) -- inferred equivalent call
	PoolViewController.SetTable(data.View, nil)
	PoolPhysics.SetTable(data.Simulation, nil)
end

function PoolTrickshotEditor:Destroy()
	for k in self.Drawn do
		PoolViewController.RemoveBall(self.View, k)
	end

	table.clear(self.Drawn)
	clearSimulation(self) -- inferred equivalent call
	clearModifiers(self) -- inferred equivalent call
	PoolViewController.SetTable(self.View, nil)
	PoolPhysics.SetTable(self.Simulation, nil)
	self.Maid:DoCleaning()
end

for _, v in {
	"MoveSelection",
	"MovePatrolTarget",
	"SetScale",
	"SetPatrolSpeed",
	"SetModifierRotation",
	"SetModifierStrength",
	"SetTableSize"
} do
	local v2 = PoolTrickshotEditor[v]

	PoolTrickshotEditor[v] = function(p, ...)
		p.HistoryContinuous += 1

		local v3 = table.pack(pcall(v2, p, ...))

		p.HistoryContinuous -= 1

		if not v3[1] then
			error(v3[2], 0)
		end

		return table.unpack(v3, 2, v3.n)
	end
end

return PoolTrickshotEditor