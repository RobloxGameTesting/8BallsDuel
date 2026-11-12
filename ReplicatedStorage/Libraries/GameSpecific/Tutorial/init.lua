local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Profiles = require(ReplicatedStorage.Libraries.Modules.Profiles)
local Players = game:GetService("Players")
local Maid = require(ReplicatedStorage.Libraries.Classes.Maid)
game:GetService("AnalyticsService")
local ServerScriptService = game:GetService("ServerScriptService")
local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
require(script.TutorialTypes)
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local PlaceHelper = require(ReplicatedStorage.Libraries.Helpers.PlaceHelper)
local RemoteSignals = require(ReplicatedStorage.Libraries.Modules.RemoteSignals)
local RemoteEnums = require(ReplicatedStorage.Libraries.Modules.RemoteSignals.RemoteEnums)

local isServer = RunService:IsServer()
local v = Maid.new()
local Assets = ReplicatedStorage.Assets
local bindableEvent = Instance.new("BindableEvent")
local bindableEvent2 = Instance.new("BindableEvent")
PlaceHelper.GetPlaceType()

local v2 = { "Introduction" }

local requirements = {
	Introduction = function(p): boolean
		local userId = tostring(p.UserId)
		return not Profiles.GetPlayerReplica(userId).Data.tutorials.Introduction
	end
}

local v3 = {}

local Tutorial = { Started = bindableEvent2.Event, Finished = bindableEvent.Event }

function Tutorial.GetNext(p)
	for _, v4 in v2 do
		if requirements[v4](p) then
			return v4
		end
	end

	return nil
end

function Tutorial.GetSequence(childName)
	local child = script.Tutorials:FindFirstChild(childName)
	local module = require(child)

	return module
end

function Tutorial.GetRequirements()
	return requirements
end

function Tutorial.IsPlaying(p)
	return v3[p]
end

function Tutorial.Play(...)
	local v4 = { ... }

	if isServer then
		local Loaded = require(ServerScriptService.Libraries.Modules.Loaded)

		local v5 = v4[1]
		local v6 = v4[2]
		local userId = tostring(v5.UserId)

		if v3[userId] then
			return
		end

		v3[userId] = v6
		Loaded.FireClientGuarantee(v5, RemoteEnums.TutorialStart, v6)
	else
		require(ReplicatedStorage.Libraries.Modules.Menu)
		local v5 = v4[1]

		local userId = tostring(Players.LocalPlayer.UserId)

		if v3[userId] then
			return
		end

		local sequence = Tutorial.GetSequence(v5)

		v3[userId] = v5

		task.spawn(function()
			for i = 1, #sequence do
				local v6 = sequence[i]

				if v6.stepStartAudio then
					Sounds.Play(Sounds.new(v6.stepStartAudio, nil), nil, true)
				end

				Tutorial.Message(v6.message)
				Tutorial.ProgressBar(v6.progressBar)
				local v7 = Maid.new()

				for k, v8 in v6.guidance do
					v7[k] = Tutorial[v8.call](v8.values)
				end

				if v6.startFunction then
					v6.startFunction()
				end

				RemoteSignals.FireServer(RemoteEnums.TutorialOnboarding, v5, i, "Reached")

				Tutorial[v6.target.call](v6.target.values)
				v.progressListener = nil

				if v6.endFunction then
					v6.endFunction()
				end

				v7:Destroy()
				RemoteSignals.FireServer(RemoteEnums.TutorialOnboarding, v5, i, "Passed")

				if v6.stepEndAudio then
					Sounds.Play(Sounds.new(v6.stepEndAudio, nil), nil, true)
				end

				if v6.progressBar then
					task.wait(1)
				end
			end

			v3[userId] = nil

			Tutorial.Finish(v5)
		end)
	end

	bindableEvent2:Fire()
end

