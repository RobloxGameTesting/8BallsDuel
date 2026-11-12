local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local TweenService = game:GetService("TweenService")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local EffectUI = PlayerGui:WaitForChild("EffectUI")

local v = { "Crosshair" }
local positionsByGuiObject = {}

for _, v2 in { PlayerGui:WaitForChild("MainUI"), EffectUI } do
	for _, guiObject in v2:GetChildren(), nil, nil do
		if not guiObject:IsA("GuiObject") or table.find(v, guiObject.Name) then
			continue
		end

		positionsByGuiObject[guiObject] = guiObject.Position
	end
end

Menu.FunctionOnClose(function()
	for instance, position in positionsByGuiObject do
		TweenService:Create(instance, TweenInfo.new(0.2), { Position = position }):Play()
	end
end)