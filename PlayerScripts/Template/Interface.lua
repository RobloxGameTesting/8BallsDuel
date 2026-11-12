local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Modules.Menu)
require(ReplicatedStorage.Libraries.Modules.Profiles)
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
LocalPlayer:WaitForChild("PlayerGui")
LocalPlayer:WaitForChild("PlayerScripts")
local interface = ReplicatedStorage:WaitForChild("Interface")
local buttons = interface:WaitForChild("Buttons")
local pads = interface:WaitForChild("Pads")
local prompts = interface.Prompts

local v = {}

local function update()
	local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { humanoidRootPart }

	for _, moduleScript in pads:GetChildren(), nil, nil do
		local module = require(moduleScript)
		local pads2 = module.GetPads()

		for _, pad in pads2 do
			if not pad then
				continue
			end

			if #workspace:GetPartsInPart(pad, overlapParams) > 0 then
				if not v[pad] then
					v[pad] = true
					module.Touch(pad)
				end
			elseif v[pad] then
				v[pad] = false
				module.TouchEnded(pad)
			end
		end
	end
end

RunService.Heartbeat:Connect(update)

for _, moduleScript in buttons:GetChildren(), nil, nil do
	local module = require(moduleScript)
	local buttons2 = module.GetButtons()

	for _, button in buttons2 do
		local v2 = button
		Button.Create(button, function()
			local function recurseUntilScreenGui(screenGui)
				if screenGui:IsA("ScreenGui") then
					return screenGui
				end

				return recurseUntilScreenGui(screenGui.Parent)
			end

			local screenGui = v2

			if not screenGui:IsA("ScreenGui") then
				screenGui = recurseUntilScreenGui(screenGui.Parent)
			end

			local function removeUISuffix(name: string) -- 1 equivalent call inferred from this helper
				return string.gsub(name, "UI$", "")
			end

			local v3 = removeUISuffix(screenGui.Name) -- inferred equivalent call

			module.Toggle(v3)
		end)
	end
end

for _, moduleScript in prompts:GetChildren(), nil, nil do
	local module = require(moduleScript)
	local references = module.GetReferences()

	for _, reference in references do
		local v2 = reference
		reference.Triggered:Connect(function()
			module.Triggered(v2.Parent.Parent.Name)
		end)
	end

	module.ReferenceAdded.Event:Connect(function(p)
		p.Triggered:Connect(function()
			module.Triggered(p.Parent.Parent.Name)
		end)
	end)
end