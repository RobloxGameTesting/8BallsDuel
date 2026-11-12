local Players = game:GetService("Players")
local PlayerGuiUtils = {}

function PlayerGuiUtils.getPlayerGui()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		error("[PlayerGuiUtils.getPlayerGui] - No localPlayer")
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		error("[PlayerGuiUtils.getPlayerGui] - No playerGui")
	end

	return playerGui
end

function PlayerGuiUtils.findPlayerGui()
	local localPlayer = Players.LocalPlayer

	if localPlayer then
		return localPlayer:FindFirstChildOfClass("PlayerGui")
	end

	return nil
end

return PlayerGuiUtils