function Tutorial.Finish(...)
	local v4 = { ... }
	local v5

	if isServer then
		v5 = v4[1]
		local v6 = v4[2]
		local userId = tostring(v5.UserId)
		local playerReplica = Profiles.GetPlayerReplica(userId)

		if table.find(v2, v6) then
			v3[userId] = nil

			playerReplica:Write("Tutorials", v6)
		else
			warn(v6 .. " isn't a valid tutorial value")
			return
		end
	else
		local v6 = v4[1]

		v5 = Players.LocalPlayer
		local commander = v5:WaitForChild("PlayerGui"):WaitForChild("EffectUI"):WaitForChild("Commander")
		commander:WaitForChild("Speech")

		RemoteSignals.FireServer(RemoteEnums.TutorialFinish, v6)

		commander.Visible = false
	end

	bindableEvent:Fire(v5)
end

function Tutorial.GuidanceButtonHighlight(p)
	local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)
	Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")

	local v4 = Maid.new()
	local v5 = { Target = p.button(), padding = 7 }

	v4.highlight = UserInterfaceHelper.HighlightFrame(v5)

	return v4
end

function Tutorial.GuidanceArrow(data)
	Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")

	local button = data.button()
	local v4 = Maid.new()
	local clone = script.Assets.Arrows:FindFirstChild(data.highlightName or "Arrow"):Clone()
	clone.Size = data.size or UDim2.fromScale(3, 3)
	clone.ImageColor3 = data.colour or Color3.fromRGB(255, 255, 255)
	clone.Parent = button

	if data.offset == "Bottom" then
		clone.AnchorPoint = Vector2.new(0.5, 0)
		clone.Rotation = 0
		clone.Position = UDim2.fromScale(0.5, 1.2)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, true, 0),
			{ Position = UDim2.fromScale(0.5, 1) }
		)

		tween:Play()
		function v4.tweenStop()
			tween:Cancel()
			tween:Destroy()
		end
	elseif data.offset == "Top" then
		clone.AnchorPoint = Vector2.new(0.5, 1)
		clone.Rotation = 180
		clone.Position = UDim2.fromScale(0.5, -0.2)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, true, 0),
			{ Position = UDim2.fromScale(0.5, 0) }
		)

		tween:Play()
		function v4.tweenStop()
			tween:Cancel()
			tween:Destroy()
		end
	elseif data.offset == "Right" then
		clone.AnchorPoint = Vector2.new(0, 0.5)
		clone.Rotation = -90
		clone.Position = UDim2.fromScale(-1, 0.5)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, true, 0),
			{ Position = UDim2.fromScale(-1.15, 0.5) }
		)

		tween:Play()
		function v4.tweenStop()
			tween:Cancel()
			tween:Destroy()
		end
	elseif data.offset == "Left" then
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Rotation = 90
		clone.Position = UDim2.fromScale(-0.35, 0.5)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, true, 0),
			{ Position = UDim2.fromScale(-0.5, 0.5) }
		)

		tween:Play()
		function v4.tweenStop()
			tween:Cancel()
			tween:Destroy()
		end
	end

	v4.indication = clone

	return v4
end

function Tutorial.GuidanceButton(data)
	Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI")

	local button = data.button()
	local v4 = Maid.new()
	local clone = script.Assets:FindFirstChild(data.highlightName or "Highlight"):Clone()
	clone.ImageColor3 = data.colour or Color3.fromRGB(255, 255, 255)
	clone.Parent = button

	local function update()
		local _, _ = GuiService:GetGuiInset()
		v4.tweenStop = nil
		clone.Size = UDim2.fromOffset(button.AbsoluteSize.X * 2, button.AbsoluteSize.Y * 2)
		clone.Position = UDim2.fromScale(0.5, 0.5)

		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1e999, true, 0),
			{
				Size = UDim2.fromOffset(button.AbsoluteSize.X * 3, button.AbsoluteSize.Y * 3)
			}
		)

		tween:Play()
		function v4.tweenStop()
			tween:Cancel()
			tween:Destroy()
		end
	end

	update()
	button:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	button:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)

	v4.rotateConnection = RunService.Heartbeat:Connect(function(dt: number)
		clone.Rotation += dt * 16
	end)
	v4.indication = clone

	return v4
end

