local HapticService = game:GetService("HapticService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolModifiers = require(Pool.PoolModifiers)
local PoolPhysics = require(Pool.PoolPhysics)

local v = {
	Pocket = { Strength = 0.85, Seconds = 0.16 },
	Bubble = { Strength = 0.55, Seconds = 0.09 },
	Rim = {
		{ Strength = 0.3, Seconds = 0.05 },
		{ Strength = 0.45, Seconds = 0.06 },
		{ Strength = 0.6, Seconds = 0.08 },
		{ Strength = 0.8, Seconds = 0.12 }
	},
	OutwardScale = 0.4,
	RimMargin = 1.2,
	MinGap = 0.05
}

local v2 = {}

local function refreshTargets()
	table.clear(v2)

	if not RunService:IsClient() then
		return
	end

	local v3 = {}

	if UserInputService.TouchEnabled then
		table.insert(v3, Enum.UserInputType.Touch)
	end

	for _, v4 in UserInputService:GetConnectedGamepads() do
		table.insert(v3, v4)
	end

	for _, v4 in v3 do
		local success, result = pcall(function()
			return HapticService:IsVibrationSupported(v4)
				and HapticService:IsMotorSupported(v4, Enum.VibrationMotor.Large)
		end)

		if success and result then
			table.insert(v2, v4)
		end
	end
end

local function drive(p: number)
	for _, v3 in v2 do
		pcall(function()
			HapticService:SetMotor(v3, Enum.VibrationMotor.Large, p)
		end)
	end
end

local function pulse(state, strength: number, seconds: number)
	if not state.Enabled or strength <= 0 then
		return
	end

	local now = os.clock()

	if now - state.StartedAt < v.MinGap and strength <= state.Strength then
		return
	end

	state.Strength = strength
	state.StartedAt = now

	state.Until = math.max(state.Until, now + seconds)

	drive(strength)
end

local function decay(state) -- 1 equivalent call inferred from this helper
	if state.Strength <= 0 then
		return
	end

	if os.clock() >= state.Until then
		state.Strength = 0
		drive(0)
	end
end

local PoolTableHaptics = {}

function PoolTableHaptics.new()
	local v3 = {
		Cursor = 0,
		Enabled = true,
		Bands = {},
		Strength = 0,
		Until = 0,
		StartedAt = 0,
		Connection = nil
	}

	if not RunService:IsClient() then
		return v3
	end

	refreshTargets()

	UserInputService.GamepadConnected:Connect(refreshTargets)
	UserInputService.GamepadDisconnected:Connect(refreshTargets)

	v3.Connection = RunService.Heartbeat:Connect(function()
		decay(v3) -- inferred equivalent call
	end)

	return v3
end

function PoolTableHaptics:SetEnabled(enabled: boolean)
	self.Enabled = enabled

	if not enabled then
		self.Strength = 0
		self.Until = 0
		drive(0)
	end
end

function PoolTableHaptics:Reset()
	self.Cursor = 0
	table.clear(self.Bands)
	self.Strength = 0
	self.Until = 0
	drive(0)
end

local function bandAt(magnitude: number, radius: number) -- 1 equivalent call inferred from this helper
	local starsAt = PoolModifiers.StarsAt(magnitude + v.RimMargin, radius)
	local starsAt2 = PoolModifiers.StarsAt(magnitude - v.RimMargin, radius)

	return if starsAt == starsAt2 then starsAt2 else nil
end

local function updateRims(p, p2)
	for k, modifier in p2.Modifiers do
		if modifier.Kind ~= "Bullseye" then
			continue
		end

		for _, v3 in PoolPhysics.GetActiveBalls(p2) do
			if v3.Static or v3.Driven or v3.Height > 0 then
				continue
			end

			local starsAt = bandAt((v3.Position - modifier.Position).Magnitude, modifier.Radius) -- inferred equivalent call

			if not starsAt then
				continue
			end

			local v4 = p.Bands[v3.Number]

			if not v4 then
				v4 = {}
				p.Bands[v3.Number] = v4
			end

			local v5 = v4[k]
			v4[k] = starsAt

			if not (v5 ~= nil and starsAt ~= v5) then
				continue
			end

			local v6 = math.max(starsAt, v5)
			local v7 = v.Rim[v6]

			if not v7 then
				continue
			end

			local v8 = v5 < starsAt and 1 or v.OutwardScale

			pulse(p, v7.Strength * v8, v7.Seconds)
		end
	end
end

function PoolTableHaptics:Update(p)
	local events = p.Events

	if self.Cursor > #events then
		self.Cursor = 0
	end

	for i = self.Cursor + 1, #events do
		local event = events[i]

		if event.Kind == "Pocketed" then
			pulse(self, v.Pocket.Strength, v.Pocket.Seconds)
		elseif event.Kind == "Popped" then
			pulse(self, v.Bubble.Strength, v.Bubble.Seconds)
		end
	end

	self.Cursor = #events

	updateRims(self, p)
end

function PoolTableHaptics:Destroy()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	self.Strength = 0
	self.Until = 0
	drive(0)
end

return PoolTableHaptics