game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local function addConveyor(instance) -- 1 equivalent call inferred from this helper
	instance.Velocity = (instance:GetAttribute("Speed") or 20) * instance.CFrame.LookVector
end

CollectionService:GetInstanceAddedSignal("Conveyor"):Connect(addConveyor)

for _, v in ipairs(CollectionService:GetTagged("Conveyor")) do
	addConveyor(v) -- inferred equivalent call
end