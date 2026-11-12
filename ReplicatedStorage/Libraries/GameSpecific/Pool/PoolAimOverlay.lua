local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)
local PoolTableRenderer2D = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolTableRenderer2D)

local function frameW() -- 5 equivalent calls inferred from this helper
	return PoolTableRenderer2D.GetFrameSize().X
end

local function frameH() -- 6 equivalent calls inferred from this helper
	return PoolTableRenderer2D.GetFrameSize().Y
end

local vector2 = Vector2.new(0.5, 0.5)

local color = Color3.fromRGB(226, 64, 47)

local function toScale(vector2_2: Vector2) -- 4 equivalent calls inferred from this helper
	return UDim2.fromScale(0.5 + vector2_2.X / frameW(), 0.5 - vector2_2.Y / frameH()) -- inferred equivalent call
end

local function makeImage(guiObject, name: string, color2: Color3, p: number, data)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.AnchorPoint = vector2
	imageLabel.BorderSizePixel = 0
	imageLabel.Visible = false

	imageLabel.ZIndex = (not guiObject:IsA("GuiObject") and 0 or guiObject.ZIndex) + p
	local image

	if data then
		image = data.Image
	end

	local v

	if image == nil then
		v = false
	else
		v = image ~= ""
	end

	local transparency = data and data.Transparency or 0

	imageLabel.BackgroundColor3 = color2
	imageLabel.ImageColor3 = color2
	imageLabel.Image = not v and "" or image
	imageLabel.BackgroundTransparency = v and 1 or transparency
	imageLabel.ImageTransparency = not v and 1 or transparency

	if v and data then
		local scaleType = data.ScaleType and Enum.ScaleType[data.ScaleType]

		if scaleType then
			imageLabel.ScaleType = scaleType
		end

		if data.SliceCenter then
			imageLabel.SliceCenter = data.SliceCenter
		end

		if data.SliceSourceHeight then
			imageLabel:SetAttribute("SliceSourceHeight", data.SliceSourceHeight)
		end

		if data.SliceScale then
			imageLabel.SliceScale = data.SliceScale
		end

		if data.TileSize then
			imageLabel.TileSize = data.TileSize
		end
	end

	imageLabel.Parent = guiObject

	return imageLabel
end

local function tint(p, color2: Color3) -- 3 equivalent calls inferred from this helper
	p.BackgroundColor3 = color2
	p.ImageColor3 = color2
end

local function setLine(instance, vector2_2: Vector2, vector2_3: Vector2, p: number)
	local v = vector2_3 - vector2_2
	local magnitude = v.Magnitude

	if magnitude < 0.001 then
		instance.Visible = false
		return
	end

	instance.Position = toScale((vector2_2 + vector2_3) / 2) -- inferred equivalent call
	instance.Size = UDim2.fromScale(magnitude / frameW(), p / frameH()) -- inferred equivalent call
	instance.Rotation = math.deg((math.atan2(-v.Y, v.X)))
	instance.Visible = true

	local sliceSourceHeight = instance:GetAttribute("SliceSourceHeight")

	if sliceSourceHeight and instance.Parent then
		local y = instance.Parent.AbsoluteSize.Y

		if y > 0 then
			instance.SliceScale = math.max(p / frameH() * y / sliceSourceHeight, 0.01) -- inferred equivalent call
		end
	end
end

