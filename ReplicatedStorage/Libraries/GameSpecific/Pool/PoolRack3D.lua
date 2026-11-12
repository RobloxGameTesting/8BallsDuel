local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")

local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolAudio = require(Pool.PoolAudio)
local PoolConstants = require(Pool.PoolConstants)
local PoolTableRenderer3D = require(Pool.PoolTableRenderer3D)

local PoolRack3D = {}

local Rack3D = PoolConstants.Rack3D
local BallDiameter = PoolConstants.BallDiameter
local halfBallDiameter = BallDiameter / 2

local function rectToTable(anchor, tableRect)
	local absoluteSize = tableRect.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return nil, 0, 0
	end

	local v = tableRect.AbsolutePosition + absoluteSize / 2
	local v2 = anchor.AbsolutePosition + anchor.AbsoluteSize / 2 - v

	return
		Vector2.new(
			v2.X / absoluteSize.X * PoolConstants.FrameWidth,
			-(v2.Y / absoluteSize.Y * PoolConstants.FrameHeight)
		),
		anchor.AbsoluteSize.X / absoluteSize.X * PoolConstants.FrameWidth,
		anchor.AbsoluteSize.Y / absoluteSize.Y * PoolConstants.FrameHeight
end

local function orient(world: Vector3, vector3: Vector3, p: number)
	local unit = (Vector3.new(0, 1, 0)):Cross(vector3).Unit
	local vector = vector3 * math.cos(p) - Vector3.new(0, 1, 0) * math.sin(p)
	local unit2 = vector:Cross(unit).Unit

	local vector2 = -vector
	return CFrame.fromMatrix(world, vector2, unit2, vector2:Cross(unit2)), vector, unit2
end

local function buildFrame(p)
	local v = Rack3D.Offset
	local length = Rack3D.Length
	local width = Rack3D.Width
	local vertical = false

	if p and p.Anchor and p.TableRect then
		local v2, v3, v4 = rectToTable(p.Anchor, p.TableRect)

		if v2 then
			vertical = v3 < v4
			local v5 = if vertical then v4 else v3
			length = math.max(v5, BallDiameter * 2)

			if vertical then
				v4 = v3
			end

			width = math.max(v4, BallDiameter * 1.2)
			v = v2
		end
	end

	local v2 = math.atan2(Rack3D.Drop, length)
	local cframe, along, normal = orient(
		PoolTableRenderer3D.ToWorld(v, Rack3D.Height),
		vertical and Vector3.new(0, 0, 1) or Vector3.new(-1, 0, 0),
		v2
	)
	return {
		HighEnd = cframe.Position - along * (length / 2),
		Along = along,
		Normal = normal,
		CFrame = cframe,
		Length = length,
		Width = width,
		Vertical = vertical
	}
end

local function centreAt(frame, p: number) -- 2 equivalent calls inferred from this helper
	return frame.HighEnd + frame.Along * p + frame.Normal * (Rack3D.Thickness / 2 + halfBallDiameter)
end

local function restingDistance(frame, p: number) -- 3 equivalent calls inferred from this helper
	local v = (p - 0.5) * BallDiameter * Rack3D.Spacing

	return (math.max(frame.Length - v, 0))
end

function PoolRack3D.new(parent, anchor, tableRect)
	local maid = Maid.new()

	local poolRack3D = Instance.new("Folder")
	poolRack3D.Name = "PoolRack3D"
	maid:GiveTask(poolRack3D)

	local rack = Instance.new("Part")
	rack.Name = "Rack"
	rack.Color = Rack3D.Colour
	rack.Material = Enum.Material.SmoothPlastic
	rack.Anchored = true
	rack.CanCollide = false
	rack.CanQuery = false
	rack.CanTouch = false
	rack.CastShadow = false
	rack.Parent = poolRack3D

	local v = {
		Root = poolRack3D,
		Surface = rack,
		Slots = {},
		Active = false,
		Anchor = anchor,
		TableRect = tableRect,
		Frame = buildFrame(nil),
		LastPosition = nil,
		LastSize = nil,
		TableSize = nil,
		RollSound = nil,
		Maid = maid
	}

	poolRack3D.Parent = parent

	PoolRack3D.Refresh(v)

	return v
end

