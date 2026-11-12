local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local v = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = v:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(character)
	v = character
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

local instances = {}

Scheduler.BindHeartbeat(function()
	if not humanoidRootPart then
		return
	end

	for _, v2 in instances do
		v2.WorldPosition = v2.Parent:GetClosestPointOnSurface(humanoidRootPart.Position)
	end
end)

local function tag(instance) -- 1 equivalent call inferred from this helper
	table.insert(instances, instance)

	local proximityPrompt = instance:FindFirstChildWhichIsA("ProximityPrompt")

	if proximityPrompt then
		proximityPrompt.MaxActivationDistance = proximityPrompt:GetAttribute("MaxActivationDistanceClient") or 20
	end
end

local function removeTag(p)
	table.remove(instances, table.find(instances, p))
end

CollectionService:GetInstanceAddedSignal("MoveToSurface"):Connect(tag)
CollectionService:GetInstanceRemovedSignal("MoveToSurface"):Connect(removeTag)

for _, v2 in CollectionService:GetTagged("MoveToSurface"), nil, nil do
	tag(v2) -- inferred equivalent call
end