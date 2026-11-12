local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local TweenService = game:GetService("TweenService")
local ClientSounds = require(ReplicatedStorage.Libraries.Modules.ClientSounds)

local giftUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("GiftUI")

Menu.Opened:Connect(function(p)
	if p == "Gift" then
		Sounds.Play(ClientSounds.MenuOpen)

		giftUI.Background.Transparency = 1
		TweenService:Create(giftUI.Background, TweenInfo.new(0.3), { Transparency = 0.1 }):Play()

		giftUI.Background.Lines.Position = UDim2.new(1.5, 0, -1.5, 0)
		TweenService:Create(giftUI.Background.Lines, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
	end
end)