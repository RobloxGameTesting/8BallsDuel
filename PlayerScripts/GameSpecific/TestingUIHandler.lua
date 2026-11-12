local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function onTestingUI(childName, enabled)
	if typeof(childName) ~= "string" then
		warn("[TestingUI] first argument must be a ScreenGui name, got " .. typeof(childName))

		return
	end

	if typeof(enabled) ~= "boolean" then
		warn("[TestingUI] second argument must be a boolean, got " .. typeof(enabled))

		return
	end

	local layerCollector = PlayerGui:FindFirstChild(childName)

	if layerCollector then
		if not layerCollector:IsA("LayerCollector") then
			warn("[TestingUI] " .. childName .. " is a " .. layerCollector.ClassName .. ", which has no Enabled property")

			return
		end

		layerCollector.Enabled = enabled

		print(string.format("[TestingUI] %s.Enabled = %s", childName, (tostring(enabled))))
	else
		local names = {}

		for _, screenGui in PlayerGui:GetChildren() do
			if screenGui:IsA("ScreenGui") then
				table.insert(names, screenGui.Name)
			end
		end

		table.sort(names)
		warn("[TestingUI] no ScreenGui called " .. childName .. ". Available: " .. table.concat(names, ", "))
	end
end

RemoteSignals.OnClientEvent("TestingUI", onTestingUI)