local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolConstants = require(Pool.PoolConstants)
local PoolSkins = require(Pool.PoolSkins)

local PoolVisuals = {}

local VisualCues = PoolConstants.VisualCues

function PoolVisuals.new()
	return { BallInHand = nil, Highlights = {} }
end

local function anchorTo(p, part)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return
	end

	local folder = Visuals.GetObject(p)

	if not folder then
		return
	end

	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, part2 in descendants do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = true

		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.Massless = true
	end
end

local function applyScale(p, part, p2)
	local scale = tonumber(p2 and p2.Scale) or 1

	if typeof(part) == "Instance" and part:IsA("BasePart") then
		local object = Visuals.GetObject(p)

		local referenceDiameter = object and tonumber(object:GetAttribute("ReferenceDiameter"))
			or VisualCues.ReferenceBallDiameter

		if referenceDiameter and referenceDiameter > 0 then
			local size = part.Size

			scale *= math.max(size.X, size.Y, size.Z) / referenceDiameter
		end
	end

	Visuals.Scale(p, scale)
end

local function applyLightEmission(p, lightEmission: number)
	local folder = Visuals.GetObject(p)

	if not folder then
		return
	end

	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, emitter in descendants do
		if emitter:IsA("ParticleEmitter") then
			emitter.LightEmission = lightEmission
		end
	end
end

local function playAt(data, p, flag: boolean?)
	if not data then
		return nil
	end

	local success, result = pcall(Visuals.new, data.Path, p)

	if not (success and result) then
		warn("[PoolVisuals] could not play effect: " .. tostring(result))

		return nil
	end

	if data.Colour then
		pcall(Visuals.Recolour, result, data.Colour)
	end

	if typeof(data.LightEmission) == "number" then
		pcall(applyLightEmission, result, data.LightEmission)
	end

	pcall(anchorTo, result, p)

	pcall(applyScale, result, p, data)

	local v = data.Timer == "Manual"

	pcall(Visuals.Play, result, data.Timer, not v)

	if not flag and Sounds.SearchPath(data.Path) then
		Sounds.Play(Sounds.new(data.Path, nil), nil, true)
	end

	return result
end

function PoolVisuals:ShowBallInHand(p)
	PoolVisuals.HideBallInHand(self)

	if not p then
		return
	end

	self.BallInHand = playAt(VisualCues.BallInHand, p)
end

function PoolVisuals:HideBallInHand()
	local ballInHand = self.BallInHand

	if not ballInHand then
		return
	end

	self.BallInHand = nil

	pcall(Visuals.Stop, ballInHand)
	pcall(Visuals.Destroy, ballInHand)
end

function PoolVisuals.HighlightBalls(p, items, p2)
	PoolVisuals.ClearHighlights(p)

	local v = p2 or VisualCues.YourBalls

	for k, item in items do
		p.Highlights[k] = playAt(v, item)
	end
end

function PoolVisuals.ClearHighlights(p)
	for k, highlight in p.Highlights do
		pcall(Visuals.Stop, highlight)
		pcall(Visuals.Destroy, highlight)

		p.Highlights[k] = nil
	end
end

function PoolVisuals.PlayPot(vector3: Vector3, p: string?, flag: boolean?)
	playAt(PoolSkins.GetPotCue(p), vector3, flag)
end

function PoolVisuals.Clear(p)
	PoolVisuals.HideBallInHand(p)
	PoolVisuals.ClearHighlights(p)
end

return PoolVisuals