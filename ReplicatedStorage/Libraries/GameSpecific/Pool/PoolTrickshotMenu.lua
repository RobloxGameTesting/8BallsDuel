local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
require(Pool.PoolTableRenderer3D)
local PoolTrickshotStyle = require(Pool.PoolTrickshotStyle)
local PoolButtonSkin = require(Pool.PoolButtonSkin)
local PoolTrickshotTypes = require(Pool.PoolTrickshotTypes)
local PoolModifiers = require(Pool.PoolModifiers)
local PoolGeometry = require(Pool.PoolGeometry)

local PoolTrickshotMenu = {}

local Panel = PoolTrickshotStyle.Panel
local Border = PoolTrickshotStyle.Border
local Text = PoolTrickshotStyle.Text

local color = Color3.fromRGB(120, 220, 255)
local Go = PoolTrickshotStyle.Go
local Neutral = PoolTrickshotStyle.Neutral
local Danger = PoolTrickshotStyle.Danger
Color3.fromRGB(120, 128, 140)

local NormaliseZ = PoolTrickshotStyle.NormaliseZ

local v = {
	[Enum.KeyCode.DPadLeft] = -1,
	[Enum.KeyCode.DPadRight] = 1,
	[Enum.KeyCode.Left] = -1,
	[Enum.KeyCode.Right] = 1
}

local function isGamepadConfirm(input): boolean -- 1 equivalent call inferred from this helper
	return input.KeyCode == Enum.KeyCode.ButtonA and input.UserInputType.Name:sub(1, 7) == "Gamepad"
end

local function restoreSwatchCamera(instance)
	local body = instance:FindFirstChild("Body")

	if not body then
		return
	end

	local camera = body:FindFirstChildOfClass("Camera")

	if camera then
		body.CurrentCamera = camera
	end
end

local function paintBullseye(child)
	for k, bullseyeRing in PoolModifiers.BullseyeRings do
		local child2 = child:FindFirstChild(k == 1 and "Body" or "Band" .. k)

		if not child2 then
			continue
		end

		child2.BackgroundColor3 = bullseyeRing.Colour
		child2.Size = UDim2.fromScale(0.78 * bullseyeRing.Fraction, 0.78 * bullseyeRing.Fraction)
	end
end

local function paletteOrder(p) -- 3 equivalent calls inferred from this helper
	if p.Ordinary then
		return (PoolTrickshotTypes.NormalPaletteOrder())
	end

	return (PoolTrickshotTypes.PaletteOrder())
end

local function applyPaletteList(data)
	local v2 = {}
	local v3 = paletteOrder(data) -- inferred equivalent call

	for k, v4 in v3 do
		v2[v4] = k
	end

	for k, swatch in data.Swatches do
		local v4 = v2[k]

		swatch.Visible = v4 ~= nil
		swatch.LayoutOrder = data.Ordinary and v4 or data.SwatchOrder[k] or swatch.LayoutOrder
	end

	for _, modSwatch in data.ModSwatches do
		modSwatch.Visible = not data.Ordinary
	end

	local listToggle = data.ListToggle

	if listToggle then
		local caption = listToggle:FindFirstChild("Caption")

		if caption then
			caption.Text = data.Ordinary and "SPECIAL" or "NORMAL"
		end

		local setColour = PoolButtonSkin.SetColour
		local v4 = if data.Ordinary then color else Neutral
		setColour(listToggle, v4)
	end
end

local function bindPalette(state)
	local palette = state.Palette

	for _, guiObject in palette:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Name:match("^Ball%d+$") then
			guiObject.Visible = false
		end
	end

	local set = {}
	local v2 = {}

	for _, v3 in { PoolTrickshotTypes.PaletteOrder(), PoolTrickshotTypes.NormalPaletteOrder() } do
		for _, v4 in v3 do
			if set[v4] then
				continue
			end

			set[v4] = true
			table.insert(v2, v4)
		end
	end

	for _, v3 in v2 do
		local child = palette:FindFirstChild("Ball" .. v3)

		if child then
			local body = child:FindFirstChild("Body")

			local camera = body and body:FindFirstChildOfClass("Camera")

			if camera then
				body.CurrentCamera = camera
			end

			state.Swatches[v3] = child
			state.SwatchOrder[v3] = child.LayoutOrder

			state.Maid:GiveTask(child.Activated:Connect(function()
				if state.Swapping then
					state.Swapping = false
					state.swapEvent:Fire(v3, state.Ordinary)
					PoolTrickshotMenu.SetPalette(state, v3)
				else
					PoolTrickshotMenu.SetPalette(state, v3)
					state.paletteEvent:Fire(v3, state.Ordinary, true)
				end
			end))
		else
			warn(string.format("[Trickshot] no authored swatch named Ball%d", v3))
		end
	end

	for _, v3 in PoolTrickshotTypes.ModifierPaletteOrder() do
		local child = palette:FindFirstChild("Mod" .. v3)

		if child then
			state.ModSwatches[v3] = child

			if v3 == "Bullseye" then
				paintBullseye(child)
			end

			state.Maid:GiveTask(child.Activated:Connect(function()
				if state.Swapping then
					state.modifierSwapEvent:Fire(v3)

					return
				end

				PoolTrickshotMenu.SetPalette(state, v3)
				state.modifierEvent:Fire(v3)
			end))
		else
			warn(string.format("[Trickshot] no authored swatch named Mod%s", v3))
		end
	end

	local listToggle = state.Root:FindFirstChild("ListToggle")

	if listToggle then
		state.ListToggle = listToggle

		state.Maid:GiveTask(listToggle.Activated:Connect(function()
			PoolTrickshotMenu.SetPaletteList(state, not state.Ordinary)
		end))
	else
		warn("[Trickshot] no authored ListToggle on the menu; the normal ball list is unavailable")
	end

	applyPaletteList(state)
