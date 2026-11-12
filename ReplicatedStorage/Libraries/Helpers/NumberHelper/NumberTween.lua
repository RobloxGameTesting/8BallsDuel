local TweenService = game:GetService("TweenService")

local NumberTween = {}
NumberTween.__index = NumberTween

function NumberTween.new(value)
	local object = setmetatable({}, NumberTween)

	object.intValue = Instance.new("NumberValue")
	object.bindable = Instance.new("BindableEvent")
	object.Updated = object.bindable.Event

	object.updateConnection = object.intValue:GetPropertyChangedSignal("Value"):Connect(function()
		object.bindable:Fire(object.intValue.Value)
	end)

	object.intValue.Value = value or 0

	return object
end

function NumberTween:Start(p, tweenInfo)
	self:Stop()

	self.tween = TweenService:Create(self.intValue, tweenInfo, { Value = p })

	self.tween:Play()
end

function NumberTween:Stop()
	if self.tween then
		self.tween:Cancel()
		self.tween = nil
	end
end

function NumberTween:Destroy()
	self:Stop()

	self.updateConnection:Disconnect()
	self.intValue:Destroy()
	self.bindable:Destroy()
end

return NumberTween