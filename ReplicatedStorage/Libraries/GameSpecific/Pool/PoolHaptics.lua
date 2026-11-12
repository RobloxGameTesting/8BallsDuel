local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()

local GameplayCollision = Enum.HapticEffectType.GameplayCollision

local v = true

local v2 = nil
local v3 = 0

local function handle()
	if v2 and v2.Parent then
		return v2
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return nil
	end

	local success, result = pcall(function()
		local poolPotHaptic = Instance.new("HapticEffect")
		poolPotHaptic.Name = "PoolPotHaptic"
		poolPotHaptic.Type = GameplayCollision
		poolPotHaptic.Looped = false
		poolPotHaptic.Parent = localPlayer

		return poolPotHaptic
	end)

	if not success then
		return nil
	end

	v2 = result

	return result
end

local PoolHaptics = {}

function PoolHaptics.SetEnabled(flag: boolean)
	v = flag
end

function PoolHaptics.IsEnabled()
	return v
end

function PoolHaptics.PotYourBall()
	if isServer or not v then
		return
	end

	local now = os.clock()

	if now - v3 < 0.12 then
		return
	end

	local result

	if v2 and v2.Parent then
		result = v2
	else
		local localPlayer = Players.LocalPlayer

		if localPlayer then
			local success
			success, result = pcall(function()
				local poolPotHaptic = Instance.new("HapticEffect")
				poolPotHaptic.Name = "PoolPotHaptic"
				poolPotHaptic.Type = GameplayCollision
				poolPotHaptic.Looped = false
				poolPotHaptic.Parent = localPlayer

				return poolPotHaptic
			end)

			if success then
				v2 = result
			else
				result = nil
			end
		else
			result = nil
		end
	end

	if not result then
		return
	end

	v3 = now

	pcall(function()
		result:Play()
	end)
end

function PoolHaptics.Reset()
	v3 = 0
end

return PoolHaptics