end

function PoolTrickshotMenu:SetPalette(armed)
	self.Armed = armed

	for k, swatch in self.Swatches do
		local edge = swatch:FindFirstChild("Edge")
		local v2 = k == armed
		local color2 = if v2 then color else Border
		edge.Color = color2
		edge.Thickness = v2 and 3 or 1
	end

	for k, modSwatch in self.ModSwatches do
		local edge = modSwatch:FindFirstChild("Edge")
		local v2 = k == armed
		local color2 = if v2 then color else Border
		edge.Color = color2
		edge.Thickness = v2 and 3 or 1
	end
end

function PoolTrickshotMenu:SetPaletteList(ordinary: boolean)
	self.Ordinary = ordinary
	applyPaletteList(self)

	local v2 = self.Armed

	if typeof(v2) == "number" then
		if not table.find(paletteOrder(self), v2) then -- inferred equivalent call
			v2 = PoolConstants.CueBallNumber
		end
	else
		v2 = PoolConstants.CueBallNumber
	end

	PoolTrickshotMenu.SetPalette(self, v2)
	self.paletteEvent:Fire(v2, self.Ordinary)

	local alignSnap = self.alignSnap

	if alignSnap then
		task.defer(alignSnap)
	end
end

local function bindSlider(data, childName: string, callback, p: number, fn, p2)
	local child = (p2 or data.Toolbar):FindFirstChild(childName)

	if not child then
		warn(string.format("[Trickshot] the authored toolbar has no %s", childName))

		return
	end

	local track = child:FindFirstChild("Track")
	local flag = false
	local connection = nil
	local inputEndedConnection = nil

	local flag2 = false

	local function grab() -- 3 equivalent calls inferred from this helper
		if not flag2 then
			flag2 = true
			data.sliderGestureEvent:Fire(true)
		end
	end

	local function release() -- 3 equivalent calls inferred from this helper
		if flag2 then
			flag2 = false
			data.sliderGestureEvent:Fire(false)
		end
	end

	track.Selectable = true
	track.NextSelectionLeft = track
	track.NextSelectionRight = track

	local function apply(x: number) -- 4 equivalent calls inferred from this helper
		local v2, v3 = callback()
		local x2 = track.AbsolutePosition.X
		local v4 = math.max(track.AbsoluteSize.X, 1)
		local v5 = math.clamp((x - x2) / v4, 0, 1)
		local v6 = v2 + (v3 - v2) * v5

		fn((math.clamp(math.round(v6 / p) * p, v2, v3)))
	end

	local function stepBy(p3: number) -- 2 equivalent calls inferred from this helper
		local v2, v3 = callback()
		local v4 = child:GetAttribute("Value")

		if typeof(v4) ~= "number" then
			v4 = v2
		end

		local v5 = math.round((v4 + p3 * p) / p) * p

		fn((math.clamp(v5, v2, v3)))
	end

	local function stop() -- 4 equivalent calls inferred from this helper
		flag = false

		if connection then
			connection:Disconnect()
			connection = nil
		end

		if inputEndedConnection then
			inputEndedConnection:Disconnect()
			inputEndedConnection = nil
		end

		release() -- inferred equivalent call
	end

	data.Maid:GiveTask(track.InputBegan:Connect(function(input)
		if isGamepadConfirm(input) then -- inferred equivalent call
			stop() -- inferred equivalent call
			flag = true
			grab() -- inferred equivalent call
			apply(UserInputService:GetMouseLocation().X) -- inferred equivalent call

			connection = RunService.RenderStepped:Connect(function()
				if flag then
					apply(UserInputService:GetMouseLocation().X) -- inferred equivalent call
				end
			end)

			inputEndedConnection = UserInputService.InputEnded:Connect(function(input2)
				if input2.KeyCode == Enum.KeyCode.ButtonA then
					stop() -- inferred equivalent call
				end
			end)
		else
			if
				input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			stop() -- inferred equivalent call
			flag = true
			grab() -- inferred equivalent call
			apply(input.Position.X) -- inferred equivalent call

			connection = UserInputService.InputChanged:Connect(function(input2)
				if not flag then
					return
				end

				if
					input2.UserInputType == Enum.UserInputType.MouseMovement
					or input2.UserInputType == Enum.UserInputType.Touch
				then
					apply(input2.Position.X) -- inferred equivalent call
				end
			end)

			inputEndedConnection = UserInputService.InputEnded:Connect(function(input2)
				if input2.UserInputType == input.UserInputType then
					stop() -- inferred equivalent call
				end
			end)
		end
	end))

	data.Maid:GiveTask(stop)

	local v2 = 0
	local keyCode = nil
	local v3 = 0

	data.Maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		local v4 = v[input.KeyCode]

		if not v4 or GuiService.SelectedObject ~= track or not child.Visible then
			return
		end

		v2 = v4
		keyCode = input.KeyCode
		v3 = os.clock() + 0.35
		grab() -- inferred equivalent call
		stepBy(v4) -- inferred equivalent call
	end))

	data.Maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == keyCode then
			v2 = 0
			keyCode = nil

			if not flag then
				release() -- inferred equivalent call
			end
		end
	end))

	data.Maid:GiveTask(RunService.Heartbeat:Connect(function()
		if v2 == 0 then
			return
		end

		if GuiService.SelectedObject == track and child.Visible then
			local now = os.clock()

			if v3 <= now then
				v3 = now + 0.06
				stepBy(v2) -- inferred equivalent call
			end
		else
			v2 = 0
			keyCode = nil

			if not flag then
				release() -- inferred equivalent call
			end
		end
	end))
