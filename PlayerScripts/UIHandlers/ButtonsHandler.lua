game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local Button = require(ReplicatedStorage.Libraries.Modules.Button)
game:GetService("TweenService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Libraries.Constants.SharedConstants)
require(ReplicatedStorage.Libraries.Modules.Sales)
game:GetService("MarketplaceService")
require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local ClientSounds = require(ReplicatedStorage.Libraries.Modules.ClientSounds)
require(ReplicatedStorage.Libraries.Modules.Events)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)

if not Profiles.GetPlayerReplica(userId) then
	Profiles.WaitForPlayerReplica(userId)
end

local MainUI = PlayerGui:WaitForChild("MainUI")

local children = {}

for _, v in { "LeftPanel", "RightPanel", "BottomPanel", "Header", "Currency1" } do
	local children2 = {}

	for _, child in MainUI:GetChildren(), nil, nil do
		if string.find(child.Name, v) then
			table.insert(children2, child)
		end
	end

	for _, v2 in children2 do
		for _, child in (v2:FindFirstChild("Buttons") or v2):GetChildren(), nil, nil do
			if child:FindFirstChild("Button") then
				table.insert(children, child)
			end
		end
	end
end

Menu.Opened:Connect(function()
	for _, v in children do
		Button.MouseLeave(v, "Normal")
	end
end)

for _, v in children do
	if not tonumber(v.Name) then
		Button.Create(v, function()
			if Menu.IsOpen(v.Name) then
				Menu.Close(v.Name)
				return
			end

			Menu.Open(v.Name)
			Sounds.Play(ClientSounds.Click, nil, false)
		end, "Normal")
	end
end