local PoolAimOverlay = {
	new = function(guiObject)
		local maid = Maid.new()
		local theme = PoolConstants.GetTheme()

		local aimOverlay = Instance.new("Frame")
		aimOverlay.Name = "AimOverlay"
		aimOverlay.BackgroundTransparency = 1
		aimOverlay.BorderSizePixel = 0
		aimOverlay.Size = UDim2.fromScale(1, 1)

		aimOverlay.ZIndex = (not guiObject:IsA("GuiObject") and 0 or guiObject.ZIndex) + 1
		aimOverlay.Parent = guiObject
		maid:GiveTask(aimOverlay)

		local aimArt = PoolConstants.AimArt

		local image = makeImage(aimOverlay, "CueStick", Color3.fromRGB(185, 138, 78), 30, aimArt.CueStick)
		local image2 = makeImage(aimOverlay, "AimLine", PoolConstants.AimLineColour, 31, aimArt.AimLine)
		local image3 = makeImage(aimOverlay, "ObjectLine", theme.Accent, 31, aimArt.ObjectLine)
		local image4 = makeImage(aimOverlay, "CueLine", PoolConstants.AimLineColour, 31, aimArt.CueLine)

		local image5 = makeImage(aimOverlay, "Ghost", Color3.new(1, 1, 1), 32, aimArt.Ghost)
		image5.Size = UDim2.fromScale(
			PoolConstants.BallDiameter / frameW() * 1.15, -- inferred equivalent call
			PoolConstants.BallDiameter / frameH() * 1.15 -- inferred equivalent call
		)
		local v

		if aimArt.Ghost == nil or aimArt.Ghost.Image == nil then
			v = false
		else
			v = aimArt.Ghost.Image ~= ""
		end

		if v then
			local uiStroke = image5:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke:Destroy()
			end
		else
			image5.BackgroundTransparency = 1

			local uiCorner = Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(1, 0)
			uiCorner.Parent = image5

			local uiStroke = image5:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke.Thickness = 1.5
				uiStroke.Color = Color3.new(1, 1, 1)
				uiStroke.Transparency = 0.25
			end
		end

		local heldBallHalo = PoolConstants.HeldBallHalo
		local colour = heldBallHalo.Colour
		local heldBallHalo2 = Instance.new("ImageLabel")
		heldBallHalo2.Name = "HeldBallHalo"
		heldBallHalo2.AnchorPoint = vector2
		heldBallHalo2.BorderSizePixel = 0
		heldBallHalo2.Visible = false

		heldBallHalo2.ZIndex = (not aimOverlay:IsA("GuiObject") and 0 or aimOverlay.ZIndex) + 29

		heldBallHalo2.BackgroundColor3 = colour
		heldBallHalo2.ImageColor3 = colour
		heldBallHalo2.Image = ""
		heldBallHalo2.BackgroundTransparency = 0
		heldBallHalo2.ImageTransparency = 1

		heldBallHalo2.Parent = aimOverlay

		local v2 = PoolConstants.BallDiameter * heldBallHalo.Scale
		heldBallHalo2.Size = UDim2.fromScale(v2 / frameW(), v2 / frameH()) -- inferred equivalent call
		heldBallHalo2.BackgroundTransparency = heldBallHalo.Transparency

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = heldBallHalo2

		local bindableEvent = Instance.new("BindableEvent")
		maid:GiveTask(bindableEvent)

		return {
			Root = aimOverlay,
			AimLine = image2,
			Ghost = image5,
			ObjectLine = image3,
			CueLine = image4,
			CueStick = image,
			Halo = heldBallHalo2,
			StickEnabled = true,
			GuidesEnabled = true,
			AccentColour = theme.Accent,
			PocketMarkers = {},
			PocketPicked = bindableEvent.Event,
			PocketPickedBindable = bindableEvent,
			PocketsKey = "",
			Maid = maid
		}
	end,
	ShowHeldBall = function(data, vector2_2: Vector2)
		data.Halo.Position = toScale(vector2_2) -- inferred equivalent call
		data.Halo.Visible = true

		data.CueStick.Visible = false
		data.AimLine.Visible = false
		data.Ghost.Visible = false
		data.ObjectLine.Visible = false
		data.CueLine.Visible = false
	end,
	HideHeldBall = function(p)
		p.Halo.Visible = false
	end,
	SetVisible = function(p, visible: boolean)
		p.Root.Visible = visible
	end,
	SetStickVisible = function(self, stickEnabled: boolean)
		self.StickEnabled = stickEnabled

		if not stickEnabled then
			self.CueStick.Visible = false
		end
	end,
	SetGuidesVisible = function(self, guidesEnabled: boolean)
		self.GuidesEnabled = guidesEnabled

		if not guidesEnabled then
			self.AimLine.Visible = false
			self.Ghost.Visible = false
			self.ObjectLine.Visible = false
			self.CueLine.Visible = false
		end
	end,
	IsAimShown = function(data)
		local instance

		if data.GuidesEnabled then
			instance = data.AimLine
		else
			instance = data.Root
		end

		if not (instance and instance.Visible) or data.Halo and data.Halo.Visible then
			return false
		end

		while instance do
			if instance:IsA("GuiObject") and not instance.Visible then
				return false
			end

			if instance:IsA("LayerCollector") then
				return instance.Enabled
			end

			instance = instance.Parent
		end

		return false
	end,
	HideGuides = function(data)
		data.AimLine.Visible = false
		data.Ghost.Visible = false
		data.ObjectLine.Visible = false
		data.CueLine.Visible = false
	end,
	Update = function(data, vector2_2: Vector2, vector2_3: Vector2, data2, value: number, p: number, flag: boolean?)
		if vector2_3.Magnitude < 0.0001 then
			return
		end

		local v = flag ~= false
		local color2 = if v then PoolConstants.AimLineColour else color
		local v2 = if v then data.AccentColour else color

		tint(data.AimLine, color2) -- inferred equivalent call
		tint(data.ObjectLine, v2) -- inferred equivalent call
		tint(data.CueLine, color2) -- inferred equivalent call

		local uiStroke = data.Ghost:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Color = color2
		end

		local unit = vector2_3.Unit

		local v3 = math.clamp(value, 0, 1) * 9 + 1.6
		local v4 = vector2_2 - unit * (PoolConstants.BallRadius + v3)
		local v5 = v4 - unit * 34

		if data.StickEnabled then
			setLine(data.CueStick, v5, v4, 0.85)
		else
			data.CueStick.Visible = false
		end

		if data2 and data2.Kind ~= "None" and data.GuidesEnabled then
			local ghost = data2.Ghost

			setLine(data.AimLine, vector2_2, ghost, 0.5)

			data.Ghost.Position = toScale(ghost) -- inferred equivalent call
			data.Ghost.Visible = true

			if data2.Kind == "Ball" and data2.ObjectDirection then
				local v6 = p * (data2.ImpactFraction or 1)

				if v6 > 0.25 then
					local v7 = ghost + data2.ObjectDirection * PoolConstants.BallDiameter
					setLine(data.ObjectLine, v7, v7 + data2.ObjectDirection * v6, 0.5)
				else
					data.ObjectLine.Visible = false
				end

				if not data2.CueDirection then
					data.CueLine.Visible = false
					return
				end

				local v7 = p * 0.55 * (data2.CueFraction or 1)

				if v7 > 0.25 then
					setLine(data.CueLine, ghost, ghost + data2.CueDirection * v7, 0.5)
				else
					data.CueLine.Visible = false
				end
			else
				data.ObjectLine.Visible = false
				data.CueLine.Visible = false
			end
		else
			data.AimLine.Visible = false
			data.Ghost.Visible = false
			data.ObjectLine.Visible = false
			data.CueLine.Visible = false
		end
	end
}