end

local function setSliderDisplay(p, childName: string, p2: number, value: number, value2: number, text: string, p3)
	local child = (p3 or p.Toolbar):FindFirstChild(childName)

	if not child then
		return
	end

	local readout = child:FindFirstChild("Readout")
	readout.Text = text

	child:SetAttribute("Value", p2)

	local track = child:FindFirstChild("Track")

	if not track then
		return
	end

	if (typeof)(value) ~= "number" or (typeof)(value2) ~= "number" then
		warn(string.format("[Trickshot] %s was given a nil range and cannot be drawn", childName))

		return
	end

	local v2 = (math.max)(value2 - value, 1e-6)
	local v3 = math.clamp((p2 - value) / v2, 0, 1)

	local fill = track:FindFirstChild("Fill")

	if fill then
		fill.Size = UDim2.fromScale(v3, 1)
	end

	local knob = track:FindFirstChild("Knob")

	if knob then
		knob.Position = UDim2.fromScale(v3, 0.5)
	end
end

function PoolTrickshotMenu:SetSpeedDisplay(p: number)
	local speedToDial = PoolModifiers.SpeedToDial(p)

	self.SpeedMode = "Patrol"

	setSliderDisplay(
		self,
		"SpeedSlider",
		speedToDial,
		PoolModifiers.MinDial,
		PoolModifiers.MaxDial,
		(tostring(speedToDial))
	)
end

function PoolTrickshotMenu:SetSpinDisplay(p: number)
	self.SpeedMode = "Spin"

	setSliderDisplay(
		self,
		"SpeedSlider",
		PoolModifiers.SpinToDial(p),
		PoolModifiers.MinDial,
		PoolModifiers.MaxDial,
		string.format("%d°/s", (math.round(p)))
	)
end

function PoolTrickshotMenu.SetArmDisplay(p, p2: number, p3: number)
	setSliderDisplay(p, "LengthSlider", p2, PoolModifiers.MinSpinnerArm, PoolModifiers.MaxSpinnerArm, (tostring(p2)))

	setSliderDisplay(p, "WidthSlider", p3, PoolModifiers.MinSpinnerArm, PoolModifiers.MaxSpinnerArm, (tostring(p3)))
end

function PoolTrickshotMenu.SetRotationDisplay(p, p2: number)
	setSliderDisplay(p, "RotationSlider", p2 % 360, 0, 360, string.format("%d°", (math.round(p2 % 360))))
end

function PoolTrickshotMenu.SetStrengthDisplay(p, p2: number)
	setSliderDisplay(
		p,
		"StrengthSlider",
		p2,
		PoolModifiers.MinDial,
		PoolModifiers.MaxDial,
		(tostring((math.round(p2))))
	)
end

function PoolTrickshotMenu.SetScaleDisplay(p, p2: number)
	setSliderDisplay(p, "SizeSlider", p2, p.ScaleMin, p.ScaleMax, string.format("%.2fx", p2))
end

local function bindToolbar(state)
	local toolbar = state.Toolbar
	local swap = toolbar:FindFirstChild("Swap")
	local anchor = toolbar:FindFirstChild("Anchor")
	local target = toolbar:FindFirstChild("Target")
	local clone = toolbar:FindFirstChild("Clone")
	local delete = toolbar:FindFirstChild("Delete")

	state.Maid:GiveTask(swap.Activated:Connect(function()
		state.Swapping = not state.Swapping
		local caption = swap:FindFirstChild("Caption")
		caption.Text = state.Swapping and "PICK" or "SWAP"
		local setColour = PoolButtonSkin.SetColour
		local v2 = if state.Swapping then color else Neutral
		setColour(swap, v2)
	end))

	state.Maid:GiveTask(anchor.Activated:Connect(function()
		state.anchorEvent:Fire(anchor:GetAttribute("On") ~= true)
	end))

	state.Maid:GiveTask(target.Activated:Connect(function() end))

	state.Maid:GiveTask(clone.Activated:Connect(function()
		state.cloneEvent:Fire()
	end))

	state.Maid:GiveTask(delete.Activated:Connect(function()
		state.deleteEvent:Fire()
	end))
