local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
return {
	new = function()
		local clone = script.LoadingUI:Clone()
		clone.Parent = LocalPlayer.PlayerGui
		return clone
	end
}