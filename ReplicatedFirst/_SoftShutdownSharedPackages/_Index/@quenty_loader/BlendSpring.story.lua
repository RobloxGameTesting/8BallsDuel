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

	maid:GiveTask(v.New("Frame")({
		Size = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(0.9, 0.9, 0.9),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = backgroundTransparency,
		Parent = parent,
		[v.Children] = {
			v.New("UIScale")({
				Scale = v.Computed(spring, function(p)
					return 0.8 + 0.2 * p
				end)
			}),
			v.New("UICorner")({ CornerRadius = UDim.new(0.05, 0) })
		}
	}):Subscribe())

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		boolValue.Value = os.clock() / 5 % 1 < 0.5
	end))

	return function()
		maid:DoCleaning()
	end
end