local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Classes"):WaitForChild("Maid"))
local RunService = game:GetService("RunService")
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)

local visuals = script.Visuals

local Visuals = {}

local function _createVisual(p)
	local folder = Visuals.SearchPath(p)

	if not folder then
		warn("Couldn't find path ", p)
		return
	end

	if folder:IsA("BasePart") then
		folder.CanCollide = false
		folder.CanQuery = false
		folder.CanTouch = false
		folder.Massless = true
	elseif folder:IsA("Model") then
		for _, part in folder:GetDescendants(), nil, nil do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
		end
	end

	return folder:Clone()
end

function Visuals.new(p, p2, ...)
	local result = {}
	result.maid = Maid.new()
	result.maid.finishedEvent = Instance.new("BindableEvent")
	result.Finished = result.maid.finishedEvent.Event

	local visual = _createVisual(p)

	if not visual then
		error("Visual path doesn't lead to anything")
	end

	result.maid.visualInstance = visual

	Visuals.Parent(result, p2, ...)

	result.fadeTime = 0
	result.particles = result.maid.visualInstance

	for _, emitter in result.particles:GetDescendants(), nil, nil do
		if emitter:IsA("ParticleEmitter") and emitter.Lifetime.Max > result.fadeTime then
			result.fadeTime = emitter.Lifetime.Max
		end
	end

	return result
end

function Visuals.Parent(p, value, ...)
	p.maid.weld = nil

	if typeof(value) == "Instance" then
		local cframe = ({ ... })[1] or value.CFrame

		if p.maid.visualInstance:IsA("BasePart") then
			p.maid.visualInstance.CFrame = cframe
		elseif p.maid.visualInstance:IsA("Model") then
			p.maid.visualInstance:PivotTo(cframe)
		end

		local weld = ModelHelper:Weld(p.maid.visualInstance, value)
		function p.maid.weld()
			for _, v in weld do
				v:Destroy()
			end
		end
		p.maid.visualInstance.Parent = value
	elseif typeof(value) == "Vector3" then
		if p.maid.visualInstance:IsA("Attachment") then
			p.maid.visualInstance.WorldPosition = value
		elseif p.maid.visualInstance:IsA("BasePart") then
			p.maid.visualInstance.Position = value
		elseif p.maid.visualInstance:IsA("Model") then
			p.maid.visualInstance:PivotTo(CFrame.new(value))
		end

		p.maid.visualInstance.Parent = workspace
	elseif typeof(value) == "CFrame" then
		if p.maid.visualInstance:IsA("BasePart") then
			p.maid.visualInstance.CFrame = value
		elseif p.maid.visualInstance:IsA("Model") then
			p.maid.visualInstance:PivotTo(value)
		end

		p.maid.visualInstance.Parent = workspace
	end
end

function Visuals.Play(data, p, flag: boolean)
	if tonumber(p) then
		for _, emitter in data.particles:GetDescendants(), nil, nil do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local total = 0

		data.maid.timerConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if p <= total then
				data.maid.timerConnection = nil
				Visuals.Stop(data)
			end
		end)
	elseif p == nil then
		for _, emitter in data.particles:GetDescendants(), nil, nil do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local emitCount = emitter:GetAttribute("EmitCount") or emitter:GetAttribute("Emit")
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				task.spawn(function()
					task.wait(emitDelay)
					emitter:Emit(emitCount)
				end)
			else
				emitter:Emit(emitCount)
			end
		end

		local fadeTime = data.fadeTime
		local total = 0

		data.maid.timerConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if fadeTime <= total then
				data.maid.timerConnection = nil
				Visuals.Stop(data)
			end
		end)
	elseif p == "Manual" then
		for _, emitter in data.particles:GetDescendants(), nil, nil do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end

	if flag then
		data.Finished:Connect(function()
			Visuals.Destroy(data)
		end)
	end
end

function Visuals.Stop(p)
	for _, emitter in p.particles:GetDescendants(), nil, nil do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	p.maid.timerConnection = nil
	p.maid.finishedEvent:Fire()
end

function Visuals.Recolour(p, color: Color3)
	for _, emitter in p.particles:GetDescendants(), nil, nil do
		if emitter:IsA("ParticleEmitter") then
			emitter.Color = ColorSequence.new(color)
		end
	end
end

local function scaleSequence(size, value: number)
	local numberSequenceKeypoints = {}

	for k, keypoint in size.Keypoints do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * value,
			keypoint.Envelope * value
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function Visuals.Scale(p, value: number)
	local particles = p and p.particles

	if not particles or typeof(value) ~= "number" or value ~= value or value <= 0 or value == 1 then
		return
	end

	local descendants = particles:GetDescendants()
	table.insert(descendants, particles)

	for _, instance in descendants do
		if instance:IsA("BasePart") then
			instance.Size *= value
		elseif instance:IsA("Attachment") then
			instance.Position *= value
		elseif instance:IsA("SpecialMesh") then
			instance.Scale *= value
			instance.Offset *= value
		elseif instance:IsA("ParticleEmitter") then
			instance.Size = scaleSequence(instance.Size, value)
			instance.Speed = NumberRange.new(instance.Speed.Min * value, instance.Speed.Max * value)
			instance.Acceleration *= value
		elseif instance:IsA("Beam") then
			instance.Width0 *= value
			instance.Width1 *= value
			instance.CurveSize0 *= value
			instance.CurveSize1 *= value
		elseif instance:IsA("Light") then
			instance.Range *= value
		end
	end
end

function Visuals.GetObject(p)
	return p.particles
end

function Visuals.Destroy(p)
	p.maid:Destroy()
end

function Visuals.SearchPath(items)
	local child = visuals

	for _, childName in items do
		child = child:FindFirstChild(childName)
	end

	return child
end

return Visuals