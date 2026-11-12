local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Device = require(ReplicatedStorage.Libraries.Modules.Device)

local function updateDevice() -- 1 equivalent call inferred from this helper
	if Device:Get() == "Console" then
		UserInputService.MouseIconEnabled = false
	else
		UserInputService.MouseIconEnabled = true
	end
end

updateDevice() -- inferred equivalent call
Device.Changed:Connect(updateDevice)