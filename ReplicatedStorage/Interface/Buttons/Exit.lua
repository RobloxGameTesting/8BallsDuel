local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Modules"):WaitForChild("Menu"))
game:GetService("TweenService")
require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)

Players.LocalPlayer:WaitForChild("PlayerGui")

local buttons = {}
local Exit = {}

function Exit.GetButtons()
	return buttons
end

function Exit.Enter() end

function Exit.Leave() end

function Exit.Toggle(p)
	Menu.Close(p)
end

return Exit