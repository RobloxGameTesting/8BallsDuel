local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)
local Level = require(ReplicatedStorage.Libraries.Modules.Level)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)
local v = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
local data = v.Data
local parent = script.Parent

local instances = {}

local function update(instance) -- 2 equivalent calls inferred from this helper
	local level, _, _ = Level:GetLevel(
		instance:GetAttribute("Experience"),
		instance:GetAttribute("EquationId") or "LEVEL_EQUATION"
	)
	instance.Text = tostring(level)
end

local function tag(instance)
	table.insert(instances, instance)

	if not instance:GetAttribute("Experience") then
		local function update2() -- 1 equivalent call inferred from this helper
			instance:SetAttribute("Experience", data.experience)
		end

		update2() -- inferred equivalent call
		v:ListenToWrite("Experience", update2)
	end

	update(instance) -- inferred equivalent call
	instance:GetAttributeChangedSignal("Experience"):Connect(function()
		update(instance) -- inferred equivalent call
	end)
end

CollectionService:GetInstanceAddedSignal("LevelLabel"):Connect(function(p)
	tag(p)
end)

for _, v2 in CollectionService:GetTagged("LevelLabel"), nil, nil do
	tag(v2)
end