local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyTypes)
local CharacterHelper = require(ReplicatedStorage.Libraries.Helpers.CharacterHelper)
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Enemies = require(ReplicatedStorage.Libraries.GameSpecific.Enemies)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
require(ReplicatedStorage.Libraries.Classes.Animations.AnimationTypes)
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local EnemyHelpers = require(ReplicatedStorage.Libraries.GameSpecific.Enemies.EnemyHelpers)
require(ReplicatedStorage.Libraries.Classes.StateMachine.StateMachineTypes)
local parentModule = require(script.Parent.Parent)
local Idle = {}
Idle.name = "Idle"

function Idle.Enter(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local model = enemyById.model
	ModelHelper.SetNetworkOwner(enemyById.model, nil)
	local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")
	local animations = enemyById.animations

	if humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		humanoid:MoveTo(humanoidRootPart.Position)

		local alignAttachment = Instance.new("Attachment")
		alignAttachment.Name = "AlignAttachment"
		alignAttachment.Parent = humanoidRootPart

		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.MaxAngularVelocity = 1e999
		alignOrientation.MaxTorque = 1e999
		alignOrientation.Responsiveness = 15
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.AlignType = Enum.AlignType.PrimaryAxisParallel
		alignOrientation.Attachment0 = alignAttachment
		alignOrientation.Parent = humanoidRootPart

		Animations.Play(animations, {
			{ animation = "idle", looped = true }
		})
	end
end

function Idle.Exit(p)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)
	local model = enemyById.model
	local animations = enemyById.animations
	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local alignOrientation = humanoidRootPart:FindFirstChildWhichIsA("AlignOrientation")
		local alignAttachment = humanoidRootPart:FindFirstChild("AlignAttachment")

		if alignOrientation then
			alignOrientation:Destroy()
		end

		if alignAttachment then
			alignAttachment:Destroy()
		end
	end

	Animations.Stop(animations)
end

function Idle.Update(p, _: number)
	local enemyById = Enemies._getEnemyById(p.stateContext.npcId)

	if EnemyHelpers.IsDead(enemyById) then
		return "Died"
	end

	local humanoidRootPart = enemyById.model:FindFirstChild("HumanoidRootPart")
	local alignOrientation = humanoidRootPart:FindFirstChildWhichIsA("AlignOrientation")
	local v = CharacterHelper.GetClosestCharacter(humanoidRootPart.Position, true)[1]

	if v and v.character.PrimaryPart and alignOrientation then
		local position = v.character.PrimaryPart.Position
		local position2 = humanoidRootPart.Position

		local vector3 = Vector3.new(position.X - position2.X, 0, position.Z - position2.Z)
		local v2 = vector3 / vector3.Magnitude
		alignOrientation.CFrame = CFrame.lookAt(position2, position2 + v2)
	end

	return parentModule.FindNextState(p)
end

return Idle