function Tutorial.GuidancePath(data)
	local result = Maid.new()

	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoidRootPart = character and character:WaitForChild("HumanoidRootPart")
	local colour = data.colour or Color3.fromRGB(0, 255, 0)

	local attachment = Instance.new("Attachment")
	attachment.Parent = data.parent0 or humanoidRootPart

	for k, parent in data.parent1(), nil, nil do
		local attachment2 = Instance.new("Attachment")
		attachment2.Parent = parent

		local clone = script.Assets.Beam:Clone()
		clone.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, colour), ColorSequenceKeypoint.new(1, colour) })

		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		clone.Parent = workspace

		result[`attachment1{k}`] = attachment2
		result[`beam{k}`] = clone
	end

	result.attachment0 = attachment

	return result
end

function Tutorial.ProgressBar(data)
	local localPlayer = Players.LocalPlayer
	local userId = tostring(localPlayer.UserId)
	local playerReplica = Profiles.GetPlayerReplica(userId)
	local commander = localPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI"):WaitForChild("Commander")
	commander:WaitForChild("Speech")

	v.progressListener = nil

	if not data then
		commander.ProgressBar.Visible = false

		return
	end

	local function update()
		local value = data.getValue(playerReplica)

		local v4 = value and math.clamp(value, 0, data.requirement)

		if v4 then
			local v5 = math.clamp(v4 / data.requirement, 0, 1)
			commander.ProgressBar.Label.Text = `{v4}/{data.requirement}`
			commander.ProgressBar.Bar.Percent.Size = UDim2.fromScale(v5, 1)

			if v5 > 0 then
				if v5 == 1 then
					commander.ProgressBar.Label.Text = "COMPLETE"
				end

				commander.ProgressBar.Bar.Percent.Display.Size = UDim2.fromScale(1 / v5, 1)
			end
		end
	end

	update()
	local connection = nil

	if data.writeLib then
		connection = playerReplica:ListenToWrite(data.writeLib, update)
	elseif data.timer then
		local timer = data.timer
		local total = 0

		connection = RunService.Heartbeat:Connect(function(dt: number)
			total += dt

			if timer <= total then
				total = 0
				update()
			end
		end)
	end

	function v.progressListener()
		connection:Disconnect()
		connection = nil
	end

	commander.ProgressBar.Visible = true
end
function Tutorial.Message(text: string)
	local commander = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI"):WaitForChild("Commander")
	local speech = commander:WaitForChild("Speech")

	if text == "" then
		commander.Visible = false
		return
	end

	commander.Visible = true

	speech.TextSize = math.floor(speech.AbsoluteSize.Y / 2)
	v.textSizeConnection = speech:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		speech.TextSize = math.floor(speech.AbsoluteSize.Y / 2)
	end)
	speech.Text = ""

	v.typeConnection = nil

	speech.Text = text
end

function Tutorial.Next(p)
	local Button = require(ReplicatedStorage.Libraries.Modules.Button)

	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()

	local nextNode = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("EffectUI"):WaitForChild("Commander"):WaitForChild("Next")
	nextNode:FindFirstChild("Button")

	nextNode.Content.Label.Text = p.nextButtonText or "Next"
	nextNode.Visible = true

	Button.Create(nextNode, function()
		bindableEvent3:Fire()
	end)

	bindableEvent3.Event:Wait()
	bindableEvent3:Destroy()
	v4:Destroy()

	nextNode.Visible = false
end

function Tutorial.GoToPart(p)
	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()

	local localPlayer = Players.LocalPlayer
	local touchingParts = p.region:GetTouchingParts()

	for _, touchingPart in touchingParts do
		local parent = touchingPart and touchingPart.Parent
		local playerFromCharacter = parent and Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter and playerFromCharacter == localPlayer then
			bindableEvent3:Fire()
		end
	end

	v4.enterConnection = p.region.Touched:Connect(function(otherPart)
		local parent = otherPart and otherPart.Parent
		local playerFromCharacter = parent and Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter and playerFromCharacter == localPlayer then
			bindableEvent3:Fire()
		end
	end)

	bindableEvent3.Event:Wait()
	bindableEvent3:Destroy()
	v4:Destroy()
end

function Tutorial.ProximityPrompt(p)
	require(ReplicatedStorage.Libraries.Modules.Button)

	local bindableEvent3 = Instance.new("BindableEvent")
	local connections = Maid.new()

	for k, v4 in p.prompt(), nil, nil do
		connections[v4.Name .. k] = v4.Triggered:Connect(function(_)
			bindableEvent3:Fire()
		end)
	end

	bindableEvent3.Event:Wait()
	bindableEvent3:Destroy()
	connections:Destroy()
