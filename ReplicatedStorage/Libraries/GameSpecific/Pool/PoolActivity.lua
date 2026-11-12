local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local PoolActivity = {}

local set = {
	[Enum.UserInputType.Gyro] = true,
	[Enum.UserInputType.Accelerometer] = true,
	[Enum.UserInputType.TextInput] = true,
	[Enum.UserInputType.InputMethod] = true,
	[Enum.UserInputType.Focus] = true,
	[Enum.UserInputType.None] = true
}

local lastTime = 0

local v = nil

local function mark() -- 3 equivalent calls inferred from this helper
	lastTime = os.clock()
end

local function changedIsPhysical(input)
	local userInputType = input.UserInputType

	if set[userInputType] then
		return false
	end

	if userInputType == Enum.UserInputType.MouseMovement then
		if input.Delta.Magnitude > 0 then
			v = Vector2.new(input.Position.X, input.Position.Y)

			return true
		end

		local vector2 = Vector2.new(input.Position.X, input.Position.Y)
		local v2

		if v == nil then
			v2 = false
		else
			v2 = (vector2 - v).Magnitude > 0
		end

		v = vector2

		return v2
	end

	if userInputType == Enum.UserInputType.MouseWheel then
		return true
	end

	return userInputType == Enum.UserInputType.Touch or input.Position.Magnitude > 0.15
end

if RunService:IsClient() then
	UserInputService.InputBegan:Connect(function(input)
		if not set[input.UserInputType] then
			mark() -- inferred equivalent call
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if not set[input.UserInputType] then
			mark() -- inferred equivalent call
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if changedIsPhysical(input) then
			mark() -- inferred equivalent call
		end
	end)
end

function PoolActivity.IsActive(p: number): boolean
	return lastTime > 0 and os.clock() - lastTime <= p
end

function PoolActivity.SecondsSince()
	if lastTime <= 0 then
		return 1e999
	end

	return os.clock() - lastTime
end

return PoolActivity