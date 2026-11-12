local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Sounds = require(ReplicatedStorage.Libraries.Classes.Sounds)
local Visuals = require(ReplicatedStorage.Libraries.Classes.Visuals)
local Device = require(ReplicatedStorage.Libraries.Modules.Device)
local Rarities = require(ReplicatedStorage.Libraries.Modules.Rarities)

local Pool = ReplicatedStorage.Libraries.GameSpecific.Pool
local PoolSkins = require(Pool.PoolSkins)

local color = Color3.fromRGB(255, 216, 96)
local rbxassetfontsfamiliesTekojson = Font.new("rbxasset://fonts/families/Teko.json", Enum.FontWeight.Bold)

local color2 = Color3.fromRGB(120, 215, 255)

local v = {
	Normal = "COMMON",
	Tier1 = "COMMON",
	Tier2 = "UNCOMMON",
	Tier3 = "RARE",
	Tier4 = "EPIC",
	Tier5 = "LEGENDARY",
	Tier6 = "MYTHIC",
	Tier7 = "MYTHIC"
}

local v2 = { cueSticks = "CUE STICK", poolTables = "POOL TABLE", poolEffects = "POT EFFECT" }

local v3 = { "PoolMenuUI", "PoolGameUI", "TopbarPlus", "PoolStatsUI" }

local packOpening = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("PackOpening")

local v4 = nil
local v5 = nil
local flag = false

local bindableEvent = Instance.new("BindableEvent")
local PoolPackOpening = {}

PoolPackOpening.Started = bindableEvent.Event
local bindableEvent2 = Instance.new("BindableEvent")
PoolPackOpening.Finished = bindableEvent2.Event

local function play(p, p2: number?)
	local success, result = pcall(Sounds.new, p, nil)

	if success and result then
		if p2 then
			Sounds.SetPitch(result, p2)
		end

		Sounds.Play(result, nil, true)
	end
end

local function rarityOf(p)
	local result = p and p.rarity

	if typeof(result) == "function" then
		local success
		success, result = pcall(result, {}, p)

		if not success then
			result = nil
		end
	end

	return if typeof(result) == "string" then result else "Tier1"
end

