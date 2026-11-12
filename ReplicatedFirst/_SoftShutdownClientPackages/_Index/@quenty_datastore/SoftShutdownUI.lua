local loader = require(script.Parent.loader)
local loaded = loader.load(script)

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local v = loaded("BasicPane")
local v2 = loaded("Blend")
local v3 = loaded("SpringObject")
local v4 = loaded("Rx")
local v5 = loaded("Math")

local object = setmetatable({}, v)
object.ClassName = "SoftShutdownUI"
object.__index = object

function object.new()
	local object2 = setmetatable(v.new(), object)

	object2._title = Instance.new("StringValue")
	object2._title.Value = ""
	object2._maid:GiveTask(object2._title)

	object2._subtitle = Instance.new("StringValue")
	object2._subtitle.Value = ""
	object2._maid:GiveTask(object2._subtitle)

	object2._percentVisible = v3.new(0, 40)
	object2._maid:GiveTask(object2._percentVisible)

	object2._maid:GiveTask(object2.VisibleChanged:Connect(function(p, p2)
		object2._percentVisible.t = p and 1 or 0

		if p2 then
			object2._percentVisible.p = object2._percentVisible.t
			object2._percentVisible.v = 0
		end
	end))

	object2._blur = Instance.new("BlurEffect")
	object2._blur.Name = "SoftShutdownBlur"
	object2._blur.Enabled = false
	object2._blur.Size = 0
	object2._blur.Parent = Workspace.CurrentCamera
	object2._maid:GiveTask(object2._blur)

	object2._maid:GiveTask(object2:_render():Subscribe(function(gui)
		object2.Gui = gui
	end))

	return object2
end

function object:SetTitle(p)
	self._title.Value = p
end

function object:SetSubtitle(p)
	self._subtitle.Value = p
end

function object:_render()
	local v6 = self._percentVisible:ObserveRenderStepped()
	local computed = v2.Computed(v6, function(p)
		return 1 - p
	end)

	local color = Color3.new(0, 0, 0)
	local color2 = Color3.new(0.9, 0.9, 0.9)

	self._maid:GiveTask(v6:Subscribe(function(p)
		self._blur.Size = p * 30
		self._blur.Enabled = p > 0
	end))

	local v7 = v2.New("Frame")
	local v8 = {
		["Name"] = nil,
		Name = "SoftShutdownUI",
		Size = UDim2.new(1, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Active = v2.Computed(v6, function(p): boolean
			return p > 0
		end),
		Visible = v2.Computed(v6, function(p): boolean
			return p > 0
		end),
		BackgroundColor3 = color,
		BackgroundTransparency = v2.Computed(v6, function(p)
			return v5.map(p, 0, 1, 1, 0.4)
		end)
	}

	local children = v2.Children
	local v9 = v2.New("UIPadding")({
		PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 20),
		PaddingTop = UDim.new(0, 20),
		PaddingBottom = UDim.new(0, 20)
	})

	local v10 = v2.New("Frame")
	local v11 = {
		Name = "ContentContainer",
		["Size"] = UDim2.new(1, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1
	}

	local children2 = v2.Children
	local v12 = v2.New("UIScale")({
		Scale = v2.Computed(v6, function(p)
			return 0.7 + 0.3 * p
		end)
	})

	local v13 = v2.New("Frame")({
		Name = "ImageLabelContainer",
		Size = UDim2.new(0, 80, 0, 80),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		[v2.Children] = { v2.New("ImageLabel")({
				Size = UDim2.new(1, 0, 1, 0),
				ImageTransparency = computed,
				BackgroundTransparency = 1,
				Image = "rbxassetid://6031302916"
			}) }
	})

	local v14 = v2.New("Frame")({
		Name = "LabelContainer",
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		[v2.Children] = {
			v2.New("TextLabel")({
				Name = "TitleLabel",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.new(1, 0, 0.6, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Text = self._title,
				Font = Enum.Font.SourceSansBold,
				TextTransparency = computed,
				TextColor3 = color2,
				LayoutOrder = 1,
				TextScaled = true
			}),
			v2.New("TextLabel")({
				Name = "SubtitleLabel",
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.new(1, 0, 0.3, 0),
				AnchorPoint = Vector2.new(0.5, 1),
				Text = self._subtitle,
				Font = Enum.Font.SourceSansLight,
				TextTransparency = computed,
				TextColor3 = color2,
				LayoutOrder = 2,
				TextScaled = true
			}),
			v2.New("UIAspectRatioConstraint")({ AspectRatio = 5 })
		}
	})

	local v15 = v2.New("Frame")({
		Name = "Spacer",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 50),
		LayoutOrder = 3
	})

	local v16 = v2.New("Frame")
	local v17 = {
		Name = "LoadingLabel",
		["Position"] = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		LayoutOrder = 4,
		Size = UDim2.fromScale(0.25, 0.25),
		BackgroundTransparency = 1
	}

	local children3 = v2.Children
	v17[children3] = {
		v2.New("Frame")({
			Name = "RobloxLogo",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = color2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = computed,
			Rotation = v4.fromSignal(RunService.RenderStepped):Pipe({ v4.map(function()
					local v18 = tick() * 3.141592653589793 * 1.5
					local v19 = math.sin(v18)
					local midpoint = (math.sin(v18 - 1.5707963267948966) + 1) / 2

					if v19 > 0 then
						return midpoint * 360 + 15
					end

					return 15
				end) }),
			[v2.Children] = { v2.New("Frame")({
					BackgroundColor3 = color,
					Size = UDim2.fromScale(2 / 7, 2 / 7),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = computed
				}) }
		}),
		v2.New("UIAspectRatioConstraint")({ AspectRatio = 1 }),
		v2.New("UISizeConstraint")({ MaxSize = Vector2.new(1e999, 50) })
	}
	v11[children2] = {
		v12,
		v13,
		v14,
		v15,
		v16(v17),
		v2.New("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10)
		})
	}
	v8[children] = { v9, v10(v11) }
	return v7(v8)
end

return object