local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)

Players.LocalPlayer:WaitForChild("PlayerGui")

local buttons = {}
local Back = {}

function Back.GetButtons()
	return buttons
end

function Back.Enter() end

function Back.Leave() end

function Back.Toggle(p)
	Menu.Close(p)
	local previous = Menu.GetPrevious()

	if previous then
		Menu.Open(previous[1])
	end
end

return Back