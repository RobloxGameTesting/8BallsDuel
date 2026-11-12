game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local function addReplicate(instance) -- 1 equivalent call inferred from this helper
	local Command = require(instance:WaitForChild("Command"))
	Command()
end

CollectionService:GetInstanceAddedSignal("Replicate"):Connect(addReplicate)

for _, v in CollectionService:GetTagged("Replicate"), nil, nil do
	addReplicate(v) -- inferred equivalent call
end