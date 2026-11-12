local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local RunService = game:GetService("RunService")

local v = loaded("Blend")
local v2 = loaded("Maid")
local v3 = loaded("ValueObject")
local v4 = loaded("Rx")

return function(parent)
	local maid = v2.new()

	local state = v.State(0)
	local state2 = v.State("a")
	maid:GiveTask(state2)

	local v5 = v3.new()
	v5.Value = v.New("UICorner")({ CornerRadius = UDim.new(0, 5) })

	maid:GiveTask(v5)

	maid:GiveTask(task.delay(1, function()
		v5.Value = v.New("UICorner")({ CornerRadius = UDim.new(0, 5) })
	end))

	local computed = v.Computed(state, function(p)
		return 1 - p
	end)

	maid:GiveTask(v.New("TextLabel")({
		Parent = parent,
		Font = Enum.Font.FredokaOne,
		Size = v.Computed(state, function(p)
			return UDim2.new(0, p * 100 + 50, 0, 50)
		end),
		TextTransparency = computed,
		BackgroundTransparency = computed,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Text = state2,
		TextSize = 15,
		TextScaled = false,
		[v.Children] = {
			v.New("UIPadding")({
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10)
			}),
			v.New("UIScale")({
				Scale = v.Computed(state, function(p)
					return 0.8 + 0.2 * p
				end)
			}),
			v5,
			v4.NEVER,
			v4.EMPTY,
			{ v.Single(v.Computed(state, function(p)
					if p <= 0.5 then
						return nil
					end

					return v.New("Frame")({
						Size = UDim2.new(0, 150, 0, 30),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(0.5, 0, 1, 10),
						BackgroundTransparency = computed,
						v.New("UICorner")({ CornerRadius = UDim.new(0, 10) })
					})
				end)) },
			{ v.Single(v.Computed(state, function(p)
					local result = {}

					for i = 0, p * 100, 20 do
						local v6 = v.New("Frame")
						local v7 = {
							Size = UDim2.new(0, 8, 0, 8),
							Position = UDim2.new(i / 100, 0, 0.9, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(i / 100, 0.5, 0.5),
							BackgroundTransparency = computed,
							[v.Children] = { v.New("UICorner")({ CornerRadius = UDim.new(0, 10) }) }
						}
						table.insert(result, v6(v7))
					end

					return result
				end)) }
		}
	}):Subscribe())

	maid:GiveTask(RunService.RenderStepped:Connect(function()
		local now = os.clock()
		state2.Value = string.format(
			"%02d:%02d:%0.3d",
			math.floor(now / 60) % 60,
			math.floor(now % 60),
			math.floor(now * 1000) % 1000
		)
		state.Value = math.clamp(math.sin(os.clock() * 3.141592653589793 * 2 / 5) + 1, 0, 1)
	end))

	return function()
		maid:DoCleaning()
	end
end