local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Maid = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Classes"):WaitForChild("Maid"))
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local sounds = script.Sounds

local Sounds = {}

local function _createPart() -- 2 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true

	return part
end

local function _createSound(p) -- 1 equivalent call inferred from this helper
	local path = Sounds.SearchPath(p)

	if path then
		return path:Clone()
	end
end

function Sounds.new(p, p2)
	local v = {}
	v.maid = Maid.new()
	v.maid.finishedEvent = Instance.new("BindableEvent")
	v.Finished = v.maid.finishedEvent.Event
	local sound = _createSound(p) -- inferred equivalent call

	if not sound then
		error("Sound path" .. HttpService:JSONEncode(p) .. "doesn't lead to anything")
	end

	v.maid.soundInstance = sound
	v.maid.soundInstance.SoundGroup = SoundService.SoundEffects
	v.volume = v.maid.soundInstance.Volume

	Sounds.Parent(v, p2)

	return v
end

function Sounds.Parent(p, value)
	p.maid.soundInstance.Parent = SoundService
	p.maid.weld = nil

	if typeof(value) == "Instance" then
		local part = _createPart() -- inferred equivalent call
		part.CFrame = value.CFrame
		part.Anchored = false
		part.Parent = value

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = value
		weldConstraint.Parent = part

		p.maid.weld = weldConstraint
		p.maid.part = part
	elseif typeof(value) == "Vector3" or typeof(value) == "CFrame" then
		if typeof(value) == "CFrame" then
			value = value.Position
		end

		local part = _createPart() -- inferred equivalent call
		part.Position = value
		part.Parent = workspace

		p.maid.part = part
		p.maid.part.Anchored = true
	end

	p.maid.soundInstance.Parent = p.maid.part or SoundService.SoundEffects
end

function Sounds:Play(p, flag: boolean, p2: number?)
	self.maid.stopTimerConnection = nil
	TweenService:Create(self.maid.soundInstance, TweenInfo.new(0), {
		Volume = p2 or self.maid.soundInstance.Volume
	}):Play()
	self.maid.soundInstance:Play()

	if p ~= "Manual" then
		if p then
			local total = 0
			local v = tonumber(p)

			self.maid.timerConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt

				if v <= total then
					self.maid.timerConnection = nil

					self:Stop(0.3)
				end
			end)
		elseif p == nil then
			self.maid.timerConnection = self.maid.soundInstance.Ended:Connect(function()
				self.maid.finishedEvent:Fire()
			end)
		end
	end

	if flag then
		self.Finished:Connect(function()
			Sounds.Destroy(self)
		end)
	end
end

function Sounds:Stop(value: number)
	local v = value or 0

	TweenService:Create(self.maid.soundInstance, TweenInfo.new(v), { Volume = 0 }):Play()

	local total = 0

	self.maid.stopTimerConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if v <= total then
			self.maid.stopTimerConnection = nil
			self.maid.soundInstance:Stop()
			self.maid.finishedEvent:Fire()
		end
	end)
end

function Sounds.SetRange(p, rollOffMaxDistance: number)
	p.maid.soundInstance.RollOffMaxDistance = rollOffMaxDistance
end

function Sounds.SetSpeed(p, playbackSpeed: number)
	p.maid.soundInstance.PlaybackSpeed = playbackSpeed
end

function Sounds.SetVolume(p, volume: number)
	p.maid.soundInstance.Volume = volume
end

function Sounds.SetPitch(p, octave: number)
	if not p.maid.pitch then
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchShiftSoundEffect.Parent = p.maid.soundInstance

		p.maid.pitch = pitchShiftSoundEffect
	end

	p.maid.pitch.Octave = octave
end

function Sounds.SetDistortion(p, level: number)
	if not p.maid.distort then
		local distortionSoundEffect = Instance.new("DistortionSoundEffect")
		distortionSoundEffect.Parent = p.maid.soundInstance

		p.maid.distort = distortionSoundEffect
	end

	p.maid.distort.Level = level
end

function Sounds.Destroy(p)
	p.maid:Destroy()
end

function Sounds.SearchPath(items)
	local child = sounds

	for _, childName in items do
		child = child:FindFirstChild(childName)
	end

	return child
end

return Sounds