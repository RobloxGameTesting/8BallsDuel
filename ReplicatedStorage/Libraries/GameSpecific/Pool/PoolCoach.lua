local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Device = require(ReplicatedStorage.Libraries.Modules.Device)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolHudRenderer = require(Pool.PoolHudRenderer)
local PoolPlayerData = require(Pool.PoolPlayerData)

local function aimText(): string -- 1 equivalent call inferred from this helper
	local v = Device:Get()

	if v == "Console" then
		return "Use the D-Pad ◄ ► to aim at your ball"
	elseif v == "Mobile" then
		return "Swipe across the table to move your aim"
	end

	return "Move your mouse to aim at your ball"
end

local function powerText() -- 1 equivalent call inferred from this helper
	local v = Device:Get()

	if v == "Console" then
		return string.format(
			"Use the D-Pad ▲ ▼ to set power, press %s to shoot",
			Device.GetButtonLabel(Enum.KeyCode.ButtonR2)
		)
	elseif v == "Mobile" then
		return "Drag the power bar down, release to shoot"
	end

	return "Click and drag back from the ball to charge your shot"
end

local function dpadText(): string
	return "Use the D-Pad ◄ ► for precise aim"
end

local function forget(state) -- 1 equivalent call inferred from this helper
	state.Idle = 0
	state.Travel = 0
	state.Last = nil
	state.Armed = true
end

local PoolCoach = {}

function PoolCoach.new()
	return {
		Enabled = false,
		WasTurn = false,
		Idle = 0,
		Travel = 0,
		Last = nil,
		Armed = true,
		AimTime = 0,
		DPadHintedThisTurn = false,
		DPadHints = 0,
		DPadUsed = false
	}
end

function PoolCoach:Update(data, p, p2: number, wasTurn: boolean)
	if wasTurn and not self.WasTurn then
		local level = PoolPlayerData.GetLevel(Players.LocalPlayer.UserId)

		self.Enabled = level >= 1 and level <= 2

		self.AimTime = 0
		self.DPadHintedThisTurn = false
	end

	self.WasTurn = wasTurn

	if wasTurn and self.Enabled and data.State == "Aiming" and not (data.AimLocked or data.BallHeld) then
		if Device:Get() == "Console" then
			if data.Nudge ~= 0 or data.NudgeAnchor ~= nil then
				self.DPadUsed = true
			end

			self.AimTime += p2

			if
				not self.DPadUsed
				and not self.DPadHintedThisTurn
				and self.DPadHints < 3
				and self.AimTime > 3
				and not p.Banner.Visible
			then
				PoolHudRenderer.Notify(p, "Use the D-Pad ◄ ► for precise aim", 4)

				self.DPadHintedThisTurn = true
				self.DPadHints += 1

				self.Idle = 0
			end
		end

		local direction = data.Direction
		local last = self.Last

		self.Last = direction

		if last and direction.Magnitude > 0.001 and last.Magnitude > 0.001 then
			local v = math.acos((math.clamp(direction.Unit:Dot(last.Unit), -1, 1)))

			if v > 0.0008726646259971648 then
				self.Travel += v
			end
		end

		if self.Travel >= 0.026179938779914945 then
			self.Travel = 0
			self.Idle = 0
			self.Armed = true

			return
		else
			self.Idle += p2

			if not self.Armed or self.Idle < 5 or p.Banner.Visible then
				return
			end

			local notify = PoolHudRenderer.Notify
			local v

			if data.AimOnLegalBall then
				v = powerText() -- inferred equivalent call
			else
				v = aimText() -- inferred equivalent call
			end

			notify(p, v, 4)

			self.Armed = false
			self.Idle = 0
			return
		end
	end

	forget(self) -- inferred equivalent call
end

return PoolCoach