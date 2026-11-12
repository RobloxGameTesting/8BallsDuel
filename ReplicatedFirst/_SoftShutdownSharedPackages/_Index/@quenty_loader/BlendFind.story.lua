local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local RunService = game:GetService("RunService")

local v = loaded("Blend")
local v2 = loaded("Maid")

return function(parent)
	local maid = v2.new()

	local boolValue = Instance.new("BoolValue")
	boolValue.Value = false

	local spring = v.Spring(v.Computed(boolValue, function(p): number
		return if p then 1 else 0
	end), 35)

	local backgroundTransparency = v.Computed(spring, function(p)
		return 1 - p
	end)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.5, 0, 0.5, 0)
	frame.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.BackgroundTransparency = backgroundTransparency
	frame.Parent = parent
	maid:GiveTask(frame)

	local centerFrame = Instance.new("Frame")
	centerFrame.Name = "CenterFrame"
	centerFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
	centerFrame.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
	centerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	centerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	centerFrame.BackgroundTransparency = backgroundTransparency
	centerFrame.Parent = frame

	local myUIScale = Instance.new("UIScale")
	myUIScale.Name = "MyUIScale"
	myUIScale.Parent = centerFrame

	maid:GiveTask(v.mount(frame, {
		Size = UDim2.new(0.5, 0, 0.5, 0),
		v.New("UICorner")({ CornerRadius = UDim.new(0.05, 0) }),
		v.Find("Frame")({
			Name = "CenterFrame",
			v.Find("UIScale")({
				Name = "MyUIScale",
				Scale = v.Computed(spring, function(p)
					return 0.8 + 0.2 * p
				end)
			}),
			v.New("UICorner")({ CornerRadius = UDim.new(0.05, 0) })
		})
	}))

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		boolValue.Value = os.clock() / 2 % 1 < 0.5
	end))

	return function()
		maid:DoCleaning()
	end
end