local CollectionService = game:GetService("CollectionService")

local PoolButtonSkin = require(script.Parent.PoolButtonSkin)

local PoolPriceTag = {
	["Tag"] = nil,
	["Tag"] = nil,
	["Tag"] = nil,
	Tag = "PoolPriceTag",
	IconImage = "rbxassetid://108026607903890",
	IconColour = Color3.new(1, 1, 1),
	ButtonColour = Color3.new(0, 1, 0),
	Outline = Color3.new(0, 0, 0),
	Icon = function(p)
		local parent = p.Parent
		local robuxIcon = parent and parent:FindFirstChild("RobuxIcon")

		if robuxIcon and robuxIcon:IsA("ImageLabel") then
			return robuxIcon
		end

		return nil
	end
}

local function record(instance, instance2)
	if instance:GetAttribute("PriceTagLabelPos") == nil then
		instance:SetAttribute("PriceTagLabelPos", instance.Position)
		instance:SetAttribute("PriceTagLabelSize", instance.Size)
		instance:SetAttribute("PriceTagLabelAnchor", instance.AnchorPoint)
		instance:SetAttribute("PriceTagLabelAlign", instance.TextXAlignment.Name)
	end

	local uiStroke = instance:GetAttribute("PriceTagStroke") == nil and instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		instance:SetAttribute("PriceTagStroke", uiStroke.Color)
	end

	if instance2:GetAttribute("PriceTagIconPos") == nil then
		instance2:SetAttribute("PriceTagIconPos", instance2.Position)
		instance2:SetAttribute("PriceTagIconAnchor", instance2.AnchorPoint)
	end
end

function PoolPriceTag.FitIcon(instance, instance2)
	local v = instance:GetAttribute("PriceTagLabelPos")
	local v2 = instance:GetAttribute("PriceTagLabelAnchor")

	if typeof(v) ~= "UDim2" or typeof(v2) ~= "Vector2" then
		v = instance.Position
		v2 = instance.AnchorPoint
	end

	instance2.Size = UDim2.new(instance2.Size.X.Scale, instance2.Size.X.Offset, 0.65, 0)

	local priceTagIconPos = instance2:GetAttribute("PriceTagIconPos")
	local x

	if typeof(priceTagIconPos) == "UDim2" then
		x = priceTagIconPos.X
	else
		x = instance2.Position.X
	end

	local udim = UDim2.new(x.Scale, x.Offset, v.Y.Scale + 0.02, v.Y.Offset)
	local vector2 = Vector2.new(instance2.AnchorPoint.X, v2.Y)

	instance2:SetAttribute("PriceTagIconPos", udim)
	instance2:SetAttribute("PriceTagIconAnchor", vector2)
	instance2.Position = UDim2.new(instance2.Position.X.Scale, instance2.Position.X.Offset, udim.Y.Scale, udim.Y.Offset)
	instance2.AnchorPoint = Vector2.new(instance2.AnchorPoint.X, vector2.Y)
end

local function paintOutline(parent, priceTagPriced: boolean) -- 1 equivalent call inferred from this helper
	parent:SetAttribute("PriceTagPriced", priceTagPriced)

	if priceTagPriced then
		local v = parent:FindFirstChildOfClass("UIStroke")

		if not v then
			v = Instance.new("UIStroke")
			v.Thickness = 2
			v.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			v.Parent = parent
		end

		v.Color = PoolPriceTag.Outline
	else
		local parent2 = parent.Parent

		if parent2 and PoolButtonSkin.IsSkinned(parent2) then
			PoolButtonSkin.PaintOutlines(parent2, PoolButtonSkin.GetColour(parent2))
			return
		end

		local priceTagStroke = parent:GetAttribute("PriceTagStroke")
		local uiStroke = parent:FindFirstChildOfClass("UIStroke")

		if uiStroke and typeof(priceTagStroke) == "Color3" then
			uiStroke.Color = priceTagStroke
		end
	end
end

local function restore(instance, instance2)
	local priceTagLabelPos = instance:GetAttribute("PriceTagLabelPos")
	local priceTagLabelSize = instance:GetAttribute("PriceTagLabelSize")
	local priceTagLabelAnchor = instance:GetAttribute("PriceTagLabelAnchor")
	local priceTagLabelAlign = instance:GetAttribute("PriceTagLabelAlign")

	if
		typeof(priceTagLabelPos) == "UDim2"
		and typeof(priceTagLabelSize) == "UDim2"
		and typeof(priceTagLabelAnchor) == "Vector2"
	then
		instance.Position = priceTagLabelPos
		instance.Size = priceTagLabelSize
		instance.AnchorPoint = priceTagLabelAnchor
	end

	if typeof(priceTagLabelAlign) == "string" then
		instance.TextXAlignment = Enum.TextXAlignment[priceTagLabelAlign]
	end

	local priceTagIconPos = instance2:GetAttribute("PriceTagIconPos")
	local priceTagIconAnchor = instance2:GetAttribute("PriceTagIconAnchor")

	if typeof(priceTagIconPos) == "UDim2" and typeof(priceTagIconAnchor) == "Vector2" then
		instance2.Position = priceTagIconPos
		instance2.AnchorPoint = priceTagIconAnchor
	end