function PoolRack3D:Refresh()
	local anchor = self.Anchor
	local tableRect = self.TableRect

	if anchor and tableRect then
		local absolutePosition = anchor.AbsolutePosition
		local absoluteSize = anchor.AbsoluteSize

		local absoluteSize2 = tableRect.AbsoluteSize

		if
			self.LastPosition == absolutePosition
			and self.LastSize == absoluteSize
			and self.TableSize == absoluteSize2
		then
			return
		end

		self.LastPosition = absolutePosition
		self.LastSize = absoluteSize
		self.TableSize = absoluteSize2
	end

	local frame = buildFrame(self)
	self.Frame = frame

	self.Surface.Size = Vector3.new(frame.Length, Rack3D.Thickness, frame.Width)
	self.Surface.CFrame = frame.CFrame

	for k, slot in self.Slots do
		slot.Target = restingDistance(frame, k) -- inferred equivalent call

		if not slot.Ball then
			continue
		end

		local distance

		if slot.Settled then
			distance = slot.Target
		else
			distance = math.min(slot.Distance, frame.Length)
		end

		slot.Distance = distance
		slot.Ball.CFrame = CFrame.new(centreAt(frame, distance)) * slot.Ball.CFrame.Rotation -- inferred equivalent call
	end
end

local function place(state, p, distance: number)
	local ball = p.Ball
	local frame = state.Frame
	local v = centreAt(frame, distance) -- inferred equivalent call
	local v2 = v - ball.Position
	local magnitude = v2.Magnitude
	local rotation = ball.CFrame.Rotation

	if magnitude > 0.0001 then
		local cross = frame.Normal:Cross(v2)

		if cross.Magnitude > 1e-6 then
			rotation = CFrame.fromAxisAngle(cross.Unit, magnitude / halfBallDiameter) * rotation
		end
	end

	ball.CFrame = CFrame.new(v) * rotation
	p.Distance = distance
end

function PoolRack3D:Add(number: number)
	if not Rack3D.Enabled then
		return
	end

	for _, slot in self.Slots do
		if slot.Number == number then
			return
		end
	end

	local v = #self.Slots + 1
	local v2 = {
		Number = number,
		Ball = nil,
		Distance = 0,
		Speed = 0,
		Target = restingDistance(self.Frame, v), -- inferred equivalent call
		Settled = false
	}

	self.Slots[v] = v2
	local count = 0

	for i = 1, v - 1 do
		if not self.Slots[i].Ball then
			count += 1
		end
	end

	task.delay(Rack3D.ReturnDelay + count * Rack3D.ReturnStagger, function()
		if not (self.Root.Parent and table.find(self.Slots, v2)) then
			return
		end

		v2.Ball = PoolTableRenderer3D.CreateLooseBall(self.Root, number, "RackBall" .. number)
		v2.Speed = Rack3D.EntrySpeed

		place(self, v2, 0)

		self.Active = true
	end)
end

function PoolRack3D:Update(p: number)
	PoolRack3D.Refresh(self)

	if not self.Active then
		return
	end

	local active = false

	for k, slot in self.Slots do
		if slot.Ball and not slot.Settled then
			local slot2 = self.Slots[k - 1]
			local target = slot.Target

			if slot2 and slot2.Ball then
				target = math.min(target, slot2.Distance - BallDiameter * Rack3D.Spacing)
			end

			local v = math.max(target, 0)

			local speed = slot.Speed + Rack3D.Acceleration * p
			local v2 = slot.Distance + speed * p

			if v <= v2 then
				if slot.Target - 0.001 <= v then
					speed = -speed * Rack3D.Restitution

					if math.abs(speed) < Rack3D.SettleSpeed then
						slot.Settled = true
						speed = 0
					end
				else
					speed = 0
				end
			elseif v2 < 0 then
				speed = 0
				v = 0
			else
				v = v2
			end

			slot.Speed = speed
			place(self, slot, v)

			if not slot.Settled then
				active = true
			end
		elseif not slot.Ball then
			active = true
		end
	end

	self.Active = active

	if active and not self.RollSound then
		self.RollSound = PoolAudio.PlayCue("RackRoll")
	elseif not active and self.RollSound then
		local rollSound = self.RollSound
		self.RollSound = nil

		pcall(function()
			rollSound:Stop()
			rollSound:Destroy()
		end)
	end
end

function PoolRack3D:Remove(p: number)
	local v = nil

	for k, slot in self.Slots do
		if slot.Number == p then
			v = k
			break
		end
	end

	if not v then
		return
	end

	local v2 = table.remove(self.Slots, v)

	if v2 and v2.Ball then
		v2.Ball:Destroy()
	end

	for k, slot in self.Slots do
		slot.Target = restingDistance(self.Frame, k) -- inferred equivalent call

		if v <= k then
			slot.Settled = false
		end
	end

	self.Active = #self.Slots > 0
end

function PoolRack3D:Clear()
	for _, slot in self.Slots do
		if slot.Ball then
			slot.Ball:Destroy()
		end
	end

	table.clear(self.Slots)
	self.Active = false
end

function PoolRack3D.SetVisible(p, flag: boolean)
	p.Surface.Transparency = flag and 0 or 1

	for _, slot in p.Slots do
		if slot.Ball then
			slot.Ball.Transparency = flag and 0 or 1
		end
	end
end

function PoolRack3D:Destroy()
	PoolRack3D.Clear(self)
	self.Maid:DoCleaning()
end

return PoolRack3D