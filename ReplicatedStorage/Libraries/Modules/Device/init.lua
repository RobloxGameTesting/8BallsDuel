local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Input = require(script.Input)

local bindableEvent = Instance.new("BindableEvent")

local function _getDevice(): boolean | string
	local gamepadEnabled = GuiService:IsTenFootInterface() and UserInputService.GamepadEnabled
	local v = UserInputService.TouchEnabled and not (UserInputService.MouseEnabled or gamepadEnabled)

	if gamepadEnabled then
		return "Console"
	end

	if v then
		return "Mobile"
	end

	return not (gamepadEnabled or v) and "Desktop"
end

local function _getDeviceByInput(p): nil | string -- 3 equivalent calls inferred from this helper
	if table.find(Input.Desktop, p) then
		return "Desktop"
	end

	if table.find(Input.Mobile, p) then
		return "Mobile"
	end

	return if table.find(Input.Console, p) then "Console" else nil
end

local Device = { device = 0, Changed = 0 }
local gamepadEnabled = GuiService:IsTenFootInterface() and UserInputService.GamepadEnabled
local v = UserInputService.TouchEnabled and not (UserInputService.MouseEnabled or gamepadEnabled)

Device.device = gamepadEnabled and "Console" or v and "Mobile" or not (gamepadEnabled or v) and "Desktop"
Device.Changed = bindableEvent.Event

function Device:Get()
	return self.device
end

function Device:Set(device)
	if not device then
		return
	end

	if self.device ~= device then
		self.device = device
		bindableEvent:Fire(device)
	end
end

function Device.GetButtonLabel(p)
	local success, result = pcall(function()
		return UserInputService:GetStringForKeyCode(p)
	end)

	if not success or typeof(result) ~= "string" or result == "" then
		result = p.Name
	end

	return (string.gsub(result, "^Button", ""))
end

UserInputService.GamepadConnected:Connect(function()
	local gamepadEnabled2 = GuiService:IsTenFootInterface() and UserInputService.GamepadEnabled
	local v2 = UserInputService.TouchEnabled and not (UserInputService.MouseEnabled or gamepadEnabled2)

	Device:Set(gamepadEnabled2 and "Console" or v2 and "Mobile" or not (gamepadEnabled2 or v2) and "Desktop")
end)

UserInputService.GamepadDisconnected:Connect(function()
	local gamepadEnabled2 = GuiService:IsTenFootInterface() and UserInputService.GamepadEnabled
	local v2 = UserInputService.TouchEnabled and not (UserInputService.MouseEnabled or gamepadEnabled2)

	Device:Set(gamepadEnabled2 and "Console" or v2 and "Mobile" or not (gamepadEnabled2 or v2) and "Desktop")
end)

UserInputService.LastInputTypeChanged:Connect(function(p)
	Device:Set(_getDeviceByInput(p)) -- inferred equivalent call
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	Device:Set(_getDeviceByInput(input.KeyCode == Enum.KeyCode.Unknown and input.UserInputType or input.KeyCode)) -- inferred equivalent call
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local userInputType = input.KeyCode == Enum.KeyCode.Unknown and input.UserInputType or input.KeyCode

	if Device:Get() == "Console" and userInputType == Enum.UserInputType.MouseMovement then
		return
	end

	Device:Set(_getDeviceByInput(userInputType)) -- inferred equivalent call
end)

return Device