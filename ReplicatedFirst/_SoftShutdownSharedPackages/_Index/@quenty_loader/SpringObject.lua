local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local RunService = game:GetService("RunService")

local v = loaded("Spring")
local v2 = loaded("Maid")
local v3 = loaded("Signal")
local v4 = loaded("StepUtils")
local v5 = loaded("Observable")
local v6 = loaded("SpringUtils")
local v7 = loaded("Blend")
local v8 = loaded("Rx")
local v9 = loaded("Promise")

local SpringObject = {
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	["ClassName"] = nil,
	ClassName = "SpringObject"
}

SpringObject.__index = SpringObject

function SpringObject.new(target, speed, damper)
	local self = setmetatable({ _maid = v2.new(), _epsilon = 1e-6, Changed = v3.new() }, SpringObject)

	self._maid:GiveTask(self.Changed)

	if target then
		self.Target = target
	else
		self:_getSpringForType(0)
	end

	if speed then
		self.Speed = speed
	end

	if damper then
		self.Damper = damper
	end

	return self
end

function SpringObject.isSpringObject(p): boolean
	return type(p) == "table" and getmetatable(p) == SpringObject
end

function SpringObject:ObserveRenderStepped()
	return self:ObserveOnSignal(RunService.RenderStepped)
end

function SpringObject:Observe()
	return self:ObserveRenderStepped()
end

function SpringObject.ObserveTarget(p)
	return v5.new(function(object)
		local maid = v2.new()

		local v10 = p.Target

		maid:GiveTask(p.Changed:Connect(function()
			local target = p.Target

			if v10 ~= target then
				v10 = target
				object:Fire(target)
			end
		end))

		object:Fire(v10)

		return maid
	end)
end

function SpringObject:ObserveVelocityOnRenderStepped()
	return self:ObserveVelocityOnSignal(RunService.RenderStepped)
end

function SpringObject:PromiseFinished(p)
	local v10 = p or RunService.RenderStepped

	local maid = v2.new()
	local v11 = v9.new()
	maid:GiveTask(v11)

	local v12, v13 = v4.bindToSignal(v10, function()
		local animating = v6.animating(self._currentSpring, self._epsilon)

		if not animating then
			v11:Resolve(true)
		end

		return animating
	end)

	maid:GiveTask(v13)
	maid:GiveTask(self.Changed:Connect(v12))
	v12()

	self._maid[v11] = maid

	v11:Finally(function()
		self._maid[v11] = nil
	end)

	maid:GiveTask(function()
		self._maid[v11] = nil
	end)

	return v11
end

function SpringObject:ObserveVelocityOnSignal(p)
	return v5.new(function(object)
		local maid = v2.new()

		local v10, v11 = v4.bindToSignal(p, function()
			local animating = v6.animating(self._currentSpring, self._epsilon)

			if animating then
				object:Fire(v6.fromLinearIfNeeded(self._currentSpring.Velocity))
				return animating
			end

			object:Fire(v6.fromLinearIfNeeded(0 * self._currentSpring.Velocity))

			return animating
		end)

		maid:GiveTask(v11)
		maid:GiveTask(self.Changed:Connect(v10))
		v10()

		return maid
	end)
end

function SpringObject:ObserveOnSignal(p)
	return v5.new(function(object)
		local maid = v2.new()

		local v10, v11 = v4.bindToSignal(p, function()
			local animating, v10 = v6.animating(self._currentSpring, self._epsilon)
			object:Fire(v6.fromLinearIfNeeded(v10))
			return animating
		end)

		maid:GiveTask(v11)
		maid:GiveTask(self.Changed:Connect(v10))
		v10()

		return maid
	end)
end

function SpringObject:IsAnimating()
	return (v6.animating(self._currentSpring, self._epsilon))
end

function SpringObject:Impulse(p)
	self._currentSpring:Impulse(v6.toLinearIfNeeded(p))
	self.Changed:Fire()
end

