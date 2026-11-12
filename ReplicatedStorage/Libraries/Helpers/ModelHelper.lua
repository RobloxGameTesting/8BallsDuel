local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("Players")

local v = Maid.new()

local function resizeModel(instance, p: number) -- 2 equivalent calls inferred from this helper
	instance:ScaleTo(p)
end

local ModelHelper = {
	Size = function(_, instance, p: number, p2: number, p3, p4)
		if p2 then
			if p == 0 then
				resizeModel(instance, p2) -- inferred equivalent call
				return
			end

			local v2 = p2 - 1
			local v3 = 0
			local v4 = 0
			local heartbeatConnection = nil

			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				if not (v3 < 1) then
					heartbeatConnection:Disconnect()

					return
				end

				v3 = math.min(v3 + dt / p, 1)

				local value = TweenService:GetValue(v3, p3 or Enum.EasingStyle.Linear, p4 or Enum.EasingDirection.Out)
				resizeModel(instance, (value * v2 + 1) / (v4 * v2 + 1)) -- inferred equivalent call
				v4 = value
			end)
		end
	end,
	CFrame = function(_, instance, cframe, tweenInfo)
		if tweenInfo.Time == 0 then
			instance:PivotTo(cframe)
			return
		end

		local v2 = Maid.new()
		v[instance] = v2

		local cframeValue = Instance.new("CFrameValue")
		cframeValue.Value = instance:GetPivot()

		cframeValue:GetPropertyChangedSignal("Value"):Connect(function()
			if instance.PrimaryPart then
				instance:PivotTo(cframeValue.Value)
			else
				v[instance] = nil
			end
		end)

		local tween = TweenService:Create(cframeValue, tweenInfo, { Value = cframe })
		tween:Play()

		tween.Completed:Connect(function()
			v[instance] = nil
		end)

		v2.cframe = cframeValue
		v2.tween = tween
	end,
	Transparency = function(_, part, duration, transparency)
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Transparency = transparency
			}):Play()
		end

		for _, part2 in part:GetDescendants(), nil, nil do
			if part2:IsA("BasePart") then
				TweenService:Create(part2, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Transparency = transparency
				}):Play()
			end
		end
	end,
	CanCollide = function(folder, canCollide: boolean)
		for _, part in folder:GetDescendants(), nil, nil do
			if part:IsA("BasePart") and part.CanCollide ~= canCollide then
				part.CanCollide = canCollide
			end
		end
	end,
	Properties = function(_, folder, items)
		for _, part in folder:GetDescendants(), nil, nil do
			if not part:IsA("BasePart") then
				continue
			end

			for k, item in items do
				part[k] = item
			end
		end
	end,
	Tween = function(p, p2, p3, items)
		for k, item in items do
			if p[k] then
				p[k](p, p2, p3, item)
			end
		end
	end,
	Weld = function(_, instance, part)
		local result = {}

		if instance:IsA("Model") then
			for _, part2 in instance:GetDescendants(), nil, nil do
				if not part2:IsA("BasePart") then
					continue
				end

				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = part2
				weldConstraint.Part1 = part
				weldConstraint.Parent = part2

				table.insert(result, weldConstraint)
			end
		elseif instance:IsA("BasePart") then
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = instance
			weldConstraint.Part1 = part
			weldConstraint.Parent = instance
			table.insert(result, weldConstraint)
		end

		return result
	end,
	InBounds = function(_, instance, p): boolean
		local position = nil

		if instance:IsA("Model") then
			position = instance:GetBoundingBox().Position
		elseif instance:IsA("BasePart") then
			position = instance.Position
		end

		local position2 = p.Position
		local size = p.Size

		local v2 = position2 - size / 2
		local v3 = position2 + size / 2

		return position.X >= v2.X
			and position.X <= v3.X
			and position.Y >= v2.Y
			and position.Y <= v3.Y
			and position.Z >= v2.Z
			and position.Z <= v3.Z
	end,
	GetMass = function(self)
		local mass = 0

		for _, part in self:GetDescendants(), nil, nil do
			if not part:IsA("BasePart") or part.Massless then
				continue
			end

			mass += part:GetMass()
		end

		return mass
	end,
	SetNetworkOwner = function(self, p)
		if self:IsA("Model") then
			for _, part in self:GetDescendants(), nil, nil do
				if not part:IsA("BasePart") then
					continue
				end

				local canSetNetworkOwnership, _ = part:CanSetNetworkOwnership()

				if canSetNetworkOwnership then
					part:SetNetworkOwner(p)
				end
			end
		elseif self:IsA("BasePart") then
			local canSetNetworkOwnership, _ = self:CanSetNetworkOwnership()

			if canSetNetworkOwnership then
				self:SetNetworkOwner(p)
			end
		end
	end,
	SetLocalTransparencyModifier = function(folder, localTransparencyModifier: number)
		for _, part in folder:GetDescendants(), nil, nil do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = localTransparencyModifier
			end
		end
	end
}

local v2 = {}

function ModelHelper.Visible(p)
	if not v2[p] then
		warn("Already visible")
		return
	end

	for instance, _ in v2[p] do
		if instance:IsA("BasePart") or instance:IsA("Decal") then
			instance.Transparency = v2[p][instance]
		elseif instance:IsA("BillboardGui") then
			instance.Enabled = v2[p][instance]
		end
	end

	v2[p] = nil
end

function ModelHelper.Invisible(folder)
	if v2[folder] then
		warn("Already invisible")
		return
	end

	v2[folder] = {}

	for _, descendant in folder:GetDescendants(), nil, nil do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			v2[folder][descendant] = descendant.Transparency
			descendant.Transparency = 1
		elseif descendant:IsA("BillboardGui") then
			v2[folder][descendant] = descendant.Enabled
			descendant.Enabled = false
		end
	end
end

function ModelHelper.GetChildrenByParentString(instance, items)
	for _, childName in items do
		instance = instance:FindFirstChild(childName)
	end

	return instance
end

function ModelHelper.SafeFind(instance, items)
	for _, childName in items do
		if not instance then
			return nil
		end

		instance = instance:FindFirstChild(childName)
	end

	return instance
end

return ModelHelper