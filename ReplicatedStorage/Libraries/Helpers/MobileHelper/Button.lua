local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Classes"):WaitForChild("Maid"))

local Assets = ReplicatedStorage.Assets
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = workspace.CurrentCamera
local button = Assets.MobileHelper.Button

local Button = {}
Button.__index = Button

function Button.new(image, imageDown, scale, p, imageCountdown, p2: string?)
	local object = setmetatable({}, Button)

	object.enabled = false
	object.pressed = false
	object.image = image
	object.imageDown = imageDown
	object.imageCountdown = imageCountdown
	object.scale = scale

	object.button = button:Clone()
	object.button.Image = image

	local touchGui = PlayerGui:WaitForChild("TouchGui")
	local jumpButton = PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")

	object.button.Parent = touchGui
	object.text = ""
	object:SetText(p2)

	object.maid = Maid.new()

	local function update()
		object.button.Position = jumpButton.Position - UDim2.new(
			0,
			jumpButton.Size.Y.Offset * p.X,
			0,
			jumpButton.Size.Y.Offset * p.Y
		)
		object.button.Size = UDim2.new(
			jumpButton.Size.X.Scale * scale,
			jumpButton.Size.X.Offset * scale,
			jumpButton.Size.Y.Scale * scale,
			jumpButton.Size.Y.Offset * scale
		)
	end

	update()
	object.maid.viewportSizeChange = CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
	object.maid.jumpButtonPositionChange = jumpButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
	object.maid.jumpButtonSizeChange = jumpButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)

	if object.imageCountdown then
		object.button.Countdown.Icon.Image = object.imageCountdown
	end

	object.activatedEvent = Instance.new("BindableEvent")
	object.Activated = object.activatedEvent.Event
	object.deactivatedEvent = Instance.new("BindableEvent")
	object.Deactivated = object.deactivatedEvent.Event
	object.enabledEvent = Instance.new("BindableEvent")
	object.Enabled = object.enabledEvent.Event
	object.disabledEvent = Instance.new("BindableEvent")
	object.Disabled = object.disabledEvent.Event
	object.changedEvent = Instance.new("BindableEvent")
	object.Changed = object.changedEvent.Event
	object.destroyedEvent = Instance.new("BindableEvent")
	object.Destroyed = object.destroyedEvent.Event
	object.lastActivated = tick()
	object.holdEvent = Instance.new("BindableEvent")
	object.Held = object.holdEvent.Event
	object:Enable()

	return object
end

function Button:SetText(value)
	self.text = value or ""
	self.button.Name = self.text
	self.button.TextLabel.Text = self.text
end

function Button.Countdown(p, p2: number, p3: number)
	if p2 > 0 then
		p.button.Countdown.Size = UDim2.new(1, 0, p3, 0)
		p.button.Countdown.Icon.Size = UDim2.new(1, 0, 1 / p3, 0)
		p.button.Timer.Text = tostring(p2)
	else
		p.button.Countdown.Size = UDim2.new(1, 0, 0, 0)
		p.button.Countdown.Icon.Size = UDim2.new(1, 0, 0, 0)
		p.button.Timer.Text = ""
	end
end

function Button.Highlight(p)
	local clone = Assets.MobileHelper.Highlight:Clone()
	clone.Parent = p.button
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
		clone.Rotation *= dt * 16
	end)
	function p.maid.highlight()
		clone:Destroy()
		heartbeatConnection:Disconnect()
	end
end

function Button.StopHighlight(p)
	p.maid.highlight = nil
end

function Button:Enable()
	if self.enabled then
		return
	end

	self.maid.inputStart = self.button.MouseButton1Down:Connect(function()
		self:ForceActivate()
	end)

	self.maid.inputEnd = self.button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			self:ForceDeactivate()
		end
	end)

	self.enabled = true
	self.enabledEvent:Fire()
end

function Button:Disable()
	if not self.enabled then
		return
	end

	self.maid.inputStart = nil
	self.maid.inputEnd = nil

	self:ForceDeactivate()
	self.enabled = false
	self.disabledEvent:Fire()
end

function Button:ForceActivate()
	if self.activated then
		return
	end

	self.activated = true
	self.lastActivated = tick()
	self.activatedEvent:Fire()
	self.holdConnect = RunService.Heartbeat:Connect(function()
		self.holdEvent:Fire(tick() - self.lastActivated)
	end)
end

function Button:ForceDeactivate()
	if not self.activated then
		return
	end

	self.activated = false
	self.deactivatedEvent:Fire(tick() - self.lastActivated)

	if self.holdConnect then
		self.holdConnect:Disconnect()
		self.holdConnect = nil
	end
end

function Button:Press()
	self.pressed = true
	self.button.Image = self.imageDown
end

function Button:Release()
	self.pressed = false
	self.button.Image = self.image
end

function Button:Change(image: string?, imageDown: string?, scale: number?, vector2: Vector2?)
	PlayerGui:WaitForChild("TouchGui")
	local jumpButton = PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")

	if image then
		self.image = image

		if not self.pressed then
			self:Release()
		end
	end

	if imageDown then
		self.imageDown = imageDown

		if self.pressed then
			self:Press()
		end
	end

	if scale then
		self.button.Size = UDim2.new(
			jumpButton.Size.X.Scale * scale,
			jumpButton.Size.X.Offset * scale,
			jumpButton.Size.Y.Scale * scale,
			jumpButton.Size.Y.Offset * scale
		)

		self.scale = scale
	end

	if vector2 then
		self.button.Position = jumpButton.Position - UDim2.new(
			0,
			jumpButton.Size.Y.Offset * vector2.X,
			0,
			jumpButton.Size.Y.Offset * vector2.Y
		)
	end

	self.changedEvent:Fire()
end

function Button.SetVisible(p, visible)
	p.button.Visible = visible
end

function Button:Destroy()
	self.destroyedEvent:Fire()
	self.button:Destroy()
	self.activatedEvent:Destroy()
	self.deactivatedEvent:Destroy()
	self.maid:Destroy()
end

function Button.GetButton(p)
	return p.button
end

function Button.GetOffset(p)
	PlayerGui:WaitForChild("TouchGui")
	local jumpButton = PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")

	local absolutePosition = jumpButton.AbsolutePosition
	local absolutePosition2 = p.button.AbsolutePosition
	local y = jumpButton.AbsoluteSize.Y

	local v = (absolutePosition.X - absolutePosition2.X) / y
	local v2 = (absolutePosition.Y - absolutePosition2.Y) / y
	return Vector2.new(v, v2)
end

return Button