local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local Players = game:GetService("Players")
local NumberHelper = require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Mouses = require(ReplicatedStorage.Libraries.Classes.Mouses)

local v = Maid.new()

local CharacterHelper = {}

function CharacterHelper.TeleportTo(instance, p)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoidRootPart and humanoid then
		instance:PivotTo(p.CFrame * CFrame.new(0, humanoid.HipHeight + humanoidRootPart.Size.Y / 2, 0))
	else
		warn("No HRP/Humanoid", instance)
	end
end

function CharacterHelper.ResizeR6(instance, p: number, flag: boolean)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")
	local head = instance and instance:FindFirstChild("Head")
	local torso = instance and instance:FindFirstChild("Torso")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local userId = playerFromCharacter and tostring(playerFromCharacter.UserId)
	local humanoid = instance and instance:FindFirstChild("Humanoid")

	if not (instance and humanoidRootPart and humanoid) then
		return
	end

	if flag then
		p = 1 / (humanoidRootPart.Size.Y / 2) * p
	end

	local function _resizeAccessories()
		if instance:FindFirstChild("Head") then
			local specialMesh = head:FindFirstChildWhichIsA("SpecialMesh")

			if specialMesh and specialMesh.MeshId ~= "" then
				specialMesh.Scale *= p
			end
		end

		for _, accessory in instance:GetChildren(), nil, nil do
			if accessory:IsA("Accessory") then
				local handle = accessory:FindFirstChild("Handle")
				local accessoryWeld = handle:FindFirstChild("AccessoryWeld")
				local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

				accessoryWeld.C0 = CFrame.new(accessoryWeld.C0.Position * p) * (accessoryWeld.C0 - accessoryWeld.C0.Position)
				accessoryWeld.C1 = CFrame.new(accessoryWeld.C1.Position * p) * (accessoryWeld.C1 - accessoryWeld.C1.Position)

				if specialMesh then
					specialMesh.Scale *= p
				end

				v[userId .. "appearanceLoaded"] = nil
			else
				print("no accessory")
			end
		end
	end

	v[userId .. "appearanceLoaded"] = playerFromCharacter.CharacterAppearanceLoaded:Connect(function()
		_resizeAccessories()
	end)

	local v2 = {}

	table.insert(v2, (humanoidRootPart:FindFirstChild("RootJoint")))

	for _, motor6D in torso:GetChildren(), nil, nil do
		if motor6D:IsA("Motor6D") ~= false then
			table.insert(v2, motor6D)
		end
	end

	for _, v3 in v2 do
		v3.C0 = CFrame.new(v3.C0.Position * p) * (v3.C0 - v3.C0.Position)
		v3.C1 = CFrame.new(v3.C1.Position * p) * (v3.C1 - v3.C1.Position)
	end

	for _, part in instance:GetChildren(), nil, nil do
		if part:IsA("BasePart") then
			part.Size *= p
		end
	end

	_resizeAccessories()

	local tool = instance:FindFirstChildWhichIsA("Tool")
	local scale = tool:GetScale()

	if tool then
		tool:ScaleTo(scale * p)
	end

	v[userId .. "toolAdded"] = instance.ChildAdded:Connect(function(tool2)
		if tool2:IsA("Tool") then
			tool2:ScaleTo(tool2:GetScale() * p)
		end
	end)

	v[userId .. "toolRemoved"] = instance.ChildRemoved:Connect(function(tool2)
		if tool2:IsA("Tool") then
			tool2:ScaleTo(tool2:GetScale() / p)
		end
	end)
end

function CharacterHelper.ScaleUpR15(model, p: number)
	if not (model and model:IsA("Model")) then
		return
	end

	local humanoid = model:FindFirstChild("Humanoid")

	if not (humanoid and humanoid:IsA("Humanoid")) then
		return
	end

	local walkSpeed = humanoid.WalkSpeed
	local jumpHeight = humanoid.JumpHeight

	model:ScaleTo(p)

	humanoid.WalkSpeed = walkSpeed
	humanoid.JumpHeight = jumpHeight
end

function CharacterHelper.GetMoveDirectionRelativeToLookVector(instance)
	if not instance then
		return 0
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return 0
	end

	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude < 0.001 then
		return 0
	end

	return (math.clamp(moveDirection:Dot(humanoidRootPart.CFrame.RightVector), -1, 1))
end

local v2 = {
	WalkSpeed = function(p)
		return p.WalkSpeed
	end,
	JumpHeight = function(p)
		return p.JumpHeight
	end
}

local v3 = {
	WalkSpeed = function(p, walkSpeed)
		p.WalkSpeed = walkSpeed
	end,
	JumpHeight = function(p, jumpHeight)
		p.JumpHeight = jumpHeight
	end
}

local v4 = {}

function CharacterHelper.SetHumanoidProperty(player, propertyName: string, p: number)
	local userId = tostring(player.UserId)
	local character = player.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return
	end

	if not v2[propertyName] then
		warn(`There isn't a getter for property {propertyName}`)
		return
	end

	if not v3[propertyName] then
		warn(`There isn't a setter for property {propertyName}`)
		return
	end

	if not v4[userId] then
		v4[userId] = {}
	end

	v4[userId][propertyName] = v2[propertyName](humanoid)
	v3[propertyName](humanoid, p)
	v[`changedConnection{propertyName}{userId}`] = humanoid:GetPropertyChangedSignal(propertyName):Connect(function()
		if v2[propertyName](humanoid) == p then
			return
		end

		v4[userId][propertyName] = v2[propertyName](humanoid)
		v3[propertyName](humanoid, p)
	end)
