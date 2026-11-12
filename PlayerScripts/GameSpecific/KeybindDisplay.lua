local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Types.Types)
require(ReplicatedStorage.Types.DataTypes)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data

local function getKeybindFrames()
	local descendants = {}

	for _, descendant in PlayerGui:GetDescendants(), nil, nil do
		if descendant:GetAttribute("Keybind") and descendant:GetAttribute("datastoreKey") then
			table.insert(descendants, descendant)
		end
	end

	return descendants
end

local function findCorrespondingKeybind(k) -- 1 equivalent call inferred from this helper
	for _, v in getKeybindFrames(), nil, nil do
		if v:GetAttribute("datastoreKey") == k then
			return v
		end
	end

	return nil
end

local function updateKeybinds()
	local v = Device:Get()
	local v2 = data.configuration[`{string.lower(v)}Keybinds`]
	local buttons = v2 and v2.buttons

	if v2 then
		for _, v3 in getKeybindFrames(), nil, nil do
			if buttons[v3:GetAttribute("datastoreKey")] then
				v3.Parent.Visible = true
			else
				v3.Parent.Visible = false
			end
		end
	end

	if v == "Desktop" or v == "Console" then
		for k, button in buttons do
			local correspondingKeybind = findCorrespondingKeybind(k) -- inferred equivalent call

			if not correspondingKeybind then
				continue
			end

			local v3 = Enum.KeyCode:FromValue(button)

			if v3 then
				correspondingKeybind:SetAttribute("Keybind", v3.Name)
			end
		end
	end
end

updateKeybinds()
Device.Changed:Connect(updateKeybinds)