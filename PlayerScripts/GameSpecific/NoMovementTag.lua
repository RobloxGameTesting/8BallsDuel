game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Helpers.DebugHelper)
local Scheduler = require(ReplicatedStorage.Libraries.Modules.Scheduler)
local MechanicHandler = require(ReplicatedStorage.Libraries.Modules.MechanicHandler)
local HealthHandler = require(ReplicatedStorage.Libraries.Modules.HealthHandler)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local instances = {}
local v = false
local total = 0

Scheduler.BindHeartbeat(function(p)
	if
		HealthHandler.IsDowned(userId)
		or not LocalPlayer.Character
		or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	then
		return
	end

	total += p

	if total < 0.1 then
		return
	end

	total = 0

	overlapParams.FilterDescendantsInstances = { LocalPlayer.Character.HumanoidRootPart }
	local v2 = false

	for _, v3 in instances do
		if #workspace:GetPartsInPart(v3, overlapParams) > 0 then
			v2 = true
			break
		end
	end

	if v ~= v2 then
		v = v2
		MechanicHandler.Sprint(LocalPlayer, not v2)
		MechanicHandler.CanDash(not v2)
		MechanicHandler.CanCrouch(not v2)
	end
end)

local function tag(instance) -- 1 equivalent call inferred from this helper
	if not instance:IsDescendantOf(workspace) then
		return
	end

	table.insert(instances, instance)
end

local function removeTag(p)
	table.remove(instances, table.find(instances, p))
end

CollectionService:GetInstanceRemovedSignal("NoMovement"):Connect(removeTag)
CollectionService:GetInstanceAddedSignal("NoMovement"):Connect(tag)

for _, v2 in CollectionService:GetTagged("NoMovement"), nil, nil do
	tag(v2) -- inferred equivalent call
end