local function rarityColour(p: string) -- 1 equivalent call inferred from this helper
	local rarityData = Rarities.GetRarityData(p)
	local keypoints = rarityData and rarityData.colour and rarityData.colour.Keypoints

	if keypoints and keypoints[#keypoints] then
		return keypoints[#keypoints].Value
	end

	return color
end

local function rarityRank(value: string) -- 1 equivalent call inferred from this helper
	return tonumber(string.match(value, "%d+")) or 1
end

local function getScene()
	if v4 then
		return v4
	end

	local packOpeningScene = packOpening:WaitForChild("PackMenu"):Clone()

	for _, part in packOpeningScene:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CFrame += Vector3.new(-477, 4000, -1490)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
	end

	for _, descendant in packOpeningScene:GetDescendants() do
		if descendant:IsA("TextLabel") then
			descendant.FontFace = rbxassetfontsfamiliesTekojson
			descendant.Text = ""
		elseif descendant:IsA("ImageLabel") and (descendant.Name == "Starburst" or descendant.Name == "Ring") then
			descendant.ImageColor3 = color
		elseif descendant:IsA("UIStroke") and descendant.Parent and descendant.Parent.Name == "Outline" then
			descendant.Color = color
		end
	end

	local camera = packOpeningScene:FindFirstChild("Camera")
	local position = camera.Position
	local backdrop = Instance.new("Part")
	backdrop.Name = "Backdrop"
	backdrop.Size = Vector3.new(220, 124, 1)
	backdrop.CFrame = CFrame.lookAt(position + camera.CFrame.LookVector * 48, position)
	backdrop.Anchored = true
	backdrop.CanCollide = false
	backdrop.CanQuery = false
	backdrop.CanTouch = false
	backdrop.CastShadow = false
	backdrop.Transparency = 1
	backdrop.Parent = packOpeningScene

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.LightInfluence = 0
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 10
	surfaceGui.Parent = backdrop

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundColor3 = Color3.fromRGB(16, 22, 40)
	imageLabel.Image = "rbxassetid://136906199972215"

	imageLabel.ImageColor3 = Color3.fromRGB(110, 120, 150)
	imageLabel.ScaleType = Enum.ScaleType.Crop
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = surfaceGui

	packOpeningScene.Name = "PackOpeningScene"
	packOpeningScene.Parent = workspace
	v4 = packOpeningScene

	return packOpeningScene
end

local function part(childName: string) -- 8 equivalent calls inferred from this helper
	return (getScene():FindFirstChild(childName, true))
end

local function burst(parent)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://122592893043264"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(0, 0)
	imageLabel.ImageTransparency = 0.4
	imageLabel.Rotation = math.random(-180, 180)
	imageLabel.ZIndex = 5
	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.Parent = imageLabel
	imageLabel.Parent = parent

	local tween = TweenService:Create(imageLabel, TweenInfo.new(0.4), {
		Size = UDim2.fromScale(3, 3),
		ImageTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		imageLabel:Destroy()
	end)

	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Image = "rbxassetid://90753168102376"
	imageLabel2.ImageColor3 = color
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel2.Size = UDim2.fromScale(0.2, 0.2)
	imageLabel2.ZIndex = 5
	local uiAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint_2.Parent = imageLabel2
	imageLabel2.Parent = parent

	local tween2 = TweenService:Create(imageLabel2, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
		Size = UDim2.fromScale(1.2, 1.2),
		ImageTransparency = 1
	})

	tween2:Play()
	tween2.Completed:Connect(function()
		imageLabel2:Destroy()
	end)
end

local function isCurrency(data): boolean -- 1 equivalent call inferred from this helper
	return data.Kind == "Coins" or data.Kind == "Gems"
end

local function currencyModel(kind: string, p: number)
	local currencyReward = Instance.new("Model")
	currencyReward.Name = "CurrencyReward"

	local v6 = p * 10
	local plate = Instance.new("Part")
	plate.Name = "Plate"
	plate.Size = Vector3.new(v6, v6, 0.05)
	plate.Transparency = 1
	plate.Anchored = true
	plate.CanCollide = false
	plate.CanQuery = false
	plate.CanTouch = false
	plate.CastShadow = false
	plate.Parent = currencyReward
	currencyReward.PrimaryPart = plate

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Back
	surfaceGui.LightInfluence = 0
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 40
	surfaceGui.Parent = plate

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = kind == "Gems" and "rbxassetid://91068843812037" or "rbxassetid://140250576355900"
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(0.9, 0.9)
	imageLabel.Parent = surfaceGui

	return currencyReward
end

local function rewardModel(p)
	local model = ReplicatedStorage

	for _, childName in typeof(p.modelFolder) ~= "table" and {} or p.modelFolder do
		model = model and model:FindFirstChild(childName)
	end

	if model then
		if typeof(p.modelName) == "string" then
			model = model:FindFirstChild(p.modelName)
		else
			model = false
		end
	end

	if not (model and model:IsA("Model")) then
		return nil
	end

	local clone = model:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	return clone
end

local function rewardPose(p: string, vector3: Vector3, cframe: CFrame, p2: number)
	local rightVector = cframe.RightVector
	local upVector = cframe.UpVector
	local cframe2 = CFrame.fromMatrix(vector3, rightVector, upVector)

	if p == "poolTables" then
		return function(p3: number)
			return cframe2 * CFrame.Angles(0.4363323129985824, math.rad(p3 * 20), 0)
		end
	end

	return function(p3: number)
		local v6 = math.sin(p3 * 1.3) * 10

		return cframe2 * CFrame.new(0, math.sin(p3 * 2) * 0.25 * p2, 0) * CFrame.Angles(0, math.rad(v6), 0)
	end
end

local function fitReward(instance, category: string, p: number)
	local _, v6 = instance:GetBoundingBox()
	local v7

	if category == "poolTables" then
		v7 = math.min(20 / math.max(math.max(v6.X, v6.Z), 0.01), 12 / math.max(v6.Y, 0.01))
	else
		v7 = 24 / math.max(v6.X, v6.Y, v6.Z, 0.01)
	end

	local v8 = v7 * p

	instance:ScaleTo(instance:GetScale() * v8)
	local boundingBox, v9 = instance:GetBoundingBox()

	local objectSpace = boundingBox:ToObjectSpace(instance:GetPivot())

	if category == "poolTables" then
		return objectSpace
	end

	local v10 = { boundingBox.RightVector, boundingBox.UpVector, boundingBox.LookVector }
	local v11 = { v9.X, v9.Y, v9.Z }
	local v12 = 1

	local v13 = v11[2] > v11[v12] and 2 or v12
	local v14 = v11[3] > v11[v13] and 3 or v13

	local v15 = v14 == 2 and 3 or 2

	local cframe = CFrame.fromMatrix(Vector3.new(0, 0, 0), v10[v14], v10[v15])
	return CFrame.fromMatrix(Vector3.new(0, 0, 0), Vector3.new(0.9659258, 0.25881904, 0), Vector3.new(0, 0, 1)) * cframe:Inverse() * boundingBox.Rotation * objectSpace
end

function PoolPackOpening.IsBusy()
	return flag
end

function PoolPackOpening.Play(data)
	local parent = v5

	if typeof(data) ~= "table" or not parent then
		return
	end

	local currency = isCurrency(data) -- inferred equivalent call
	local v6

	if not currency then
		v6 = PoolSkins.GetItem(data.Category, data.Item)
	end

	if not (currency or v6) then
		warn("[PoolPackOpening] no skin " .. tostring(data.Category) .. "/" .. tostring(data.Item))

		return
	end

	local v7

	if typeof(data.VenueName) == "string" then
		v7 = string.upper(data.VenueName) .. " LOOTBOX  •  "
	else
		v7 = ""
	end

	while flag do
		task.wait(0.2)
	end

	flag = true
	bindableEvent:Fire()

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local currentCamera = workspace.CurrentCamera
	local v8 = part("Camera") -- inferred equivalent call
	local v9 = part("Pack") -- inferred equivalent call
	local v10 = part("Starburst") -- inferred equivalent call
	local v11 = part("Card") -- inferred equivalent call
	local v12 = { part("Circle"), part("Square") } -- inferred equivalent call
	local v13 = { v12[1].CFrame, v12[2].CFrame }
	local v14 = part("Reward") -- inferred equivalent call
	local v15 = part("Chance") -- inferred equivalent call

	for _, folder in { v14, v15 } do
		for _, label in folder:GetDescendants() do
			if label:IsA("TextLabel") then
				label.Text = ""
			end
		end
	end

	local v16 = {
		Type = currentCamera.CameraType,
		CFrame = currentCamera.CFrame,
		FieldOfView = currentCamera.FieldOfView
	}

	local screenGuis = {}

	for _, childName in v3 do
		local screenGui = playerGui:FindFirstChild(childName)

		if not (screenGui and screenGui:IsA("ScreenGui") and screenGui.Enabled) then
			continue
		end

		screenGui.Enabled = false
		table.insert(screenGuis, screenGui)
	end

	parent.Enabled = true

	local subheader = parent:FindFirstChild("Subheader")
	local button = parent:FindFirstChild("Button")

	local v17 = 0
	local v18 = 0

	local function shake(p: number, p2: number) -- 2 equivalent calls inferred from this helper
		v18 = p
		v17 = os.clock() + p2
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 70

	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local mouseLocation = UserInputService:GetMouseLocation()
		local viewportSize = currentCamera.ViewportSize
		local v19 = (mouseLocation.Y - viewportSize.Y / 2) / math.max(viewportSize.Y, 1) * -8
		local v20 = (mouseLocation.X - viewportSize.X / 2) / math.max(viewportSize.X, 1) * -8
		local v21 = CFrame.identity
		local v22 = v17 - os.clock()

		if v22 > 0 then
			local v23 = v18 * v22
			v21 = CFrame.new(math.random(-100, 100) / 100 * v23, math.random(-100, 100) / 100 * v23, 0)
		end

		currentCamera.CFrame = v8.CFrame * CFrame.Angles(math.rad(v19), math.rad(v20), 0) * v21
	end)

	local imageLabel = v10:FindFirstChildWhichIsA("ImageLabel", true)

	if imageLabel then
		imageLabel.ImageTransparency = 1
		TweenService:Create(imageLabel, TweenInfo.new(0.5), { ImageTransparency = 0.2 }):Play()
	end

	local total = 0
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if imageLabel then
			imageLabel.Rotation += dt * 15
		end

		v12[1].CFrame = v13[1] * CFrame.Angles(0, 0, (math.rad(total * 45)))
		v12[2].CFrame = v13[2] * CFrame.Angles(0, 0, (math.rad(-total * 30)))
	end)

	local clone = packOpening:WaitForChild("GiftBox"):Clone()

	for _, part2 in clone:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
	end

	local _, v19 = clone:GetBoundingBox()
	clone:ScaleTo(clone:GetScale() * 5.4 / math.max(v19.Y, 0.01))

	local boundingBox = clone:GetBoundingBox()
	local objectSpace = boundingBox:ToObjectSpace(clone:GetPivot())
	local gift_Lid = clone:FindFirstChild("Gift_Lid", true)
	local v20

	if gift_Lid then
		v20 = boundingBox:ToObjectSpace(gift_Lid:GetPivot())
	else
		v20 = CFrame.identity
	end

	local v21 = {}

	local v22 = CFrame.identity

	if gift_Lid then
		if gift_Lid:IsA("BasePart") then
			table.insert(v21, gift_Lid)
		end

		for _, part2 in gift_Lid:GetDescendants() do
			if part2:IsA("BasePart") then
				table.insert(v21, part2)
			end
		end
	end

	local function placePack(cframe: CFrame) -- 3 equivalent calls inferred from this helper
		clone:PivotTo(cframe * objectSpace)

		if gift_Lid then
			gift_Lid:PivotTo(cframe * v20 * v22)
		end
	end

	local v23 = v9.Position + Vector3.new(0, 0.54, 0)
	local v24 = (v8.Position - v9.Position) * Vector3.new(1, 0, 1)
	local v25 = CFrame.lookAt(v23, v23 - v24) * CFrame.Angles(0.2792526803190927, 0, 0) * CFrame.Angles(0, 0.5235987755982988, 0)

	local v26 = v25 * CFrame.new(0, -15, 0)
	clone:PivotTo(v26 * objectSpace)

	if gift_Lid then
		gift_Lid:PivotTo(v26 * v20 * v22)
	end

	clone.Parent = getScene()

	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Value = v25 * CFrame.new(0, -15, 0)
	cframeValue.Changed:Connect(placePack)
	TweenService:Create(cframeValue, TweenInfo.new(1.6, Enum.EasingStyle.Elastic), { Value = v25 }):Play()
	local success, result = pcall(Sounds.new, { "PackOpening", "Open" }, nil)

	if success and result then
		Sounds.Play(result, nil, true)
	end

	local success2, result2 = pcall(Sounds.new, { "PackOpening", "Open2" }, nil)

	if success2 and result2 then
		Sounds.Play(result2, nil, true)
	end

	local count = 0

	local function shakePack(count2: number) -- 1 equivalent call inferred from this helper
		count += 1

		local v27 = count
		local lastTime = os.clock()
		local v28 = (count2 * 0.04 + 0.04) * 5.4
		local heartbeatConnection2 = nil

		heartbeatConnection2 = RunService.Heartbeat:Connect(function()
			local v29 = os.clock() - lastTime

			if v27 == count and not (v29 >= 0.4) and clone.Parent then
				local v30 = math.sin(v29 * 60) * (1 - v29 / 0.4)

				v22 = CFrame.new(0, math.sin(3.141592653589793 * v29 / 0.4) * v28, 0) * CFrame.Angles(0, 0, (math.rad(v30 * 6)))
				placePack(v25 * CFrame.new(v30 * 0.35, math.abs(v30) * 0.12, 0) * CFrame.Angles(0, math.rad(v30 * 6), (math.rad(v30 * 12)))) -- inferred equivalent call
			else
				heartbeatConnection2:Disconnect()

				if v27 == count and clone.Parent then
					v22 = CFrame.identity
					placePack(v25) -- inferred equivalent call
				end
			end
		end)
	end

	local bindableEvent3 = Instance.new("BindableEvent")
	local activatedConnection = button.Activated:Connect(function()
		bindableEvent3:Fire()
	end)

	ContextActionService:BindActionAtPriority("PoolPackTap", function(_, p)
		if p == Enum.UserInputState.Begin then
			bindableEvent3:Fire()
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonA)

	local function prompt(p: string) -- 3 equivalent calls inferred from this helper
		local v27 = Device:Get()
		subheader.Text = (v27 == "Console" and "PRESS A " or v27 == "Mobile" and "TAP " or "CLICK ") .. p
	end

	local count2 = 0
	subheader.Visible = true
	prompt(string.format("%d TIMES TO OPEN", 3)) -- inferred equivalent call
	subheader.Text = v7 .. subheader.Text

	local bindableEvent4 = Instance.new("BindableEvent")
	local eventConnection = bindableEvent3.Event:Connect(function()
		if count2 >= 3 then
			return
		end

		count2 += 1
		burst(parent)
		local v27 = 0.9 + math.random() * 0.3
		local success3, result3 = pcall(Sounds.new, { "PackOpening", "Rustle" }, nil)

		if success3 and result3 then
			if v27 then
				Sounds.SetPitch(result3, v27)
			end

			Sounds.Play(result3, nil, true)
		end

		if count2 < 3 then
			shakePack(count2) -- inferred equivalent call
			prompt(string.format("%d TIMES TO OPEN", 3 - count2)) -- inferred equivalent call
			subheader.Text = v7 .. subheader.Text
			local v28 = 0.9 + math.random() * 0.2
			local success4, result4 = pcall(Sounds.new, { "PackOpening", "Hit" }, nil)

			if success4 and result4 then
				if v28 then
					Sounds.SetPitch(result4, v28)
				end

				Sounds.Play(result4, nil, true)
			end
		else
			count += 1
			subheader.Visible = false
			bindableEvent4:Fire()
		end
	end)

	bindableEvent4.Event:Wait()
	eventConnection:Disconnect()
	bindableEvent4:Destroy()
	local success3, result3 = pcall(Sounds.new, { "PackOpening", "Final" }, nil)

	if success3 and result3 then
		Sounds.Play(result3, nil, true)
	end

	local heartbeatConnection2 = nil

	local glow = Instance.new("Part")
	glow.Name = "Glow"
	glow.Size = Vector3.new(0.2, 0.2, 0.2)
	glow.Transparency = 1
	glow.Anchored = true
	glow.CanCollide = false
	glow.CanQuery = false
	glow.CanTouch = false
	glow.CFrame = cframeValue.Value * CFrame.new(0, 0.54, 0)
	glow.Parent = clone

	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Range = 8.64
	pointLight.Brightness = 0
	pointLight.Shadows = false
	pointLight.Parent = glow
	TweenService:Create(pointLight, TweenInfo.new(0.25), { Brightness = 6 }):Play()

	local attachment = Instance.new("Attachment")
	attachment.Parent = glow
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, 8.1, 0)
	attachment2.Parent = glow

	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2

	beam.Color = ColorSequence.new(Color3.fromRGB(255, 186, 60))
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.6, 0.75),
		NumberSequenceKeypoint.new(1, 1)
	})

	beam.LightEmission = 1
	beam.FaceCamera = true
	beam.Segments = 1
	beam.Width0 = 0
	beam.Width1 = 0
	beam.Parent = glow
	TweenService:Create(beam, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Width0 = 2.9700000000000006,
		Width1 = 5.13
	}):Play()

	if gift_Lid then
		local lastTime = os.clock()

		heartbeatConnection2 = RunService.Heartbeat:Connect(function()
			local v27 = math.min((os.clock() - lastTime) / 0.7, 1)
			local v28 = 1 - (1 - v27) ^ 3

			v22 = CFrame.new(v28 * 1.62, v28 * 8.100000000000001, 0) * CFrame.Angles(
				math.rad(v28 * -40),
				math.rad(v28 * 150),
				(math.rad(v28 * -35))
			)

			for _, v29 in v21 do
				v29.Transparency = v27 * v27
			end

			placePack(cframeValue.Value) -- inferred equivalent call

			if v27 >= 1 and heartbeatConnection2 then
				heartbeatConnection2:Disconnect()
			end
		end)
	end

	if imageLabel then
		TweenService:Create(imageLabel, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
	end

	task.wait(0.8)
	TweenService:Create(cframeValue, TweenInfo.new(0.8), {
		Value = v25 * CFrame.new(0, -15, 0)
	}):Play()

	local v27 = currency and "Tier2" or rarityOf(v6)
	local v28

	if currency then
		v28 = if data.Kind == "Gems" then color2 else color
	else
		v28 = rarityColour(v27) -- inferred equivalent call
	end

	local success4, result4 = pcall(Visuals.new, { "Change" }, v11.CFrame)

	if success4 and result4 then
		Visuals.Recolour(result4, v28)
		Visuals.Play(result4, nil, true)
	end

	if rarityRank(v27) >= 4 then -- inferred equivalent call
		local success5, result5 = pcall(Sounds.new, { "UserInterface", "Legendary" }, nil)

		if success5 and result5 then
			Sounds.Play(result5, nil, true)
		end

		shake(1.2, 0.5) -- inferred equivalent call
	else
		local success5, result5 = pcall(Sounds.new, { "UserInterface", "Sparkles" }, nil)

		if success5 and result5 then
			Sounds.Play(result5, nil, true)
		end

		shake(0.5, 0.3) -- inferred equivalent call
	end

	if imageLabel then
		imageLabel.ImageColor3 = v28
		TweenService:Create(imageLabel, TweenInfo.new(0.6), { ImageTransparency = 0.35 }):Play()
	end

	local v29

	if currency then
		v29 = currencyModel(data.Kind, 0.55)
	else
		v29 = rewardModel(v6)
	end

	local heartbeatConnection3 = nil

	if v29 then
		local position = v8.Position
		local v30 = position + (v11.Position - position) * 0.55
		local v31

		if currency then
			v31 = CFrame.identity
		else
			v31 = fitReward(v29, data.Category, 0.55)
		end

		local v32 = rewardPose(currency and "currency" or data.Category, v30, v8.CFrame, 0.55)
		local lastTime = os.clock()

		v29:PivotTo(v32(0) * v31)
		v29.Parent = getScene()

		heartbeatConnection3 = RunService.Heartbeat:Connect(function()
			local v34 = os.clock() - lastTime

			local v35 = math.min(v34 / 0.45, 1)
			local v36 = ((1 - v35) * (1 - v35) * -4 + math.sin(v35 * 3.141592653589793) * 0.6) * 0.55

			v29:PivotTo(CFrame.new(0, v36, 0) * v32(v34) * v31)
		end)
	else
		warn("[PoolPackOpening] no model for " .. tostring(data.Item))
	end

	local v30 = v2[data.Category] or "REWARD"
	local textLabel = v14:FindFirstChild("TextLabel", true)
	local rarity = v14:FindFirstChild("Rarity", true)
	local rarity2 = v15:FindFirstChild("Rarity", true)

	if textLabel then
		local text

		if currency then
			text = "+" .. PoolSkins.FormatAmount(tonumber(data.Amount) or 0)
		else
			text = string.upper((tostring(v6.name or data.Item)))
		end

		textLabel.Text = text

		textLabel.TextColor3 = Color3.new(1, 1, 1)
	end

	if rarity then
		local text

		if currency then
			text = string.upper(data.Kind)
		else
			text = string.format("%s %s", v[v27] or string.upper(v27), v30)
		end

		rarity.Text = text

		rarity.TextColor3 = v28
	end

	local uiGradient = nil

	if rarity2 then
		if currency then
			rarity2.Text = "ADDED TO YOUR BALANCE"
			rarity2.TextColor3 = v28
		elseif data.Duplicate then
			rarity2.Text = string.format(
				"ALREADY OWNED  •  +%s COINS",
				PoolSkins.FormatAmount(tonumber(data.Coins) or 0)
			)
			rarity2.TextColor3 = color
		else
			rarity2.Text = string.format("NEW %s!", v30)
			rarity2.TextColor3 = Color3.new(1, 1, 1)
			uiGradient = Instance.new("UIGradient")
			uiGradient.Color = ColorSequence.new(Color3.fromRGB(255, 236, 140), Color3.fromRGB(255, 150, 40))
			uiGradient.Parent = rarity2
		end
	end

	subheader.Visible = true
	prompt("TO CONTINUE") -- inferred equivalent call
	task.wait(0.6)
	bindableEvent3.Event:Wait()

	ContextActionService:UnbindAction("PoolPackTap")
	activatedConnection:Disconnect()
	bindableEvent3:Destroy()

	subheader.Visible = false

	if uiGradient then
		uiGradient:Destroy()
	end

	for _, v31 in { textLabel, rarity, rarity2 } do
		if v31 then
			v31.Text = ""
		end
	end

	if imageLabel then
		imageLabel.ImageColor3 = color
	end

	if heartbeatConnection3 then
		heartbeatConnection3:Disconnect()
	end

	if v29 then
		v29:Destroy()
	end

	if heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
	end

	clone:Destroy()
	cframeValue:Destroy()
	heartbeatConnection:Disconnect()
	renderSteppedConnection:Disconnect()
	parent.Enabled = false

	currentCamera.CameraType = v16.Type
	currentCamera.CFrame = v16.CFrame
	currentCamera.FieldOfView = v16.FieldOfView

	for _, v31 in screenGuis do
		v31.Enabled = true
	end

	flag = false
	bindableEvent2:Fire()
end

function PoolPackOpening.Init()
	if v5 then
		return
	end

	local packOpenUI = packOpening:WaitForChild("PackOpenUI"):Clone()

	packOpenUI.Name = "PackOpenUI"
	packOpenUI.Enabled = false
	packOpenUI.ResetOnSpawn = false
	packOpenUI.DisplayOrder = 30
	packOpenUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	v5 = packOpenUI
end

return PoolPackOpening