local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("StarterGui")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Device = require(ReplicatedStorage.Libraries.Modules.Device)

local Assets = ReplicatedStorage.Assets

local Shine = script.ClickEffects.Shine
local CurrentCamera = workspace.CurrentCamera
local Effects = script.Effects
local v = Maid.new()
local v2 = Maid.new()
local v3 = Maid.new()

local UserInterfaceHelper = {}

function UserInterfaceHelper.FilterTextBox(instance, p: string)
	local v4 = p == "Letters" and "[^%a]" or "[^%d]"

	instance:GetPropertyChangedSignal("Text"):Connect(function()
		local text = instance.Text:gsub(v4, "")

		if text ~= instance.Text then
			local cursorPosition = instance.CursorPosition

			instance.Text = text
			instance.CursorPosition = math.min(cursorPosition - 1, #text + 1)
		end
	end)
end

function UserInterfaceHelper.Effect(childName: string)
	local child = Effects:FindFirstChild(childName)

	if not child then
		return
	end

	local module = require(child)
	return module
end

function UserInterfaceHelper.IsVisible(_, guiObject): boolean
	local screenGui = guiObject and guiObject:FindFirstAncestorWhichIsA("ScreenGui")

	if not (screenGui and screenGui.Enabled) then
		return false
	end

	while guiObject ~= screenGui and guiObject ~= nil do
		if guiObject:IsA("GuiObject") and guiObject.Visible == false then
			return false
		end

		guiObject = guiObject.Parent
	end

	return true
end

function UserInterfaceHelper.FitFrame(_, instance, value, p)
	local v4 = value or "Y"
	local uiListLayout = instance:FindFirstChildOfClass("UIListLayout")
		or instance:FindFirstChildOfClass("UIGridLayout")

	if not uiListLayout then
		warn("No layout found in ", instance:GetFullName())
		return
	end

	local function sizeUp()
		instance.Size = UDim2.fromScale(1, 1)
	end

	local function setSize()
		local x = nil
		local y = nil

		if uiListLayout:IsA("UIGridLayout") then
			local v5 = uiListLayout
			x = v5.AbsoluteContentSize.X
			y = v5.AbsoluteContentSize.Y
		elseif uiListLayout:IsA("UIListLayout") then
			local v5 = uiListLayout
			x = v5.AbsoluteContentSize.X
			y = v5.AbsoluteContentSize.Y
		end

		instance.Size = (v4 == "Y" and UDim2.new(0, 0, 0, y) or UDim2.new(0, x, 0, 0)) + p
	end

	setSize()
	v[instance] = uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(setSize)
	instance.ChildAdded:Connect(sizeUp)
end

function UserInterfaceHelper.FitScrollingFrame(_, instance, value, p)
	local v4 = value or "Y"

	local uiListLayout = instance:FindFirstChildOfClass("UIListLayout")
		or instance:FindFirstChildOfClass("UIGridLayout")

	if not uiListLayout then
		warn("No layout found in ", instance:GetFullName())
		return
	end

	local function setSize()
		if (v4 == "Y" and uiListLayout.AbsoluteContentSize.Y or uiListLayout.AbsoluteContentSize.X) == 0 then
			return
		end

		instance.CanvasSize = (v4 == "Y" and UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y) or UDim2.new(0, uiListLayout.AbsoluteContentSize.X, 0, 0)) + p
	end

	setSize()
	v[instance] = uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(setSize)
end

function UserInterfaceHelper.StopAutomaticFit(_, p)
	v[p] = nil
end

function UserInterfaceHelper.ScrollTo(_, p, state, p2: string?, p3: string?)
	if p2 == "Y" then
		local v4 = p.AbsolutePosition.Y - state.AbsolutePosition.Y + state.CanvasPosition.Y

		state.CanvasPosition = Vector2.new(0, v4)
	elseif p2 == "X" and p3 == "Middle" then
		local v4 = state.CanvasPosition.X + (p.AbsolutePosition.X - state.AbsolutePosition.X) - state.AbsoluteSize.X / 2 + p.AbsoluteSize.X / 2

		state.CanvasPosition = Vector2.new(v4, 0)
	end