end

local function bindControls(data)
	local controls = data.Controls
	local play = controls:FindFirstChild("Play")

	for childName, v2 in {
		Exit = "exitEvent",
		Load = "loadEvent",
		Save = "saveEvent",
		Reset = "resetEvent",
		Publish = "publishEvent"
	} do
		local child = controls:FindFirstChild(childName)

		if child then
			data.Maid:GiveTask(child.Activated:Connect(function()
				data[v2]:Fire()
			end))
		end
	end

	data.Maid:GiveTask(play.Activated:Connect(function()
		if play:GetAttribute("Mode") == "Play" then
			data.editEvent:Fire()
		else
			data.playEvent:Fire()
		end
	end))
end

local function setToggle(instance, on: boolean, flag: boolean) -- 3 equivalent calls inferred from this helper
	instance:SetAttribute("On", on)
	local setColour = PoolButtonSkin.SetColour
	local v2 = if on then Go else Neutral
	setColour(instance, v2)
	instance.AutoButtonColor = flag
	instance.Active = flag
	instance.Selectable = flag
	local caption = instance:FindFirstChild("Caption")
	caption.TextTransparency = flag and 0 or 0.55
end

function PoolTrickshotMenu:SetSelection(list, options, p: number?, list2)
	local v2 = options or {}
	local v3 = #list + #v2

	self.Toolbar.Visible = v3 > 0
	self.HasSelection = v3 > 0
	PoolTrickshotMenu.RefreshTablePanel(self)

	if v3 == 0 then
		return
	end

	local speedSlider = self.Toolbar:FindFirstChild("SpeedSlider")
	local rotationSlider = self.Toolbar:FindFirstChild("RotationSlider")
	local strengthSlider = self.Toolbar:FindFirstChild("StrengthSlider")
	local lengthSlider = self.Toolbar:FindFirstChild("LengthSlider")
	local widthSlider = self.Toolbar:FindFirstChild("WidthSlider")

	if speedSlider then
		speedSlider.Visible = false
	end

	if rotationSlider then
		rotationSlider.Visible = false
	end

	if strengthSlider then
		strengthSlider.Visible = false
	end

	if lengthSlider then
		lengthSlider.Visible = false
	end

	if widthSlider then
		widthSlider.Visible = false
	end

	if #v2 > 0 then
		local s = v2[1].S or 1
		local v4 = true

		for _, v5 in v2 do
			if (v5.S or 1) ~= s then
				v4 = false
			end
		end

		local v5 = nil
		local v6 = nil

		for _, v7 in v2 do
			local scaleRange, v8 = PoolModifiers.ScaleRange(PoolModifiers.Get(v7.K))

			if v5 then
				v5 = math.min(v5, scaleRange)
			else
				v5 = scaleRange
			end

			if v6 then
				v6 = math.max(v6, v8)
			else
				v6 = v8
			end
		end

		self.ScaleMin = v5 or PoolModifiers.MinScale
		self.ScaleMax = v6 or PoolModifiers.MaxScale

		local anchor = self.Toolbar:FindFirstChild("Anchor")
		anchor:SetAttribute("On", false)
		PoolButtonSkin.SetColour(anchor, Neutral)
		anchor.AutoButtonColor = false
		anchor.Active = false
		anchor.Selectable = false
		local caption = anchor:FindFirstChild("Caption")
		caption.TextTransparency = 0.55

		local target = self.Toolbar:FindFirstChild("Target")
		target:SetAttribute("On", false)
		PoolButtonSkin.SetColour(target, Neutral)
		target.AutoButtonColor = false
		target.Active = false
		target.Selectable = false
		local caption_2 = target:FindFirstChild("Caption")
		caption_2.TextTransparency = 0.55

		setToggle(self.Toolbar:FindFirstChild("Swap"), self.Swapping, true) -- inferred equivalent call
		local v7 = true

		for _, v8 in v2 do
			local v9 = PoolModifiers.Get(v8.K)

			if not (v9 and v9.Rotatable) then
				v7 = false
				break
			end
		end

		if rotationSlider and v7 then
			rotationSlider.Visible = true
			PoolTrickshotMenu.SetRotationDisplay(self, v2[1].R or 0)
		end

		local v8 = true

		for _, v9 in v2 do
			if not PoolModifiers.HasStrength(PoolModifiers.Get(v9.K)) then
				v8 = false
				break
			end
		end

		if strengthSlider and v8 then
			local v9 = v2[1]
			local v10 = PoolModifiers.Get(v9.K)

			strengthSlider.Visible = true
			PoolTrickshotMenu.SetStrengthDisplay(
				self,
				PoolModifiers.StrengthToDial(v10, PoolModifiers.StrengthOf(v10, v9.P))
			)
		end

		PoolTrickshotMenu.SetScaleDisplay(self, s)

		local caption_3 = self.Toolbar:FindFirstChild("SizeSlider"):FindFirstChild("Caption")
		caption_3.Text = v4 and "SIZE" or "SIZE (MIXED)"
	else
		local s = list[1].S or 1

		self.ScaleMin = PoolTrickshotTypes.MinScale
		self.ScaleMax = PoolTrickshotTypes.MaxScale
		local v4 = true
		local v5 = false
		local v6 = false
		local v7 = true

		for _, item in list do
			local v8 = item.N == PoolConstants.CueBallNumber

			if not item.A then
				v4 = false
			end

			v6 = true
			v5 = not v8 or v5

			if (item.S or 1) ~= s then
				v7 = false
			end
		end

		local anchor = self.Toolbar:FindFirstChild("Anchor")
		local target = self.Toolbar:FindFirstChild("Target")
		local swap = self.Toolbar:FindFirstChild("Swap")
		setToggle(anchor, v4, v5) -- inferred equivalent call
		target:SetAttribute("On", false)
		PoolButtonSkin.SetColour(target, Neutral)
		target.AutoButtonColor = false
		target.Active = false
		target.Selectable = false
		local caption = target:FindFirstChild("Caption")
		caption.TextTransparency = 0.55

		setToggle(swap, self.Swapping, v6) -- inferred equivalent call

		local v8 = PoolModifiers.DefaultPatrolSpeed
		local v9 = true

		for k, item in list do
			if item.RX and item.RY then
				if k == 1 then
					v8 = item.RS or PoolModifiers.DefaultPatrolSpeed
				end
			else
				v9 = false
				break
			end
		end

		if speedSlider and p then
			speedSlider.Visible = true
			PoolTrickshotMenu.SetSpinDisplay(self, p)
		elseif speedSlider and v9 then
			speedSlider.Visible = true
			PoolTrickshotMenu.SetSpeedDisplay(self, v8)
		end

		if list2 and lengthSlider and widthSlider then
			lengthSlider.Visible = true
			widthSlider.Visible = true
			PoolTrickshotMenu.SetArmDisplay(self, list2[1], list2[2])
		end

		PoolTrickshotMenu.SetScaleDisplay(self, s)

		local caption_2 = self.Toolbar:FindFirstChild("SizeSlider"):FindFirstChild("Caption")
		caption_2.Text = v7 and "SIZE" or "SIZE (MIXED)"
	end
