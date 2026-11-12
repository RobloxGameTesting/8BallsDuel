local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Device = require(ReplicatedStorage.Libraries.Modules.Device)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local _ = { "Main", "Practice" }
local v = {
	LobbyUI = function(_) end,
	MainUI = function(_) end
}

local nameSet = {}

local function apply(child) -- 2 equivalent calls inferred from this helper
	local name = child.Name
	local v2 = v[name]

	if v2 and not nameSet[name] then
		nameSet[name] = true
		v2(child)
	end
end

if Device:Get() == "Mobile" then
	for _, child in PlayerGui:GetChildren(), nil, nil do
		apply(child) -- inferred equivalent call
	end

	PlayerGui.ChildAdded:Connect(function(child)
		apply(child) -- inferred equivalent call
	end)
end