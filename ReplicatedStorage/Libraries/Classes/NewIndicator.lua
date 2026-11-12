local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

assert(RunService:IsClient(), "NewIndicator is a client-only module and cannot be required on the server")

local LocalPlayer = Players.LocalPlayer

local v = nil

local function getGui(displayOrder: number) -- 1 equivalent call inferred from this helper
	if v and v.Parent then
		return v
	end

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local newIndicators = Instance.new("ScreenGui")
	newIndicators.Name = "NewIndicators"
	newIndicators.ResetOnSpawn = false
	newIndicators.IgnoreGuiInset = true
	newIndicators.DisplayOrder = displayOrder
	newIndicators.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	newIndicators.Parent = playerGui
	v = newIndicators
	return newIndicators
end

local function getWorldPosition(target)
	if target:IsA("Model") then
		local primaryPart = target.PrimaryPart

		if primaryPart then
			return primaryPart.Position
		end

		return target:GetPivot().Position
	end

	if target:IsA("BasePart") then
		return target.Position
	end

	if target:IsA("Attachment") then
		return target.WorldPosition
	end

	if target:IsA("PVInstance") then
		return target:GetPivot().Position
	end

	return nil
end

local v2 = {
	Vector3.new(-1, -1, -1),
	Vector3.new(-1, -1, 1),
	Vector3.new(-1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(1, -1, -1),
	Vector3.new(1, -1, 1),
	Vector3.new(1, 1, -1),
	Vector3.new(1, 1, 1)
}

local function getBoundingBox(instance)
	if instance:IsA("Model") then
		return instance:GetBoundingBox()
	end

	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end

	return nil, nil
end

local function isFullyVisible(currentCamera, target): boolean
	local cframe, v3

	if target:IsA("Model") then
		cframe, v3 = target:GetBoundingBox()
	elseif target:IsA("BasePart") then
		cframe = target.CFrame
		v3 = target.Size
	end

	if not (cframe and v3) then
		return false
	end

	local v4 = v3 / 2
	local viewportSize = currentCamera.ViewportSize

	for _, v5 in v2 do
		local worldToViewportPoint = currentCamera:WorldToViewportPoint((cframe:PointToWorldSpace(v5 * v4)))

		if
			worldToViewportPoint.Z <= 0
			or worldToViewportPoint.X < 0
			or worldToViewportPoint.X > viewportSize.X
			or worldToViewportPoint.Y < 0
			or worldToViewportPoint.Y > viewportSize.Y
		then
			return false
		end
	end

	return true
end

local NewIndicator = {}
NewIndicator.__index = NewIndicator

function NewIndicator.new(target, options)
	local config = options or {}

	local arrowSize = config.ArrowSize or 64
	local color = config.Color or Color3.new(1, 1, 1)
	local outlineColor = config.OutlineColor or Color3.new(0, 0, 0)
	local outlineThickness = config.OutlineThickness or 3

	local gui = getGui(config.DisplayOrder or 50) -- inferred equivalent call

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.Size = UDim2.fromOffset(0, 0)
	indicator.BackgroundTransparency = 1
	indicator.Visible = false
	indicator.Parent = gui
	local arrow

	if config.ArrowImage then
		arrow = Instance.new("ImageLabel")
		arrow.Image = config.ArrowImage
		arrow.ImageColor3 = color
		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.fromOffset(arrowSize, arrowSize)
	else
		arrow = Instance.new("TextLabel")
		arrow.Text = "▲"
		arrow.Font = Enum.Font.GothamBold
		arrow.TextColor3 = color
		arrow.TextScaled = true
		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.fromOffset(arrowSize, arrowSize)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = outlineColor
		uiStroke.Thickness = outlineThickness
		uiStroke.Parent = arrow
	end

	arrow.Name = "Arrow"
	arrow.AnchorPoint = Vector2.new(0.5, 0.5)
	arrow.Position = UDim2.fromOffset(0, 0)
	arrow.Parent = indicator

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Text = config.Text or "NEW"
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = color
	label.TextSize = math.max(14, (math.floor(arrowSize * 0.45)))
	label.BackgroundTransparency = 1
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Size = UDim2.fromOffset(arrowSize * 2.4, arrowSize * 0.6)
	label.Position = UDim2.fromOffset(0, arrowSize)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = outlineColor
	uiStroke.Thickness = outlineThickness
	uiStroke.Parent = label
	label.Parent = indicator

	local self = setmetatable({
		_target = target,
		_config = config,
		_conn = nil,
		_container = indicator,
		_arrow = arrow,
		_label = label,
		_highlight = nil,
		_arrowSize = arrowSize,
		_edgeMargin = config.EdgeMargin or 48,
		_onScreenOffset = config.OnScreenOffset or 70,
		_bob = config.Bob ~= false,
		_hideDistance = config.HideDistance,
		_autoDismiss = config.AutoDismiss ~= false,
		_dismissing = false,
		_destroyed = false
	}, NewIndicator)
	self:_setupHighlight()
	self:_start()
	return self
end

function NewIndicator:_setupHighlight()
	local config = self._config

	if config.ShowHighlight == false then
		return
	end

	local target = self._target

	if not (target and (target:IsA("Model") or target:IsA("BasePart"))) then
		return
	end

	local newHighlight = Instance.new("Highlight")
	newHighlight.Name = "NewHighlight"
	newHighlight.FillColor = config.HighlightFillColor or Color3.fromRGB(255, 255, 120)
	newHighlight.OutlineColor = config.HighlightOutlineColor or Color3.fromRGB(255, 255, 255)
	newHighlight.FillTransparency = config.HighlightFillTransparency or 1
	newHighlight.OutlineTransparency = config.HighlightOutlineTransparency or 0
	local depthMode

	if config.HighlightAlwaysOnTop then
		depthMode = Enum.HighlightDepthMode.AlwaysOnTop
	else
		depthMode = Enum.HighlightDepthMode.Occluded
	end

	newHighlight.DepthMode = depthMode

	newHighlight.Adornee = target
	newHighlight.Parent = target
	self._highlight = newHighlight
end

function NewIndicator:_start()
	self._conn = RunService.RenderStepped:Connect(function()
		self:_update()
	end)
end

function NewIndicator:_hideAll()
	self._container.Visible = false

	if self._highlight then
		self._highlight.Enabled = false
	end
end

function NewIndicator:_update()
	if self._destroyed then
		return
	end

	local currentCamera = Workspace.CurrentCamera
	local target = self._target

	if not (currentCamera and target and target.Parent) then
		self:_hideAll()
		return
	end

	local worldPosition = getWorldPosition(target)

	if not worldPosition then
		self:_hideAll()
		return
	end

	local character = self._hideDistance and LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if
			humanoidRootPart
			and humanoidRootPart:IsA("BasePart")
			and (humanoidRootPart.Position - worldPosition).Magnitude <= self._hideDistance
		then
			self:_hideAll()
			return
		end
	end

	if self._highlight then
		self._highlight.Enabled = true
	end

	local viewportSize = currentCamera.ViewportSize
	local halfViewportSize = viewportSize / 2
	local worldToViewportPoint = currentCamera:WorldToViewportPoint(worldPosition)
	local z = worldToViewportPoint.Z
	local vector2 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
	local v3

	if z > 0 and vector2.X >= 0 and vector2.X <= viewportSize.X and vector2.Y >= 0 then
		v3 = vector2.Y <= viewportSize.Y
	else
		v3 = false
	end

	self._container.Visible = true

	if v3 then
		self:_renderOnScreen(vector2)
	else
		self:_renderOffScreen(vector2, z, halfViewportSize, viewportSize)
	end

	if self._dismissing then
		return
	end

	if self._autoDismiss then
		local v4

		if target:IsA("Model") then
			v4 = target:GetBoundingBox()
		elseif target:IsA("BasePart") then
			v4 = target.CFrame
			local _size = target.Size
		end

		if v4 then
			v3 = isFullyVisible(currentCamera, target)
		end

		if v3 then
			self:_dismiss()
		end
	end
end

function NewIndicator:_renderOnScreen(vector2: Vector2)
	self._container.Position = UDim2.fromOffset(vector2.X, vector2.Y)

	local v3 = not self._bob and 0 or math.sin(os.clock() * 5) * 6
	local v4 = self._onScreenOffset + v3

	self._arrow.Rotation = 180
	self._arrow.Position = UDim2.fromOffset(0, -v4)

	self._label.Rotation = 0
	self._label.Position = UDim2.fromOffset(0, -v4 - self._arrowSize * 0.85)
end

function NewIndicator:_renderOffScreen(vector2: Vector2, p: number, vector2_2: Vector2, vector2_3: Vector2)
	local v3 = vector2 - vector2_2

	if p < 0 then
		v3 = -v3
	end

	if v3.Magnitude < 0.0001 then
		v3 = Vector2.new(0, 1)
	end

	local unit = v3.Unit

	local edgeMargin = self._edgeMargin
	local v4 = math.max(vector2_3.X / 2 - edgeMargin, 0)
	local v5 = math.max(vector2_3.Y / 2 - edgeMargin, 0)

	local v6 = vector2_2 + unit * math.min(
		not (math.abs(unit.X) > 0.00001) and 1e999 or v4 / math.abs(unit.X),
		not (math.abs(unit.Y) > 0.00001) and 1e999 or v5 / math.abs(unit.Y)
	)

	self._container.Position = UDim2.fromOffset(v6.X, v6.Y)

	self._arrow.Rotation = math.deg((math.atan2(unit.X, -unit.Y)))

	local v7 = not self._bob and 0 or (math.sin(os.clock() * 6) * 0.5 + 0.5) * 10
	self._arrow.Position = UDim2.fromOffset(unit.X * v7, unit.Y * v7)

	self._label.Rotation = 0
	self._label.Position = UDim2.fromOffset(-unit.X * self._arrowSize * 0.95, -unit.Y * self._arrowSize * 0.95)
end

function NewIndicator:_dismiss()
	if self._dismissing or self._destroyed then
		return
	end

	self._dismissing = true

	local config = self._config
	local dismissTime = config.DismissTime or 2
	local v3 = math.clamp(config.DismissFade or 0.5, 0, dismissTime)
	local v4 = dismissTime - v3

	task.delay(v4, function()
		if self._destroyed then
			return
		end

		local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		TweenService:Create(self._container, tweenInfo, { Size = UDim2.fromScale(0, 0) }):Play()

		local arrow = self._arrow

		if arrow:IsA("ImageLabel") then
			TweenService:Create(arrow, tweenInfo, { ImageTransparency = 1 }):Play()
		elseif arrow:IsA("TextLabel") then
			TweenService:Create(arrow, tweenInfo, { TextTransparency = 1 }):Play()
		end

		local uiStroke = arrow:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			TweenService:Create(uiStroke, tweenInfo, { Transparency = 1 }):Play()
		end

		TweenService:Create(self._label, tweenInfo, { TextTransparency = 1 }):Play()
		local uiStroke2 = self._label:FindFirstChildOfClass("UIStroke")

		if uiStroke2 then
			TweenService:Create(uiStroke2, tweenInfo, { Transparency = 1 }):Play()
		end

		if self._highlight then
			TweenService:Create(self._highlight, tweenInfo, {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		end

		task.delay(v3, function()
			self:Destroy()
		end)
	end)
end

function NewIndicator:SetTarget(target)
	self._target = target
	self._dismissing = false

	if self._highlight then
		self._highlight:Destroy()
		self._highlight = nil
	end

	self:_setupHighlight()
end

function NewIndicator:SetText(text: string)
	self._label.Text = text
end

function NewIndicator:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	if self._highlight then
		self._highlight:Destroy()
		self._highlight = nil
	end

	self._container:Destroy()
end

return NewIndicator