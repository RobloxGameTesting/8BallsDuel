local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local ClientSounds = require(ReplicatedStorage.Libraries.Modules.ClientSounds)

return {
	Normal = {
		mouseEnter = function(p)
			TweenService:Create(p.Content, TweenInfo.new(0.1), { Size = UDim2.fromScale(1.2, 1.2) }):Play()

			Sounds.Play(ClientSounds.Hover, nil, false)
		end,
		mouseLeave = function(p)
			TweenService:Create(p.Content, TweenInfo.new(0.1), { Size = UDim2.fromScale(1, 1) }):Play()
		end
	}
}