function SpringObject:SetTarget(p, p2)
	local v10 = v7.toPropertyObservable(p) or v8.of(p)

	if p2 then
		self._maid._targetSub = v10:Subscribe(function(p3)
			local linearIfNeeded = v6.toLinearIfNeeded(p3)
			assert(linearIfNeeded, "Not a valid converted value")

			local springForType = self:_getSpringForType(linearIfNeeded)
			springForType.Target = linearIfNeeded

			springForType.Position = linearIfNeeded
			springForType.Velocity = 0 * linearIfNeeded

			self.Changed:Fire()
		end)
	else
		self._maid._targetSub = v10:Subscribe(function(p3)
			local linearIfNeeded = v6.toLinearIfNeeded(p3)
			local springForType = self:_getSpringForType(linearIfNeeded)
			springForType.Target = linearIfNeeded

			self.Changed:Fire()
		end)
	end
end

function SpringObject:TimeSkip(value)
	assert(type(value) == "number", "Bad delta")

	self._currentSpring:TimeSkip(value)
	self.Changed:Fire()
end

function SpringObject:__index(p)
	if p == "Value" or p == "Position" or p == "p" then
		return v6.fromLinearIfNeeded(self._currentSpring.Value)
	end

	if p == "Velocity" or p == "v" then
		return v6.fromLinearIfNeeded(self._currentSpring.Velocity)
	end

	if p == "Target" or p == "t" then
		return v6.fromLinearIfNeeded(self._currentSpring.Target)
	end

	if p == "Damper" or p == "d" then
		return self._currentSpring.Damper
	end

	if p == "Speed" or p == "s" then
		return self._currentSpring.Speed
	end

	if p == "Clock" then
		return self._currentSpring.Clock
	elseif p == "Epsilon" then
		return self._epsilon
	end

	if SpringObject[p] then
		return SpringObject[p]
	end

	error(("%q is not a member of SpringObject"):format((tostring(p))))
end

function SpringObject:__newindex(p, clock)
	if p == "Value" or p == "Position" or p == "p" then
		local v10 = v7.toPropertyObservable(clock) or v8.of(clock)

		self._maid._valueSub = v10:Subscribe(function(p2)
			local linearIfNeeded = v6.toLinearIfNeeded(p2)
			local springForType = self:_getSpringForType(linearIfNeeded)
			springForType.Value = linearIfNeeded
			self.Changed:Fire()
		end)
	elseif p == "Velocity" or p == "v" then
		local v10 = v7.toPropertyObservable(clock) or v8.of(clock)

		self._maid._velocitySub = v10:Subscribe(function(p2)
			local linearIfNeeded = v6.toLinearIfNeeded(p2)

			local springForType = self:_getSpringForType(0 * linearIfNeeded)
			springForType.Velocity = linearIfNeeded
			self.Changed:Fire()
		end)
	elseif p == "Target" or p == "t" then
		self:SetTarget(clock)
	elseif p == "Damper" or p == "d" then
		local v10 = assert(v7.toNumberObservable(clock), "Invalid damper")

		self._maid._damperSub = v10:Subscribe(function(damper)
			assert(type(damper) == "number", "Bad damper")

			self._currentSpring.Damper = damper
			self.Changed:Fire()
		end)
	elseif p == "Speed" or p == "s" then
		local v10 = assert(v7.toNumberObservable(clock), "Invalid speed")

		self._maid._speedSub = v10:Subscribe(function(speed)
			assert(type(speed) == "number", "Bad damper")

			self._currentSpring.Speed = speed
			self.Changed:Fire()
		end)
	elseif p == "Epsilon" then
		assert(type(clock) == "number", "Bad value")
		rawset(self, "_epsilon", clock)
	else
		if p ~= "Clock" then
			error(("%q is not a member of SpringObject"):format((tostring(p))))

			return
		end

		assert(type(clock) == "function", "Bad clock value")
		self._currentSpring.Clock = clock
		self.Changed:Fire()
	end
end

function SpringObject:_getSpringForType(p)
	if rawget(self, "_currentSpring") == nil then
		rawset(self, "_currentSpring", v.new(p))
		return self._currentSpring
	end

	if typeof(v6.fromLinearIfNeeded(self._currentSpring.Value)) == typeof(v6.fromLinearIfNeeded(p)) then
		return self._currentSpring
	end

	local d = self._currentSpring.d
	local s = self._currentSpring.s
	local clock = self._currentSpring.Clock

	self._currentSpring = v.new(p)
	self._currentSpring.Clock = clock
	self._currentSpring.Speed = s
	self._currentSpring.Damper = d
	return self._currentSpring
end

function SpringObject:Destroy()
	self._maid:DoCleaning()
	setmetatable(self, nil)
end

return SpringObject