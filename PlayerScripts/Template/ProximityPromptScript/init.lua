local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = {
	[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
	[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
	[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
	[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRS.png"
}

local v2 = {
	[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
	[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
	[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png"
}

local v3 = {
	["'"] = "rbxasset://textures/ui/Controls/apostrophe.png",
	[","] = "rbxasset://textures/ui/Controls/comma.png",
	["`"] = "rbxasset://textures/ui/Controls/graveaccent.png",
	["."] = "rbxasset://textures/ui/Controls/period.png",
	[" "] = "rbxasset://textures/ui/Controls/spacebar.png"
}

local v4 = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
	[Enum.KeyCode.F1] = "F1",
	[Enum.KeyCode.F2] = "F2",
	[Enum.KeyCode.F3] = "F3",
	[Enum.KeyCode.F4] = "F4",
	[Enum.KeyCode.F5] = "F5",
	[Enum.KeyCode.F6] = "F6",
	[Enum.KeyCode.F7] = "F7",
	[Enum.KeyCode.F8] = "F8",
	[Enum.KeyCode.F9] = "F9",
	[Enum.KeyCode.F10] = "F10",
	[Enum.KeyCode.F11] = "F11",
	[Enum.KeyCode.F12] = "F12"
}

local function getScreenGui() -- 2 equivalent calls inferred from this helper
	local proximityPrompts = PlayerGui:FindFirstChild("ProximityPrompts")

	if proximityPrompts ~= nil then
		return proximityPrompts
	end

	proximityPrompts = Instance.new("ScreenGui")
	proximityPrompts.Name = "ProximityPrompts"
	proximityPrompts.ResetOnSpawn = false
	proximityPrompts.Parent = PlayerGui

	return proximityPrompts
end

local function setUpCircularProgressBar(progressBar) -- 1 equivalent call inferred from this helper
	local uiGradient = progressBar.LeftGradient.ProgressBarImage.UIGradient
	local uiGradient2 = progressBar.RightGradient.ProgressBarImage.UIGradient

	progressBar.Progress.Changed:Connect(function(p)
		local v5 = math.clamp(p * 360, 0, 360)
		uiGradient.Rotation = math.clamp(v5, 180, 360)
		uiGradient2.Rotation = math.clamp(v5, 0, 180)
	end)
end

local function createPrompt(instance, p, parent)
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local tweenInfo = TweenInfo.new(instance.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo3 = TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfo4 = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	local clone = nil
	local theme = instance:GetAttribute("Theme")

	if theme then
		local child = script:FindFirstChild(theme)

		if child then
			clone = child:Clone()
		end
	end

	if clone == nil then
		clone = script.Default:Clone()
	end

	clone.Enabled = true

	local promptFrame = clone.PromptFrame
	local content = promptFrame.Content

	local inputFrame = promptFrame.InputFrame
	local actionText = promptFrame.ActionText
	local objectText = promptFrame.ObjectText

	content.Background.ImageTransparency = 1
	content.Inlay.ImageTransparency = 1

	local frame = inputFrame.Frame
	local uiScale = frame.UIScale
	local scale = p == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	table.insert(v5, TweenService:Create(uiScale, tweenInfo2, { Scale = scale }))
	table.insert(v6, TweenService:Create(uiScale, tweenInfo2, { Scale = 1 }))

	local buttonFrame = frame.ButtonFrame

	local function setupButtonFrameTweens()
		local backgroundTransparency = buttonFrame.BackgroundTransparency
		local imageTransparency = buttonFrame.ImageTransparency

		table.insert(
			v7,
			TweenService:Create(buttonFrame, tweenInfo3, {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			})
		)
		table.insert(
			v8,
			TweenService:Create(buttonFrame, tweenInfo3, {
				BackgroundTransparency = backgroundTransparency,
				ImageTransparency = imageTransparency
			})
		)

		for _, uiStroke in pairs(buttonFrame:getChildren()) do
			if not uiStroke:IsA("UIStroke") then
				continue
			end

			local transparency = uiStroke.Transparency
			table.insert(v7, TweenService:Create(uiStroke, tweenInfo3, { Transparency = 1 }))
			table.insert(v8, TweenService:Create(uiStroke, tweenInfo3, {
				Transparency = transparency
			}))
		end
	end
	setupButtonFrameTweens()

	local buttonImage = frame.ButtonImage
	local buttonText = frame.ButtonText
	local buttonTextImage = frame.ButtonTextImage

	local function setupButtonTextTweens()
		local textTransparency = buttonText.TextTransparency
		local textStrokeTransparency = buttonText.TextStrokeTransparency
		local backgroundTransparency = buttonText.BackgroundTransparency
		buttonText.BackgroundTransparency = 1
		buttonText.TextStrokeTransparency = 1
		buttonText.TextTransparency = 1
		table.insert(
			v7,
			TweenService:Create(buttonText, tweenInfo3, {
				TextTransparency = 1,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1
			})
		)
		table.insert(
			v8,
			TweenService:Create(buttonText, tweenInfo3, {
				TextTransparency = textTransparency,
				TextStrokeTransparency = textStrokeTransparency,
				BackgroundTransparency = backgroundTransparency
			})
		)

		for _, uiStroke in pairs(buttonText:getChildren()) do
			if not uiStroke:IsA("UIStroke") then
				continue
			end

			local transparency = uiStroke.Transparency
			table.insert(v7, TweenService:Create(uiStroke, tweenInfo3, { Transparency = 1 }))
			table.insert(v8, TweenService:Create(uiStroke, tweenInfo3, {
				Transparency = transparency
			}))
		end
	end

	local function setupButtonImageTweens()
		local imageTransparency = buttonImage.ImageTransparency
		local backgroundTransparency = buttonImage.BackgroundTransparency
		buttonImage.BackgroundTransparency = 1
		buttonImage.ImageTransparency = 1
		table.insert(
			v7,
			TweenService:Create(buttonImage, tweenInfo3, {
				ImageTransparency = 1,
				BackgroundTransparency = 1
			})
		)
		table.insert(
			v8,
			TweenService:Create(buttonImage, tweenInfo3, {
				ImageTransparency = imageTransparency,
				BackgroundTransparency = backgroundTransparency
			})
		)
	end

	local function setupIconTweens() end

	if p == Enum.ProximityPromptInputType.Gamepad then
		if v[instance.GamepadKeyCode] then
			buttonTextImage.Image = v[instance.GamepadKeyCode]

			buttonText.Visible = false
			buttonImage.Visible = false
			buttonTextImage.Visible = true
		end
	elseif p == Enum.ProximityPromptInputType.Touch then
		setupButtonImageTweens()
		buttonImage.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"

		buttonText.Visible = false
		buttonTextImage.Visible = false
		buttonImage.Visible = true
	else
		setupButtonImageTweens()

		buttonImage.Visible = true

		local text = UserInputService:GetStringForKeyCode(instance.KeyboardKeyCode)

		local image = v2[instance.KeyboardKeyCode]

		if image == nil then
			image = v3[text]
		end

		text = image == nil and v4[instance.KeyboardKeyCode] or text

		if image then
			buttonTextImage.Image = image

			buttonText.Visible = false
			buttonTextImage.Visible = true
		elseif text == nil or text == "" then
			error("ProximityPrompt '" .. instance.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(instance.KeyboardKeyCode))
		else
			if string.len(text) > 2 then
				buttonText.TextSize = math.round(buttonText.TextSize * 6 / 7)
			end

			setupButtonTextTweens()
			buttonText.Text = text

			buttonTextImage.Visible = false
			buttonText.Visible = true
		end
	end

	if p == Enum.ProximityPromptInputType.Touch or instance.ClickablePrompt then
		local textButton = clone.TextButton

		local v9 = false

		textButton.InputBegan:Connect(function(input)
			if
				(input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1)
				and input.UserInputState ~= Enum.UserInputState.Change
			then
				instance:InputHoldBegin()
				v9 = true
			end
		end)
		textButton.InputEnded:Connect(function(input)
			if
				(input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1)
				and v9
			then
				v9 = false
				instance:InputHoldEnd()
			end
		end)

		clone.Active = true
	end

	if instance.HoldDuration > 0 then
		local progressBar = frame.ProgressBar
		setUpCircularProgressBar(progressBar) -- inferred equivalent call
		table.insert(v5, TweenService:Create(progressBar.Progress, tweenInfo, { Value = 1 }))
		table.insert(v6, TweenService:Create(progressBar.Progress, tweenInfo4, { Value = 0 }))
	end

	local promptButtonHoldBeganConnection, promptButtonHoldEndedConnection

	if instance.HoldDuration > 0 then
		promptButtonHoldBeganConnection = instance.PromptButtonHoldBegan:Connect(function()
			for _, v9 in ipairs(v5) do
				v9:Play()
			end
		end)

		promptButtonHoldEndedConnection = instance.PromptButtonHoldEnded:Connect(function()
			for _, v9 in ipairs(v6) do
				v9:Play()
			end
		end)
	else
		promptButtonHoldBeganConnection = nil
		promptButtonHoldEndedConnection = nil
	end

	local triggeredConnection = instance.Triggered:Connect(function()
		for _, v9 in ipairs(v7) do
			v9:Play()
		end
	end)

	local triggerEndedConnection = instance.TriggerEnded:Connect(function()
		for _, v9 in ipairs(v8) do
			v9:Play()
		end
	end)

	local function updateUIFromPrompt()
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = instance.ActionText
		getTextBoundsParams.Font = actionText.FontFace
		getTextBoundsParams.Size = actionText.TextSize
		getTextBoundsParams.Width = 1000
		local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)

		local getTextBoundsParams2 = Instance.new("GetTextBoundsParams")
		getTextBoundsParams2.Text = instance.ObjectText
		getTextBoundsParams2.Font = objectText.FontFace
		getTextBoundsParams2.Size = objectText.TextSize
		getTextBoundsParams2.Width = 1000
		local textBoundsAsync2 = TextService:GetTextBoundsAsync(getTextBoundsParams2)

		math.max(textBoundsAsync.X, textBoundsAsync2.X)

		local _ = instance.ObjectText == nil or instance.ObjectText == ""

		actionText.Text = instance.ActionText
		objectText.Text = instance.ObjectText
		actionText.AutoLocalize = instance.AutoLocalize
		actionText.RootLocalizationTable = instance.RootLocalizationTable

		objectText.AutoLocalize = instance.AutoLocalize
		objectText.RootLocalizationTable = instance.RootLocalizationTable

		clone.Size = UDim2.fromOffset(150, 56)
		clone.SizeOffset = Vector2.new(
			instance.UIOffset.X / clone.Size.Width.Offset,
			instance.UIOffset.Y / clone.Size.Height.Offset
		)
	end

	local changedConnection = instance.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()

	clone.Adornee = instance.Parent
	clone.Parent = parent

	for _, v9 in ipairs(v8) do
		v9:Play()
	end

	local function cleanup()
		if promptButtonHoldBeganConnection then
			promptButtonHoldBeganConnection:Disconnect()
		end

		if promptButtonHoldEndedConnection then
			promptButtonHoldEndedConnection:Disconnect()
		end

		triggeredConnection:Disconnect()
		triggerEndedConnection:Disconnect()
		changedConnection:Disconnect()

		for _, v9 in v7 do
			v9:Play()
		end

		wait(0.2)

		clone.Parent = nil
	end

	return cleanup
end

local function onLoad()
	ProximityPromptService.PromptShown:Connect(function(p, p2)
		if p.Style == Enum.ProximityPromptStyle.Default then
			return
		end

		local prompt = createPrompt(p, p2, getScreenGui()) -- inferred equivalent call

		p.PromptHidden:Wait()

		prompt()
	end)
end

ProximityPromptService.PromptShown:Connect(function(p, p2)
	if p.Style == Enum.ProximityPromptStyle.Default then
		return
	end

	local prompt = createPrompt(p, p2, getScreenGui()) -- inferred equivalent call

	p.PromptHidden:Wait()

	prompt()
end)