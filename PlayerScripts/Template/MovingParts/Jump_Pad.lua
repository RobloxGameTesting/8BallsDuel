local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Classes.Visuals)
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(ReplicatedStorage.Libraries.Modules.Device)
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterPlayer = game:GetService("StarterPlayer")

local LocalPlayer = Players.LocalPlayer
LocalPlayer:WaitForChild("PlayerGui")

local function addJumpPad(instance) -- 1 equivalent call inferred from this helper
	local size = instance:WaitForChild("Visual").Value.Size
	local v = true

	instance.Touched:Connect(function(otherPart)
		if not v then
			return
		end

		local parent = otherPart.Parent
		local humanoid = parent and parent:FindFirstChild("Humanoid")

		if Players:GetPlayerFromCharacter(parent) == LocalPlayer and humanoid then
			v = false
			Sounds.Play(Sounds.new({ "SoundEffects", "BounceWindUp" }, instance.Position), nil, true)
			TweenService:Create(instance.Visual.Value, TweenInfo.new(0.1), {
				Size = size * 0.7
			}):Play()

			task.wait(0.1)

			humanoid.JumpHeight = instance:GetAttribute("Jump") or 50
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			humanoid.StateChanged:Wait()
			task.wait(0.05)
			Sounds.Play(Sounds.new({ "SoundEffects", "BounceRelease" }, instance.Position), nil, true)
			TweenService:Create(instance.Visual.Value, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
				Size = size
			}):Play()
			humanoid.JumpHeight = StarterPlayer.CharacterJumpHeight
			v = true
		end
	end)
end

CollectionService:GetInstanceAddedSignal("JumpPad"):Connect(addJumpPad)

for _, v in CollectionService:GetTagged("JumpPad"), nil, nil do
	addJumpPad(v) -- inferred equivalent call
end