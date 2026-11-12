local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local RunService = game:GetService("RunService")

local v = loaded("Blend")
local v2 = loaded("Maid")
local v3 = loaded("PlayerThumbnailUtils")

return function(parent)
	local maid = v2.new()

	local intValue = Instance.new("IntValue")
	intValue.Value = 4397833
	maid:GiveTask(intValue)

	local boolValue = Instance.new("BoolValue")
	boolValue.Value = false
	maid:GiveTask(boolValue)

	local dynamic = v.Dynamic(intValue, function(p)
		return v3.promiseUserThumbnail(p)
	end)

	local dynamic2 = v.Dynamic(intValue, function(p)
		return v3.promiseUserName(p)
	end)

	local spring = v.Spring(v.Computed(boolValue, function(p): number
		return if p then 1 else 0
	end), 35)

	local computed = v.Computed(spring, function(p)
		return 1 - p
	end)

	local v4 = v.New("Frame")
	local v5 = {
		["Parent"] = parent,
		Name = "ProfileImage",
		LayoutOrder = 15,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 130),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
	local children = v.Children
	local v6 = v.New("UIScale")({
		Scale = v.Computed(spring, function(p)
			return 0.8 + 0.2 * p
		end)
	})

	local v7 = v.New("TextLabel")({
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		TextTransparency = computed,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 20,
		Font = Enum.Font.Gotham,
		Text = dynamic2
	})

	local v8 = v.New("Frame")
	local v9 = {
		["Position"] = UDim2.new(0.5, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.2, 0.25, 0.2),
		BackgroundTransparency = computed
	}

	local children2 = v.Children
	v9[children2] = {
		v.New("UIAspectRatioConstraint")({ AspectRatio = 1 }),
		v.New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
		v.New("UIPadding")({
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2)
		}),
		v.New("ImageLabel")({
			Size = UDim2.new(1, 0, 1, 0),
			Image = dynamic,
			BackgroundTransparency = computed,
			ImageTransparency = computed,
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			[v.Children] = { v.New("UICorner")({ CornerRadius = UDim.new(1, 0) }) }
		})
	}
	v5[children] = { v6, v7, v8(v9) }
	maid:GiveTask(v4(v5):Subscribe())

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		boolValue.Value = os.clock() / 2 % 1 < 0.5
	end))

	local flag = true
	maid:GiveTask(function()
		flag = false
	end)
	maid:GiveTask(boolValue.Changed:Connect(function()
		if not boolValue.Value then
			task.delay(1, function()
				if flag then
					intValue.Value = Random.new():NextInteger(1, 1000000000)
				end
			end)
		end
	end))

	return function()
		maid:DoCleaning()
	end
end