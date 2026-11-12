local TweenService = game:GetService("TweenService")

local Tween = {}
Tween.__index = Tween

function Tween.new(value)
	local object = setmetatable({}, Tween)

	object.intValue = Instance.new("IntValue")
	object.bindable = Instance.new("BindableEvent")
	object.Updated = object.bindable.Event

	object.updateConnection = object.intValue:GetPropertyChangedSignal("Value"):Connect(function()
		object.bindable:Fire(object.intValue.Value)
	end)

	object.intValue.Value = value or 0

	return object
end

function Tween:Start(p, tweenInfo)
	self:Stop()

	self.tween = TweenService:Create(self.intValue, tweenInfo, { Value = p })

	self.tween:Play()
end

function Tween:Stop()
	if self.tween then
		self.tween:Cancel()
		self.tween = nil
	end
end

function Tween:Destroy()
	self:Stop()

	self.updateConnection:Disconnect()
	self.intValue:Destroy()
	self.bindable:Destroy()
end

return Tween