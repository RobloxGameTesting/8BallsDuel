local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Indicator = {}

local v = {
	prefix = "",
	suffix = "",
	decimals = 0,
	travelDirection = Vector2.new(0, -1),
	travelPixels = 42,
	risePixels = 42,
	randomJitterPixels = 14,
	screenOffset = Vector2.new(0, 0),
	size = Vector2.new(240, 60),
	textSize = 18,
	font = Enum.Font.GothamBold,
	strokeTransparency = 0.2,
	strokeColor = Color3.new(0, 0, 0),
	strokeThickness = 1,
	maxDistanceStuds = 250,
	fadeStartAlpha = 0.65
}

local flag = false
local v2 = nil
local parent = nil

local v3 = {}
local v4 = {}

local function mergeOptions(items)
	if not items then
		return v
	end

	local result = {}

	for k, v5 in pairs(v) do
		result[k] = v5
	end

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function ensureGui()
	if v2 and parent then
		return
	end

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local worldIndicators = Instance.new("ScreenGui")
	worldIndicators.Name = "WorldIndicators"
	worldIndicators.ResetOnSpawn = false
	worldIndicators.IgnoreGuiInset = true
	worldIndicators.DisplayOrder = 10000
	worldIndicators.Parent = playerGui

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.BackgroundTransparency = 1
	container.Size = UDim2.fromScale(1, 1)
	container.Position = UDim2.fromScale(0, 0)
	container.Parent = worldIndicators

	v2 = worldIndicators
	parent = container
end

local function makeLabel()
	local indicator = Instance.new("TextLabel")
	indicator.Name = "Indicator"
	indicator.BackgroundTransparency = 1
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.Size = UDim2.fromOffset(v.size.X, v.size.Y)
	indicator.TextXAlignment = Enum.TextXAlignment.Center
	indicator.TextYAlignment = Enum.TextYAlignment.Center
	indicator.TextScaled = false
	indicator.RichText = false
	indicator.Visible = false
	indicator.Position = UDim2.fromOffset(-10000, -10000)

	local scale = Instance.new("UIScale")
	scale.Name = "Scale"
	scale.Scale = 1
	scale.Parent = indicator

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Stroke"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Thickness = v.strokeThickness or 1
	stroke.Transparency = v.strokeTransparency or 0.2
	stroke.Color = v.strokeColor or Color3.new(0, 0, 0)
	stroke.Parent = indicator

	indicator.Parent = parent
	return indicator
end

local function acquireLabel() -- 1 equivalent call inferred from this helper
	local label = table.remove(v3) or makeLabel()

	label.Visible = true
	return label
end

local function releaseLabel(instance)
	instance.Visible = false
	instance.TextTransparency = 0
	instance.Text = ""
	instance.Position = UDim2.fromOffset(-10000, -10000)

	local size = v.size
	instance.Size = UDim2.fromOffset(size.X, size.Y)

	local scale = instance:FindFirstChild("Scale")

	if scale and scale:IsA("UIScale") then
		scale.Scale = 1
	end

	local stroke = instance:FindFirstChild("Stroke")

	if stroke and stroke:IsA("UIStroke") then
		stroke.Transparency = v.strokeTransparency or 0.2
		stroke.Color = v.strokeColor or Color3.new(0, 0, 0)
		stroke.Thickness = v.strokeThickness or 1
	end

	v4[instance] = nil
	table.insert(v3, instance)
end

local function formatNumber(p: number, decimals: number) -- 1 equivalent call inferred from this helper
	if decimals <= 0 then
		return (tostring((math.floor(p + 0.5))))
	end

	local v5 = 10 ^ decimals
	return (tostring(math.floor(p * v5 + 0.5) / v5))
end

local function lerp(p: number, finalScale: number, p2: number) -- 2 equivalent calls inferred from this helper
	return p + (finalScale - p) * p2
end

local function safeUnit(travelDirection: Vector2, travelDirection2: Vector2) -- 1 equivalent call inferred from this helper
	local magnitude = travelDirection.Magnitude

	if magnitude < 1e-6 then
		return travelDirection2
	end

	return travelDirection / magnitude
end