end

local function makeIcon(instance)
	local robuxIcon = Instance.new("ImageLabel")
	robuxIcon.Name = "RobuxIcon"
	robuxIcon.BackgroundTransparency = 1
	robuxIcon.Image = PoolPriceTag.IconImage
	robuxIcon.ImageColor3 = PoolPriceTag.IconColour
	robuxIcon.ScaleType = Enum.ScaleType.Fit
	robuxIcon.AnchorPoint = Vector2.new(1, 0.5)
	robuxIcon.Size = UDim2.fromScale(1, instance.Size.Y.Scale * 1.1)
	robuxIcon.Position = UDim2.new(
		instance.Position.X.Scale,
		instance.Position.X.Offset,
		instance.Position.Y.Scale + (0.5 - instance.AnchorPoint.Y) * instance.Size.Y.Scale,
		instance.Position.Y.Offset
	)

	robuxIcon.ZIndex = instance.ZIndex
	robuxIcon.Visible = false

	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uiAspectRatioConstraint.Parent = robuxIcon

	robuxIcon.Parent = instance.Parent

	return robuxIcon
end

function PoolPriceTag.Attach(instance)
	local selected = PoolPriceTag.Icon(instance) or makeIcon(instance)

	record(instance, selected)
	PoolPriceTag.FitIcon(instance, selected)
	CollectionService:AddTag(instance, PoolPriceTag.Tag)

	return selected
end

function PoolPriceTag:SetText(text: string)
	local v = PoolPriceTag.Icon(self) or PoolPriceTag.Attach(self)
	local match = text:match("^%s*R%$%s*(.-)%s*$")

	if match then
		self.Text = match
		v.Visible = true
	else
		self.Text = text
		v.Visible = false
	end

	PoolPriceTag.Layout(self)
end

function PoolPriceTag:Layout()
	local icon = PoolPriceTag.Icon(self)
	local parent = self.Parent

	if not (icon and parent and parent:IsA("GuiObject")) then
		return
	end

	record(self, icon)

	if icon.Visible and self.Text ~= "" then
		paintOutline(self, true) -- inferred equivalent call
		local x = parent.AbsoluteSize.X
		local x2 = icon.AbsoluteSize.X

		if x <= 0 or x2 <= 0 then
			return
		end

		local priceTagLabelPos = self:GetAttribute("PriceTagLabelPos")
		local priceTagLabelSize = self:GetAttribute("PriceTagLabelSize")
		local priceTagLabelAnchor = self:GetAttribute("PriceTagLabelAnchor")
		local priceTagIconPos = icon:GetAttribute("PriceTagIconPos")
		local priceTagIconAnchor = icon:GetAttribute("PriceTagIconAnchor")

		local v = x2 * 0.12
		local v2 = priceTagLabelSize.X.Scale * x + priceTagLabelSize.X.Offset

		local v3 = math.max(1, (math.min(v2, x * 0.92 - x2 - v)))

		self.Size = UDim2.new(0, v3, priceTagLabelSize.Y.Scale, priceTagLabelSize.Y.Offset)
		self.TextXAlignment = Enum.TextXAlignment.Left

		local v4 = math.min(self.TextBounds.X, v3)
		local v5 = x2 + v + v4

		local v6 = priceTagLabelPos.X.Scale * x + priceTagLabelPos.X.Offset + (0.5 - priceTagLabelAnchor.X) * v2 - v5 / 2

		icon.AnchorPoint = Vector2.new(0, priceTagIconAnchor.Y)
		icon.Position = UDim2.new(0, math.floor(v6 + 0.5), priceTagIconPos.Y.Scale, priceTagIconPos.Y.Offset)

		self.AnchorPoint = Vector2.new(0, priceTagLabelAnchor.Y)
		self.Position = UDim2.new(0, math.floor(v6 + x2 + v + 0.5), priceTagLabelPos.Y.Scale, priceTagLabelPos.Y.Offset)
	else
		restore(self, icon)

		if self:GetAttribute("PriceTagPriced") ~= false then
			paintOutline(self, false)
		end
	end
end

function PoolPriceTag.Bind(instance)
	local icon = PoolPriceTag.Icon(instance)
	local parent = instance.Parent

	if not (icon and parent and parent:IsA("GuiObject")) then
		return function() end
	end

	local connections = {}
	local flag = false

	local function relayout()
		if flag then
			return
		end

		flag = true

		task.defer(function()
			flag = false

			if instance.Parent == parent then
				PoolPriceTag.Layout(instance)
			end
		end)
	end

	for _, v in {
		instance:GetPropertyChangedSignal("TextBounds"),
		instance:GetPropertyChangedSignal("Text"),
		parent:GetPropertyChangedSignal("AbsoluteSize"),
		icon:GetPropertyChangedSignal("AbsoluteSize"),
		icon:GetPropertyChangedSignal("Visible")
	} do
		table.insert(connections, v:Connect(relayout))
	end

	PoolPriceTag.Layout(instance)

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end
end

return PoolPriceTag