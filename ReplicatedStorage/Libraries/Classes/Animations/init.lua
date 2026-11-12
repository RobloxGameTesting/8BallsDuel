game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RunService = game:GetService("RunService")
game:GetService("ContentProvider")
local Promises = require(ReplicatedStorage.Libraries.Classes.Promises)
require(script.AnimationTypes)

local Animations = {}

function Animations.new(animationList, controller)
	local bindableEvent = Instance.new("BindableEvent")

	local v = {
		maid = Maid.new(),
		animations = {},
		controller = controller,
		animationList = animationList,
		animationObjects = {},
		sequence = nil,
		keyframeEvent = bindableEvent,
		KeyframeEvent = bindableEvent.Event
	}

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local parent = controller.Parent

	if
		localPlayer
		and character
		and parent
		and parent:IsA("Humanoid")
		and character:FindFirstChildWhichIsA("Humanoid")
		and character:FindFirstChildWhichIsA("Humanoid") == parent
	then
		v.maid.updateControllerEvent = localPlayer.CharacterAdded:Connect(function(character2)
			v.controller = character2:WaitForChild("Humanoid"):WaitForChild("Animator")
			Animations.Load(v)
		end)
	end

	Animations.Init(v, v.animationList)
	Animations.Load(v)

	return v
end

function Animations.Init(p, items)
	if not items then
		warn("list not passed")
		return
	end

	for k, item in items do
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. item
		p.maid[k] = animation

		p.animationObjects[k] = animation
	end
end

function Animations.Load(data)
	for k, animation in data.animationObjects do
		local track = data.controller:LoadAnimation(animation)

		data.animations[k] = {
			animationTrack = track,
			length = Promises.new(function(callback, _, _)
				repeat
					RunService.Heartbeat:Wait()
				until track.Length > 0

				callback(track.Length)
			end)
		}

		data.maid["keyframeEvent" .. k] = data.animations[k].animationTrack.KeyframeReached:Connect(function(p)
			data.keyframeEvent:Fire(p)
		end)
	end
end

function Animations.GetLength(p, p2: string)
	return p.animations[p2].length:expect()
end

function Animations.FreezeFrame(p, p2, p3: number)
	local animation = p.animations[p2]
	animation.animationTrack:Play()
	animation.animationTrack:AdjustSpeed(0)
	animation.animationTrack.TimePosition = Animations.GetLength(p, p2) * p3
end

function Animations.StopFreezeFrame(p, p2: string)
	local animation = p.animations[p2]
	animation.animationTrack:Stop()
	animation.animationTrack:AdjustSpeed(1)
end

function Animations:Play(p)
	Animations.Stop(self)
	self.sequence = Animations.newSequence(self, p)
	Animations.PlaySequence(self.sequence)
end

function Animations:Stop()
	if self.sequence then
		Animations.DestroySequence(self.sequence)
		self.sequence = nil
	end
end

function Animations:AdjustSpeed(p: number)
	local sequence = Animations.GetSequence(self)

	if sequence then
		for _, v in sequence.sequence do
			local animation = v.animation
			local speed = v.speed or 1
			local _fadeIn = v.fadeIn or 0.1
			local _weight = v.weight or 1
			local _looped = v.looped or false
			local _priority = v.priority
			local _playCount = v.playCount or 1

			sequence.animations.animations[animation].animationTrack:AdjustSpeed(speed * p)
		end
	end
end

function Animations.GetSequence(p)
	return p.sequence
end

function Animations.GetAnimation(p, p2: string)
	return p.animations[p2]
end

function Animations:Destroy()
	Animations.Stop(self)
	self.maid:Destroy()
end

function Animations.newSequence(animations, sequence)
	return { sequence = sequence, animations = animations, maid = Maid.new(), stopped = false }
end

function Animations.PlaySequence(data)
	task.spawn(function()
		for _, v in data.sequence do
			local animation = v.animation
			local speed = v.speed or 1
			local fadeIn = v.fadeIn or 0.1
			local weight = v.weight or 1
			local looped = v.looped or false
			local priority = v.priority
			local playCount = v.playCount or 1

			if priority then
				data.animations.animations[animation].animationTrack.Priority = priority
			end

			data.animations.animations[animation].animationTrack.Looped = looped

			for _ = 1, playCount do
				if data.stopped then
					return
				end

				data.animations.animations[animation].animationTrack:Play(fadeIn, weight, speed)
				data.animations.animations[animation].animationTrack.Stopped:Wait()
			end

			if data.stopped then
				break
			end
		end
	end)
end

function Animations:StopSequence()
	self.stopped = true

	for _, animation in self.animations.animations do
		animation.animationTrack:Stop()
	end
end

function Animations.GetSequenceLength(p, list)
	local sequenceLength = 0

	for _, v in p.sequence do
		if table.find(list, v.animation) then
			continue
		end

		local length = Animations.GetLength(p.animations, v.animation)
		local playCount = v.playCount or 1
		local speed = v.speed or 1

		sequenceLength += length * playCount / speed
	end

	return sequenceLength
end

function Animations.DestroySequence(p)
	Animations.StopSequence(p)
	p.maid:Destroy()
end

return Animations