local CollectionService = game:GetService("CollectionService")

local PoolButtonSkin = {
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	Tag = "PoolButtonSkin",
	RectImage = "rbxassetid://17460666535",
	RoundImage = "rbxassetid://90486481588413",
	SliceCenter = Rect.new(30, 31, 30, 31)
}

local v = { Bevel = true, Gloss = true, Lip = true }

PoolButtonSkin.Exit = {
	Colour = Color3.new(1, 0, 0),
	Text = "←",
	FontFace = Font.new("rbxasset://fonts/families/Teko.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
	TextColour = Color3.new(1, 1, 1),
	Outline = Color3.new(0.298039, 0.0972549, 0.0972549),
	OutlineThickness = 2,
	LabelPosition = UDim2.fromScale(0.5, 0.4),
	LabelSize = UDim2.fromScale(1, 1)
}

local function keepsText(instance): boolean -- 2 equivalent calls inferred from this helper
	local background = instance:FindFirstChild("Background")

	return background ~= nil and background:GetAttribute("SkinKeepText") == true
end

function PoolButtonSkin.SetKeepText(instance, flag: boolean)
	local background = instance:FindFirstChild("Background")

	if background then
		background:SetAttribute("SkinKeepText", flag and true or nil)
	end
end

function PoolButtonSkin.OutlineFor(color: Color3)
	local hsv, v2, v3 = color:ToHSV()

	return Color3.fromHSV(hsv, v2, v3 * 0.75)
end

local function textStrokes(folder)
	local uiStrokes = {}

	for _, uiStroke in folder:GetDescendants() do
		if not uiStroke:IsA("UIStroke") then
			continue
		end

		local parent = uiStroke.Parent

		if not (parent and (parent:IsA("TextLabel") or parent:IsA("TextButton") or parent:IsA("TextBox")) and parent ~= folder) then
			continue
		end

		if parent:GetAttribute("PriceTagPriced") == true then
			continue
		end

		local parent2 = parent.Parent

		while parent2 and parent2 ~= folder and not parent2:IsA("GuiButton") do
			parent2 = parent2.Parent
		end

		if parent2 == folder then
			table.insert(uiStrokes, uiStroke)
		end
	end

	return uiStrokes
end

function PoolButtonSkin.CentreText(instance)
	if keepsText(instance) then -- inferred equivalent call
		return
	end

	local labels = {}

	for _, label in instance:GetChildren() do
		if label:IsA("TextLabel") then
			table.insert(labels, label)
		end
	end

	if #labels == 0 then
		return
	end

	local minValue = 1e999
	local maxValue = -1e999

	for _, v2 in labels do
		local scale = v2.Position.Y.Scale
		local scale2 = v2.Size.Y.Scale
		local y = v2.AnchorPoint.Y

		minValue = math.min(minValue, scale - scale2 * y)
		maxValue = math.max(maxValue, scale + scale2 * (1 - y))
	end

	local v2 = 0.46 - (minValue + maxValue) / 2

	for _, v3 in labels do
		local position = v3.Position
		local v4 = math.round((position.Y.Scale + v2) * 1000) / 1000

		v3.Position = UDim2.new(position.X.Scale, position.X.Offset, v4, position.Y.Offset)
	end
end

function PoolButtonSkin.PaintOutlines(instance, color: Color3)
	if keepsText(instance) then -- inferred equivalent call
		return
	end

	local outlineFor = PoolButtonSkin.OutlineFor(color)

	for _, v2 in textStrokes(instance) do
		v2.Color = outlineFor
	end
end

local function isSkinImage(image: string): boolean -- 1 equivalent call inferred from this helper
	return image == PoolButtonSkin.RectImage or image == PoolButtonSkin.RoundImage
end

function PoolButtonSkin.SliceScaleFor(vector2: Vector2)
	local v2 = math.min(vector2.X, vector2.Y)

	if v2 <= 0 then
		return 1
	end

	return (math.clamp(v2 / 72, 0.12, 1.5))
end

function PoolButtonSkin.FaceZIndex(folder)
	local minZIndex = 1e999

	for _, guiObject in folder:GetDescendants() do
		if
			not guiObject:IsA("GuiObject")
			or guiObject.Name == "Background"
			or (v[guiObject.Name] or guiObject.Parent and v[guiObject.Parent.Name])
		then
			continue
		end

		minZIndex = math.min(minZIndex, guiObject.ZIndex)
	end

	return (math.min(folder.ZIndex, minZIndex - 1))
end

function PoolButtonSkin.Face(instance)
	local background = instance:FindFirstChild("Background")

	if background and background:IsA("ImageLabel") and isSkinImage(background.Image) then -- inferred equivalent call
		return background
	end

	return nil
end

function PoolButtonSkin.IsSkinned(p): boolean
	return PoolButtonSkin.Face(p) ~= nil
end

local function tintOf(instance)
	local backgroundColor3 = instance.BackgroundColor3
	local uiGradient = instance:FindFirstChildOfClass("UIGradient")

	if uiGradient and backgroundColor3.R > 0.95 and backgroundColor3.G > 0.95 and backgroundColor3.B > 0.95 then
		return uiGradient.Color.Keypoints[1].Value
	end

	return backgroundColor3
end

local function isRound(parent): boolean -- 1 equivalent call inferred from this helper
	local uiCorner = parent:FindFirstChildOfClass("UICorner")

	return uiCorner ~= nil and uiCorner.CornerRadius.Scale >= 0.5
end

local function liftOwnText(button)
	if not button:IsA("TextButton") or button.Text == "" or button:FindFirstChild("Top") then
		return
	end

	local top = Instance.new("TextLabel")
	top.Name = "Top"
	top.BackgroundTransparency = 1
	top.AnchorPoint = Vector2.new(0.5, 0.5)
	top.Position = UDim2.fromScale(0.5, 0.5)
	top.Size = UDim2.fromScale(1, 1)
	top.Text = button.Text
	top.FontFace = button.FontFace
	top.TextColor3 = button.TextColor3
	top.TextScaled = button.TextScaled
	top.TextSize = button.TextSize
	top.TextWrapped = button.TextWrapped
	top.TextXAlignment = button.TextXAlignment
	top.TextYAlignment = button.TextYAlignment
	top.TextTransparency = button.TextTransparency
	top.ZIndex = button.ZIndex + 1
	top.Parent = button

	for _, child in button:GetChildren() do
		if child:IsA("UIPadding") or child:IsA("UITextSizeConstraint") then
			child.Parent = top
		end
	end

	button.Text = ""
end

function PoolButtonSkin:Apply(options)
	local v2 = options or {}
	local face = PoolButtonSkin.Face(self)

	if face then
		if v2.Tint then
			PoolButtonSkin.SetColour(self, v2.Tint)
		else
			if face:GetAttribute("SkinTint") == nil then
				face:SetAttribute("SkinTint", face.ImageColor3)
			end

			PoolButtonSkin.PaintOutlines(self, PoolButtonSkin.GetColour(self))
		end

		CollectionService:AddTag(face, PoolButtonSkin.Tag)

		return face
	else
		local v3

		if v2.Round == nil then
			v3 = isRound(self) -- inferred equivalent call
		else
			v3 = v2.Round
		end

		local v4 = v2.Tint

		if not v4 then
			v4 = self.BackgroundColor3
			local uiGradient = self:FindFirstChildOfClass("UIGradient")

			if uiGradient and v4.R > 0.95 and v4.G > 0.95 and v4.B > 0.95 then
				v4 = uiGradient.Color.Keypoints[1].Value
			end
		end

		local uiGradient = self:FindFirstChildOfClass("UIGradient")

		liftOwnText(self)

		local background = Instance.new("ImageLabel")
		background.Name = "Background"
		background.BackgroundTransparency = 1
		background.BorderSizePixel = 0
		background.AnchorPoint = Vector2.new(0.5, 0.5)
		background.Position = UDim2.fromScale(0.5, 0.5)
		background.Size = UDim2.fromScale(1, 1)
		background.ImageColor3 = v4
		background.ZIndex = PoolButtonSkin.FaceZIndex(self)
		background.Active = false
		background.Selectable = false

		if v3 then
			background.Image = PoolButtonSkin.RoundImage
			background.ScaleType = Enum.ScaleType.Stretch
		else
			background.Image = PoolButtonSkin.RectImage
			background.ScaleType = Enum.ScaleType.Slice
			background.SliceCenter = PoolButtonSkin.SliceCenter
			background.SliceScale = PoolButtonSkin.SliceScaleFor(self.AbsoluteSize)
		end

		background:SetAttribute("SkinTint", v4)
		background.Parent = self

		if v2.KeepGradient and uiGradient then
			uiGradient.Parent = background
		end

		for _, child in self:GetChildren() do
			if not (child ~= background and (child:IsA("UICorner") or child:IsA("UIGradient") or child:IsA("UIStroke") or v[child.Name])) then
				continue
			end

			child:Destroy()
		end

		self.BackgroundTransparency = 1

		self.BackgroundColor3 = v4

		PoolButtonSkin.PaintOutlines(self, v4)
		PoolButtonSkin.CentreText(self)

		CollectionService:AddTag(background, PoolButtonSkin.Tag)

		return background
	end
end

function PoolButtonSkin:SetColour(skinTint: Color3)
	self.BackgroundColor3 = skinTint

	local face = PoolButtonSkin.Face(self)

	if face then
		face.ImageColor3 = skinTint
		face:SetAttribute("SkinTint", skinTint)
		PoolButtonSkin.PaintOutlines(self, skinTint)
	end
end

function PoolButtonSkin.ApplyExit(parent)
	local exit = PoolButtonSkin.Exit
	local v2 = PoolButtonSkin.Apply(parent, { Tint = exit.Colour, Round = false })
	local top = nil

	for _, label in parent:GetChildren() do
		if not label:IsA("TextLabel") then
			continue
		end

		if top then
			label:Destroy()
		else
			top = label
		end
	end

	if not top then
		top = Instance.new("TextLabel")
		top.Name = "Top"
		top.BackgroundTransparency = 1
		top.ZIndex = v2.ZIndex + 1
		top.Parent = parent
	end

	top.AnchorPoint = Vector2.new(0.5, 0.5)
	top.Position = exit.LabelPosition
	top.Size = exit.LabelSize
	top.Text = exit.Text
	top.FontFace = exit.FontFace
	top.TextColor3 = exit.TextColour
	top.TextScaled = true
	top.TextTransparency = 0
	top.TextXAlignment = Enum.TextXAlignment.Center
	top.TextYAlignment = Enum.TextYAlignment.Center

	for _, uiPadding in top:GetChildren() do
		if uiPadding:IsA("UIPadding") then
			uiPadding:Destroy()
		end
	end

	local uiStroke = top:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = exit.Outline
	uiStroke.Thickness = exit.OutlineThickness
	uiStroke.Transparency = 0
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uiStroke.Parent = top

	v2:SetAttribute("SkinKeepText", true)

	return v2
end

function PoolButtonSkin.GetColour(p)
	local face = PoolButtonSkin.Face(p)
	local skinTint = face and face:GetAttribute("SkinTint")

	if typeof(skinTint) == "Color3" then
		return skinTint
	end

	return p.BackgroundColor3
end

function PoolButtonSkin:SetFaded(p: number)
	local face = PoolButtonSkin.Face(self)

	if face then
		face.ImageTransparency = p
	else
		self.BackgroundTransparency = p
	end
end

function PoolButtonSkin:Bind()
	local parent = self.Parent

	if not (parent and parent:IsA("GuiButton")) then
		return function() end
	end

	if typeof(self:GetAttribute("SkinTint")) ~= "Color3" then
		self:SetAttribute("SkinTint", self.ImageColor3)
	end

	local v2 = false
	local v3 = false
	local connections = {}

	local function paint()
		local skinTint = self:GetAttribute("SkinTint")

		if typeof(skinTint) ~= "Color3" then
			return
		end

		local active = parent.AutoButtonColor and parent.Active
		local v4 = active and v3 and 0.25 or active and v2 and 0.1 or 0

		if v4 > 0 then
			skinTint = skinTint:Lerp(Color3.new(0, 0, 0), v4)
		end

		self.ImageColor3 = skinTint
	end

	local function resize() -- 1 equivalent call inferred from this helper
		if self.ScaleType == Enum.ScaleType.Slice then
			local absoluteSize = parent.AbsoluteSize

			if absoluteSize.X > 0 and absoluteSize.Y > 0 then
				self.SliceScale = PoolButtonSkin.SliceScaleFor(absoluteSize)
			end
		end
	end

	local function connect(object, callback) -- 4 equivalent calls inferred from this helper
		table.insert(connections, object:Connect(callback))
	end

	table.insert(connections, parent.MouseEnter:Connect(function()
		v2 = true
		paint()
	end))
	table.insert(connections, parent.MouseLeave:Connect(function()
		v2 = false
		v3 = false
		paint()
	end))
	table.insert(connections, parent.MouseButton1Down:Connect(function()
		v3 = true
		paint()
	end))
	table.insert(connections, parent.MouseButton1Up:Connect(function()
		v3 = false
		paint()
	end))
	table.insert(connections, parent.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			v2 = false
			v3 = false
			paint()
		end
	end))

	connect(parent:GetPropertyChangedSignal("AutoButtonColor"), paint) -- inferred equivalent call
	connect(parent:GetPropertyChangedSignal("Active"), paint) -- inferred equivalent call
	connect(parent:GetPropertyChangedSignal("AbsoluteSize"), resize) -- inferred equivalent call
	connect(self:GetAttributeChangedSignal("SkinTint"), paint) -- inferred equivalent call
	table.insert(connections, parent.DescendantAdded:Connect(function(instance)
		if instance:IsA("UIStroke") or instance:IsA("TextLabel") or instance:IsA("TextButton") then
			task.defer(function()
				if self.Parent == parent then
					PoolButtonSkin.PaintOutlines(parent, PoolButtonSkin.GetColour(parent))
				end
			end)
		end
	end))

	PoolButtonSkin.PaintOutlines(parent, PoolButtonSkin.GetColour(parent))
	resize() -- inferred equivalent call
	paint()

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end
end

return PoolButtonSkin