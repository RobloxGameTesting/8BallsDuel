local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Assets.Images.KeybindImages)
require(ReplicatedStorage.Assets.Images.ConsoleKeybindImages)
require(ReplicatedStorage.Libraries.Modules.Defaults)

local ConfigChecker = { MINSIZE = 0.5, MAXSIZE = 2 }

function ConfigChecker.Verify(_, data): boolean
	if data.configurationType ~= "misc" then
		return false
	end

	if data.configuration == "shadows" then
		return data.val == "On" or data.val == "Off"
	end

	if data.configuration == "unit" then
		return data.val == "Metric" or data.val == "Imperial"
	end

	if not (data.configuration ~= "nameTags" and data.configuration ~= "instaOpen") then
		return data.val == "On" or data.val == "Off"
	end

	if data.configuration == "autoTeleport" then
		return type(data.val) == "boolean"
	end

	if data.configuration == "poolAimMode" then
		return data.val == "Drag" or data.val == "Tap"
	end

	if data.configuration == "poolSoundVolume" then
		local val = tonumber(data.val)

		return type(data.val) == "string" and val ~= nil and val == math.floor(val) and val >= 1 and val <= 10
	elseif data.configuration == "poolAimSensitivity" then
		local val = tonumber(data.val)

		return type(data.val) == "string" and val ~= nil and val == math.floor(val) and val >= 1 and val <= 5
	else
		if not (data.configuration ~= "poolHidePredictions" and data.configuration ~= "poolShowSkins") then
			return data.val == "On" or data.val == "Off"
		end

		return data.configuration == "poolHaptics" and (data.val == "On" or data.val == "Off")
	end
end

function ConfigChecker.GetSoundVolume(_, p: number)
	return p * 0.05
end

function ConfigChecker.VerifyMobileButton(p: string, p2: number, _: number, _: number): boolean
	if
		(p == "Spike" or p == "Block" or p == "ThumbstickSet" or p == "BackwardSet" or p == "ForwardSet" or p == "Bump" or p == "Dive" or p == "StopSet" or p == "SpawnBall" or p == "Shiftlock" or p == "Jump")
		and ConfigChecker.MINSIZE <= p2
	then
		return p2 <= ConfigChecker.MAXSIZE
	end

	return false
end

return ConfigChecker