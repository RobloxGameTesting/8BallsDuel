local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Modules"):WaitForChild("Profiles"))
game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Device)
local CollectionService = game:GetService("CollectionService")
local VectorHelper = require(ReplicatedStorage.Libraries.Helpers.VectorHelper)
local Light = require(ReplicatedStorage.Libraries.Modules.Light)
local Music = require(ReplicatedStorage.Libraries.Modules.Music)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

LocalPlayer:WaitForChild("PlayerGui")
local music = SoundService.Music

local v = Maid.new()
local CurrentCamera = workspace.CurrentCamera
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local v2 = nil
local v3 = {}

local function setRegion(instance)
	if not (instance and v2 ~= instance) then
		return
	end

	v2 = instance
	local music2 = instance:GetAttribute("Music")
	local light = instance:GetAttribute("Light")
	local transition = instance:GetAttribute("Transition")

	if music2 then
		Music.Play(music2)
	end

	if light then
		Light:Load(light, transition)
	end

	v.attributeChanged = instance.AttributeChanged:Connect(function(p)
		if p == "Music" then
			local music3 = instance:GetAttribute("Music")
			Music.Play(music3)
		elseif p == "Light" then
			Light:Load(instance:GetAttribute("Light"), (instance:GetAttribute("Transition")))
		end
	end)
end

v.regionConnection = RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	overlapParams.FilterDescendantsInstances = { humanoidRootPart }

	for _, v4 in v3 do
		if VectorHelper.IsPointInsidePart(CurrentCamera.CFrame.Position, v4) then
			setRegion(v4)
			break
		end
	end
end)

local function tag(part) -- 1 equivalent call inferred from this helper
	table.insert(v3, part)
end

local function removeTag(p)
	table.remove(v3, table.find(v3, p))
end

CollectionService:GetInstanceAddedSignal("Region"):Connect(tag)
CollectionService:GetInstanceRemovedSignal("Region"):Connect(removeTag)

for _, part in CollectionService:GetTagged("Region"), nil, nil do
	if part:IsA("BasePart") then
		tag(part) -- inferred equivalent call
	end
end