end

function UserInterfaceHelper.AlignFrameToText(parent, p, p2)
	local padding = p2.padding or 0
	local iconSize = p2.iconSize or 1

	p.Parent = parent
	p.AnchorPoint = Vector2.new(1, 0.5)

	local function update()
		local x = parent.TextBounds.X
		local v4 = parent.TextBounds.Y * iconSize

		p.Size = UDim2.new(0, v4, 0, v4)
		local v5, v6

		if parent.TextXAlignment == Enum.TextXAlignment.Left then
			v5 = 0
			v6 = 0
		elseif parent.TextXAlignment == Enum.TextXAlignment.Right then
			v6 = -x
			v5 = 1
		else
			v6 = -x / 2
			v5 = 0.5
		end

		p.Position = UDim2.new(v5, v6 - padding, 0.5, 0)
	end

	update()
	parent:GetPropertyChangedSignal("TextBounds"):Connect(update)
	parent:GetPropertyChangedSignal("TextXAlignment"):Connect(update)
end

function UserInterfaceHelper.ViewportEmote(_, parent, animation)
	local camera = Instance.new("Camera")
	camera.Parent = parent

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = parent

	local clone = Assets.EmoteRig:Clone()
	local animationController = Instance.new("AnimationController")
	animationController.Parent = clone
	local animator = Instance.new("Animator")
	animator.Parent = animationController

	camera.CFrame = CFrame.new(
		clone.HumanoidRootPart.Position + Vector3.new(0, 1, 0) + clone.HumanoidRootPart.CFrame.LookVector * 5,
		clone.HumanoidRootPart.Position
	)

	parent.CurrentCamera = camera
	clone.Parent = workspace

	local track = animator:LoadAnimation(animation)
	track.Looped = true
	track:Play()

	clone.Parent = worldModel

	v3[parent] = function()
		track:Destroy()
		clone:Destroy()
		worldModel:Destroy()
		camera:Destroy()
		animationController:Destroy()
	end
end

function UserInterfaceHelper.ViewportModel(_, parent, instance)
	local clone = instance:Clone()
	clone.Parent = parent
	local primaryPart = clone.PrimaryPart
	local camera = clone:FindFirstChild("Camera")

	local camera2 = Instance.new("Camera")
	camera2.Parent = parent
	camera2.CFrame = primaryPart.CFrame * camera.Value

	parent.CurrentCamera = camera2

	v3[parent] = function()
		camera2:Destroy()
	end
end

function UserInterfaceHelper.CoreGuiEnable(_, items)
	task.spawn(function()
		for _ = 1, 10 do
			if pcall(function()
				for k, item in pairs(items) do
					StarterGui:SetCoreGuiEnabled(k, item)
				end
			end) then
				break
			end

			task.wait(1)
		end
	end)
end

function UserInterfaceHelper.ResetCallback(_, p)
	task.spawn(function()
		for _ = 1, 10 do
			if pcall(function()
				StarterGui:SetCore("ResetButtonCallback", p)
			end) then
				break
			end

			task.wait(1)
		end
	end)
end

