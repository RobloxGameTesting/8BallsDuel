local ServerScriptService = game:GetService("ServerScriptService")
local loaded = require(ServerScriptService:FindFirstChild("LoaderUtils", true).Parent).load(script)

local v = loaded("Blend")
local v2 = loaded("Maid")

return function(parent)
	local maid = v2.new()

	local state = v.State("hi")

	local v3 = v.New("Frame")
	local v4 = { ["Size"] = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = parent }

	local children = v.Children
	v4[children] = {
		v.New("TextBox")({
			Size = UDim2.new(0, 200, 0, 50),
			Text = state,
			[v.OnChange("Text")] = state,
			[v.OnEvent("Focused")] = function()
				print("Focused")
			end,
			[function(p)
				return p.Focused
			end] = function()
				print("Focused (via func)")
			end,
			[function(instance)
				return instance:GetPropertyChangedSignal("Text")
			end] = function()
				print("Property changed from :GetPropertyChangedSignal()")
			end
		}),
		v.New("TextBox")({
			Size = UDim2.new(0, 200, 0, 50),
			[v.OnChange("Text")] = state,
			Text = state
		}),
		v.New("UIListLayout")({ Padding = UDim.new(0, 10) })
	}
	maid:GiveTask(v3(v4):Subscribe())

	return function()
		maid:DoCleaning()
	end
end