local color2 = Color3.fromRGB(255, 206, 84)
local v = PoolConstants.BallDiameter * 2.6

local function pocketSpot(item) -- 2 equivalent calls inferred from this helper
	return (item.MouthCentre + item.BowlCentre) / 2
end

function PoolAimOverlay:SetPockets(items)
	local v2 = {}

	for _, item in items do
		local v3 = pocketSpot(item) -- inferred equivalent call
		table.insert(v2, string.format("%s:%.2f,%.2f", item.Id, v3.X, v3.Y))
	end

	local joined = table.concat(v2, "|")

	if joined == self.PocketsKey then
		return
	end

	self.PocketsKey = joined

	for _, pocketMarker in self.PocketMarkers do
		pocketMarker:Destroy()
	end

	table.clear(self.PocketMarkers)

	local zIndex = self.Root.ZIndex + 33

	for _, item in items do
		local imageButton = Instance.new("ImageButton")
		imageButton.Name = "Pocket_" .. item.Id
		imageButton.AnchorPoint = vector2
		imageButton.Position = toScale(pocketSpot(item)) -- inferred equivalent call
		imageButton.Size = UDim2.fromScale(v / frameW(), v / frameH()) -- inferred equivalent call
		imageButton.BackgroundColor3 = color2
		imageButton.BackgroundTransparency = 1
		imageButton.BorderSizePixel = 0
		imageButton.Image = ""
		imageButton.AutoButtonColor = false
		imageButton.ZIndex = zIndex
		imageButton.Visible = false

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = imageButton

		local ring = Instance.new("UIStroke")
		ring.Name = "Ring"
		ring.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ring.Thickness = 2
		ring.Color = Color3.new(1, 1, 1)
		ring.Transparency = 0.45
		ring.Parent = imageButton

		local tag = Instance.new("TextLabel")
		tag.Name = "Tag"
		tag.AnchorPoint = Vector2.new(0.5, 1)
		tag.Position = UDim2.fromScale(0.5, -0.05)
		tag.Size = UDim2.fromScale(2.2, 0.55)
		tag.BackgroundTransparency = 1
		tag.Font = Enum.Font.GothamBlack
		tag.Text = "CALLED"
		tag.TextColor3 = color2
		tag.TextScaled = true
		tag.ZIndex = zIndex + 1
		tag.Visible = false

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1.5
		uiStroke.Color = Color3.fromRGB(40, 28, 8)
		uiStroke.Parent = tag
		tag.Parent = imageButton

		local id = item.Id

		self.Maid:GiveTask(imageButton.Activated:Connect(function()
			if imageButton.Active then
				self.PocketPickedBindable:Fire(id)
			end
		end))

		imageButton.Parent = self.Root
		self.PocketMarkers[id] = imageButton
	end
end

function PoolAimOverlay.ShowPocketCall(p, p2: string?, flag: boolean)
	for k, pocketMarker in p.PocketMarkers do
		local visible = k == p2
		local ring = pocketMarker:FindFirstChild("Ring")
		local tag = pocketMarker:FindFirstChild("Tag")

		pocketMarker.Visible = visible or flag
		pocketMarker.Active = flag
		pocketMarker.Interactable = flag
		pocketMarker.BackgroundTransparency = visible and 0.62 or 1

		if ring then
			local color3

			if visible then
				color3 = color2
			else
				color3 = Color3.new(1, 1, 1)
			end

			ring.Color = color3
			ring.Thickness = visible and 3 or 2
			ring.Transparency = visible and 0 or 0.45
		end

		if tag then
			tag.Visible = visible
		end
	end
end

function PoolAimOverlay.HidePocketCall(p)
	for _, pocketMarker in p.PocketMarkers do
		pocketMarker.Visible = false
		pocketMarker.Active = false
		pocketMarker.Interactable = false
	end
end

function PoolAimOverlay:Destroy()
	self.Maid:DoCleaning()
end

return PoolAimOverlay