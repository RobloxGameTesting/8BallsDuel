local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local v = Maid.new()
local DebugHelper = {}

function DebugHelper.CreatePartAtVector3(position: Vector3)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = Vector3.new(4, 1, 4)
	part.Anchored = true
	part.Position = position
	part.Color = Color3.new(1, 0, 0)
	part.Parent = workspace

	v[#v._tasks] = part

	return part
end

function DebugHelper.ClearParts()
	v:Destroy()
end

function DebugHelper.DrawRay(vector3: Vector3, vector3_2: Vector3, raycastResult: RaycastResult?)
	local magnitude = vector3_2.Magnitude
	local debugRay = Instance.new("Part")
	debugRay.Anchored = true
	debugRay.CanCollide = false
	debugRay.CanQuery = false
	debugRay.Material = Enum.Material.Neon
	debugRay.Color = raycastResult and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	debugRay.Size = Vector3.new(0.05, 0.05, magnitude)
	debugRay.CFrame = CFrame.new(vector3, vector3 + vector3_2) * CFrame.new(0, 0, -magnitude / 2)
	debugRay.Name = "DebugRay"

	debugRay.Parent = workspace

	local Debris = game:GetService("Debris")
	Debris:AddItem(debugRay, 2)

	if raycastResult then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 255, 0)
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(0.2, 0.2, 0.2)
		part.CFrame = CFrame.new(raycastResult.Position)
		part.Parent = workspace
		local Debris2 = game:GetService("Debris")
		Debris2:AddItem(part, 2)
	end
end

function DebugHelper.DuplicateAttachment(p)
	local debugAttachment = Instance.new("Part")
	debugAttachment.Name = "DebugAttachment"
	debugAttachment.Anchored = false
	debugAttachment.Massless = true
	debugAttachment.CanCollide = false
	debugAttachment.CanQuery = false
	debugAttachment.CanTouch = false
	debugAttachment.Material = Enum.Material.Neon
	debugAttachment.Color = Color3.fromRGB(255, 0, 0)
	debugAttachment.Shape = Enum.PartType.Ball
	debugAttachment.Size = Vector3.new(0.4, 0.4, 0.4)
	debugAttachment.Parent = p.Parent

	debugAttachment.CFrame = p.WorldCFrame

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = debugAttachment
	weldConstraint.Part1 = p.Parent
	weldConstraint.Parent = debugAttachment

	v[#v._tasks] = debugAttachment

	return debugAttachment
end

return DebugHelper