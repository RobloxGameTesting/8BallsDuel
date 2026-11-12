local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Classes.Inventories)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local leftPanel1 = PlayerGui:WaitForChild("MainUI"):WaitForChild("LeftPanel1")

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

local background = PlayerGui:WaitForChild("QuestsUI").Background
local list = background.Content.List
local header = background.Header

local v = Maid.new()

Menu.Opened:Connect(function(p)
	if p ~= "Quests" then
		return
	end

	background.Position = UDim2.new(0, -background.AbsoluteSize.X - 4, 0.5, 0)

	TweenService:Create(background, TweenInfo.new(0.5), { Position = UDim2.new(0, 4, 0.5, 0) }):Play()

	v.alignConnection = RunService.PreRender:Connect(function()
		leftPanel1.Position = UDim2.new(0, background.AbsolutePosition.X + background.AbsoluteSize.X + 12, 0.5, 0)
	end)
	leftPanel1.Quests.Content.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
end)

Menu.Closed:Connect(function(p)
	if p ~= "Quests" then
		return
	end

	v.alignConnection = nil
	leftPanel1.Position = UDim2.fromScale(0, 0.5)
	leftPanel1.Quests.Content.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
end)