end

function PoolTrickshotMenu:SetCampaign(campaign: boolean)
	self.Campaign = campaign
	PoolTrickshotMenu.RefreshTablePanel(self)

	if campaign then
		self.Palette.Visible = false
		self.Toolbar.Visible = false
	else
		PoolTrickshotMenu.SetShotCount(self, nil, nil)
	end

	local save = self.Controls:FindFirstChild("Save")
	save.Visible = not campaign
	local load = self.Controls:FindFirstChild("Load")
	load.Visible = not campaign
	local play = self.Controls:FindFirstChild("Play")
	play.Visible = not campaign

	local reset = self.Controls:FindFirstChild("Reset")
	reset.Visible = not campaign
	local exit = self.Controls:FindFirstChild("Exit")
	exit.Visible = not campaign
	self.Controls.Visible = not campaign

	if campaign then
		PoolTrickshotMenu.SetPublishable(self, false)
	end
end

function PoolTrickshotMenu:SetPublishable(canPublish: boolean)
	self.CanPublish = canPublish

	local publish = self.Controls:FindFirstChild("Publish")

	if publish then
		publish.Visible = canPublish and not self.Campaign and self.Mode == "Play"
	end
end

function PoolTrickshotMenu.RefreshTablePanel(data)
	local visible = not data.Campaign and data.Mode ~= "Play"

	if data.Snap then
		data.Snap.Visible = visible
	end

	if data.ListToggle then
		data.ListToggle.Visible = visible
	end

	if data.History then
		data.History.Visible = visible
	end

	local tablePanel = data.TablePanel

	if not tablePanel then
		return
	end

	tablePanel.Visible = visible and not data.HasSelection
end

function PoolTrickshotMenu.SetSnapDisplay(p, p2: number)
	local snap = p.Snap

	if not snap then
		return
	end

	local caption = snap:FindFirstChild("Caption")

	if caption then
		caption.Text = not (p2 > 0) and "SNAP: OFF" or string.format("SNAP: %g BALL", p2)
	end

	local setColour = PoolButtonSkin.SetColour
	local v2 = if p2 > 0 then color else Neutral
	setColour(snap, v2)
end

