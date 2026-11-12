local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelHelper = require(ReplicatedStorage.Libraries.Helpers.ModelHelper)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local buildConstraints = require(script:WaitForChild("buildConstraints"))
local buildCollisionFilters = require(script:WaitForChild("buildCollisionFilters"))

local v = Maid.new()
local v2 = {
	{
		name = "LeftHipRagdollJoint",
		cframe = CFrame.new(-0.5, -1, 0),
		parent = "Torso",
		parent1 = "Left Leg",
		joint = "BallSocketConstraint",
		motor6d = { "Torso", "Left Hip" }
	},
	{
		name = "RightHipRagdollJoint",
		cframe = CFrame.new(0.5, -1, 0),
		parent = "Torso",
		parent1 = "Right Leg",
		joint = "BallSocketConstraint",
		motor6d = { "Torso", "Right Hip" }
	},
	{
		name = "NeckRagdollJoint",
		cframe = CFrame.new(0, 1, 0),
		parent = "Torso",
		parent1 = "Head",
		joint = "BallSocketConstraint",
		motor6d = { "Torso", "Neck" }
	},
	{
		name = "LeftArmRagdollJoint",
		cframe = CFrame.new(-1, 1, 0),
		parent = "Torso",
		parent1 = "Left Arm",
		joint = "BallSocketConstraint",
		motor6d = { "Torso", "Left Shoulder" }
	},
	{
		name = "RightArmRagdollJoint",
		cframe = CFrame.new(1, 1, 0),
		parent = "Torso",
		parent1 = "Right Arm",
		joint = "BallSocketConstraint",
		motor6d = { "Torso", "Right Shoulder" }
	}
}

function buildAttachmentMap(instance)
	local attachmentMap = {}

	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		for _, attachment in pairs(part:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local match = attachment.Name:match("^(.+)RigAttachment$")
			local child

			if match then
				child = attachment.Parent:FindFirstChild(match) or nil
			end

			if child then
				attachmentMap[attachment.Name] = {
					Joint = child,
					Attachment0 = child.Part0[attachment.Name],
					Attachment1 = child.Part1[attachment.Name]
				}
			end
		end
	end

	return attachmentMap
end

local function buildR6(parent)
	local ragdollConstraints = Instance.new("Folder")
	ragdollConstraints.Name = "RagdollConstraints"
	ragdollConstraints.Parent = parent

	for _, v3 in v2 do
		local attachment = Instance.new("Attachment")
		attachment.Name = v3.name
		attachment.CFrame = v3.cframe
		attachment.Parent = parent:FindFirstChild(v3.parent)

		local attachment2 = Instance.new("Attachment")
		attachment2.Name = v3.name
		attachment2.WorldCFrame = parent:FindFirstChild(v3.parent1).CFrame:ToObjectSpace(attachment.WorldCFrame)
		attachment2.Parent = parent:FindFirstChild(v3.parent1)

		local instance = Instance.new(v3.joint)
		instance.LimitsEnabled = true
		instance.Attachment0 = attachment
		instance.Attachment1 = attachment2
		instance.Parent = ragdollConstraints

		local rigidJoint = Instance.new("ObjectValue")
		rigidJoint.Name = "RigidJoint"
		local child = parent

		for _, childName in v3.motor6d do
			child = child:FindFirstChild(childName)
		end

		rigidJoint.Value = child
		rigidJoint.Parent = instance

		instance.LimitsEnabled = true
	end
end

return function(instance)
	local parent = instance.Parent
	local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

	instance.BreakJointsOnDeath = false

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.CanCollide = false
	end

	v.networkConnection = RunService.Heartbeat:Connect(function()
		ModelHelper.SetNetworkOwner(parent, playerFromCharacter)
	end)

	if instance.RigType == Enum.HumanoidRigType.R15 then
		local attachmentMap = buildAttachmentMap(parent)
		local constraints = buildConstraints(attachmentMap)
		local collisionFilters = buildCollisionFilters(attachmentMap, parent.PrimaryPart)

		collisionFilters.Parent = constraints
		constraints.Parent = parent
	elseif instance.RigType == Enum.HumanoidRigType.R6 then
		buildR6(parent)
	end

	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(instance, "Ragdoll")
end