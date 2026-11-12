local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local Mouses = {}

local function isConfirmButton(input): boolean -- 2 equivalent calls inferred from this helper
	return input.KeyCode == Enum.KeyCode.ButtonA and input.UserInputType.Name:sub(1, 7) == "Gamepad"
end

function Mouses.PressReachedWorld(flag: boolean): boolean
	if not flag then
		return true
	end

	local lastInputType = UserInputService:GetLastInputType()

	if
		lastInputType == Enum.UserInputType.Gamepad1
		or lastInputType == Enum.UserInputType.Gamepad2
		or lastInputType == Enum.UserInputType.Gamepad3
		or lastInputType == Enum.UserInputType.Gamepad4
	then
		return GuiService.SelectedObject == nil
	end

	return false
end

function Mouses.new()
	local bindableEvent = Instance.new("BindableEvent")
	local bindableEvent2 = Instance.new("BindableEvent")
	local bindableEvent3 = Instance.new("BindableEvent")
	local bindableEvent4 = Instance.new("BindableEvent")
	local bindableEvent5 = Instance.new("BindableEvent")

	local v = {
		activatedEvent = bindableEvent,
		Activated = bindableEvent.Event,
		deactivatedEvent = bindableEvent2,
		Deactivated = bindableEvent2.Event,
		rightActivatedEvent = bindableEvent3,
		RightActivated = bindableEvent3.Event,
		rightDeactivatedEvent = bindableEvent4,
		RightDeactivated = bindableEvent4.Event,
		movedEvent = bindableEvent5,
		Moved = bindableEvent5.Event,
		whitelist = {},
		blacklist = {},
		mousePos = Vector2.new(),
		mouseViewport = Vector2.new(),
		mouseDelta = Vector2.new(),
		clicking = false,
		secondaryClicking = false,
		maid = Maid.new()
	}

	Mouses.SetPosition(v)

	v.maid.inputChangedConnection = UserInputService.InputChanged:Connect(function(input, _)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseMovement then
			local vector2 = Vector2.new(input.Position.X, input.Position.Y)
			local v2 = vector2 - v.mousePos
			v.mousePos = vector2
			v.mouseDelta = Vector2.new(v2.X, v2.Y)
			v.movedEvent:Fire()
		elseif userInputType == Enum.UserInputType.Touch then
			v.movedEvent:Fire()
		end
	end)

	v.maid.gamepadPollConnection = RunService.RenderStepped:Connect(function()
		local lastInputType = UserInputService:GetLastInputType()

		if
			lastInputType ~= Enum.UserInputType.Gamepad1
			and lastInputType ~= Enum.UserInputType.Gamepad2
			and lastInputType ~= Enum.UserInputType.Gamepad3
			and lastInputType ~= Enum.UserInputType.Gamepad4
		then
			return
		end

		local mouseViewport = v.mouseViewport

		Mouses.SetPosition(v)

		if v.mouseViewport ~= mouseViewport then
			v.mouseDelta = v.mouseViewport - mouseViewport
			v.movedEvent:Fire()
		end
	end)

	v.maid.inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 then
			if not gameProcessed then
				v.clicking = true
			end

			v.activatedEvent:Fire(gameProcessed)
		elseif userInputType == Enum.UserInputType.MouseButton2 then
			if not gameProcessed then
				v.secondaryClicking = true
			end

			v.rightActivatedEvent:Fire(gameProcessed)
		elseif userInputType == Enum.UserInputType.Touch then
			if not gameProcessed then
				v.clicking = true
			end

			Mouses.SetPosition(v)
			v.activatedEvent:Fire(gameProcessed)
		elseif isConfirmButton(input) then -- inferred equivalent call
			if not gameProcessed then
				v.clicking = true
			end

			Mouses.SetPosition(v)
			v.activatedEvent:Fire(gameProcessed)
		end
	end)

	v.maid.inputEndedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		local userInputType = input.UserInputType

		if userInputType == Enum.UserInputType.MouseButton1 then
			v.clicking = false
			v.deactivatedEvent:Fire(gameProcessed)
		elseif userInputType == Enum.UserInputType.MouseButton2 then
			v.secondaryClicking = false
			v.rightDeactivatedEvent:Fire(gameProcessed)
		elseif userInputType == Enum.UserInputType.Touch then
			Mouses.SetPosition(v)
			v.clicking = false
			v.deactivatedEvent:Fire(gameProcessed)
		elseif isConfirmButton(input) then -- inferred equivalent call
			Mouses.SetPosition(v)
			v.clicking = false
			v.deactivatedEvent:Fire(gameProcessed)
		end
	end)

	return v
end

function Mouses.GetPosition(p)
	Mouses.SetPosition(p)

	if Device:Get() == "Mobile" or Device:Get() == "Console" or UserInputService.GamepadEnabled then
		return p.mouseViewport
	end

	return p.mousePos
end

function Mouses:SetPosition()
	local guiInset = GuiService:GetGuiInset()
	local mouseLocation = UserInputService:GetMouseLocation()

	self.mouseViewport = Vector2.new(mouseLocation.X, mouseLocation.Y)
	self.mousePos = Vector2.new(mouseLocation.X, mouseLocation.Y - guiInset.Y)
end

function Mouses.GetList(p, p2: string)
	return p2 == "Whitelist" and p.whitelist or p.blacklist
end

function Mouses.AddList(p, p2: string, ...)
	local list = Mouses.GetList(p, p2)

	for _, v in { ... } do
		if table.find(list, v) then
			continue
		end

		table.insert(list, v)

		p.maid[v] = v.Destroying:Connect(function()
			Mouses.RemoveList(p, p2, v)
		end)
	end
end

function Mouses.RemoveList(p, p2, ...)
	local list = Mouses.GetList(p, p2)
	local v = { ... }

	if #v > 0 then
		local index = table.find(list, v[1])

		if index then
			local item = list[index]

			p.maid[item] = nil
			table.remove(list, index)
		end

		table.remove(v, 1)

		Mouses.RemoveList(p, p2, table.unpack(v))
	end
end

function Mouses.ClearList(p, p2)
	local whitelist = p2 == "Whitelist" and p.whitelist or p.blacklist

	Mouses.RemoveList(p, p2, table.unpack(whitelist))
end

function Mouses.Project(p, p2: string, vector2: Vector2?, value: number?)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = p2 == "Whitelist" and p.whitelist or p.blacklist
	raycastParams.FilterType = p2 == "Whitelist" and Enum.RaycastFilterType.Include or Enum.RaycastFilterType.Exclude

	local v = vector2 or Mouses.GetPosition(p)
	local v2 = nil

	if Device:Get() == "Mobile" or Device:Get() == "Console" or UserInputService.GamepadEnabled then
		v2 = CurrentCamera:ViewportPointToRay(v.X, v.Y, 0)
	elseif Device:Get() == "Desktop" then
		v2 = CurrentCamera:ScreenPointToRay(v.X, v.Y, 0)
	else
		error("No ray could be generated for Mouses.Project")
	end

	return workspace:Raycast(v2.Origin, v2.Direction * (value or 999), raycastParams), v2
end

return Mouses