function PoolTrickshotMenu.SetHistory(p, undo: boolean, redo: boolean)
	local history = p.History

	if not history then
		return
	end

	for childName, v2 in { Undo = undo, Redo = redo } do
		local child = history:FindFirstChild(childName)

		if not child then
			continue
		end

		child.AutoButtonColor = v2
		child.Selectable = v2
		PoolButtonSkin.SetFaded(child, v2 and 0 or 0.45)

		local caption = child:FindFirstChild("Caption")

		if caption then
			caption.TextTransparency = v2 and 0 or 0.55
		end
	end
end

function PoolTrickshotMenu:SetTableSizeDisplay(tableLength: number, tableHeight: number)
	self.TableLength = tableLength
	self.TableHeight = tableHeight

	local tablePanel = self.TablePanel

	if not tablePanel then
		return
	end

	setSliderDisplay(
		self,
		"LengthSlider",
		tableLength,
		PoolGeometry.MinScale,
		PoolGeometry.MaxScale,
		string.format("%.2fx", tableLength),
		tablePanel
	)
	setSliderDisplay(
		self,
		"HeightSlider",
		tableHeight,
		PoolGeometry.MinScale,
		PoolGeometry.MaxScale,
		string.format("%.2fx", tableHeight),
		tablePanel
	)
end

function PoolTrickshotMenu:SetMode(mode: string, flag: boolean)
	local play = self.Controls:FindFirstChild("Play")
	local v2 = mode == "Play"
	self.Mode = mode
	PoolTrickshotMenu.RefreshTablePanel(self)

	play:SetAttribute("Mode", mode)
	local caption = play:FindFirstChild("Caption")
	caption.Text = v2 and "EDIT" or "PLAY"
	local setColour = PoolButtonSkin.SetColour
	local v3 = if v2 then Neutral else Go
	setColour(play, v3)

	if not v2 then
		local caption_2 = play:FindFirstChild("Caption")
		caption_2.TextTransparency = flag and 0 or 0.5
	end

	if self.Campaign then
		self.Palette.Visible = false
		self.Toolbar.Visible = false
		self.Hint.Visible = false
		play.Visible = false
		local save = self.Controls:FindFirstChild("Save")
		save.Visible = false
		local load = self.Controls:FindFirstChild("Load")
		load.Visible = false
		local reset = self.Controls:FindFirstChild("Reset")
		reset.Visible = false
		local exit = self.Controls:FindFirstChild("Exit")
		exit.Visible = false
		self.Controls.Visible = false

		local publish = self.Controls:FindFirstChild("Publish")

		if publish then
			publish.Visible = false
		end
	else
		self.Controls.Visible = true
		local reset = self.Controls:FindFirstChild("Reset")
		reset.Visible = true

		self.Palette.Visible = not v2

		if v2 then
			self.Toolbar.Visible = false
			self.Hint.Visible = false
		end

		local save = self.Controls:FindFirstChild("Save")
		save.Visible = not v2
		local load = self.Controls:FindFirstChild("Load")
		load.Visible = not v2

		local exit = self.Controls:FindFirstChild("Exit")
		exit.Visible = not v2

		local publish = self.Controls:FindFirstChild("Publish")

		if publish then
			publish.Visible = v2 and self.CanPublish
		end
	end
end

function PoolTrickshotMenu.Toast(p, text: string)
	local now = os.clock()

	p.Toast.Text = text
	p.Toast.Visible = true
	p.Toast:SetAttribute("Token", now)

	task.delay(2.5, function()
		if p.Toast.Parent and p.Toast:GetAttribute("Token") == now then
			p.Toast.Visible = false
		end
	end)
end

function PoolTrickshotMenu.SetShotCount(p, value: number?, max: number?)
	if not value or not max or max <= 0 then
		p.Shots.Visible = false

		return
	end

	p.Shots.Visible = true

	p.Shots.Text = string.format("%d/%d attempt%s", math.clamp(value, 0, max), max, max == 1 and "" or "s")
end

function PoolTrickshotMenu.SetHint(p, value: string?)
	p.Hint.Text = value or ""
	p.Hint.Visible = value ~= nil
end

function PoolTrickshotMenu.SetVisible(p, visible: boolean)
	p.Root.Visible = visible
end

local function getAuthoredTree() -- 1 equivalent call inferred from this helper
	local frame = PoolTrickshotStyle.Authored("PoolTrickshotUI", "Menu")

	assert(frame:IsA("Frame"), "[Trickshot] PoolTrickshotUI.Menu must be a Frame")

	return frame
end

