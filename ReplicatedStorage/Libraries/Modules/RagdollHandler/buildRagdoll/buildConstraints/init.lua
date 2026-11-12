local getLastWordFromPascalCase = require(script.Parent:WaitForChild("getLastWordFromPascalCase"))

local childrenByName = {}

for _, child in pairs(script:GetChildren()) do
	childrenByName[child.Name] = child
end

function getConstraintTemplate(p)
	return childrenByName[getLastWordFromPascalCase(p)] or childrenByName.Default
end

function createConstraint(data)
	local name = data.Joint.Name
	local clone = getConstraintTemplate(name):Clone()

	clone.Attachment0 = data.Attachment0
	clone.Attachment1 = data.Attachment1
	clone.Name = name .. "RagdollConstraint"

	local rigidJoint = Instance.new("ObjectValue", clone)
	rigidJoint.Name = "RigidJoint"
	rigidJoint.Value = data.Joint

	return clone
end

return function(items)
	local ragdollConstraints = Instance.new("Folder")
	ragdollConstraints.Name = "RagdollConstraints"

	for _, item in pairs(items) do
		if item.Joint.Name == "Root" then
			continue
		end

		local constraint = createConstraint(item)
		constraint.Parent = ragdollConstraints
	end

	return ragdollConstraints
end