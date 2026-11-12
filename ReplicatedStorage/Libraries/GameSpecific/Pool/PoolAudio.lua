local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
require(Pool.PoolPhysics)

local PoolAudio = {}

local Feel = PoolConstants.Feel
local SoundCues = PoolConstants.SoundCues

local v = 1

function PoolAudio.SetGlobalVolume(value: number)
	v = math.clamp(value, 0, 1)
end

function PoolAudio.PlayCue(p: string, value: number?)
	local soundCue = SoundCues[p]

	if typeof(soundCue) ~= "table" then
		warn("[PoolAudio] unknown cue: " .. tostring(p))

		return nil
	end

	local v2 = (soundCue.Volume or 1) * v * (value or 1)

	if v2 <= 0.001 then
		return nil
	end

	local success, result = pcall(Sounds.new, soundCue.Path, nil)

	if not (success and result) then
		return nil
	end

	if soundCue.Speed then
		Sounds.SetSpeed(result, soundCue.Speed)
	end

	Sounds.Play(result, nil, true, v2)

	return result
end

function PoolAudio.PlayCueStrike(p: number)
	local v2 = (SoundCues.CueHardThreshold or 0.5) <= p

	PoolAudio.PlayCue(v2 and "CueHard" or "CueSoft")
end

local v2 = -1

function PoolAudio.TurnClock(p: number)
	local v3 = math.max(math.ceil(p), 0)

	if v3 == v2 then
		return
	end

	v2 = v3

	if v3 >= 1 and v3 <= (SoundCues.TurnClockTickFrom or 5) then
		PoolAudio.PlayCue("TurnClock")
	end
end

function PoolAudio.new()
	return {
		Cursor = 0,
		BurstStartedAt = -1e999,
		BurstVoices = 0,
		Muted = false,
		VolumeScale = 1
	}
end

function PoolAudio:SetVolumeScale(value: number)
	self.VolumeScale = math.clamp(value, 0, 1)
end

function PoolAudio:Reset()
	self.Cursor = 0
	self.BurstVoices = 0
	self.BurstStartedAt = -1e999
end

function PoolAudio:SetMuted(muted: boolean)
	self.Muted = muted
end

local function shape(p: number) -- 1 equivalent call inferred from this helper
	local v3 = math.max(Feel.BallHitLoudSpeed - Feel.BallHitMinSpeed, 0.001)
	local v4 = math.sqrt((math.clamp((p - Feel.BallHitMinSpeed) / v3, 0, 1)))

	return
		Feel.BallHitMinVolume + (Feel.BallHitMaxVolume - Feel.BallHitMinVolume) * v4,
		Feel.BallHitMinPlaybackSpeed + (Feel.BallHitMaxPlaybackSpeed - Feel.BallHitMinPlaybackSpeed) * v4
end

local function playHit(speed: number, volumeScale: number)
	local v3, total = shape(speed) -- inferred equivalent call
	local ballHitPlaybackJitter = Feel.BallHitPlaybackJitter

	local v4 = v3 * volumeScale

	if v4 <= 0.001 then
		return
	end

	if ballHitPlaybackJitter > 0 then
		total += (math.random() * 2 - 1) * ballHitPlaybackJitter
	end

	local success, result = pcall(Sounds.new, Feel.BallHitSound, nil)

	if success and result then
		Sounds.SetSpeed(result, (math.max(total, 0.05)))
		Sounds.Play(result, nil, true, v4)
	end
end

function PoolAudio:Update(p)
	local events = p.Events

	if self.Cursor > #events then
		self.Cursor = 0
	end

	if self.Cursor == #events then
		return
	end

	for i = self.Cursor + 1, #events do
		local event = events[i]

		if event.Kind == "BallHit" and not self.Muted then
			local speed = event.Speed or 0

			if Feel.BallHitMinSpeed <= speed then
				local time = event.Time

				if time - self.BurstStartedAt > Feel.BallHitBurstWindow then
					self.BurstStartedAt = time
					self.BurstVoices = 0
				end

				if self.BurstVoices < Feel.BallHitMaxVoices then
					self.BurstVoices += 1
					playHit(speed, self.VolumeScale)
				end
			end
		elseif event.Kind == "Pocketed" and not self.Muted then
			PoolAudio.PlayCue("Pocket")
		end
	end

	self.Cursor = #events
end

return PoolAudio