local CameraShaker = {}
CameraShaker.__index = CameraShaker

local profilebegin = debug.profilebegin
local profileend = debug.profileend

local newCFrame = CFrame.new
local Angles = CFrame.Angles
local rad = math.rad
local vector3 = Vector3.new()

local CameraShakeInstance = require(script.CameraShakeInstance)
local CameraShakeState = CameraShakeInstance.CameraShakeState

CameraShaker.CameraShakeInstance = CameraShakeInstance
CameraShaker.Presets = require(script.CameraShakePresets)

function CameraShaker.new(renderPriority, callback)
	assert(type(renderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
	assert(type(callback) == "function", "Callback must be a function")

	return (setmetatable({
		_running = false,
		_renderName = "CameraShaker",
		_renderPriority = renderPriority,
		_posAddShake = vector3,
		_rotAddShake = vector3,
		_camShakeInstances = {},
		_removeInstances = {},
		_callback = callback
	}, CameraShaker))
end

function CameraShaker:Start()
	if self._running then
		return
	end

	self._running = true
	local callback = self._callback
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep(self._renderName, self._renderPriority, function(p)
		profilebegin("CameraShakerUpdate")
		local v = self:Update(p)
		profileend()
		callback(v)
	end)
end

function CameraShaker:Stop()
	if not self._running then
		return
	end

	local RunService = game:GetService("RunService")
	RunService:UnbindFromRenderStep(self._renderName)
	self._running = false
end

function CameraShaker:StopSustained(p)
	for _, camShakeInstance in pairs(self._camShakeInstances) do
		if camShakeInstance.fadeOutDuration == 0 then
			camShakeInstance:StartFadeOut(p or camShakeInstance.fadeInDuration)
		end
	end
end

function CameraShaker:Update(p)
	local v = vector3
	local v2 = vector3

	local camShakeInstances = self._camShakeInstances

	for i = 1, #camShakeInstances do
		local camShakeInstance = camShakeInstances[i]
		local state = camShakeInstance:GetState()

		if state == CameraShakeState.Inactive and camShakeInstance.DeleteOnInactive then
			self._removeInstances[#self._removeInstances + 1] = i
		elseif state ~= CameraShakeState.Inactive then
			local v3 = camShakeInstance:UpdateShake(p)
			v += v3 * camShakeInstance.PositionInfluence
			v2 += v3 * camShakeInstance.RotationInfluence
		end
	end

	for i = #self._removeInstances, 1, -1 do
		local removeInstance = self._removeInstances[i]
		table.remove(camShakeInstances, removeInstance)
		self._removeInstances[i] = nil
	end

	return newCFrame(v) * Angles(0, rad(v2.Y), 0) * Angles(rad(v2.X), 0, (rad(v2.Z)))
end

function CameraShaker:Shake(p)
	local v = type(p) == "table" and p._camShakeInstance
	assert(v, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = p
	return p
end

function CameraShaker:ShakeSustain(object)
	local v = type(object) == "table" and object._camShakeInstance
	assert(v, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = object
	object:StartFadeIn(object.fadeInDuration)
	return object
end

function CameraShaker:ShakeOnce(p, p2, p3, p4, p5, p6)
	local v = CameraShakeInstance.new(p, p2, p3, p4)
	v.PositionInfluence = typeof(p5) == "Vector3" and p5 or Vector3.new(0.15, 0.15, 0.15)
	v.RotationInfluence = typeof(p6) == "Vector3" and p6 or Vector3.new(1, 1, 1)
	self._camShakeInstances[#self._camShakeInstances + 1] = v
	return v
end

function CameraShaker:StartShake(p, p2, p3, p4, p5)
	local v = CameraShakeInstance.new(p, p2, p3)
	v.PositionInfluence = typeof(p4) == "Vector3" and p4 or Vector3.new(0.15, 0.15, 0.15)
	v.RotationInfluence = typeof(p5) == "Vector3" and p5 or Vector3.new(1, 1, 1)
	v:StartFadeIn(p3)
	self._camShakeInstances[#self._camShakeInstances + 1] = v
	return v
end

return CameraShaker