function PoolTrickshotMenu.new(parent)
	local maid = Maid.new()

	local trickshotMenu = getAuthoredTree():Clone() -- inferred equivalent call
	trickshotMenu.Name = "TrickshotMenu"
	trickshotMenu.Visible = true
	trickshotMenu.Parent = parent
	maid:GiveTask(trickshotMenu)

	local v2 = {}

	for _, v3 in {
		"palette",
		"modifier",
		"modifierSwap",
		"swap",
		"anchor",
		"target",
		"clone",
		"delete",
		"speed",
		"spin",
		"armLength",
		"armWidth",
		"rotation",
		"strength",
		"scale",
		"play",
		"reset",
		"edit",
		"save",
		"load",
		"exit",
		"tableSize",
		"undo",
		"redo",
		"sliderGesture",
		"snap",
		"publish"
	} do
		local bindableEvent = Instance.new("BindableEvent")
		maid:GiveTask(bindableEvent)
		v2[v3] = bindableEvent
	end

	local v3 = {
		Root = trickshotMenu,
		Palette = trickshotMenu:FindFirstChild("Palette"),
		Toolbar = trickshotMenu:FindFirstChild("Toolbar"),
		Controls = trickshotMenu:FindFirstChild("Controls"),
		Toast = trickshotMenu:FindFirstChild("Toast"),
		Hint = trickshotMenu:FindFirstChild("Hint"),
		Shots = trickshotMenu:FindFirstChild("Shots"),
		Swatches = {},
		ModSwatches = {},
		Swapping = false,
		Ordinary = false,
		ListToggle = nil,
		SwatchOrder = {},
		Armed = nil,
		Campaign = false,
		TablePanel = trickshotMenu:FindFirstChild("TablePanel"),
		TableLength = 1,
		TableHeight = 1,
		Mode = "Edit",
		HasSelection = false,
		SpeedMode = "Patrol",
		TableSizeChanged = v2.tableSize.Event,
		History = trickshotMenu:FindFirstChild("History"),
		UndoRequested = v2.undo.Event,
		RedoRequested = v2.redo.Event,
		SliderGesture = v2.sliderGesture.Event,
		Snap = trickshotMenu:FindFirstChild("Snap"),
		SnapRequested = v2.snap.Event,
		ScaleMin = PoolTrickshotTypes.MinScale,
		ScaleMax = PoolTrickshotTypes.MaxScale,
		PaletteSelected = v2.palette.Event,
		ModifierSelected = v2.modifier.Event,
		ModifierSwapRequested = v2.modifierSwap.Event,
		SwapRequested = v2.swap.Event,
		AnchorToggled = v2.anchor.Event,
		TargetToggled = v2.target.Event,
		CloneRequested = v2.clone.Event,
		DeleteRequested = v2.delete.Event,
		ScaleChanged = v2.scale.Event,
		SpeedChanged = v2.speed.Event,
		SpinChanged = v2.spin.Event,
		LengthChanged = v2.armLength.Event,
		WidthChanged = v2.armWidth.Event,
		RotationChanged = v2.rotation.Event,
		StrengthChanged = v2.strength.Event,
		PlayRequested = v2.play.Event,
		ResetRequested = v2.reset.Event,
		EditRequested = v2.edit.Event,
		SaveRequested = v2.save.Event,
		LoadRequested = v2.load.Event,
		ExitRequested = v2.exit.Event,
		PublishRequested = v2.publish.Event,
		CanPublish = false,
		Maid = maid,
		paletteEvent = v2.palette,
		modifierEvent = v2.modifier,
		modifierSwapEvent = v2.modifierSwap,
		swapEvent = v2.swap,
		anchorEvent = v2.anchor,
		targetEvent = v2.target,
		cloneEvent = v2.clone,
		deleteEvent = v2.delete,
		scaleEvent = v2.scale,
		speedEvent = v2.speed
	}
	v3.spinEvent = v2.spin
	v3.armLengthEvent = v2.armLength
	v3.armWidthEvent = v2.armWidth
	v3.rotationEvent = v2.rotation
	v3.strengthEvent = v2.strength
	v3.playEvent = v2.play
	v3.resetEvent = v2.reset
	v3.editEvent = v2.edit
	v3.saveEvent = v2.save
	v3.loadEvent = v2.load
	v3.exitEvent = v2.exit
	v3.publishEvent = v2.publish
	v3.tableSizeEvent = v2.tableSize
	v3.sliderGestureEvent = v2.sliderGesture

	bindPalette(v3)
	bindToolbar(v3)
	bindControls(v3)

	if v3.History then
		for childName, v4 in { Undo = v2.undo, Redo = v2.redo } do
			local child = v3.History:FindFirstChild(childName)

			if child then
				maid:GiveTask(child.Activated:Connect(function()
					v4:Fire()
				end))
			end
		end

		PoolTrickshotMenu.SetHistory(v3, false, false)
	else
		warn("[Trickshot] the authored menu has no History panel; undo/redo buttons are unavailable")
	end

	if v3.Snap then
		local snap = v3.Snap

		maid:GiveTask(snap.Activated:Connect(function()
			v2.snap:Fire()
		end))

		local function alignSnap()
			local v4 = paletteOrder(v3) -- inferred equivalent call
			local swatch = v3.Swatches[v4[1]]
			local swatch2 = v3.Swatches[v4[#v4]]

			if not swatch or not swatch2 or trickshotMenu.AbsoluteSize.X <= 0 then
				return
			end

			local v5 = (swatch.AbsolutePosition.X + (swatch2.AbsolutePosition.X + swatch2.AbsoluteSize.X)) / 2 - trickshotMenu.AbsolutePosition.X
			local v6 = v3.Palette.AbsolutePosition.Y + v3.Palette.AbsoluteSize.Y - trickshotMenu.AbsolutePosition.Y + 4

			local listToggle = v3.ListToggle

			if listToggle then
				local v7 = math.round(v5 - (snap.AbsoluteSize.X + 6 + listToggle.AbsoluteSize.X) / 2)

				snap.AnchorPoint = Vector2.new(0, 0)
				snap.Position = UDim2.fromOffset(v7, (math.round(v6)))
				listToggle.AnchorPoint = Vector2.new(0, 0)
				listToggle.Position = UDim2.fromOffset(v7 + snap.AbsoluteSize.X + 6, (math.round(v6)))
			else
				snap.AnchorPoint = Vector2.new(0.5, 0)
				snap.Position = UDim2.fromOffset(math.round(v5), (math.round(v6)))
			end
		end

		maid:GiveTask(trickshotMenu:GetPropertyChangedSignal("AbsoluteSize"):Connect(alignSnap))
		maid:GiveTask(v3.Palette:GetPropertyChangedSignal("AbsolutePosition"):Connect(alignSnap))

		local swatch = v3.Swatches[PoolTrickshotTypes.PaletteOrder()[1]]

		if swatch then
			maid:GiveTask(swatch:GetPropertyChangedSignal("AbsolutePosition"):Connect(alignSnap))
		end

		task.defer(alignSnap)

		v3.alignSnap = alignSnap
		PoolTrickshotMenu.SetSnapDisplay(v3, 0)
	else
		warn("[Trickshot] the authored menu has no Snap button; snapping is unavailable")
	end

	bindSlider(v3, "SizeSlider", function()
		return v3.ScaleMin, v3.ScaleMax
	end, 0.05, function(p)
		PoolTrickshotMenu.SetScaleDisplay(v3, p)
		v3.scaleEvent:Fire(p)
	end)

	bindSlider(v3, "SpeedSlider", function()
		return PoolModifiers.MinDial, PoolModifiers.MaxDial
	end, 1, function(p)
		if v3.SpeedMode == "Spin" then
			local dialToSpin = PoolModifiers.DialToSpin(p)

			PoolTrickshotMenu.SetSpinDisplay(v3, dialToSpin)
			v3.spinEvent:Fire(dialToSpin)
		else
			local dialToSpeed = PoolModifiers.DialToSpeed(p)

			PoolTrickshotMenu.SetSpeedDisplay(v3, dialToSpeed)
			v3.speedEvent:Fire(dialToSpeed)
		end
	end)

	bindSlider(v3, "LengthSlider", function()
		return PoolModifiers.MinSpinnerArm, PoolModifiers.MaxSpinnerArm
	end, 1, function(p)
		v3.armLengthEvent:Fire((math.round(p)))
	end)

	bindSlider(v3, "WidthSlider", function()
		return PoolModifiers.MinSpinnerArm, PoolModifiers.MaxSpinnerArm
	end, 1, function(p)
		v3.armWidthEvent:Fire((math.round(p)))
	end)

	bindSlider(v3, "RotationSlider", function(): (number, number)
		return 0, 360
	end, 15, function(p)
		PoolTrickshotMenu.SetRotationDisplay(v3, p)
		v3.rotationEvent:Fire(p % 360)
	end)

	bindSlider(v3, "StrengthSlider", function()
		return PoolModifiers.MinDial, PoolModifiers.MaxDial
	end, 1, function(p)
		PoolTrickshotMenu.SetStrengthDisplay(v3, p)
		v3.strengthEvent:Fire(p)
	end)

	if v3.TablePanel then
		local tablePanel = v3.TablePanel

		local function tableRange()
			return PoolGeometry.MinScale, PoolGeometry.MaxScale
		end

		bindSlider(v3, "LengthSlider", tableRange, PoolGeometry.ScaleStep, function(p)
			PoolTrickshotMenu.SetTableSizeDisplay(v3, p, v3.TableHeight)
			v3.tableSizeEvent:Fire(p, v3.TableHeight)
		end, tablePanel)

		bindSlider(v3, "HeightSlider", tableRange, PoolGeometry.ScaleStep, function(p)
			PoolTrickshotMenu.SetTableSizeDisplay(v3, v3.TableLength, p)
			v3.tableSizeEvent:Fire(v3.TableLength, p)
		end, tablePanel)

		PoolTrickshotMenu.SetTableSizeDisplay(v3, 1, 1)
	else
		warn("[Trickshot] the authored menu has no TablePanel; table size cannot be changed")
	end

	v3.Toolbar.Visible = false
	v3.Hint.Visible = false
	v3.Toast.Visible = false

	NormaliseZ(trickshotMenu)

	PoolTrickshotMenu.SetPalette(v3, PoolConstants.CueBallNumber)
	PoolTrickshotMenu.SetMode(v3, "Edit", false)

	return v3
end

function PoolTrickshotMenu.Destroy(p)
	p.Maid:DoCleaning()
end

return PoolTrickshotMenu