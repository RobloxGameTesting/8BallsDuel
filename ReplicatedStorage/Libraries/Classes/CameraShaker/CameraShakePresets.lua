local CameraShakeInstance = require(script.Parent.CameraShakeInstance)

local v = {
	Minigun = function()
		local v = CameraShakeInstance.new(1, 50, 0.1, 0.1)
		v.PositionInfluence = Vector3.new(0.2, 0.2, 0.2)
		v.RotationInfluence = Vector3.new(0.2, 0.2, 0.2)

		return v
	end,
	Bump = function()
		local v = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		v.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
		v.RotationInfluence = Vector3.new(1, 1, 1)
		return v
	end,
	Explosion = function()
		local v = CameraShakeInstance.new(5, 10, 0, 1.5)
		v.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		v.RotationInfluence = Vector3.new(4, 1, 1)
		return v
	end,
	BadTrip = function()
		local v = CameraShakeInstance.new(10, 0.15, 5, 10)
		v.PositionInfluence = Vector3.new(0, 0, 0.15)
		v.RotationInfluence = Vector3.new(2, 1, 4)
		return v
	end,
	HandheldCamera = function()
		local v = CameraShakeInstance.new(0.5, 0.25, 5, 10)
		v.PositionInfluence = Vector3.new(0, 0, 0)
		v.RotationInfluence = Vector3.new(0.2, 0.2, 0.2)
		return v
	end,
	Vibration = function()
		local v = CameraShakeInstance.new(0.4, 20, 2, 2)
		v.PositionInfluence = Vector3.new(0, 0.15, 0)
		v.RotationInfluence = Vector3.new(1.25, 0, 4)
		return v
	end,
	RoughDriving = function()
		local v = CameraShakeInstance.new(1, 2, 1, 1)
		v.PositionInfluence = Vector3.new(0, 0, 0)
		v.RotationInfluence = Vector3.new(1, 1, 1)
		return v
	end
}

return (setmetatable({}, {
	__index = function(_, p)
		local v2 = v[p]

		if type(v2) == "function" then
			return v2()
		end

		error("No preset found with index \"" .. p .. "\"")
	end
}))