function UserInterfaceHelper.HighlightFrame(instance)
	local effectUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")
	local target = instance.Target
	local parent = instance.Parent or effectUI
	local transparency = instance.Transparency or 0.5
	local color = instance.Color or Color3.new(0, 0, 0)
	local padding = instance.padding or 5

	local highlightOverlay = Instance.new("Folder")
	highlightOverlay.Name = "HighlightOverlay"
	highlightOverlay.Parent = parent

	local function makeBox(name: string) -- 4 equivalent calls inferred from this helper
		local v4 = name == "Centre" and "ImageLabel" or "Frame"
		local instance2 = Instance.new(v4)
		instance2.Name = name
		instance2.BackgroundColor3 = color
		instance2.BackgroundTransparency = transparency
		instance2.BorderSizePixel = 0
		instance2.ZIndex = target.ZIndex - 1

		if name == "Centre" then
			instance2.BackgroundTransparency = 1
			instance2.ImageTransparency = transparency
			instance2.ImageColor3 = color
			instance2.Image = "rbxassetid://98455105518290"
			instance2.ScaleType = Enum.ScaleType.Slice
			instance2.SliceCenter = Rect.new(Vector2.new(410, 410), Vector2.new(410, 410))
		end

		instance2.Parent = highlightOverlay

		return instance2
	end

	local box = makeBox("Top") -- inferred equivalent call
	local box2 = makeBox("Bottom") -- inferred equivalent call
	local box3 = makeBox("Left") -- inferred equivalent call
	local box4 = makeBox("Right") -- inferred equivalent call
	local box5 = makeBox("Centre")

	local function update()
		local v4 = target.AbsolutePosition - Vector2.new(padding, padding)
		local v5 = target.AbsoluteSize + Vector2.new(padding * 2, padding * 2)
		local absoluteSize = parent.AbsoluteSize
		local guiInset, _ = GuiService:GetGuiInset()

		box.Position = UDim2.fromOffset(0, 0)
		box.Size = UDim2.fromOffset(absoluteSize.X, guiInset.Y + v4.Y)

		box2.Position = UDim2.fromOffset(0, v4.Y + v5.Y + guiInset.Y)
		box2.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y - (v4.Y + v5.Y))

		local v6 = box2.AbsolutePosition.Y - box.AbsoluteSize.Y + guiInset.Y

		box3.Position = UDim2.fromOffset(0, v4.Y + guiInset.Y)
		box3.Size = UDim2.fromOffset(v4.X, v6)

		box4.Position = UDim2.fromOffset(v4.X + v5.X, v4.Y + guiInset.Y)
		box4.Size = UDim2.fromOffset(absoluteSize.X - (v4.X + v5.X), v6)

		box5.Position = UDim2.fromOffset(0 + box3.AbsoluteSize.X, v4.Y + guiInset.Y)
		box5.Size = UDim2.fromOffset(box4.AbsolutePosition.X - (0 + box3.AbsoluteSize.X), v6)
	end

	target:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
	target:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	update()

	return highlightOverlay
end

function UserInterfaceHelper.Shine()
	local effectUI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")

	local UserInputService = game:GetService("UserInputService")
	local mouseLocation = UserInputService:GetMouseLocation()

	local clone = Shine:Clone()
	clone.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = UDim2.new(0.3, 0, 0.3, 0),
		ImageTransparency = 1
	}):Play()
	clone.Parent = effectUI

	task.spawn(function()
		task.wait(0.3)
		clone:Destroy()
	end)
end

local enabledsByBillboardGui = {}
local v4 = true

function UserInterfaceHelper.EnableBillboardUIs(flag: boolean)
	for _, billboardGui in workspace:GetDescendants() do
		if not billboardGui:IsA("BillboardGui") then
			continue
		end

		if not flag and v4 then
			enabledsByBillboardGui[billboardGui] = billboardGui.Enabled
		end

		v4 = flag
		billboardGui.Enabled = flag and (enabledsByBillboardGui[billboardGui] or true) or false
	end
end

function UserInterfaceHelper:FollowMouse()
	local localPlayer = Players.LocalPlayer
	local effectUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")

	local function update()
		local v5 = Device:Get() == "Mobile"
		local guiInset, _ = GuiService:GetGuiInset()
		local x = self.AbsoluteSize.X

		if localPlayer:GetMouse().X + x + (v5 and 30 or 0) > CurrentCamera.ViewportSize.X then
			self.Position = UDim2.fromOffset(
				localPlayer:GetMouse().X - x - (v5 and 30 or 0),
				localPlayer:GetMouse().Y + guiInset.Y
			)
		else
			self.Position = UDim2.fromOffset(
				localPlayer:GetMouse().X + (v5 and 30 or 0),
				localPlayer:GetMouse().Y + guiInset.Y
			)
		end

		local y = effectUI.AbsoluteSize.Y
		local _ = y * 0.045
		local _ = y * 0.05
	end

	update()
	v2[self] = RunService.Heartbeat:Connect(function()
		update()
	end)
end

function UserInterfaceHelper.StopFollowMouse(p)
	v2[p] = nil
end

return UserInterfaceHelper