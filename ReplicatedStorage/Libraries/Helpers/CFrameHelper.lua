local TweenService = game:GetService("TweenService")
local CFrameHelper = {}

function CFrameHelper.RotationOnly(cframe: CFrame)
	return CFrame.fromMatrix(Vector3.new(0, 0, 0), cframe.XVector, cframe.YVector, cframe.ZVector)
end

function CFrameHelper.YawFromCFrame(cframe: CFrame)
	local lookVector = cframe.LookVector
	return (math.atan2(lookVector.X, lookVector.Z))
end

function CFrameHelper.ZeroCFrame(cframe: CFrame)
	return cframe * CFrame.new(0, -cframe.Y, 0)
end

function CFrameHelper.WrapPi(p: number)
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

function CFrameHelper.AxisAngleFromDelta(cframe: CFrame)
	local _, _, _, v, v2, v3, v4, v5, v6, v7, v8, v9 = cframe:GetComponents()

	local v10 = math.acos((math.clamp((v + v5 + v9 - 1) * 0.5, -1, 1)))

	if v10 < 1e-6 then
		return Vector3.new(1, 0, 0), 0
	end

	if math.abs(3.141592653589793 - v10) < 0.0001 then
		local v11 = (v + 1) * 0.5
		local v12 = (v5 + 1) * 0.5
		local v13 = (v9 + 1) * 0.5

		local v14 = math.sqrt((math.max(v11, 0)))
		local v15 = math.sqrt((math.max(v12, 0)))
		local v16 = math.sqrt((math.max(v13, 0)))

		if v8 - v6 < 0 then
			v14 = -v14
		end

		if v3 - v7 < 0 then
			v15 = -v15
		end

		if v4 - v2 < 0 then
			v16 = -v16
		end

		local vector3 = Vector3.new(v14, v15, v16)
		return vector3.Magnitude < 1e-6 and Vector3.new(1, 0, 0) or vector3.Unit, v10
	else
		local v11 = 1 / (math.sin(v10) * 2)

		local vector3 = Vector3.new((v8 - v6) * v11, (v3 - v7) * v11, (v4 - v2) * v11)

		return vector3.Magnitude < 1e-6 and Vector3.new(1, 0, 0) or vector3.Unit, v10
	end
end

function CFrameHelper.TweenCFrame(cframe: CFrame, cframe2: CFrame, tweenInfo, callback)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0

	if callback then
		numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			local value = TweenService:GetValue(numberValue.Value, tweenInfo.EasingStyle, tweenInfo.EasingDirection)
			callback(value, cframe:Lerp(cframe2, value))
		end)
	end

	local tween = TweenService:Create(numberValue, tweenInfo, { Value = 1 })
	tween:Play()

	return tween, numberValue
end

return CFrameHelper