end

function CharacterHelper.ResetHumanoidProperty(player, p: string)
	local userId = tostring(player.UserId)
	local character = player.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return
	end

	if not v2[p] then
		warn(`There isn't a getter for property {p}`)
		return
	end

	if not v3[p] then
		warn(`There isn't a setter for property {p}`)
		return
	end

	if not (v4[userId] and v4[userId][p]) then
		return
	end

	v[`changedConnection{p}{userId}`] = nil
	local v5 = v4[userId][p]
	v3[p](humanoid, v5)
end

function CharacterHelper.GetCharacterFromPart(instance)
	for _, v5 in Players:GetPlayers(), nil, nil do
		local character = v5.Character

		if character and instance:IsDescendantOf(character) then
			return character
		end
	end

	return nil
end

function CharacterHelper.GetClosestCharacter(vector3: Vector3, flag: boolean)
	local closestCharacter = {}

	for _, v5 in Players:GetPlayers(), nil, nil do
		tostring(v5.UserId)
		local character = v5.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

		if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
			continue
		end

		local distance

		if flag then
			distance = (vector3 - NumberHelper:SetVector3(humanoidRootPart.Position, vector3.Y)).Magnitude
		else
			distance = (vector3 - humanoidRootPart.Position).Magnitude
		end

		table.insert(closestCharacter, { distance = distance, character = character })
	end

	table.sort(closestCharacter, function(a, b): boolean
		return a.distance < b.distance
	end)

	return closestCharacter
end

function CharacterHelper.GetHumanoids()
	local humanoids = {}

	for _, humanoid in workspace:GetDescendants(), nil, nil do
		if humanoid:IsA("Humanoid") then
			table.insert(humanoids, humanoid)
		end
	end

	return humanoids
end

function CharacterHelper.GetPredictedPosition(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and playerFromCharacter) then
		return nil
	end

	local networkPing = playerFromCharacter:GetNetworkPing()

	return humanoidRootPart.Position + humanoidRootPart.AssemblyLinearVelocity * networkPing
end

function CharacterHelper:Clone()
	self.Archivable = true
	local clone = self:Clone()
	self.Archivable = false

	return clone
end

function CharacterHelper.ClosestDistancePartToPlayer(p, player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local position = humanoidRootPart and humanoidRootPart.Position

	if position then
		return (position - VectorHelper.GetClosestPointOnPart(p, position)).Magnitude
	end

	return 1e999
end

function CharacterHelper.Controls(flag: boolean)
	local localPlayer = Players.LocalPlayer
	local PlayerModule = require(localPlayer.PlayerScripts.PlayerModule)
	local controls = PlayerModule:GetControls()

	if flag then
		controls:Enable()
	else
		controls:Disable()
	end
end

function CharacterHelper.AutoRotate(_: boolean, p)
	local Device = require(ReplicatedStorage.Libraries.Modules.Device)

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (character and humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	if Device:Get() == "Mobile" then
		return
	end

	if Device:Get() == "Desktop" then
		local function rotate()
			local v5 = p and Mouses.Project(p, "Blacklist")
			local position = v5 and v5.Position or localPlayer:GetMouse().Hit.Position
			local v6 = position + Vector3.new(0, humanoidRootPart.Position.Y - position.Y, 0)

			humanoidRootPart:PivotTo((CFrame.lookAt(humanoidRootPart.Position, v6)))
		end

		rotate()
		v.rotateStopConnection = nil
		local MechanicHandler = require(ReplicatedStorage.Libraries.Modules.MechanicHandler)

		v.rotateConnection = RunService.RenderStepped:Connect(function()
			if humanoid:GetState() == Enum.HumanoidStateType.Dead then
				humanoid.AutoRotate = true
				v.rotateConnection = nil
			else
				if MechanicHandler.IsDashing() then
					return
				end

				if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
					humanoid.AutoRotate = true
					return
				end

				humanoid.AutoRotate = false

				rotate()
			end
		end)
	end
end

function CharacterHelper.StopAutoRotate(p: number?)
	if p then
		local total = 0

		v.rotateStopConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt

			if p <= total then
				CharacterHelper.StopAutoRotate()
			end
		end)
	else
		v.rotateStopConnection = nil
		v.rotateConnection = nil

		local localPlayer = Players.LocalPlayer
		local character = localPlayer and localPlayer.Character

		if character then
			character:FindFirstChildWhichIsA("Humanoid")
		end

		if character then
			character:FindFirstChild("HumanoidRootPart")
		end

		local localPlayer2 = Players.LocalPlayer
		local character2 = localPlayer2 and localPlayer2.Character
		local humanoid = character2 and character2:FindFirstChildWhichIsA("Humanoid")
		local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not (character2 and humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		humanoid.AutoRotate = true
	end
end

return CharacterHelper