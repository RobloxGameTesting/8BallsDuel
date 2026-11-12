local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local v = { "rbxassetid://17092093716", "rbxassetid://17096489887" }

local color = Color3.fromRGB(255, 222, 130)

local v2 = {
	Color3.fromRGB(255, 206, 72),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(64, 200, 255),
	Color3.fromRGB(255, 140, 40),
	Color3.fromRGB(114, 220, 78),
	Color3.fromRGB(255, 96, 150)
}

local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local random = Random.new()

local function between(p: number, p2: number) -- 11 equivalent calls inferred from this helper
	return random:NextNumber(p, p2)
end

local function round(parent) -- 2 equivalent calls inferred from this helper
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = parent
end

local function decorate(p, zIndex: number, matchFoundBurst) -- 4 equivalent calls inferred from this helper
	p.AnchorPoint = Vector2.new(0.5, 0.5)
	p.BorderSizePixel = 0
	p.Active = false
	p.ZIndex = zIndex
	p.Parent = matchFoundBurst
end

return {
	Play = function(self, parent)
		local absoluteSize = self.AbsoluteSize
		local v3 = math.min(absoluteSize.X, absoluteSize.Y) / 2

		if v3 <= 0 then
			return
		end

		local absolutePosition = parent.AbsolutePosition
		local v4 = self.AbsolutePosition.X + absoluteSize.X / 2 - absolutePosition.X
		local v5 = self.AbsolutePosition.Y + absoluteSize.Y / 2 - absolutePosition.Y
		local zIndex = self.ZIndex

		local matchFoundBurst = Instance.new("Frame")
		matchFoundBurst.Name = "MatchFoundBurst"
		matchFoundBurst.Size = UDim2.fromScale(1, 1)
		matchFoundBurst.BackgroundTransparency = 1
		matchFoundBurst.BorderSizePixel = 0
		matchFoundBurst.Active = false
		matchFoundBurst.ZIndex = zIndex
		matchFoundBurst.Parent = parent

		local udim = UDim2.fromOffset(v4, v5)
		local v6 = v3 * 2

		for k, v7 in { 50, -35 } do
			local glow = Instance.new("ImageLabel")
			glow.Name = "Glow"
			glow.BackgroundTransparency = 1
			glow.Image = "rbxassetid://17059047544"
			glow.ImageColor3 = color
			glow.ImageTransparency = 0
			glow.Position = udim
			glow.Rotation = k == 1 and 0 or 11
			glow.Size = UDim2.fromOffset(v6 * 1.4, v6 * 1.4)
			decorate(glow, zIndex - 1, matchFoundBurst) -- inferred equivalent call

			local v8 = k == 1 and 3.1 or 2.5

			TweenService:Create(glow, tweenInfo2, {
				Size = UDim2.fromOffset(v6 * v8, v6 * v8),
				ImageTransparency = 1,
				Rotation = glow.Rotation + v7
			}):Play()
		end

		local flash = Instance.new("Frame")
		flash.Name = "Flash"
		flash.BackgroundColor3 = Color3.new(1, 1, 1)
		flash.BackgroundTransparency = 0.15
		flash.Position = udim
		flash.Size = UDim2.fromOffset(v6, v6)
		round(flash) -- inferred equivalent call
		decorate(flash, zIndex + 3, matchFoundBurst) -- inferred equivalent call

		TweenService:Create(flash, tweenInfo, { BackgroundTransparency = 1 }):Play()

		local ring = Instance.new("Frame")
		ring.Name = "Ring"
		ring.BackgroundTransparency = 1
		ring.Position = udim
		ring.Size = UDim2.fromOffset(v6, v6)
		round(ring) -- inferred equivalent call
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.fromRGB(255, 236, 170)
		uiStroke.Thickness = math.max(2, v3 * 0.18)
		uiStroke.Transparency = 0.05
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = ring

		decorate(ring, zIndex + 6, matchFoundBurst) -- inferred equivalent call

		TweenService:Create(ring, tweenInfo3, {
			Size = UDim2.fromOffset(v6 * 2.1, v6 * 2.1)
		}):Play()
		TweenService:Create(uiStroke, tweenInfo3, { Transparency = 1, Thickness = 1 }):Play()

		local v7 = {}

		for i = 1, 36 do
			local sparkle = i <= 18
			local v8 = i / 36 * 3.141592653589793 * 2 + between(-0.18, 0.18) -- inferred equivalent call
			local v9 = math.cos(v8)
			local v10 = math.sin(v8)
			local v11 = v3 * between(3.4, 6.2) * (sparkle and 1 or 0.85) -- inferred equivalent call
			local v12, width, height

			if sparkle then
				v12 = Instance.new("ImageLabel")
				v12.BackgroundTransparency = 1
				v12.Image = v[random:NextInteger(1, #v)]
				width = v3 * between(0.34, 0.66) -- inferred equivalent call
				height = width
			else
				v12 = Instance.new("Frame")
				v12.BackgroundColor3 = v2[random:NextInteger(1, #v2)]

				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0.25, 0)
				uiCorner.Parent = v12
				width = v3 * 0.11 * between(0.8, 1.2) -- inferred equivalent call
				height = v3 * 0.2 * between(0.8, 1.2) -- inferred equivalent call
			end

			local v13 = v4 + v9 * v3 * 0.85
			local v14 = v5 + v10 * v3 * 0.85

			v12.Name = sparkle and "Sparkle" or "Confetti"
			v12.Position = UDim2.fromOffset(v13, v14)
			v12.Size = UDim2.fromOffset(0, 0)
			v12.Rotation = between(0, 360) -- inferred equivalent call
			decorate(v12, zIndex + 7, matchFoundBurst) -- inferred equivalent call

			local v15 = {
				Object = v12,
				X = v13,
				Y = v14,
				VX = v9 * v11,
				VY = v10 * v11 - v3 * 1.4,
				Gravity = v3 * (sparkle and 1.2 or 4.2),
				Age = 0,
				Life = 0,
				Width = 0,
				Height = 0,
				Spin = 0,
				Flip = 0,
				FlipPhase = 0,
				Sparkle = 0
			}
			local life

			if sparkle then
				life = between(0.6, 1) -- inferred equivalent call
			else
				life = between(0.95, 1.45) -- inferred equivalent call
			end

			v15.Life = life

			v15.Width = width
			v15.Height = height
			v15.Spin = between(-240, 240) -- inferred equivalent call
			local flip

			if not sparkle then
				flip = between(8, 16) -- inferred equivalent call
			end

			v15.Flip = flip
			v15.FlipPhase = between(0, 6.283185307179586) -- inferred equivalent call
			v15.Sparkle = sparkle
			table.insert(v7, v15)
		end

		local renderSteppedConnection = nil

		local function finish() -- 2 equivalent calls inferred from this helper
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			matchFoundBurst:Destroy()
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			if matchFoundBurst.Parent then
				local v8 = math.min(dt, 0.05)
				local v9 = math.exp(v8 * -2.6)
				local v10 = false

				for _, v11 in v7 do
					if v11.Age >= v11.Life then
						continue
					end

					v11.Age += v8
					v11.VX *= v9
					v11.VY = v11.VY * v9 + v11.Gravity * v8
					v11.X += v11.VX * v8
					v11.Y += v11.VY * v8

					local object = v11.Object

					if v11.Age >= v11.Life then
						object.Visible = false
					else
						v10 = true

						local v12 = v11.Age / v11.Life
						local v13 = math.clamp((v12 - 0.6) / 0.4, 0, 1)
						local v14

						if v11.Sparkle then
							if v12 < 0.12 then
								v14 = TweenService:GetValue(v12 / 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
							else
								v14 = 1 - math.clamp((v12 - 0.5) / 0.5, 0, 1)
							end
						else
							v14 = math.min(v12 / 0.06, 1)
						end

						local v15 = v11.Width * v14

						if v11.Flip then
							v15 *= math.abs((math.cos(v11.FlipPhase + v11.Age * v11.Flip)))
						end

						object.Position = UDim2.fromOffset(v11.X, v11.Y)
						object.Size = UDim2.fromOffset(v15, v11.Height * v14)
						object.Rotation += v11.Spin * v8

						if object:IsA("ImageLabel") then
							object.ImageTransparency = v13
						else
							object.BackgroundTransparency = v13
						end
					end
				end

				if not v10 then
					finish() -- inferred equivalent call
				end
			else
				finish() -- inferred equivalent call
			end
		end)
	end
}