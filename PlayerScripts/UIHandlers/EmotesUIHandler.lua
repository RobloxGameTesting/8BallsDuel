local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Animations = require(ReplicatedStorage.Libraries.Classes.Animations)
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
require(ReplicatedStorage.Libraries.Modules.Button)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local GamepadService = game:GetService("GamepadService")
local InventoryHelpers = require(ReplicatedStorage.Libraries.Classes.Inventories.InventoryHelpers)
require(ReplicatedStorage.Libraries.Modules.BindableEvents)
require(ReplicatedStorage.Types.DataTypes)
require(ReplicatedStorage.Packages.Icon)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local userId = tostring(LocalPlayer.UserId)
local EmotesUI = PlayerGui:WaitForChild("EmotesUI")
local Frame = EmotesUI.Frame
local Circle = EmotesUI.Circle
local Label = Circle.Label
local mouse = LocalPlayer:GetMouse()
local guiInset = GuiService:GetGuiInset()
local CurrentCamera = workspace.CurrentCamera
local Glow = ReplicatedStorage.Assets.InterfaceAssets.Emotes.Glow
local SelectedGradient = ReplicatedStorage.Assets.InterfaceAssets.Emotes.SelectedGradient
local data = (Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)).Data
local v = Maid.new()
local v2 = Maid.new()
local v3 = Maid.new()
local Button = EmotesUI.Button
local categoryModules = InventoryHelpers.GetCategoryModules("Emotes")

local v4 = nil

local function getMouseAngle() -- 1 equivalent call inferred from this helper
	local halfViewportSize = CurrentCamera.ViewportSize / 2
	local v5 = Vector2.new(mouse.X, mouse.Y) - halfViewportSize + Vector2.new(0, guiInset.Y)
	local mouseAngle = math.deg((math.atan2(v5.Y, v5.X)))

	if mouseAngle < 0 then
		mouseAngle += 360
	end

	return mouseAngle
end

function getEmoteIndex(p: number)
	return math.floor((p % 360 + 22.5) % 360 / 45) + 1
end

local function stopHighlight()
	if not v4 then
		return
	end

	local child = Frame:FindFirstChild((tostring(v4)))

	if not child then
		return
	end

	v4 = nil

	Label.Text = ""
	TweenService:Create(child, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(1, 1)
	}):Play()

	child.Segment.UIGradient.Enabled = true
	Glow.Parent = script
	SelectedGradient.Parent = script
end

local function highlight(emoteIndex)
	if emoteIndex == v4 then
		return
	end

	stopHighlight()
	v4 = emoteIndex
	local emote = data.equipped.emotes[v4]

	if not emote then
		return
	end

	local child = Frame:FindFirstChild((tostring(emoteIndex)))
	local v5 = 1 / Frame.Size.X.Scale

	TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(v5, v5)
	}):Play()

	child.Segment.UIGradient.Enabled = false
	SelectedGradient.Parent = child.Segment
	Glow.Parent = child.Segment

	local child2 = ReplicatedStorage.Assets.Skins.Emotes:FindFirstChild(emote)

	assert(child2)
	local module = require(child2)
	Label.Text = module and module.name or ""
end

local function prompt(_, p, _)
	EmotesUI.Enabled = p == Enum.UserInputState.Begin

	if p == Enum.UserInputState.Begin then
		for childName, childName2 in data.equipped.emotes do
			local child = ReplicatedStorage.Assets.Skins.Emotes:FindFirstChild(childName2)

			if not child then
				continue
			end

			local module = require(child)
			local findFirstChild = Frame:FindFirstChild(childName)
			findFirstChild.Segment.Icon.Image = module.image()
		end

		local function update()
			local mouseAngle = getMouseAngle() -- inferred equivalent call
			local emoteIndex = getEmoteIndex(mouseAngle)
			Circle.Rotation = mouseAngle
			TweenService:Create(Label, TweenInfo.new(0.15), {
				Rotation = -mouseAngle
			}):Play()
			highlight(emoteIndex)
		end

		update()

		if Device:Get() == "Desktop" or Device:Get() == "Console" then
			if Device:Get() == "Console" then
				task.spawn(function()
					task.wait(0.21)
					GamepadService:EnableGamepadCursor(EmotesUI.Circle)
				end)
			end

			v.mouseHandler = Button.InputChanged:Connect(function(input)
				if not EmotesUI.Enabled then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseMovement then
					update()
				end
			end)

			v.mouseClick = Button.Activated:Connect(function(p2, _)
				if
					p2.UserInputType == Enum.UserInputType.MouseButton1
					or p2.UserInputType == Enum.UserInputType.Gamepad1
				then
					prompt("Prompt", Enum.UserInputState.End, nil)
				end
			end)
		elseif Device:Get() == "Mobile" then
			v.touchSwipe = Button.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					update()
				end
			end)

			local v5 = false

			v.touchBegin = Button.InputBegan:Connect(function(_)
				v5 = true
				update()
			end)

			v.touchEnded = Button.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch and v5 then
					v5 = false
					update()
					prompt("Prompt", Enum.UserInputState.End)
				end
			end)

			v.touchTap = Button.TouchTap:Connect(function(_)
				if not v5 then
					return
				end

				prompt("Prompt", Enum.UserInputState.End)
			end)
		end
	elseif p == Enum.UserInputState.End then
		if Device:Get() == "Console" then
			GamepadService:DisableGamepadCursor()
		end

		v:Destroy()
		local emote = data.equipped.emotes[v4]
		local _emotes = ReplicatedStorage.Assets.Skins.Emotes
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		local animator = character and character:FindFirstChildWhichIsA("Animator", true)

		if not (character and humanoid and animator and emote) then
			return
		end

		local categoryModule = categoryModules[emote]
		local v5 = Animations.new({ emote = categoryModule.animationId }, animator)

		Animations.Play(v5, {
			{ animation = "emote", looped = categoryModule.looped }
		})

		function v3.animation()
			print("Destroying animation")
			Animations.Destroy(v5)
		end
		v3.walkConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			v3:Destroy()
		end)

		if humanoid.MoveDirection.Magnitude > 0 then
			v3:Destroy()
		end

		stopHighlight()
	end
end

local function updateDevice(p)
	v2:Destroy()

	if p == "Desktop" then
		function v2.connection()
			ContextActionService:UnbindAction("Prompt")
		end

		ContextActionService:BindAction("Prompt", prompt, false, Enum.KeyCode.T)
	end
end

local v5 = Device:Get()
v2:Destroy()

if v5 == "Desktop" then
	function v2.connection()
		ContextActionService:UnbindAction("Prompt")
	end

	ContextActionService:BindAction("Prompt", prompt, false, Enum.KeyCode.T)
end

Device.Changed:Connect(updateDevice)