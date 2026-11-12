local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)

local transitionUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TransitionUI")
local coverTop = transitionUI.CoverTop
local coverBottom = transitionUI.CoverBottom
Maid.new()

local v = false
local Transition = {}

function Transition.Enable(_)
	v = true
	transitionUI.Enabled = true
	coverTop.Size = UDim2.new(1, 0, 0, 0)
	TweenService:Create(coverTop, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0.5, 0) }):Play()

	coverBottom.Size = UDim2.new(1, 0, 0, 0)
	TweenService:Create(coverBottom, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0.5, 0) }):Play()
end

function Transition.Disable(_)
	v = false
	TweenService:Create(coverTop, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	TweenService:Create(coverBottom, TweenInfo.new(0.5), { Size = UDim2.new(1, 0, 0, 0) }):Play()

	task.spawn(function()
		task.wait(0.5)

		if not v then
			transitionUI.Enabled = false
		end
	end)
end

return Transition