end

function Tutorial.Function(p)
	require(ReplicatedStorage.Libraries.Modules.Button)

	local v4 = Maid.new()
	local localPlayer = Players.LocalPlayer

	while not p.func(localPlayer) do
		task.wait()
	end

	v4:Destroy()
end

function Tutorial.Button(p)
	require(ReplicatedStorage.Libraries.Modules.Button)

	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()

	v4.upConnection = p.button().Activated:Connect(function()
		bindableEvent3:Fire()
	end)

	bindableEvent3.Event:Wait()
	bindableEvent3:Destroy()
	v4:Destroy()
end

function Tutorial.Menu(p)
	local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)

	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()

	v4.upConnection = Menu.Opened:Connect(function(p2, p3)
		if p2 == p.menu and (not p.submenu or p3 == p.submenu) then
			bindableEvent3:Fire()
		end
	end)

	bindableEvent3.Event:Wait()
	bindableEvent3:Destroy()
	v4:Destroy()
end

function Tutorial.Timer(p)
	task.wait(p.timer)
end

function Tutorial.TimerLoop(p)
	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()

	local userId = tostring(Players.LocalPlayer.UserId)
	local v5 = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
	local v6 = false

	local function check(p2, ...)
		if p.checkFunction and p.checkFunction(p2, ...) then
			v6 = true
			bindableEvent3:Fire()
		end
	end

	check(v5)
	local timer = p.timer
	local total = 0

	v4.timerConnection = RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if timer <= total then
			total = 0
			check(v5)
		end
	end)

	if not v6 then
		bindableEvent3.Event:Wait()
	end

	bindableEvent3:Destroy()
	v4:Destroy()
end

function Tutorial.MenuClose()
	local Menu = require(ReplicatedStorage.Libraries.Modules.Menu)

	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()

	v4.upConnection = Menu.Closed:Connect(function(_, _)
		bindableEvent3:Fire()
	end)

	bindableEvent3.Event:Wait()
	bindableEvent3:Destroy()
	v4:Destroy()
end

function Tutorial.BindableEvent(p)
	p.bindableEvent.Event:Wait()
end

function Tutorial.EquipTool(p)
	local localPlayer = Players.LocalPlayer
	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()
	local v5 = false

	local function characterConnection()
		local character = localPlayer.Character

		if not character then
			return
		end

		local function check() -- 2 equivalent calls inferred from this helper
			local tool = character:FindFirstChildWhichIsA("Tool")

			if tool and tool.Name == p.toolName then
				v5 = true
				bindableEvent3:Fire()
			end
		end

		check() -- inferred equivalent call
		v4.listenerConnection = character.ChildAdded:Connect(function(_)
			check() -- inferred equivalent call
		end)
	end

	v4.characterAddedConnection = localPlayer.CharacterAdded:Connect(characterConnection)
	characterConnection()

	if not v5 then
		bindableEvent3.Event:Wait()
	end

	bindableEvent3:Destroy()
	v4:Destroy()
end

function Tutorial:ListenToWrite()
	local bindableEvent3 = Instance.new("BindableEvent")
	local v4 = Maid.new()

	local userId = tostring(Players.LocalPlayer.UserId)
	local v5 = Profiles.GetPlayerReplica(userId) or Profiles.WaitForPlayerReplica(userId)
	local v6 = false

	local function check(p, ...)
		if self.datastoreKey and self.neededValue then
			if p.Data[self.datastoreKey] >= self.neededValue then
				v6 = true
				bindableEvent3:Fire()
			end
		elseif self.checkFunction and self.checkFunction(p, ...) then
			v6 = true
			bindableEvent3:Fire()
		end
	end

	check(v5)
	v4.listenerConnection = v5:ListenToWrite(self.writeLib, function(...)
		check(v5, ...)
	end)

	if not v6 then
		bindableEvent3.Event:Wait()
	end

	bindableEvent3:Destroy()
	v4:Destroy()
end

Players.PlayerRemoving:Connect(function(player)
	local userId = tostring(player.UserId)
	v3[userId] = nil
end)

script:SetAttribute("Loaded", true)

return Tutorial