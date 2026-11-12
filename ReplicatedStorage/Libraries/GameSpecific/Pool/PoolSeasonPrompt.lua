local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Events = require(ReplicatedStorage.Libraries.Modules.Events)
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local Sales = require(ReplicatedStorage.Libraries.Modules.Sales)
local Notifications = require(ReplicatedStorage.Libraries.Classes.Notifications)
require(script.Parent.PoolButtonSkin)
local PoolGiftPicker = require(script.Parent.PoolGiftPicker)

local PoolSeasonPrompt = {}

local color = Color3.fromRGB(118, 122, 134)

local LocalPlayer = Players.LocalPlayer
local userId = tostring(LocalPlayer.UserId)

local v = nil

local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function find(instance, value: string)
	for childName in value:gmatch("[^%.]+") do
		local child = instance:FindFirstChild(childName)

		if not child then
			error(
				string.format(
					"[PoolSeasonPrompt] %s has no %q (looking for %s)",
					instance:GetFullName(),
					childName,
					value
				),
				2
			)
		end

		instance = child
	end

	return instance
end

local function screen(childName: string)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local v2 = playerGui:FindFirstChild(childName) or ReplicatedStorage.UI:FindFirstChild(childName)

	if not v2 and StarterGui:FindFirstChild(childName) then
		v2 = playerGui:WaitForChild(childName, 10)
	end

	if not v2 then
		error("[PoolSeasonPrompt] " .. childName .. " is in neither PlayerGui, ReplicatedStorage.UI nor StarterGui", 2)
	end

	return v2
end

local function prepare(parent, displayOrder: number)
	parent.Enabled = false
	parent.DisplayOrder = displayOrder
	parent.IgnoreGuiInset = true
	parent.ResetOnSpawn = false

	if parent:FindFirstChild("Dimmer") then
		return
	end

	local dimmer = Instance.new("TextButton")
	dimmer.Name = "Dimmer"
	dimmer.Size = UDim2.fromScale(1, 1)
	dimmer.Position = UDim2.fromScale(0, 0)
	dimmer.BackgroundColor3 = Color3.new(0, 0, 0)
	dimmer.BackgroundTransparency = 0.35
	dimmer.BorderSizePixel = 0
	dimmer.Text = ""

	dimmer.ZIndex = 1
	dimmer.AutoButtonColor = false

	dimmer.Parent = parent
end

local function bind(maid, button, onActivated)
	if not button:IsA("GuiButton") then
		error(string.format("[PoolSeasonPrompt] %s is a %s, not a button", button:GetFullName(), button.ClassName), 2)
	end

	maid:GiveTask(button.Activated:Connect(onActivated))
end

local function key(p, p2: string) -- 5 equivalent calls inferred from this helper
	return find(p, p2 .. ".Button")
end