local function updateAll(_: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position

	for k, v5 in pairs(v4) do
		local v6 = os.clock() - v5.t0

		if v5.dur <= v6 then
			releaseLabel(k)
		elseif (v5.worldPos - position).Magnitude > v5.maxDist then
			k.Visible = false
		else
			k.Visible = true

			local worldToViewportPoint, v7 = currentCamera:WorldToViewportPoint(v5.worldPos)

			if v7 then
				local v8 = v6 / v5.dur
				local v9 = 1 - (1 - v8) * (1 - v8)

				local travelVec = v5.travelVec
				local v10 = worldToViewportPoint.X + v5.jitter.X + v5.screenOffset.X + travelVec.X * v9
				local v11 = worldToViewportPoint.Y + v5.jitter.Y + v5.screenOffset.Y + travelVec.Y * v9
				k.Position = UDim2.fromOffset(v10, v11)

				local scale = k:FindFirstChild("Scale")

				if scale and scale:IsA("UIScale") then
					scale.Scale = lerp(v5.startScale, v5.finalScale, v9) -- inferred equivalent call
				end

				local stroke = k:FindFirstChild("Stroke")
				local baseStrokeTransparency = v5.baseStrokeTransparency

				if v5.fadeStart <= v8 then
					local textTransparency = math.clamp((v8 - v5.fadeStart) / (1 - v5.fadeStart), 0, 1)

					k.TextTransparency = textTransparency

					if stroke and stroke:IsA("UIStroke") then
						stroke.Transparency = lerp(baseStrokeTransparency, 1, textTransparency) -- inferred equivalent call
					end
				else
					k.TextTransparency = 0

					if stroke and stroke:IsA("UIStroke") then
						stroke.Transparency = baseStrokeTransparency
					end
				end
			else
				k.Visible = false
			end
		end
	end
end

function Indicator.init()
	if flag then
		return
	end

	flag = true

	ensureGui()

	for _ = 1, 30 do
		table.insert(v3, makeLabel())
	end

	RunService:BindToRenderStep("WorldIndicators_Update", Enum.RenderPriority.Camera.Value + 1, updateAll)
end

function Indicator.shutdown()
	if not flag then
		return
	end

	RunService:UnbindFromRenderStep("WorldIndicators_Update")

	if v2 then
		v2:Destroy()
	end

	v2 = nil
	parent = nil

	table.clear(v3)
	table.clear(v4)

	flag = false
end

function Indicator.new(p: number, p2: number, textColor: Color3, worldPos: Vector3, p3)
	if not flag then
		Indicator.init()
	end

	local v5 = mergeOptions(p3)
	local label = acquireLabel() -- inferred equivalent call
	label.TextColor3 = textColor
	label.TextSize = v5.textSize or v.textSize
	label.Font = v5.font or v.font

	local size = v5.size or v.size
	label.Size = UDim2.fromOffset(size.X, size.Y)

	local stroke = label:FindFirstChild("Stroke")
	local strokeTransparency = v5.strokeTransparency

	if strokeTransparency == nil then
		strokeTransparency = v.strokeTransparency
	end

	local strokeColor = v5.strokeColor or v.strokeColor
	local strokeThickness = v5.strokeThickness or v.strokeThickness

	if stroke and stroke:IsA("UIStroke") then
		stroke.Transparency = strokeTransparency
		stroke.Color = strokeColor
		stroke.Thickness = strokeThickness
	end

	local prefix = v5.prefix or ""
	label.Text = prefix .. formatNumber(p, v5.decimals or v.decimals) .. (v5.suffix or "") -- inferred equivalent call

	local randomJitterPixels = v5.randomJitterPixels or v.randomJitterPixels
	local vector2 = Vector2.new(
		(math.random() * 2 - 1) * randomJitterPixels,
		(math.random() * 2 - 1) * randomJitterPixels
	)

	local dur = math.max(0.08, p2)
	local fadeStartAlpha = v5.fadeStartAlpha or v.fadeStartAlpha

	local v6 = safeUnit(v5.travelDirection or v.travelDirection, v.travelDirection) -- inferred equivalent call
	local v7 = v5.travelPixels

	if v7 == nil then
		v7 = v5.risePixels or v.travelPixels
	end

	local travelVec = v6 * v7

	local v8 = 1

	if v5.finalScale == nil then
		if v5.finalSize ~= nil then
			v8 = v5.finalSize.X / math.max(1, size.X)
		end
	else
		v8 = v5.finalScale
	end

	local finalScale = math.clamp(v8, 0.1, 10)

	local scale = label:FindFirstChild("Scale")

	if scale and scale:IsA("UIScale") then
		scale.Scale = 1
	end

	v4[label] = {
		worldPos = worldPos,
		t0 = os.clock(),
		dur = dur,
		fadeStart = math.clamp(fadeStartAlpha, 0.05, 0.95),
		jitter = vector2,
		screenOffset = v5.screenOffset or v.screenOffset,
		travelVec = travelVec,
		maxDist = v5.maxDistanceStuds or v.maxDistanceStuds,
		baseStrokeTransparency = math.clamp(strokeTransparency, 0, 1),
		startScale = 1,
		finalScale = finalScale
	}

	local flag2 = false
	return {
		Destroy = function(self)
			if flag2 then
				return
			end

			flag2 = true

			if v4[label] then
				releaseLabel(label)
			end
		end
	}
end

return Indicator