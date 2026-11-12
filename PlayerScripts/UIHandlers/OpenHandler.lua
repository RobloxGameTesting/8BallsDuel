local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)
local Players = game:GetService("Players")

local mainUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI")

Menu.Opened:Connect(function(p: string)
	if p ~= "SkillTree" then
		return
	end

	mainUI.Enabled = false
end)

Menu.Closed:Connect(function(p: string)
	if p ~= "SkillTree" then
		return
	end

	mainUI.Enabled = true
end)