function PoolSeasonPrompt.new()
	local bindableEvent = Instance.new("BindableEvent")

	local v2 = {
		PromptUI = screen("SeasonPromptUI"),
		PassUI = screen("SeasonPassUI"),
		Dismissed = bindableEvent.Event,
		DismissedBindable = bindableEvent,
		PassKeys = {},
		Maid = Maid.new()
	}

	v2.Maid:GiveTask(bindableEvent)

	prepare(v2.PromptUI, 11)
	prepare(v2.PassUI, 12)

	local v3 = find(v2.PromptUI, "Background")
	local passBackground = find(v2.PassUI, "Background")

	v2.PassBackground = passBackground
	v2.PassTargetSize = passBackground.Size
	local v4 = key(v3, "GoldPass") -- inferred equivalent call
	local v5 = key(v3, "Exit") -- inferred equivalent call
	bind(v2.Maid, v4, function()
		PoolSeasonPrompt.Hide(v2)
		PoolSeasonPrompt.ShowPicker(v2)
	end)

	bind(v2.Maid, v5, function()
		PoolSeasonPrompt.Hide(v2)
		bindableEvent:Fire()
	end)
	local v6 = key(passBackground, "GoldPassBuyButton") -- inferred equivalent call
	local v7 = key(passBackground, "ExclusivePassBuyButton") -- inferred equivalent call
	local v8 = key(passBackground, "Exit") -- inferred equivalent call

	for k, v9 in {
		[v6] = Events:GetSeasonPassId(),
		[v7] = Events:GetExclusiveSeasonPassId()
	} do
		bind(v2.Maid, k, function()
			if Events:OwnsSeasonPass(LocalPlayer) then
				Notifications.new("TextNotification", {
					message = "You already have a season pass. Tap the gift button to send one to a friend!",
					length = 4
				})

				return
			end

			PoolSeasonPrompt.HidePicker(v2)
			Sales.Prompt(userId, v9, Enum.InfoType.Product)
		end)

		local parent = k.Parent
		local background = parent:FindFirstChild("Background")
		local label = background and background:FindFirstChild("Label")
		local uiGradient = background and background:FindFirstChildOfClass("UIGradient")

		local passKeys = v2.PassKeys
		local face

		if background and background:IsA("ImageLabel") then
			face = background
		end

		local label2

		if label and label:IsA("TextLabel") then
			label2 = label
		end

		local colour

		if background and background:IsA("ImageLabel") then
			colour = background.ImageColor3
		else
			colour = Color3.new(1, 1, 1)
		end

		local v10 = {
			Frame = parent,
			Face = face,
			Gradient = uiGradient,
			Label = label2,
			Colour = colour,
			Text = not (label and label:IsA("TextLabel")) and "" or label.Text
		}
		table.insert(passKeys, v10)

		v2.Maid:GiveTask(PoolGiftPicker.Badge(parent, v9, {
			OnChosen = function()
				PoolSeasonPrompt.HidePicker(v2)
			end
		}))
	end

	bind(v2.Maid, v8, function()
		PoolSeasonPrompt.HidePicker(v2)
	end)

	RemoteSignals.OnClientEvent("Events", function(p)
		if p == "GoldPassPurchase" then
			PoolSeasonPrompt.HideAll(v2)
		end
	end)

	v = v2

	return v2
end

function PoolSeasonPrompt.OpenPicker(): boolean
	if not v then
		return false
	end

	PoolSeasonPrompt.ShowPicker(v)

	return true
end

function PoolSeasonPrompt.IsVisible(p)
	return p.PromptUI.Enabled or p.PassUI.Enabled
end

function PoolSeasonPrompt.Show(p)
	if Events:OwnsSeasonPass(LocalPlayer) then
		return
	end

	p.PassUI.Enabled = false
	p.PromptUI.Enabled = true
end

function PoolSeasonPrompt.Hide(p)
	p.PromptUI.Enabled = false
end

function PoolSeasonPrompt:ShowPicker()
	local ownsSeasonPass = Events:OwnsSeasonPass(LocalPlayer)

	for _, passKey in self.PassKeys do
		if passKey.Face then
			local face = passKey.Face
			local imageColor

			if ownsSeasonPass then
				imageColor = color
			else
				imageColor = passKey.Colour
			end

			face.ImageColor3 = imageColor
		end

		if passKey.Gradient then
			passKey.Gradient.Enabled = not ownsSeasonPass
		end

		if passKey.Label then
			passKey.Label.Text = ownsSeasonPass and "OWNED" or passKey.Text
		end
	end

	self.PromptUI.Enabled = false
	self.PassUI.Enabled = true

	local passBackground = self.PassBackground
	local passTargetSize = self.PassTargetSize

	if passBackground and passTargetSize then
		if self.PassTween then
			self.PassTween:Cancel()
		end

		passBackground.Size = UDim2.new(
			passTargetSize.X.Scale * 0.5,
			passTargetSize.X.Offset * 0.5,
			passTargetSize.Y.Scale * 0.5,
			passTargetSize.Y.Offset * 0.5
		)

		local tween = TweenService:Create(passBackground, tweenInfo, { Size = passTargetSize })

		self.PassTween = tween
		tween:Play()
	end
end

function PoolSeasonPrompt.HidePicker(p)
	p.PassUI.Enabled = false
end

function PoolSeasonPrompt.HideAll(p)
	PoolSeasonPrompt.Hide(p)
	PoolSeasonPrompt.HidePicker(p)
end

function PoolSeasonPrompt:Destroy()
	if v == self then
		v = nil
	end

	self.Maid:Destroy()
end

return PoolSeasonPrompt