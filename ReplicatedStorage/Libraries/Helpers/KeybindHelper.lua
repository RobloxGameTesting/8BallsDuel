local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
game:GetService("Players")
local KeybindHelper = {}

function KeybindHelper.ConvertValueToDesktop(_, p, p2: string)
	if p2 == "kick" then
		return Enum.UserInputType.MouseButton1
	end

	local button = p.Data.configuration.desktopKeybinds.buttons[p2]
	return button and Enum.KeyCode:FromValue(button)
end

function KeybindHelper.ConvertValueToConsole(_, p, p2: string)
	local button = p.Data.configuration.consoleKeybinds.buttons[p2]
	return button and Enum.KeyCode:FromValue(button)
end

function KeybindHelper.ConvertValueToMobile(_, _, value: string)
	return "Mobile" .. string.upper((string.sub(value, 1, 1))) .. string.sub(value, 2, #value)
end

function KeybindHelper.IsToggleable(_, p)
	local playerReplica = Profiles.GetPlayerReplica(p)

	if Device:Get() == "Desktop" then
		return playerReplica.Data.configuration.desktopKeybinds.toggleable
	end

	if Device:Get() == "Console" then
		return playerReplica.Data.configuration.consoleKeybinds.toggleable
	end

	return Device:Get() == "Mobile" or nil
end

function KeybindHelper.FindCorrespondingKeybindFrame(_, _: string)
	return {}
end

return KeybindHelper